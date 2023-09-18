import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final storeTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

class User{
  String key;
  String userID;
  String userName;
  String userEmail;
  bool isTaskReminderOn;
  bool isExamReminderOn;
  DateTime taskReminderTime;
  DateTime examReminderTime;

  User(this.userID, this.userName, this.userEmail, this.isTaskReminderOn, this.isExamReminderOn, this.taskReminderTime, this.examReminderTime);

  User.fromSnapshot(DataSnapshot snapshot){
    key = snapshot.key;
    userID = snapshot.value['userID'];
    userName = snapshot.value['userName'];
    userEmail = snapshot.value['userEmail'];
    isTaskReminderOn = snapshot.value['isTaskReminderOn'];
    isExamReminderOn = snapshot.value['isExamReminderOn'];
    taskReminderTime = DateTime.parse(snapshot.value['taskReminderTime']);
    examReminderTime = DateTime.parse(snapshot.value['examReminderTime']);
  }

  toJson() {
    return {
      "userID": userID,
      "userName": userName,
      "userEmail": userEmail,
      "isTaskReminderOn": isTaskReminderOn,
      "isExamReminderOn": isExamReminderOn,
      "taskReminderTime": storeTimeFormat.format(taskReminderTime),
      "examReminderTime": storeTimeFormat.format(examReminderTime),
    };
  }
}