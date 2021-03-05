import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension GetDeviceData on BuildContext {
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}