import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/main.dart';
import 'package:student_planner_app/models/task.dart';
import 'package:student_planner_app/pages/addTaskPage.dart';
import 'package:student_planner_app/pages/taskCompletePage.dart';
import 'package:student_planner_app/pages/taskIncompletePage.dart';
import 'package:student_planner_app/services/NotificationPlugin.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:student_planner_app/widgets/customBottomAppBar.dart';
import 'package:student_planner_app/widgets/navBar.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  TabController _tabController;
  final db = FirebaseDatabase.instance.reference();
  List<Task> allTask, completeTask, incompleteTask;
  StreamSubscription<Event> onTaskAddedSubscription;
  StreamSubscription<Event> onTaskChangedSubscription;
  String userID;
  Query allTaskQuery;

  void setUpNotification() {
    List<String> taskList = new List<String>();
    List<String> examList = new List<String>();
    bool isTaskReminderOn;
    bool isExamReminderOn;
    DateTime taskReminderTime;
    DateTime examReminderTime;

    SharedPreferences.getInstance().then((value) {
      var userID = value.getString("userID");
      db.child("User").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          isTaskReminderOn = value["isTaskReminderOn"];
          isExamReminderOn = value["isExamReminderOn"];
          taskReminderTime = DateTime.parse(value["taskReminderTime"]);
          examReminderTime = DateTime.parse(value["examReminderTime"]);
        });
        if(isTaskReminderOn == true){
          db.child("Task").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, value) {
              taskList.add(value["taskName"]);
            });
            //showNotification(0, flutterLocalNotificationsPlugin, taskList, "Task Reminder", "tasks");
            showDailyAtTime(0, flutterLocalNotificationsPlugin, taskList, taskReminderTime, "Task Reminder", "tasks");
          });
        }
        if(isExamReminderOn == true){
          db.child("Exam").orderByChild("userID").equalTo(userID).once().then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, value) {
              examList.add(value["examName"]);
            });
            //showNotification(1, flutterLocalNotificationsPlugin, examList, "Exam Reminder", "exams");
            showDailyAtTime(1, flutterLocalNotificationsPlugin, taskList, examReminderTime, "Exam Reminder", "exams");
          });
        }
        else{
          print('no notification');
        }
      });
    
    });
  }

  void getAllTask(){
    SharedPreferences.getInstance().then((value) {
      setState(() {
        userID = value.getString("userID");
        allTaskQuery = db.child("Task").orderByChild("userID").equalTo(userID);
        onTaskAddedSubscription = allTaskQuery.onChildAdded.listen(onEntryAdded);
        onTaskChangedSubscription = allTaskQuery.onChildChanged.listen(onEntryChanged);
      });
    });
  }

  @override
  void initState() {   
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    allTask = new List();
    completeTask = new List();
    incompleteTask = new List();
    getAllTask();
    setUpNotification();
  }

  @override
  void dispose() {
    onTaskAddedSubscription.cancel();
    onTaskChangedSubscription.cancel();
    allTask.clear();
    completeTask.clear();
    incompleteTask.clear();
    super.dispose();
  }

  onEntryAdded(Event event){
    setState(() {
      completeTask.clear(); 
      incompleteTask.clear();
      allTask.add(Task.fromSnapshot(event.snapshot));
      allTask.sort((a,b) => a.taskDueDate.compareTo(b.taskDueDate));
      if(allTask != null){
        for(var i=0; i<allTask.length; i++){
          if(allTask[i].taskStatus == "Complete"){
            completeTask.add(allTask[i]);
          }
          else{
            incompleteTask.add(allTask[i]);
          }
        }
      }
    });
  }

  onEntryChanged(Event event){
    var oldEntry = allTask.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      allTask[allTask.indexOf(oldEntry)] = Task.fromSnapshot(event.snapshot);
    });
  }
  
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        elevation: 2.0,
        bottom: CustomBottomAppBar(
          tabController: _tabController,
          height: 150,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TaskIncompletePage(taskList: incompleteTask,),
          TaskCompletedPage(taskList: completeTask),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        backgroundColor: CustomColor.secondary1,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskPage()));
        },
      ),
    );
  }
}



