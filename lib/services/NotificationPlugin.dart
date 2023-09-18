import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_planner_app/main.dart';

Future<void> initNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('@drawable/splash');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
}

Future onSelectNotification(String payload) async {
  if (payload != null) {
    debugPrint('flutterLocalNotificationsPlugin payload: ' + payload);
    if(payload == "tasks"){
      await navigatorKey.currentState.pushReplacementNamed('/home');
    }
    else if(payload == "exams"){
      await navigatorKey.currentState.pushReplacementNamed('/exam');
    }
  }
  await navigatorKey.currentState.pushReplacementNamed('/home');
}

Future<void> cancelNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, num id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> cancelAllNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> showNotification(int id, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, List<String> dataList, String title, String content) async { 
  var inboxStyleInformation = InboxStyleInformation(dataList, contentTitle: dataList.length.toString() + ' incomplete ' + content + ":");
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL_TASK_ID', 'CHANNEL_TASK_TITLE', 'CHANNEL_TASK_DESCRIPTION',
    importance: Importance.Max,
    priority: Priority.High,
    playSound: true,
    styleInformation: inboxStyleInformation,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(id, title, 'You have '+ dataList.length.toString() + ' incomplete ' + content, platformChannelSpecifics, payload: content);
  //await flutterLocalNotificationsPlugin.periodicallyShow(id, title, 'You have '+ dataList.length.toString() + ' incomplete ' + content, RepeatInterval.EveryMinute, platformChannelSpecifics, payload: content);
}

Future<void> showDailyAtTime(int id, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, List<String> dataList, DateTime dataTime, String title, String content) async {
  var time = Time(dataTime.hour, dataTime.minute, dataTime.second);
  var inboxStyleInformation = InboxStyleInformation(dataList, contentTitle: dataList.length.toString() + ' incomplete ' + content + ":");
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL_TASK_ID', 'CHANNEL_TASK_TITLE', 'CHANNEL_TASK_DESCRIPTION',
    importance: Importance.Max,
    priority: Priority.High,
    playSound: true,
    styleInformation: inboxStyleInformation,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showDailyAtTime(id, title, 'You have '+ dataList.length.toString() + ' incomplete ' + content + ":", time, platformChannelSpecifics);
}




