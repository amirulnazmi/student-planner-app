import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:student_planner_app/models/task.dart';
import 'package:student_planner_app/pages/homePage.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:intl/intl.dart';
import 'package:student_planner_app/themes/inputStyle.dart';

class AddTaskPage extends StatefulWidget{
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>{
  String taskName, taskDesc, taskCategory, userTaskStatus;
  String taskStatus = "Incomplete";
  DateTime taskCompletedDate;
  DateTime taskDueDate = DateTime.now();
  List taskCategoryList = ['Assignment', 'Project', 'Reminder'];
  bool autovalidate = false;
  bool isShared = false;
  bool isOverdue = false;

  final inputStyle = InputStyle();
  final _formKey = new GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference();
  var dateFormat = DateFormat('EEE, d MMM y');
 
  final underlineInputBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black.withOpacity(0.0)),
  );

  Widget taskNameField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Title')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: inputStyle.inputFieldStyle('Enter task title'),
            onSaved: (value) => taskName = value,
            onChanged: (value){
              setState(() {
                taskName = value;
              });
            },
            validator: (value) => value.isEmpty ? 'Title is required' : null,
            autovalidate: autovalidate,
          ),
        ),
      ],
    ); 
  }

  Widget taskDescField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Description')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            maxLines: 3,
            style: TextStyle(color: Colors.white),
            decoration: inputStyle.inputFieldStyle('Enter task description'),
            onSaved: (value) => taskDesc = value,
            onChanged: (value){
              setState(() {
                taskDesc = value;
              });
            },
            validator: (value) => value.isEmpty ? 'Task description is required' : null,
            autovalidate: autovalidate,
          ),
        ),
      ],
    );
  }

  Widget taskCategoryField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Category')),
        SizedBox(
          width: 250.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: CustomColor.secondary1
            ),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField(
                decoration: inputStyle.inputFieldStyle('Select task category'),
                style: TextStyle(color: Colors.white),
                value: taskCategory,
                items: taskCategoryList.map((value) {
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
                    taskCategory = value;
                  });
                },
                onSaved: (value) => taskCategory = value,
                validator: (value) => value == null ? 'Task category is required' : null,
                autovalidate: autovalidate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget taskDueDateField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputStyle.inputLabelText('Due date')),
        SizedBox(
          width: 250.0,
          child: DateTimeField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.arrow_drop_down),
              hintText: 'Select task due date',
              hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: CustomColor.secondary1,
              focusedBorder: underlineInputBorderStyle,
              enabledBorder: underlineInputBorderStyle,
              errorBorder: underlineInputBorderStyle,
              border: underlineInputBorderStyle,
              focusedErrorBorder: underlineInputBorderStyle,
              errorStyle: TextStyle(color: Colors.white),
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
            onSaved: (value) => taskDueDate = value,
            onChanged: (value) {
              setState(() {
                taskDueDate = value;
              });
            },
            validator: (value){
              if(value == null){
                return 'Task due date is required';
              }
              return null;
            },
            autovalidate: autovalidate,
          ),
        ),
      ],
    );
  }

  Widget addTaskButton(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: RaisedButton(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        color: CustomColor.primary,
        child: Text('Create Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: (){
          checkTaskOverdue(taskDueDate);
          createTask();
        },
      ),
    );
  }

  Widget addTaskForm(){
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
        key: _formKey,
        child: Column(
          children: <Widget>[
            taskNameField(),
            Divider(color: Colors.white, height: 10.0,),
            taskDescField(),
            Divider(color: Colors.white, height: 10.0,),
            taskCategoryField(),
            Divider(color: Colors.white, height: 10.0,),
            taskDueDateField(),
          ],
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    taskCompletedDate = DateTime(0000, 00, 00);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text('New Task', style: TextStyle(fontWeight: FontWeight.bold),),
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
          child: addTaskForm(),
        ),
      ),
      bottomNavigationBar: addTaskButton(),
    );
  }

  void checkTaskOverdue(DateTime tDueDate){
    if(tDueDate.isBefore(DateTime.now())){
      setState(() {
        isOverdue = true;
      });
    }
    else{
      setState(() {
        isOverdue = false;
      });
    }
  }

  void createTask() async{
    final formState = _formKey.currentState;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userID = user.uid;
    Task task = new Task(userID, taskName, taskDesc, taskCategory, taskDueDate, taskStatus, isOverdue, taskCompletedDate);

    if(formState.validate()){
      formState.save();

      try{
        db.child("Task").push().set(task.toJson());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => HomePage()));
      }
      catch(e){
        setState(() {
          print(e.message);
        });
      }
    }
    else{
      setState(() {
        autovalidate = true;
      });
    }
  }
}