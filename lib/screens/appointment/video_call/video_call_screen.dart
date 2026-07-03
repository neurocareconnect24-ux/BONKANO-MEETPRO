import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import 'video_call_controller.dart';

class VideoCallScreen extends StatelessWidget {
  VideoCallScreen({super.key});

  final VideoCallController videoCallCont = Get.put(VideoCallController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          videoCallCont.endCall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() => Stack(
              children: [
                // Remote video (full screen) or waiting placeholder
                _buildRemoteVideo(),

                // Local video (small PiP, top-right)
                _buildLocalVideo(),

                // Top info bar
                _buildTopBar(),

                // Bottom controls
                _buildBottomControls(context),

                // Connecting overlay
                if (videoCallCont.callState.value == VideoCallState.connecting)
                  _buildConnectingOverlay(),

                // Failed overlay
                if (videoCallCont.callState.value == VideoCallState.failed)
                  _buildFailedOverlay(),
              ],
            )),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (videoCallCont.isRemoteUserJoined.value && videoCallCont.agoraEngine != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: videoCallCont.agoraEngine!,
          canvas: VideoCanvas(uid: videoCallCont.remoteUid.value),
          connection: RtcConnection(channelId: videoCallCont.channelName),
        ),
      );
    }
    // Waiting for patient placeholder
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: radius(60),
              child: CachedImageWidget(
                url: videoCallCont.appointment.userImage.validate(),
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                circle: true,
              ),
            ),
            24.height,
            Text(
              videoCallCont.appointment.userName.validate(),
              style: boldTextStyle(size: 22, color: Colors.white),
            ),
            12.height,
            Text(
              videoCallCont.appointment.serviceName.validate(),
              style: secondaryTextStyle(size: 14, color: Colors.white70),
            ),
            24.height,
            if (videoCallCont.callState.value == VideoCallState.connected) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(appColorPrimary),
                ),
              ),
              16.height,
              Text(
                locale.value.waitingForPatient,
                style: primaryTextStyle(size: 16, color: Colors.white60),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideo() {
    if (videoCallCont.agoraEngine == null) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: videoCallCont.isLocalVideoDisabled.value
            ? Container(
                color: const Color(0xFF2D2D3A),
                child: const Center(
                  child: Icon(Icons.videocam_off, color: Colors.white54, size: 32),
                ),
              )
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: videoCallCont.agoraEngine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => videoCallCont.endCall(),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        videoCallCont.appointment.userName.validate(),
                        style: boldTextStyle(size: 16, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(
                        locale.value.videoCall,
                        style: secondaryTextStyle(size: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (videoCallCont.isRemoteUserJoined.value)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 14),
                        6.width,
                        Obx(() => Text(
                              videoCallCont.callDurationText.value,
                              style: boldTextStyle(size: 14, color: Colors.white),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute / Unmute
                _buildControlButton(
                  icon: videoCallCont.isLocalAudioMuted.value ? Icons.mic_off : Icons.mic,
                  label: videoCallCont.isLocalAudioMuted.value
                      ? locale.value.unmuteAudio
                      : locale.value.muteAudio,
                  isActive: !videoCallCont.isLocalAudioMuted.value,
                  onTap: () => videoCallCont.toggleMuteAudio(),
                ),

                // Camera On / Off
                _buildControlButton(
                  icon: videoCallCont.isLocalVideoDisabled.value
                      ? Icons.videocam_off
                      : Icons.videocam,
                  label: videoCallCont.isLocalVideoDisabled.value
                      ? locale.value.enableCamera
                      : locale.value.disableCamera,
                  isActive: !videoCallCont.isLocalVideoDisabled.value,
                  onTap: () => videoCallCont.toggleCamera(),
                ),

                // Switch Camera
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  label: locale.value.switchCamera,
                  isActive: true,
                  onTap: () => videoCallCont.switchCamera(),
                ),

                // End Call
                _buildControlButton(
                  icon: Icons.call_end,
                  label: locale.value.endCall,
                  isActive: false,
                  isEndCall: true,
                  onTap: () => videoCallCont.endCall(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEndCall
                  ? cancelStatusColor
                  : isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: isEndCall
                  ? Colors.white
                  : isActive
                      ? Colors.white
                      : Colors.white54,
              size: 26,
            ),
          ),
          8.height,
          Text(
            label,
            style: secondaryTextStyle(size: 10, color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(appColorPrimary),
              ),
            ),
            24.height,
            Text(
              locale.value.connecting,
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: cancelStatusColor, size: 64),
            24.height,
            Text(
              locale.value.failedToJoinCall,
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
            16.height,
            Text(
              locale.value.cameraAndMicrophonePermissionRequired,
              style: secondaryTextStyle(size: 14, color: Colors.white60),
              textAlign: TextAlign.center,
            ).paddingSymmetric(horizontal: 32),
            32.height,
            AppButton(
              color: appColorPrimary,
              text: locale.value.retry,
              textStyle: boldTextStyle(color: Colors.white),
              onTap: () => videoCallCont.retryCall(),
            ).paddingSymmetric(horizontal: 48),
            16.height,
            AppButton(
              color: Colors.grey.shade700,
              text: locale.value.goBack,
              textStyle: boldTextStyle(color: Colors.white),
              onTap: () => Get.back(),
            ).paddingSymmetric(horizontal: 48),
          ],
        ),
      ),
    );
  }
}
