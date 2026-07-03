import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../models/notificationdata_model.dart';
import '../screens/appointment/appointment_detail.dart';
import '../screens/appointment/model/appointments_res_model.dart';
import 'app_common.dart';
import 'constants.dart';

class PushNotificationService {
// It is assumed that all messages contain a data field with the key 'type'

  Future<void> initFirebaseMessaging() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true, provisional: true);

      if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (Platform.isAndroid) {
          await Permission.notification.request();
        }
        log('------Request Notification Permission COMPLETED-----------');
        await registerNotificationListeners().then((value) {
          log('------Notification Listener REGISTRATION COMPLETED-----------');
        }).catchError((e) {
          log('------Notification Listener REGISTRATION ERROR-----------');
        });

        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true).then((value) {
          log('------setForegroundNotificationPresentationOptions COMPLETED-----------');
        }).catchError((e) {
          log('------setForegroundNotificationPresentationOptions ERROR-----------');
        });
      }
    } catch (e) {
      log('------Request Notification Permission ERROR: $e-----------');
    }
  }

  Future<void> registerFCMandTopics() async {
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        subScribeToTopic();
      } else {
        Future.delayed(const Duration(seconds: 3), () async {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) {
            subScribeToTopic();
          }
        });
      }
      log("===============${FirebaseTopicConst.apnsNotificationTokenKey}===============\n$apnsToken");
    }
    FirebaseMessaging.instance.getToken().then((token) {
      log("===============${FirebaseTopicConst.fcmNotificationTokenKey}===============\n$token");
    });
    subScribeToTopic();
  }

  Future<void> subScribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic(appNameTopic).whenComplete(() {
      log("${FirebaseTopicConst.topicSubscribed}$appNameTopic");
    });

    if (loginUserData.value.userRole.isNotEmpty && loginUserData.value.userRole.first.isNotEmpty) {
      await FirebaseMessaging.instance.subscribeToTopic(getUserRoleTopic(loginUserData.value.userRole.first)).then((value) {
        log("${FirebaseTopicConst.topicSubscribed}${getUserRoleTopic(loginUserData.value.userRole.first)}");
      });
    }
    await FirebaseMessaging.instance.subscribeToTopic("${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}").then((value) {
      log("${FirebaseTopicConst.topicSubscribed}${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}");
    });
  }

  Future<void> unsubscribeFirebaseTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(appNameTopic).whenComplete(() {
      log("${FirebaseTopicConst.topicUnSubscribed}$appNameTopic");
    });
    if (loginUserData.value.userRole.isNotEmpty && loginUserData.value.userRole.first.isNotEmpty) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(getUserRoleTopic(loginUserData.value.userRole.first)).whenComplete(() {
        log("${FirebaseTopicConst.topicUnSubscribed}${getUserRoleTopic(loginUserData.value.userRole.first)}");
      });
    }
    await FirebaseMessaging.instance.unsubscribeFromTopic('${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}').whenComplete(() {
      log("${FirebaseTopicConst.topicUnSubscribed}${FirebaseTopicConst.userWithUnderscoreKey}${loginUserData.value.id}");
    });
  }

  void handleNotificationClick(RemoteMessage message, {bool isForeGround = false}) {
    printLogsNotificationData(message);
    NotificationData notificationData = NotificationData.fromJson(message.data);
    log('===============${FirebaseTopicConst.notificationDataKey}===============\n${notificationData.toJson()}');
    if (isForeGround) {
      showNotification(currentTimeStamp(), message.notification!.title.validate(), message.notification!.body.validate(), message);
    } else {
      try {
        Map<String, dynamic> additionalData = jsonDecode(message.data[FirebaseTopicConst.additionalDataKey]) ?? {};
        if (additionalData.isNotEmpty) {
          int? notId = additionalData["id"];
          log("notId=== $notId");
          if (notId != null) {
            log("============ IN APPOINTMENT ================");
            Get.to(
              () => AppointmentDetail(),
              arguments: AppointmentData(id: notId),
            );
          }
        }
      } catch (e) {
        log('${FirebaseTopicConst.notificationErrorKey}: $e');
      }
    }
  }

  Future<void> registerNotificationListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotificationClick(message, isForeGround: true);
    }, onError: (e) {
      log("${FirebaseTopicConst.onMessageListen} $e");
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    }, onError: (e) {
      log("${FirebaseTopicConst.onMessageOpened} $e");
    });

    // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationClick(message);
      }
    }, onError: (e) {
      log("${FirebaseTopicConst.onGetInitialMessage} $e");
    });
  }

  Future<void> showNotification(int id, String title, String message, RemoteMessage remoteMessage) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //code for background notification channel
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      FirebaseTopicConst.notificationChannelIdKey,
      FirebaseTopicConst.notificationChannelNameKey,
      importance: Importance.high,
      enableLights: true,
      playSound: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_notification');

    var iOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var macOS = iOS;

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        handleNotificationClick(remoteMessage);
      },
    );

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      FirebaseTopicConst.notificationChannelIdKey,
      FirebaseTopicConst.notificationChannelNameKey,
      importance: Importance.high,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      playSound: true,
      priority: Priority.high,
      icon: '@drawable/ic_stat_notification',
      channelShowBadge: true,
      colorized: true,
    );

    var darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentBadge: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(id, title, message, platformChannelSpecifics);
  }

  void printLogsNotificationData(RemoteMessage message) {
    log('${FirebaseTopicConst.notificationDataKey} : ${message.data}');
    log('${FirebaseTopicConst.notificationTitleKey} -->: ${message.notification!.title}');
    log('${FirebaseTopicConst.notificationBodyKey} -->: ${message.notification!.body}');
    log('${FirebaseTopicConst.messageDataCollapseKey} : ${message.collapseKey}');
    log('${FirebaseTopicConst.messageDataMessageIdKey} : ${message.messageId}');
    log('${FirebaseTopicConst.messageDataMessageTypeKey} : ${message.messageType}');
  }
}