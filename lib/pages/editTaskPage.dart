import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:student_planner_app/models/task.dart';
import 'package:student_planner_app/pages/detailTaskPage.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  
  EditTaskPage({Key key, @required this.task}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  String taskName, taskDesc, taskCategory, taskStatus;
  DateTime taskDueDate;
  final List taskCategoryList = ['Assignment', 'Project', 'Reminder'];
  final List taskStatusList = ['Incomplete', 'Complete'];
  bool autovalidate = false;

  final _formKey = new GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference();
  final dateFormat = DateFormat('EEE, d MMM y');

  final inputBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black.withOpacity(0.0)),
  );

  @override
  void initState(){
    super.initState();
    taskDueDate = widget.task.taskDueDate;
    taskName = widget.task.taskName;
    taskCategory = widget.task.taskCategory;
    taskDesc = widget.task.taskDesc;
    taskStatus = widget.task.taskStatus;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text('Edit Task: ${widget.task.taskName}', style: TextStyle(fontWeight: FontWeight.bold),),
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
          child: editTaskForm(),
        ),
      ),
      bottomNavigationBar: editTaskButton(),
    );
  }

  inputFieldStyle(String hintText){
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: CustomColor.secondary1,
      enabledBorder: inputBorderStyle,
      focusedBorder: inputBorderStyle,
      errorBorder: inputBorderStyle,
      border: inputBorderStyle,
      focusedErrorBorder: inputBorderStyle,
    );
  }

  inputTextStyle(){
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  Widget inputLabelText(String labelText){
    return Text(
      labelText,
      style: TextStyle(
        fontSize: 18.0,
        color: CustomColor.secondary1,
      ),
    );
  }

  Widget taskNameField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputLabelText('Title')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
            initialValue: taskName,
            style: inputTextStyle(),
            decoration: inputFieldStyle('Enter task title'),
            onSaved: (value) => taskName = value,
            validator: (value) => value.isEmpty ? 'Title is required' : null,
            onChanged: (value) {
              setState(() {
                taskName = value;
              });
              },
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
        Expanded(child: inputLabelText('Description')),
        SizedBox(
          width: 250.0,
          child: TextFormField(
              initialValue: taskDesc,
              maxLines: 3,
              style: inputTextStyle(),
              decoration: inputFieldStyle('Enter task description'),
              onSaved: (value) => taskDesc = value,
              validator: (value) => value.isEmpty ? 'Task description is required' : null,
              onChanged: (value) {
                setState(() {
                  taskDesc = value;
                });
              },
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
        Expanded(child: inputLabelText('Category')),
        SizedBox(
          width: 250.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: CustomColor.secondary1
            ),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField(
                decoration: inputFieldStyle('Select task category'),
                style: inputTextStyle(),
                value: taskCategory,
                items: taskCategoryList.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value, 
                      style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 16.0,
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
        Expanded(child: inputLabelText('Due date')),
        SizedBox(
          width: 250.0,
          child: DateTimeField(
            initialValue: taskDueDate,
            style: inputTextStyle(),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.arrow_drop_down),
              hintText: 'Select task due date',
              hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: CustomColor.secondary1,
              focusedBorder: inputBorderStyle,
              enabledBorder: inputBorderStyle,
              errorBorder: inputBorderStyle,
              border: inputBorderStyle,
              focusedErrorBorder: inputBorderStyle,
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

  Widget taskStatusField(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: inputLabelText('Status')),
        SizedBox(
          width: 250.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: CustomColor.secondary1
            ),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField(
                decoration: inputFieldStyle('Select task status'),
                style: inputTextStyle(),
                value: taskStatus,
                items: taskStatusList.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value, 
                      style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 16.0,
                        )
                    ),
                  );
                }).toList(),
                onChanged: (value){
                  setState(() {
                    taskStatus = value;
                  });
                },
                onSaved: (value) => taskStatus = value,
                validator: (value) => value == null ? 'Task status is required' : null,
                autovalidate: autovalidate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget displayTaskStatus(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        inputLabelText('Status'),
        Expanded(
          child: SizedBox(
            width: 270.0,
            child: TextFormField(
              textAlign: TextAlign.right,
              initialValue: taskStatus,
              readOnly: true,
              style: inputTextStyle(),
              decoration: InputDecoration(
                enabledBorder: inputBorderStyle,
                focusedBorder: inputBorderStyle,
                errorBorder: inputBorderStyle,
                border: inputBorderStyle,
                focusedErrorBorder: inputBorderStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget editTaskButton(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: RaisedButton(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        color: CustomColor.primary,
        child: Text('Edit Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: (){
          setState(() {
            editTask();
          });
        },
      ),
    );
  }

  Widget editTaskForm(){
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
            Divider(color: Colors.white, height: 10.0,),
            taskStatusField(),
            //displayTaskStatus(),
          ],
        ),
      ),
    );
  }

  void showSuccessMessage(Task task){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Edit Task', 
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CustomColor.secondary1,
              ),
            ),
          content: Text(
            'This task has been successfully updated.', 
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => DetailTaskPage(task: task)));
              },
            ),
          ],
        );
      },
    );
  }

  void editTask() async{
    final formState = _formKey.currentState;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userID = user.uid;
    Task task = new Task(
      userID, 
      taskName, 
      taskDesc, 
      taskCategory, 
      taskDueDate, 
      taskStatus, 
      widget.task.isOverdue,
      widget.task.taskCompletedDate,
    );

    if(formState.validate()){
      formState.save();

      try{
        db.child('Task').orderByChild('userID').equalTo(userID).once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> children = snapshot.value;
          children.forEach((key, value) {
            if(key == widget.task.key){
              db.child('Task').child(key).update(
                {
                  "taskName": taskName,
                  "taskDesc": taskDesc,
                  "taskCategory": taskCategory,
                  "taskStatus": taskStatus,
                  "taskDueDate": DateFormat("yyyy-MM-dd").format(taskDueDate),
                }
              );
            }
          });
          showSuccessMessage(task);
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
        autovalidate = true;
      });
    }
  }
}