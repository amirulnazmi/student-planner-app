import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:student_planner_app/models/exam.dart';
import 'package:student_planner_app/pages/DetailExamPage.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:student_planner_app/themes/inputStyle.dart';

class EditExamPage extends StatefulWidget {
  final Exam exam;

  EditExamPage({Key key, @required this.exam}) : super(key: key);

  @override
  _EditExamPageState createState() => _EditExamPageState();
}

class _EditExamPageState extends State<EditExamPage> {
  final inputStyle = InputStyle();
  final formKey = new GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference();
  final dateFormat = DateFormat('EEE, d MMM y');
  final timeFormat = DateFormat("jm");

  String examName, examDesc, examCategory, examStatus, examLocation;
  int examDuration;
  DateTime examDate;
  DateTime examTime;
  List examCategoryList = ['Quiz', 'Test', 'Final Exam'];
  bool autoValidate = false;

  @override
  void initState() {   
    super.initState();  
    examName = widget.exam.examName;
    examDesc = widget.exam.examDesc;
    examCategory = widget.exam.examCategory;
    examStatus = widget.exam.examStatus;
    examLocation = widget.exam.examLocation;
    examDuration = widget.exam.examDuration;
    examDate = widget.exam.examDate;
    examTime = widget.exam.examTime;
  }

    @override
  void dispose() {
    super.dispose();
  }

