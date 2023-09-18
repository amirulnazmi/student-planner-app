import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:student_planner_app/themes/colors.dart';

class CustomBottomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final double height;
  final TabController tabController;

  CustomBottomAppBar({
    Key key,
    @required this.height, this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 15.0),
          child: Text(
            'Dashboard', 
            style: TextStyle(
              color: CustomColor.secondary1,
              fontSize: 50.0,
            )
          ),
        ),
        TabBar(
          // labelColor: CustomColor.secondary1,
          indicatorColor: CustomColor.secondary1,
          controller: tabController,
          tabs: [
            Tab(text: "Incomplete", icon: Icon(FontAwesome5.times_circle)),
            Tab(text: "Complete", icon: Icon(FontAwesome5.check_square)),
          ]
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
