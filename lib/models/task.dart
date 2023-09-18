import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final storeDateFormat = DateFormat("yyyy-MM-dd");

class Task{
  String key;
  String userID;
  String taskName;
  String taskDesc;
  String taskCategory;
  String taskStatus;
  bool isOverdue;
  DateTime taskCompletedDate;
  DateTime taskDueDate;

  Task(this.userID, this.taskName, this.taskDesc, this.taskCategory, this.taskDueDate, this.taskStatus, this.isOverdue, this.taskCompletedDate);

  Task.fromSnapshot(DataSnapshot snapshot){
    key = snapshot.key;
    taskName = snapshot.value['taskName'];
    taskDesc = snapshot.value['taskDesc'];
    taskCategory = snapshot.value['taskCategory'];
    taskStatus = snapshot.value['taskStatus'];
    isOverdue = snapshot.value['isOverdue'];
    taskDueDate = DateTime.parse(snapshot.value['taskDueDate']);
    taskCompletedDate = DateTime.parse(snapshot.value['taskCompletedDate']);
  }
  
  toJson() {
    return {
      "userID" : userID,
      "taskName" : taskName,
      "taskDesc" : taskDesc,
      "taskCategory" : taskCategory,
      "taskStatus" : taskStatus,
      "isOverdue" : isOverdue,
      "taskDueDate": storeDateFormat.format(taskDueDate),
      "taskCompletedDate" : storeDateFormat.format(taskCompletedDate),
    };
  }

}