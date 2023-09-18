import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/pages/examPage.dart';
import 'package:student_planner_app/pages/homePage.dart';
import 'package:student_planner_app/pages/loginPage.dart';
import 'package:student_planner_app/services/NotificationPlugin.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications(flutterLocalNotificationsPlugin);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userID = prefs.getString('userID');
  userID != null? print("Current user session: " + userID) : print("No user session");
  runApp(userID == null ? MyApp1() : MyApp2());
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Student Planner App',
      theme: ThemeData(
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/exam': (context) => ExamPage(),
      },
    );
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Student Planner App',
      theme: ThemeData(
        fontFamily: 'Nunito',
      ),
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/exam': (context) => ExamPage(),
      },
    );
  }
}
