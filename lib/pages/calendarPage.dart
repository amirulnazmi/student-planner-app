import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as event;
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/themes/colors.dart';
import 'package:student_planner_app/widgets/navBar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final db = FirebaseDatabase.instance;
  bool onDayPressed = false;
  DateTime selectedDate = DateTime.now();
  int totalTask = 0;
  List<String> calendarText = [];
  
  EventList<event.Event> markedDateMap = new EventList<event.Event>(
    events:{},
  );

  Future<void> getCalendarEventList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    String userID = prefs.getString("userID");
    Query taskQuery = db.reference().child("Task").orderByChild("userID").equalTo(userID);

    await taskQuery.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        markedDateMap.add(
          DateTime.parse(value['taskDueDate']),
          new event.Event(
            date: DateTime.parse(value['taskDueDate']),
            title: value['taskCategory'] + ": " + value['taskName'],
          )
        );
      });
    });
    setState(() {});
  }

  Future<void> getExamList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    String userID = prefs.getString("userID");
    Query examQuery = db.reference().child("Exam").orderByChild("userID").equalTo(userID);

    await examQuery.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        markedDateMap.add(
          DateTime.parse(value['examDate']),
          new event.Event(
            date: DateTime.parse(value['examDate']),
            title: value['examName'] + "\t" + value['examCategory'],
          )
        );
      });
    });
    setState(() {});
  }
  
  @override
  void initState() {
    getCalendarEventList();
    getExamList();
    super.initState();
  }

  @override
  void dispose(){
    markedDateMap.clear();
    calendarText.clear();
    super.dispose();
  }

  void refresh(DateTime date, List<event.Event> events) {
    calendarText.clear();
    if(markedDateMap.getEvents(new DateTime(date.year, date.month, date.day)).isNotEmpty){
      for(var i=0; i<events.length; i++){
        setState(() {
          calendarText.add(events[i].getTitle());
        });
      }
    }
    else{
      calendarText = ['There is no task on this day'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text('Calendar View'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            shadowColor: Colors.black,
            child: CalendarCarousel(
              height: 430.0,
              selectedDateTime: selectedDate,
              todayButtonColor: Colors.grey[700],
              selectedDayButtonColor: CustomColor.primary,
              markedDatesMap: markedDateMap,
              markedDateIconMaxShown: 2,
              markedDateWidget: Container(
                height: 5.0,
                width: 5.0,
                margin: EdgeInsets.only(right: 2.0),
                decoration: BoxDecoration(
                  color: CustomColor.secondary1,
                  shape: BoxShape.circle,
                ),
              ),
              weekdayTextStyle: TextStyle(
                color: CustomColor.primary,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.red,
              ),
              headerTextStyle: TextStyle(
                color: CustomColor.primary,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
              leftButtonIcon: Icon(Icons.chevron_left, color: CustomColor.secondary1, size: 30.0,),
              rightButtonIcon: Icon(Icons.chevron_right, color: CustomColor.secondary1, size: 30.0,),
              onDayPressed: (DateTime date, List<event.Event> events) {
                this.setState(() => refresh(date, events));
                //this.setState(() => refresh(date, events));
                setState(() {
                  onDayPressed = true;
                  selectedDate = date;
                  totalTask = events.length;
                });
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 60.0,
            color: CustomColor.primary,
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16.0),
                  child: Icon(FontAwesome5.calendar_check, color: Colors.white,)
                ),
                Container(
                  margin: EdgeInsets.only(left: 30.0),
                  child: Text(
                    DateFormat('EEEEE, d MMMM y').format(selectedDate),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Flexible(
            fit: FlexFit.tight,
            child: onDayPressed? 
            Container(
              margin: EdgeInsets.only(top: 3.0),
              child: ListView.builder(
                itemCount: calendarText.length,
                itemBuilder: (BuildContext context, int index) {
                  String text = calendarText[index];
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: CustomColor.primary,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      Divider(color: Colors.black)
                    ],
                  );
                }
              ),
            )
            :
            Container(),
          )
        ],
      ),
    );
  }
}