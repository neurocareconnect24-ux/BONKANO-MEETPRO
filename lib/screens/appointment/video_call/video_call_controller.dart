import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../api/core_apis.dart';
import '../../../configs.dart';
import '../../../main.dart';
import '../model/agora_token_res_model.dart';
import '../model/appointments_res_model.dart';

enum VideoCallState { idle, connecting, connected, disconnected, failed }

class VideoCallController extends GetxController {
  RtcEngine? agoraEngine;

  Rx<VideoCallState> callState = VideoCallState.idle.obs;
  RxBool isLocalAudioMuted = false.obs;
  RxBool isLocalVideoDisabled = false.obs;
  RxBool isRemoteUserJoined = false.obs;
  RxInt remoteUid = 0.obs;
  RxString callDurationText = '00:00'.obs;

  Timer? _callTimer;
  int _callDurationSeconds = 0;

  late AppointmentData appointment;
  String _token = '';
  String _channelName = '';
  int _uid = 0;

  /// Expose channel name for the video view
  String get channelName => _channelName;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is AppointmentData) {
      appointment = Get.arguments;
      _initCall();
    }
  }

  @override
  void onClose() {
    _callTimer?.cancel();
    _leaveChannel();
    agoraEngine?.release();
    super.onClose();
  }

  void retryCall() => _initCall();

  Future<void> _renewToken() async {
    try {
      AgoraTokenRes tokenRes = await CoreServiceApis.getAgoraToken(
        appointmentId: appointment.id.validate(),
      );
      if (tokenRes.token.isNotEmpty) {
        _token = tokenRes.token;
        await agoraEngine?.renewToken(_token);
        log('=== AGORA DEBUG [Doctor] === Token renewed successfully');
      }
    } catch (e) {
      log('=== AGORA DEBUG [Doctor] === Token renewal failed: $e');
      toast(locale.value.callDisconnected);
    }
  }

  Future<void> _initCall() async {
    callState(VideoCallState.connecting);

    // 1. Request permissions
    log('=== AGORA DEBUG [Doctor] === Step 1: Requesting permissions...');
    bool permGranted = await _handlePermissions();
    if (!permGranted) {
      log('=== AGORA DEBUG [Doctor] === FAILED: Permissions denied');
      callState(VideoCallState.failed);
      return;
    }
    log('=== AGORA DEBUG [Doctor] === Step 1: Permissions granted OK');

    // 2. Fetch token from backend
    try {
      if (appointment.id == null) {
        log('=== AGORA DEBUG [Doctor] === FAILED: Appointment ID is null');
        callState(VideoCallState.failed);
        return;
      }
      log('=== AGORA DEBUG [Doctor] === Step 2: Fetching token for appointment ${appointment.id}...');
      AgoraTokenRes tokenRes = await CoreServiceApis.getAgoraToken(
        appointmentId: appointment.id.validate(),
      );
      _token = tokenRes.token;
      _channelName = tokenRes.channelName;
      _uid = tokenRes.uid;
      log('=== AGORA DEBUG [Doctor] === Step 2: Token received OK');
      log('=== AGORA DEBUG [Doctor] === token length: ${_token.length}, channel: $_channelName, uid: $_uid');
      if (_token.isEmpty || _channelName.isEmpty) {
        log('=== AGORA DEBUG [Doctor] === FAILED: Token or channel name is EMPTY!');
        toast(locale.value.failedToJoinCall);
        callState(VideoCallState.failed);
        return;
      }
    } catch (e) {
      log('=== AGORA DEBUG [Doctor] === FAILED Step 2: Token error: $e');
      toast(locale.value.failedToJoinCall);
      callState(VideoCallState.failed);
      return;
    }

    // 3. Initialize Agora engine
    try {
      log('=== AGORA DEBUG [Doctor] === Step 3: Creating Agora engine with appId: $AGORA_APP_ID');
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine!.initialize(RtcEngineContext(
        appId: AGORA_APP_ID,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      log('=== AGORA DEBUG [Doctor] === Step 3: Engine initialized OK');
    } catch (e) {
      log('=== AGORA DEBUG [Doctor] === FAILED Step 3: Engine init error: $e');
      toast(locale.value.failedToJoinCall);
      callState(VideoCallState.failed);
      return;
    }

    // 4. Register event handlers
    agoraEngine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log('=== AGORA DEBUG [Doctor] === onJoinChannelSuccess: channel=${connection.channelId}, uid=${connection.localUid}, elapsed=$elapsed ms');
        callState(VideoCallState.connected);
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        log('=== AGORA DEBUG [Doctor] === onUserJoined: remoteUid=$rUid');
        remoteUid(rUid);
        isRemoteUserJoined(true);
        toast(locale.value.patientJoinedTheCall);
        _startTimer();
      },
      onUserOffline: (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        log('=== AGORA DEBUG [Doctor] === onUserOffline: remoteUid=$rUid, reason=$reason');
        remoteUid(0);
        isRemoteUserJoined(false);
        toast(locale.value.patientLeftTheCall);
        _stopTimer();
      },
      onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
        log('=== AGORA DEBUG [Doctor] === onConnectionStateChanged: state=$state, reason=$reason');
      },
      onConnectionLost: (RtcConnection connection) {
        log('=== AGORA DEBUG [Doctor] === onConnectionLost');
        callState(VideoCallState.disconnected);
        toast(locale.value.callDisconnected);
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        log('=== AGORA DEBUG [Doctor] === onTokenPrivilegeWillExpire - refreshing token...');
        _renewToken();
      },
      onError: (ErrorCodeType err, String msg) {
        log('=== AGORA DEBUG [Doctor] === onError: code=$err, msg=$msg');
      },
    ));

    // 5. Enable audio + video and join channel
    try {
      log('=== AGORA DEBUG [Doctor] === Step 5: enableAudio...');
      await agoraEngine!.enableAudio();
      log('=== AGORA DEBUG [Doctor] === Step 5: enableVideo...');
      await agoraEngine!.enableVideo();
      log('=== AGORA DEBUG [Doctor] === Step 5: startPreview...');
      await agoraEngine!.startPreview();
      log('=== AGORA DEBUG [Doctor] === Step 5: joinChannel(channel=$_channelName, uid=$_uid, tokenLen=${_token.length})...');
      await agoraEngine!.joinChannel(
        token: _token,
        channelId: _channelName,
        uid: _uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      log('=== AGORA DEBUG [Doctor] === Step 5: joinChannel call completed (waiting for callback)...');
    } catch (e) {
      log('=== AGORA DEBUG [Doctor] === FAILED Step 5: $e');
      toast(locale.value.failedToJoinCall);
      callState(VideoCallState.failed);
    }
  }

  Future<bool> _handlePermissions() async {
    // Vérifier d'abord si déjà accordées
    bool cameraGranted = await Permission.camera.isGranted;
    bool micGranted = await Permission.microphone.isGranted;

    if (cameraGranted && micGranted) return true;

    // Demander les permissions manquantes
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    cameraGranted = statuses[Permission.camera]!.isGranted;
    micGranted = statuses[Permission.microphone]!.isGranted;

    // Sur certains appareils, re-vérifier après un court délai
    if (!cameraGranted || !micGranted) {
      await Future.delayed(const Duration(milliseconds: 500));
      cameraGranted = await Permission.camera.isGranted;
      micGranted = await Permission.microphone.isGranted;
    }

    if (cameraGranted && micGranted) return true;

    // Si refusé définitivement, proposer d'ouvrir les paramètres
    bool cameraPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
    bool micPermanentlyDenied = await Permission.microphone.isPermanentlyDenied;

    if (cameraPermanentlyDenied || micPermanentlyDenied) {
      toast(locale.value.cameraAndMicrophonePermissionRequired);
      await openAppSettings();
      // Re-vérifier après retour des paramètres
      await Future.delayed(const Duration(seconds: 1));
      cameraGranted = await Permission.camera.isGranted;
      micGranted = await Permission.microphone.isGranted;
      if (cameraGranted && micGranted) return true;
    }

    toast(locale.value.cameraAndMicrophonePermissionRequired);
    return false;
  }

  void toggleMuteAudio() {
    isLocalAudioMuted(!isLocalAudioMuted.value);
    agoraEngine?.muteLocalAudioStream(isLocalAudioMuted.value);
  }

  void toggleCamera() {
    isLocalVideoDisabled(!isLocalVideoDisabled.value);
    agoraEngine?.muteLocalVideoStream(isLocalVideoDisabled.value);
  }

  void switchCamera() {
    agoraEngine?.switchCamera();
  }

  void endCall() {
    _stopTimer();
    _leaveChannel();
    callState(VideoCallState.disconnected);
    toast(locale.value.callEnded);
    Get.back();
  }

  Future<void> _leaveChannel() async {
    try {
      await agoraEngine?.leaveChannel();
    } catch (e) {
      log('Leave channel error: $e');
    }
  }

  void _startTimer() {
    _callDurationSeconds = 0;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      int minutes = _callDurationSeconds ~/ 60;
      int seconds = _callDurationSeconds % 60;
      callDurationText(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      );
    });
  }

  void _stopTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }
}
