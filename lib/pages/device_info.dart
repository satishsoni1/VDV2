import 'package:flutter/material.dart';

class DeviceInfo {
  BuildContext context;
  double height = 0;
  double width = 0;

  DeviceInfo(this.context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}
