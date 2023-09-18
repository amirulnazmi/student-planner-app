import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:student_planner_app/models/exam.dart';
import 'package:student_planner_app/themes/colors.dart';

import 'DetailExamPage.dart';

class ExamHistoryPage extends StatefulWidget {
  final List<Exam> examList;

  ExamHistoryPage({Key key, @required this.examList}) : super(key: key);

  @override
  _ExamHistoryPageState createState() => _ExamHistoryPageState();
}

class _ExamHistoryPageState extends State<ExamHistoryPage> {
  List<Exam> examHistory;

  @override
  void initState() {   
    super.initState();    
    examHistory = widget.examList;
  }

    @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exam History"),
        backgroundColor: CustomColor.primary,
        elevation: 2.0,
      ),
      body: displayExamHistory(),
    );
  }

  Widget displayExamHistory(){
    if(examHistory.length != 0){
      return Container(
        padding: EdgeInsets.symmetric(horizontal:5.0, vertical:10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: examHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  String examName = examHistory[index].examName;
                  String examCategory = examHistory[index].examCategory;
                  DateTime examDate = examHistory[index].examDate;
                  String formattedDate = DateFormat("d MMM yy").format(examDate);
                  DateTime examTime = examHistory[index].examTime;
                  String formattedTime = DateFormat("jm").format(examTime);
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailExamPage(exam: examHistory[index])));
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
            Text("You have no exam in the past.",
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
}