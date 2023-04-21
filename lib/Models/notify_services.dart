import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // function to request notifications permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print('user granted permission');
    }
    // else if(settings.authorizationStatus == AuthorizationStatus.provisional){
    //   print('user granted provisional permission');
    // }
    else {
      // AppSettings.openNotificationSettings();
      // print('user denied permission');
    }
  }

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications() async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('app_icon');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      // handleMessage(context, message);
    });

    FirebaseMessaging.onMessage.listen((message) {
      // print("notifications title: ${message}");
      // if (kDebugMode) {
      //   print("notifications title:"+message.notification!.title.toString());
      //   print("notifications body:"+message.notification!.body.toString());
      //   print("notifications channel id:"+message.notification!.android!.channelId.toString());
      //   print("notifications click action:"+message.notification!.android!.clickAction.toString());
      //   print("notifications color:"+message.notification!.android!.color.toString());
      //   print("notifications count:"+message.notification!.android!.count.toString());
      // }

      showNotification(message);
    });
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      '1',
      'Message',
      importance: Importance.max,
      showBadge: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'New message',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      groupKey: channel.id.toString(),
      setAsGroupSummary: true,
      //  icon: largeIconPath
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  //function to get device token on which we will send the notifications
  // Future<String> getDeviceToken() async {
  //   String? token = await messaging.getToken();
  //   return token!;
  // }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }
}
