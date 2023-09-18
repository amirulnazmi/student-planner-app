import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/main.dart';
import 'package:student_planner_app/pages/calendarPage.dart';
import 'package:student_planner_app/pages/examPage.dart';
import 'package:student_planner_app/pages/homePage.dart';
import 'package:student_planner_app/pages/loginPage.dart';
import 'package:student_planner_app/pages/reminderPage.dart';
import 'package:student_planner_app/services/NotificationPlugin.dart';
import 'package:student_planner_app/themes/colors.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Student\nPlanner\nApplication',
                style: TextStyle(
                  color: CustomColor.secondary1,
                  fontSize: 30.0,
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: CustomColor.primary,
              ),
          ),
          ListTile(
            leading: Icon(FontAwesome.list_alt, color: CustomColor.primary,),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => HomePage()));
            },
          ),
          ListTile(
            leading: Icon(FontAwesome5Solid.book_reader, color: CustomColor.primary,),
            title: Text('Exam'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => ExamPage()));
            }
          ),
          ListTile(
            leading: Icon(FontAwesome5.calendar_alt, color: CustomColor.primary,),
            title: Text('Calendar'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => CalendarPage()));
            }
          ),
          ListTile(
            leading: Icon(FontAwesome5.bell, color: CustomColor.primary,),
            title: Text('Reminder'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => ReminderPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: CustomColor.primary,),
            title: Text('Logout'),
            onTap: () async {
              cancelAllNotifications(flutterLocalNotificationsPlugin);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userID');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

