import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// close screen with [result]
  void finish({dynamic result}) {
    return Navigator.of(context).pop(result);
  }
}

extension WidgetUtilities on BuildContext{
  EdgeInsets padData2({double hor, double ver}){
    return EdgeInsets.symmetric(horizontal: hor ?? 0, vertical: ver ?? 0);
  }

  EdgeInsets padData4({double left, double right, double top, double bottom}) {
    return EdgeInsets.only(left: left ?? 0, right: right ?? 0, top: top ?? 0, bottom: bottom ?? 0);
  }
}