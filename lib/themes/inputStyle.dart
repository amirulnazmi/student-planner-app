import 'package:flutter/material.dart';
import 'colors.dart';

class InputStyle{
  final underlineInputBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black.withOpacity(0.0)),
  );

  inputFieldStyle(String hintText){
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: CustomColor.secondary1,
      enabledBorder: underlineInputBorderStyle,
      focusedBorder: underlineInputBorderStyle,
      errorBorder: underlineInputBorderStyle,
      border: underlineInputBorderStyle,
      focusedErrorBorder: underlineInputBorderStyle,
      errorStyle: TextStyle(color: Colors.grey[100]),
    );
  }

  Widget inputLabelText(String labelText){
    return Text(
      labelText,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: CustomColor.secondary1,
      ),
    );
  }
}