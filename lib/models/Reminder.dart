import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Reminder{
  String key;
  String userID;
  bool taskReminderTurnOn;
  bool examReminderTurnOn;
  TimeOfDay taskReminderTime;
  TimeOfDay examReminderTime;
  
  Reminder(this.userID, this.taskReminderTurnOn, this.examReminderTurnOn, this.taskReminderTime, this.examReminderTime);

  Reminder.fromSnapshot(DataSnapshot snapshot){
    key = snapshot.key;
    taskReminderTurnOn = snapshot.value['taskReminderTurnOn'];
    examReminderTurnOn = snapshot.value['examReminderTurnOn'];
    taskReminderTime = snapshot.value['taskReminderTime'];
    examReminderTime = snapshot.value['examReminderTime'];
  }

  toJson() {
    return {
      "userID" : userID,
      "taskReminderTurnOn" : taskReminderTurnOn,
      "examReminderTurnOn" : examReminderTurnOn,
      "taskReminderTime" : taskReminderTime,
      "examReminderTime" : examReminderTime,
    };
  }
}