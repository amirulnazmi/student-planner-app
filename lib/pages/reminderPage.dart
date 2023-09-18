import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/main.dart';
import 'package:student_planner_app/models/user.dart';
import 'package:student_planner_app/services/NotificationPlugin.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:student_planner_app/widgets/navBar.dart';

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  String userID;
  final db = FirebaseDatabase.instance.reference();
  User user;
  List<String> incompleteTaskName;
  List<String> incompleteExamName;

  bool isTaskReminderOn;
  bool isExamReminderOn;
  DateTime taskReminderTime;
  DateTime examReminderTime;
  
  void getUserData() {
    SharedPreferences.getInstance().then((value) {
      var userID = value.getString("userID");
      db.child("User").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          setState(() {
            isTaskReminderOn = value["isTaskReminderOn"];
            isExamReminderOn = value["isExamReminderOn"];
            taskReminderTime = DateTime.parse(value["taskReminderTime"]);
            examReminderTime = DateTime.parse(value["examReminderTime"]);
          });
        });
      });
    });
  }

  void getTaskList() {
    SharedPreferences.getInstance().then((value) {
      var userID = value.getString("userID");
      db.child("Task").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          if(value["taskStatus"] == "Incomplete"){
            setState(() {
              incompleteTaskName.add(value["taskName"]);
            });
          }
        });
      });
    });
  }

  void getExamList() {
    SharedPreferences.getInstance().then((value) {
      var userID = value.getString("userID");
      db.child("Exam").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          if(value["examStatus"] == "Incomplete"){
            setState(() {
              incompleteExamName.add(value["examCategory"] + ": " + value["examName"]);
            });
          }
        });
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
    incompleteTaskName = new List();
    incompleteExamName = new List();
    getUserData();
    getTaskList();
    getExamList();
  }

  @override
  void dispose() {
    incompleteTaskName.clear();
    incompleteExamName.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text("Reminders"),
      ),
      drawer: NavBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Task Reminder".toString(), style: TextStyle(color: CustomColor.secondary1, fontSize: 18.0, fontWeight: FontWeight.bold)),
            isTaskReminderOn != null?
            SwitchListTile(
              activeColor: CustomColor.secondary1,
              activeTrackColor: CustomColor.secondary1.withOpacity(0.5),
              title: Text("Daily Reminder", style: TextStyle(color: CustomColor.primary, fontSize: 18.0)),
              subtitle: Text("Reminder is set daily at specific time", style: TextStyle(color: Colors.grey)),
              value: isTaskReminderOn, 
              onChanged: (value) {
                setState(() {
                  isTaskReminderOn = value;
                  updateReminderStatus(value, "isTaskReminderOn");
                  if(isTaskReminderOn == false){
                    cancelNotification(flutterLocalNotificationsPlugin, 0);
                  }
                });
              }
            ) :
            Center(child: CircularProgressIndicator(backgroundColor: CustomColor.primary,)),
            isTaskReminderOn == true?
            ListTile(
              title: Text("Set reminder time for task", style: TextStyle(color: CustomColor.primary)),
              trailing: Text(DateFormat("jm").format(taskReminderTime), style: TextStyle(color: CustomColor.secondary1)),
              onTap: (){
                DatePicker.showTime12hPicker(
                  context, 
                  currentTime: taskReminderTime,
                  showTitleActions: true,
                  onChanged: (value) {
                    setState(() {
                      taskReminderTime = value;
                    });
                  },
                  onConfirm: (value) {
                    setState(() {
                      taskReminderTime = value;
                      updateReminderTime(value, "taskReminderTime");
                    });
                  },
                );
              },
            )
            :
            Container(),
            Divider(color: Colors.grey,),
            Text("Exam Reminder".toString(), style: TextStyle(color: CustomColor.secondary1, fontSize: 18.0, fontWeight: FontWeight.bold)),
            isTaskReminderOn != null?
            SwitchListTile(
              activeColor: CustomColor.secondary1,
              activeTrackColor: CustomColor.secondary1.withOpacity(0.5),
              title: Text("Daily Reminder", style: TextStyle(color: CustomColor.primary, fontSize: 18.0)),
              subtitle: Text("Reminder is set daily at specific time", style: TextStyle(color: Colors.grey)),
              value: isExamReminderOn, 
              onChanged: (value) {
                setState(() {
                  isExamReminderOn = value;
                  updateReminderStatus(value, "isExamReminderOn");
                  if(isExamReminderOn == false){
                    cancelNotification(flutterLocalNotificationsPlugin, 0);
                  }
                });
              }
            ) :
            Center(child: CircularProgressIndicator(backgroundColor: CustomColor.primary,)),
            isExamReminderOn == true?
            ListTile(
              title: Text("Set reminder time for exam", style: TextStyle(color: CustomColor.primary)),
              trailing: Text(DateFormat("jm").format(examReminderTime), style: TextStyle(color: CustomColor.secondary1)),
              onTap: (){
                DatePicker.showTime12hPicker(
                  context, 
                  currentTime: examReminderTime,
                  showTitleActions: true,
                  onChanged: (value) {
                    setState(() {
                      examReminderTime = value;
                    });
                  },
                  onConfirm: (value) {
                    setState(() {
                      examReminderTime = value;
                      updateReminderTime(value, "examReminderTime");
                    });
                  },
                );
              },
            )
            :
            Container(),
            Divider(color: Colors.grey,),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: CustomColor.primary,
      //   onPressed: (){
      //     showNotification(1, flutterLocalNotificationsPlugin, incompleteExamName, "Exam Reminder", "exams");
      //     showNotification(0, flutterLocalNotificationsPlugin, incompleteTaskName, "Task Reminder", "tasks");
      //   }, 
      //   label: Text("Show Notification")
      // ),
    );
  }

  void updateReminderStatus(bool status, String field) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userID = user.uid;
    try{
      db.child('User').orderByChild('userID').equalTo(userID).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> children = snapshot.value;
      children.forEach((key, value) {
        db.child('User').child(key).update({
          field: status,
        });        
      });
      print(field + " change to " + status.toString());
    });
    }
    catch(e){
      print(e.message);
    }
  }

  void updateReminderTime(DateTime time, String field) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userID = user.uid;
    try{
      db.child('User').orderByChild('userID').equalTo(userID).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> children = snapshot.value;
      children.forEach((key, value) {
        db.child('User').child(key).update({
          field: DateFormat("yyyy-MM-dd HH:mm").format(time),
        });        
      });
      print(field + " change to " + DateFormat("yyyy-MM-dd HH:mm").format(time));
    });
    }
    catch(e){
      print(e.message);
    }
  }
}