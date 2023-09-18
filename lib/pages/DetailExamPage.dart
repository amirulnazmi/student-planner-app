import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:student_planner_app/models/exam.dart';
import 'package:student_planner_app/pages/editExamPage.dart';
import 'package:student_planner_app/pages/examPage.dart';
import 'package:student_planner_app/themes/colors.dart';

class DetailExamPage extends StatefulWidget {
  final Exam exam;
  
  DetailExamPage({Key key, @required this.exam}) : super(key: key);

  @override
  _DetailExamPageState createState() => _DetailExamPageState();
}

class _DetailExamPageState extends State<DetailExamPage> {
  final db = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExamPage())),
        ),
        backgroundColor: CustomColor.primary,
        title: Text(widget.exam.examName, style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 5.0,
            ),
          child: displayExamDetail(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColor.primary,
        onPressed: () {
          displayExamMenu(context);
        },
        child: Icon(FontAwesome5Solid.bars),
      ),
    );
  }

  Widget fieldText(String fieldText){
    return Container(
      padding: EdgeInsets.only(right: 10.0),
      child: Text(
        fieldText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.0
        ),
      ),
    );
  }

  Widget labelText(String labelText){
    return Text(
      labelText,
      style: TextStyle(
        fontSize: 18.0,
        color: CustomColor.secondary1,
      ),
    );
  }

  Widget examDetailField(String label, String field){
    return Container(
      height: 70.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          labelText(label),
          fieldText(field),
        ],
      ),
    ); 
  }

  Widget displayExamDetail(){    
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: CustomColor.primary,
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            spreadRadius: 1.0,
          )
        ],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: <Widget>[
          examDetailField("Subject", "${widget.exam.examName}"),
          Divider(color: Colors.white, height: 10.0,),
          examDetailField("Description", "${widget.exam.examDesc}"),
          Divider(color: Colors.white, height: 10.0,),
          examDetailField("Location", "${widget.exam.examDesc}"),
          Divider(color: Colors.white, height: 10.0,),
          examDetailField("Category", "${widget.exam.examCategory}"),
          Divider(color: Colors.white, height: 10.0,),
          Container(
            height: 70.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                labelText("Date/Time"),
                Spacer(),
                fieldText(DateFormat('EEE, d MMM y').format(widget.exam.examDate)),
                fieldText(DateFormat('jm').format(widget.exam.examTime)),
              ],
            ),
          ),
          Divider(color: Colors.white, height: 10.0,),
          examDetailField("Duration", "${widget.exam.examDuration} minutes"),
        ],
      ),
    );
  }

  displayExamMenu(context){
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesome5.edit, color: CustomColor.primary,),
                title: Text('Edit', style: TextStyle(color: CustomColor.primary),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditExamPage(exam: widget.exam)));
                },
              ),
              ListTile(
                leading: Icon(FontAwesome5.trash_alt, color: CustomColor.primary,),
                title: Text('Delete', style: TextStyle(color: CustomColor.primary),),
                onTap: (){
                  setState(() {
                    showDeleteMessage();
                  }); 
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void showDeleteMessage(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Delete Exam', 
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CustomColor.secondary1,
              ),
            ),
          content: Text(
            'Are you sure to delete this exam?', 
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                deleteExam("${widget.exam.key}");
              },
            ),
          ],
        );
      },
    );
  }

  void deleteExam(String examID) {
    try{
      db.child("Exam").child(examID).remove().then((_) {
        print('Exam ${widget.exam.examName} successfully deleted.');
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => ExamPage()));
    }
    catch(e){
      print(e.message);
    }
  }
}