  Widget examNameField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Subject')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            initialValue: examName,
            style: TextStyle(color: Colors.white),
            decoration: inputStyle.inputFieldStyle('Enter subject'),
            onSaved: (value) => examName = value,
            onChanged: (value){
              setState(() {
                examName = value;
              });
            },
            validator: (value) => value.isEmpty ? 'Subject is required' : null,
            autovalidate: autoValidate,
          ),
        ),
      ],
    ); 
  }

  Widget examDescField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Description')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            initialValue: examDesc,
            maxLines: 2,
            style: TextStyle(color: Colors.white),
            decoration: inputStyle.inputFieldStyle('Enter exam description'),
            onSaved: (value) => examDesc = value,
            onChanged: (value){
              setState(() {
                examDesc = value;
              });
            },
            validator: (value) => value.isEmpty ? 'Exam description is required' : null,
            autovalidate: autoValidate,
          ),
        ),
      ],
    );
  }

  Widget examLocationField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Location')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            initialValue: examLocation,
            style: TextStyle(color: Colors.white),
            decoration: inputStyle.inputFieldStyle('Enter exam location'),
            onSaved: (value) => examLocation = value,
            onChanged: (value){
              setState(() {
                examLocation = value;
              });
            },
            validator: (value) => value.isEmpty ? 'Location is required' : null,
            autovalidate: autoValidate,
          ),
        ),
      ],
    ); 
  }

  Widget examCategoryField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Category')),
        Container(
          width: 220.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: CustomColor.secondary1
            ),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField(
                decoration: inputStyle.inputFieldStyle('Select exam category'),
                style: TextStyle(color: Colors.white),
                value: examCategory,
                items: examCategoryList.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value, 
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Nunito",
                        )
                    ),
                  );
                }).toList(),
                onChanged: (value){
                  setState(() {
                    examCategory = value;
                  });
                },
                onSaved: (value) => examCategory = value,
                validator: (value) => value == null ? 'Exam category is required' : null,
                autovalidate: autoValidate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget examDateField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: inputStyle.inputLabelText('Date')
        ),
        Container(
          width: 250.0,
          child: DateTimeField(
            initialValue: examDate,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.arrow_drop_down),
              hintText: 'Select exam date',
              hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: CustomColor.secondary1,
              focusedBorder: inputStyle.underlineInputBorderStyle,
              enabledBorder: inputStyle.underlineInputBorderStyle,
              errorBorder: inputStyle.underlineInputBorderStyle,
              border: inputStyle.underlineInputBorderStyle,
              focusedErrorBorder: inputStyle.underlineInputBorderStyle,
            ),
            format: dateFormat,
            onShowPicker: (context, currentValue) {
              return DatePicker.showDatePicker(context,
                minTime: DateTime(DateTime.now().year),
                currentTime: currentValue ?? DateTime.now(),
                maxTime: DateTime(DateTime.now().year + 2),
                locale: LocaleType.en,
                theme: DatePickerTheme(
                  doneStyle: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondary1,
                  ),
                  cancelStyle: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondary1,
                  ),
                  itemStyle: TextStyle(
                    color: CustomColor.primary,
                  ),
                )
              );
            },
            onSaved: (value) => examDate = value,
            onChanged: (value) {
              setState(() {
                examDate = value;
              });
            },
            validator: (value){
              if(value == null){
                return 'Exam date is required';
              }
              // else if(value.isBefore(DateTime.now())){
              //   return "Exam date cannot be less than today's date";
              // }
              return null;
            },
            autovalidate: autoValidate,
          ),
        ),
      ],
    );
  }

  Widget examTimeField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Time')),
        Container(
          width: 200.0,
          child: DateTimeField(
            initialValue: examTime,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              errorStyle: TextStyle(color: Colors.white),
              suffixIcon: Icon(Icons.arrow_drop_down),
              hintText: 'Select exam time',
              hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: CustomColor.secondary1,
              focusedBorder: inputStyle.underlineInputBorderStyle,
              enabledBorder: inputStyle.underlineInputBorderStyle,
              errorBorder: inputStyle.underlineInputBorderStyle,
              border: inputStyle.underlineInputBorderStyle,
              focusedErrorBorder: inputStyle.underlineInputBorderStyle,
            ),
            format: timeFormat,
            onShowPicker: (context, currentValue) {
              return DatePicker.showTime12hPicker(
                context, 
                currentTime: examTime,
                showTitleActions: true,
                theme: DatePickerTheme(
                  doneStyle: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondary1,
                  ),
                  cancelStyle: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondary1,
                  ),
                  itemStyle: TextStyle(
                    color: CustomColor.primary,
                  ),
                )
              );
            },
            onSaved: (value) => examTime = value,
            onChanged: (value) {
              setState(() {
                examTime = value;
              });
            },
            validator: (value){
              if(value == null){
                return 'Exam time is required';
              }
              return null;
            },
            autovalidate: autoValidate,
          ),
        ),
      ],
    );
  }

  Widget examDurationField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Duration (minute)')),
        Container(
          width: 200.0,
          decoration: BoxDecoration(
            color: CustomColor.secondary1,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              accentColor: Colors.white,
              textTheme: Theme.of(context).textTheme.copyWith(
                bodyText2: Theme.of(context).textTheme.headline5.copyWith(
                  color: CustomColor.primary,
                  fontSize: 15.0,
                )
              )
            ),
            child: NumberPicker.integer(
              itemExtent: 30,
              initialValue: examDuration, 
              minValue: 0, 
              maxValue: 300, 
              step: 10,
              onChanged: (value) {
                setState(() {
                  examDuration = value;
                });
              }
            ),
          )
        ),
      ],
    ); 
  }

  Widget addExamButton(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: RaisedButton(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        color: CustomColor.primary,
        child: Text('Update Exam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: (){
          // checkTaskOverdue(taskDueDate);
          editExam();
        },
      ),
    );
  }

  Widget addExamForm(){
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
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            examNameField(),
            Divider(color: Colors.white, height: 10.0,),
            examDescField(),
            Divider(color: Colors.white, height: 10.0,),
            examLocationField(),
            Divider(color: Colors.white, height: 10.0,),
            examCategoryField(),
            Divider(color: Colors.white, height: 10.0,),
            examDateField(),
            Divider(color: Colors.white, height: 10.0,),
            examTimeField(),
            Divider(color: Colors.white, height: 10.0,),
            examDurationField(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text('New Exam', style: TextStyle(fontWeight: FontWeight.bold),),
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
          child: addExamForm(),
        ),
      ),
      bottomNavigationBar: addExamButton(),
    );
  }

  void showSuccessMessage(Exam exam){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Edit Exam', 
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CustomColor.secondary1,
              ),
            ),
          content: Text(
            'This exam has been successfully updated.', 
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => DetailExamPage(exam: exam)));
              },
            ),
          ],
        );
      },
    );
  }

  void editExam() async{
    final formState = formKey.currentState;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userID = user.uid;
    examTime = new DateTime(examDate.year, examDate.month, examDate.day, examTime.hour, examTime.minute);
    Exam exam = new Exam(userID, examName, examDesc, examCategory, examStatus, examLocation, examDuration, examDate, examTime);

    if(formState.validate()){
      formState.save();

      try{
        db.child('Exam').orderByChild('userID').equalTo(userID).once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> children = snapshot.value;
          children.forEach((key, value) {
            if(key == widget.exam.key){
              db.child('Exam').child(key).update(exam.toJson());
            }
            
          });
          showSuccessMessage(exam);
        });
      }
      catch(e){
        setState(() {
          print(e.message);
        });
      }
    }
    else{
      setState(() {
        autoValidate = true;
      });
    }
  }
}