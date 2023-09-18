
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:student_planner_app/models/task.dart';
import 'package:student_planner_app/themes/colors.dart';

import 'detailTaskPage.dart';

class TaskCompletedPage extends StatefulWidget {
  final List<Task> taskList;
  
  TaskCompletedPage({Key key, @required this.taskList}) : super(key: key);
 

  @override
  _TaskCompletedPageState createState() => _TaskCompletedPageState();
}

class _TaskCompletedPageState extends State<TaskCompletedPage> {  
  List<Task> completeTask;

  @override
  void initState() {   
    super.initState();    
    completeTask = widget.taskList;
  }

    @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (completeTask.length != 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal:5.0, vertical:10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: completeTask.length,
                itemBuilder: (BuildContext context, int index) {
                  String taskName = completeTask[index].taskName;
                  String taskCategory = completeTask[index].taskCategory;
                  DateTime taskDueDate = completeTask[index].taskDueDate;
                  String formattedDate = DateFormat("d MMM yy").format(taskDueDate);
                  Duration timeRemaining = taskDueDate.difference(completeTask[index].taskCompletedDate);
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTaskPage(task: completeTask[index])));
                    },
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: CustomColor.primary,
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(taskCategory, style: TextStyle(color: CustomColor.secondary1, fontWeight: FontWeight.bold),),
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
                                Expanded(flex: 2, child: Text(taskName, style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: CustomColor.secondary1,),)),
                                Container(
                                  width: 80.0,
                                  child: Column(
                                    children: <Widget>[
                                      Text("Due date", style: TextStyle(color: CustomColor.primary, fontWeight: FontWeight.bold)),
                                      Text(formattedDate, style: TextStyle(color: CustomColor.primary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    else if(completeTask.length == 0) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(FontAwesome.list_alt, size: 100.0, color: CustomColor.primary.withOpacity(0.8),),
            SizedBox(height: 10.0),
            Text("You have no task completed.",
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
    else{
      return CircularProgressIndicator();
    }
  }

  Widget displayDaysRemaining(Duration time){
    if(time.inDays < 0){
      return Text(
        "Overdue by " + time.inDays.abs().toString() + " days",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 13.0
        ),
      );
    }
    else if(time.inDays == 0){
      return Text(
        "Completed today",
        style: TextStyle(
          color: CustomColor.secondary1,
          fontWeight: FontWeight.bold,
          fontSize: 13.0
        ),
      );
    }
    else{
      return Text(
        "Completed " + time.inDays.toString() + " days early",
        style: TextStyle(
          color: CustomColor.secondary1,
          fontWeight: FontWeight.bold,
          fontSize: 13.0
        ),
      );
    }
  }
}