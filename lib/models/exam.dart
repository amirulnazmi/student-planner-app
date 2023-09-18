import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final storeDateFormat = DateFormat("yyyy-MM-dd");
final storeTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

class Exam{
  String userID;
  String key;
  String examName;
  String examDesc;
  String examCategory;
  String examStatus;
  String examLocation;
  int examDuration;
  DateTime examDate;
  DateTime examTime;

  Exam(this.userID, this.examName, this.examDesc, this.examCategory, this.examStatus, this.examLocation, this.examDuration, this.examDate, this.examTime);

  Exam.fromSnapshot(DataSnapshot snapshot){
    key = snapshot.key;
    examName = snapshot.value['examName'];
    examDesc = snapshot.value['examDesc'];
    examCategory = snapshot.value['examCategory'];
    examStatus = snapshot.value['examStatus'];
    examLocation = snapshot.value['examLocation'];
    examDuration = int.parse(snapshot.value['examDuration']);
    examDate = DateTime.parse(snapshot.value['examDate']);
    examTime = DateTime.parse(snapshot.value['examTime']);
  }
  
  toJson() {
    return {
      "userID" : userID,
      "examName" : examName,
      "examDesc" : examDesc,
      "examCategory" : examCategory,
      "examStatus" : examStatus,
      "examLocation": examLocation,
      "examDuration" : examDuration.toString(),
      "examDate" : storeDateFormat.format(examDate),
      "examTime" : storeTimeFormat.format(examTime),
    };
  }
}