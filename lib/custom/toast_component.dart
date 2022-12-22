
import 'package:flutter/material.dart';
import 'package:blog_app/my_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ToastComponent {
  static showDialog(String msg, context, {duration = 0, gravity = 0}) {
    Fluttertoast.showToast(
      msg:msg,
      toastLength: duration != 0 ? duration : Toast.LENGTH_SHORT,
      gravity: gravity != 0 ? gravity : ToastGravity.TOP,
        backgroundColor:
        Color.fromRGBO(239, 239, 239, .9),
        textColor: MyTheme.font_grey,
    );
  }
}
