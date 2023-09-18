import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/models/exam.dart';
import 'package:student_planner_app/pages/DetailExamPage.dart';
import 'package:student_planner_app/pages/addExamPage.dart';
import 'package:student_planner_app/pages/examHistoryPage.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:student_planner_app/widgets/navBar.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  var dbRef;
  List<Exam> examList, examHistory;
  StreamSubscription<Event> onExamAddedSubscription;
  StreamSubscription<Event> onExamChangedSubscription;

  @override
  void initState() {   
    super.initState();
    examList = new List();
    examHistory = new List();
    getExamList();
  }

  @override
  void dispose() {
    onExamAddedSubscription.cancel();
    onExamChangedSubscription.cancel();
    super.dispose();
  }

  void getExamList(){
    SharedPreferences.getInstance().then((value) {
      setState(() {
        String userID = value.getString("userID");
        dbRef = FirebaseDatabase.instance.reference().child("Exam").orderByChild("userID").equalTo(userID);
        onExamAddedSubscription = dbRef.onChildAdded.listen(onEntryAdded);
        onExamChangedSubscription = dbRef.onChildChanged.listen(onEntryChanged);
      });
    });
  }

  onEntryAdded(Event event){
    setState(() {
      examList.add(Exam.fromSnapshot(event.snapshot));
      examList.sort((a,b) => a.examDate.compareTo(b.examDate));
      if(examList.isNotEmpty){
        for(var i=0; i<examList.length; i++){
          var daysRemaining = examList[i].examDate.difference(DateTime.now()).inDays;
          if(daysRemaining < 0){
            examHistory.add(examList[i]);
            examList.removeAt(i);
          }
        }
      }
    });
  }

  onEntryChanged(Event event){
    var oldEntry = examList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      examList[examList.indexOf(oldEntry)] = Exam.fromSnapshot(event.snapshot);
    });
  }

  Widget displayContent(){
    if(examList.length != 0){
      return Container(
        padding: EdgeInsets.symmetric(horizontal:5.0, vertical:10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: examList.length,
                itemBuilder: (BuildContext context, int index) {
                  String examName = examList[index].examName;
                  String examCategory = examList[index].examCategory;
                  DateTime examDate = examList[index].examDate;
                  String formattedDate = DateFormat("d MMM yy").format(examDate);
                  DateTime examTime = examList[index].examTime;
                  String formattedTime = DateFormat("jm").format(examTime);
                  Duration timeRemaining = examDate.difference(DateTime.now());
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailExamPage(exam: examList[index])));
                      },
                      child: Card(
                        color: CustomColor.primary,
                        child: Column(
                          children: <Widget>[
                            Container(
                              color: CustomColor.primary,
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(examCategory, style: TextStyle(color: CustomColor.secondary1, fontWeight: FontWeight.bold),),
                                  displayDaysRemaining(timeRemaining),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.grey[200],
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2, 
                                    child: Text(
                                      examName, 
                                      style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: CustomColor.secondary1,),
                                    )
                                  ),
                                  Container(
                                    child: Column(
                                      children: <Widget>[
                                        Text(formattedDate, style: TextStyle(color: CustomColor.primary),),
                                        Text(formattedTime, style: TextStyle(color: CustomColor.primary),),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      );
    }
    else{
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(FontAwesome5Solid.book_reader, size: 100.0, color: CustomColor.primary.withOpacity(0.8),),
            SizedBox(height: 10.0),
            Text("You have no exam.\nClick on the icon below to add an exam.",
            textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: CustomColor.primary
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget displayDaysRemaining(Duration time){
    if(time.inDays < 0){
      return Text(
        "Overdue by: " + time.inDays.abs().toString() + " days",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 13.0
        ),
      );
    }
    else if(time.inDays == 0){
      if(time.inHours < 0){
        return Text(
          "Today",
          style: TextStyle(
            color: CustomColor.secondary1,
            fontWeight: FontWeight.bold,
            fontSize: 13.0
          ),
        );
      }
      else{
        return Text(
          "Tomorrow",
          style: TextStyle(
            color: CustomColor.secondary1,
            fontWeight: FontWeight.bold,
            fontSize: 13.0
          ),
        );
      }
    }
    else{
      return Text(
        time.inDays.toString() + " days remaining",
        style: TextStyle(
          color: CustomColor.secondary1,
          fontWeight: FontWeight.bold,
          fontSize: 13.0
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text("Exam"),
        backgroundColor: CustomColor.primary,
        elevation: 2.0,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: FlatButton.icon(
              icon: Icon(FontAwesome.history, color: Colors.white,), 
              onPressed: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExamHistoryPage(examList: examHistory)));
              }, 
              label: Text("Exam History", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
      body: displayContent(),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        backgroundColor: CustomColor.secondary1,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddExamPage()));
        },
      ),
    );
  }
}