import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/models/task.dart';
import 'package:student_planner_app/models/user.dart';
import 'package:student_planner_app/pages/editTaskPage.dart';
import 'package:student_planner_app/pages/homePage.dart';
import 'package:student_planner_app/themes/colors.dart';

class DetailTaskPage extends StatefulWidget {
  final Task task;
  
  DetailTaskPage({Key key, @required this.task}) : super(key: key);

  @override
  _DetailTaskPageState createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {
  final formKey = new GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference();
  var currentUserID;
  StreamSubscription<Event> onAddedSubscription;
  StreamSubscription<Event> onChangedSubscription;
  List<User> userList;
  List<String> userEmailList;
  String taskStatus, userEmail;
  String sharedUserID;
  bool shareTapped = false;
  bool validate = false;
  bool autoValidate = false;
   
  @override
  void initState(){
    super.initState();
    taskStatus = widget.task.taskStatus;
    userList = new List();
    userEmailList = new List();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        currentUserID = value.getString("userID");
      });      
    });
    onAddedSubscription = db.child("User").onChildAdded.listen(onEntryAdded);
    onChangedSubscription = db.child("User").onChildChanged.listen(onEntryChanged);
  }

  @override
  dispose() {
    onAddedSubscription.cancel();
    onChangedSubscription.cancel();
    super.dispose();
  }
  
  onEntryAdded(Event event){
    setState(() {
      userEmailList.clear();
      userList.add(User.fromSnapshot(event.snapshot));
      userList.removeWhere((item) => item.userID == currentUserID);
      for(var item in userList){
        setState(() {
          userEmailList.add(item.userEmail.trim());
        });
      }
    });
  }

  onEntryChanged(Event event){
    var oldEntry = userList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      userList[userList.indexOf(oldEntry)] = User.fromSnapshot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
        ),
        backgroundColor: CustomColor.primary,
        title: Text("${widget.task.taskName}", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: displayTaskDetail(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColor.primary,
        onPressed: () {
          displayTaskMenu();
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

  Widget taskDetailField(String label, String field){
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

  Widget displayTaskDetail(){    
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
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            taskDetailField("Title", "${widget.task.taskName}"),
            Divider(color: Colors.white, height: 10.0,),
            taskDetailField("Description", "${widget.task.taskDesc}"),
            Divider(color: Colors.white, height: 10.0,),
            taskDetailField("Category", "${widget.task.taskCategory}"),
            Divider(color: Colors.white, height: 10.0,),
            taskDetailField("Due date", DateFormat('EEE, d MMM y').format(widget.task.taskDueDate)),
            Divider(color: Colors.white, height: 10.0,),
            taskDetailField("Status", "${widget.task.taskStatus}"),
          ],
        ),
      ),
    );
  }

  displayTaskMenu(){
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesome5.share_square, color: CustomColor.primary,),
                title: Text('Share', style: TextStyle(color: CustomColor.primary),),
                onTap: (){
                  setState(() {
                    autoValidate = false;
                    shareTapped = true;
                    displayUserList();
                  }); 
                },
              ),
              ListTile(
                leading: Icon(FontAwesome5.edit, color: CustomColor.primary,),
                title: Text('Edit', style: TextStyle(color: CustomColor.primary),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditTaskPage(task: widget.task)));
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
              ListTile(
                leading: Icon(
                  taskStatus == "Incomplete"? FontAwesome5.check_circle : FontAwesome5.times_circle, 
                  color: CustomColor.primary,
                ),
                title: Text(
                  taskStatus == "Incomplete"? 'Set task to Complete': 'Set task to Incomplete', 
                  style: TextStyle(color: CustomColor.primary),
                ),
                onTap: (){
                  setState(() {
                    if(taskStatus == "Incomplete"){
                      updateTaskStatus("Complete");
                    }
                    else if(taskStatus == "Complete"){
                      updateTaskStatus("Incomplete");
                    }
                  }); 
                },
              ),
            ],
          ),
        );
      }
    );
  }

  displayUserList(){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (BuildContext bc){
        return ListView.builder(
          shrinkWrap: true,
          itemCount: userList.length,
          itemBuilder: (BuildContext context, int index) {
            String userName = userList[index].userName;
            String userEmail = userList[index].userEmail;
            return ListTile(
              leading: Icon(FontAwesome.user_circle_o),
              title: Text(userName),
              subtitle: Text(userEmail),
              onTap: (){
                setState(() {
                  sharedUserID = userList[index].userID;
                  shareTask(userList[index].userEmail);
                });
              },
            );
          }
        );
      }
    );
  }

  // displayUserList(){
  //   return showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context, 
  //     builder: (BuildContext bc){
  //       return Form(
  //         key: formKey,
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, MediaQuery.of(context).viewInsets.bottom),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text("User Email", style: TextStyle(color: CustomColor.secondary1, fontWeight: FontWeight.bold, fontSize: 18.0),),
  //                 TextFormField(
  //                   autovalidate: autoValidate,
  //                   onSaved: (value) => userEmail = value.trim(),
  //                   validator: (value){
  //                     if(value.isEmpty){
  //                       return "User email is required";
  //                     }
  //                     else if(value.isNotEmpty){
  //                       if(EmailValidator.validate(value)){
  //                         userList.forEach((element) {
  //                           if(element.userEmail != value){
  //                             return "This user email is not exist";
  //                           }
  //                           return null;
  //                         });
  //                         // for(var item in userList){
  //                         //   if(item.userEmail.contains(value) == false){
  //                         //     return "This user email is not exist";
  //                         //   }
  //                         // }
  //                       }
  //                       else{
  //                         return "Please enter a valid email";
  //                       }    
  //                     }
  //                     return null;
  //                   },
  //                   style: TextStyle(color: CustomColor.primary),
  //                   decoration: InputDecoration(
  //                     hintStyle: TextStyle(color: CustomColor.primary),
  //                     enabledBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                         color: CustomColor.primary
  //                       )
  //                     ),
  //                     focusedBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                         color: CustomColor.primary
  //                       )
  //                     ),
  //                     border: UnderlineInputBorder(
  //                       borderSide: BorderSide(
  //                         color: CustomColor.primary
  //                       )
  //                     ),
  //                     hintText: "Enter email of the user to be shared"
  //                   ),
  //                 ),
  //                 Container(
  //                   margin: EdgeInsets.only(top: 10.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: <Widget>[
  //                       Container(
  //                         child: FlatButton(
  //                           child: Text("Cancel", style: TextStyle(color: CustomColor.secondary1, fontWeight: FontWeight.bold, fontSize: 16.0),),
  //                           onPressed: (){
  //                             Navigator.of(context).pop();
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(width: 10.0,),
  //                       Container(
  //                         child: FlatButton(
  //                           child: Text("OK", style: TextStyle(color: CustomColor.secondary1, fontWeight: FontWeight.bold, fontSize: 16.0),),
  //                           onPressed: (){
  //                             setState(() {
  //                               shareTapped = true;
  //                             });
  //                             print(userEmail);
  //                             for(var i=0; i<userEmailList.length; i++){
  //                               print(userEmailList[i]);
  //                               if(userEmailList[i] == userEmail){
  //                                 final test = userEmailList[i];
  //                                 print("hello " + test);
  //                                 for(var i=0; i<userList.length; i++){
  //                                   if(userList[i].userEmail == test){
  //                                     setState(() {
  //                                       sharedUserID = userList[i].userID;
  //                                     });
  //                                   }
                                    
  //                                 }
                                  
  //                               }
  //                               else{
  //                                 setState(() {
  //                                   sharedUserID = null;
  //                                 });
  //                               }
  //                             }
  //                             print(sharedUserID);
  //                             shareTask();
  //                           },
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //   );
  // }

  void showDeleteMessage(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Delete Task', 
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CustomColor.secondary1,
              ),
            ),
          content: Text(
            'Are you sure to delete this task?', 
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
                deleteTask("${widget.task.key}");
              },
            ),
          ],
        );
      },
    );
  }

  void showSuccessMessage(String title, String content, String userName, Task task){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            title, 
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CustomColor.secondary1,
              ),
            ),
          content: Text(
            shareTapped == true? content + userName: content, 
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => DetailTaskPage(task: task,)));
              },
            ),
          ],
        );
      },
    );
  }

  void updateTaskStatus(String status){
    DateTime completeTask = DateTime.now();
    Task task = Task(
      widget.task.userID,
      widget.task.taskName,
      widget.task.taskDesc,
      widget.task.taskCategory,
      widget.task.taskDueDate,
      status,
      widget.task.isOverdue,
      widget.task.taskCompletedDate
    );

    try{
      db.child("Task").orderByChild("taskName").equalTo(widget.task.taskName).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          if(key == widget.task.key){
            if(status == "Complete"){
              db.child("Task").child(key).update(
                {
                  "taskCompletedDate": DateFormat("yyyy-MM-dd").format(completeTask),
                  "taskStatus": status,
                }
              );
            }
            else{
              db.child("Task").child(key).update(
                {
                  "taskCompletedDate": DateFormat("yyyy-MM-dd").format(DateTime(0000, 00, 00)),
                  "taskStatus": status,
                }
              );
            }
          } 
        });
      });
      showSuccessMessage("Update Task Status", "Task status has been successfully updated", null, task);
    }
    catch(e){
      print(e.message);
    }    
  }

  void shareTask(String uEmail){
    Task task = new Task(
      sharedUserID, 
      widget.task.taskName,
      widget.task.taskDesc,
      widget.task.taskCategory,
      widget.task.taskDueDate,
      widget.task.taskStatus,
      widget.task.isOverdue,
      widget.task.taskCompletedDate
    );

    try{
      db.child("Task").push().set(task.toJson());
      print("task successfully shared.");
      showSuccessMessage("Share Task", "You have successfully share this task to ", uEmail, widget.task);
    }
    catch(e){
      print(e.message);
    }
  }

  // void shareTask(){
  //   final formState = formKey.currentState;
  //   Task task = new Task(
  //     sharedUserID, 
  //     widget.task.taskName,
  //     widget.task.taskDesc,
  //     widget.task.taskCategory,
  //     widget.task.taskDueDate,
  //     widget.task.taskStatus,
  //     widget.task.isOverdue,
  //     widget.task.taskCompletedDate
  //   );


  //   if(formState.validate()){
  //     formState.save();
  //     try{
  //       db.child("Task").push().set(task.toJson());
  //       print("task successfully shared.");
  //       showSuccessMessage("Share Task", "You have successfully share this task to ", userEmail, widget.task);
  //     }
  //     catch(e){
  //       print(e.message);
  //     }
  //   }
  //   else{
  //     setState(() {
  //       autoValidate = true;
  //     });
  //   }
  // }

  void deleteTask(String taskID) {
    db.child("Task").child(taskID).remove().then((_) {
      print("Task " + taskID + " successfully deleted.");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => HomePage()));
    });
  }
}