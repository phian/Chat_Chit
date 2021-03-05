import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_chit/base/base_state.dart';

class AppPaddingWidget extends StatelessWidget {
  final Widget child;
  final double paddingLeft,
      paddingRight,
      paddingTop,
      paddingBottom,
      horizontal,
      vertical;

  AppPaddingWidget({
    @required this.child,
    this.paddingLeft,
    this.paddingRight,
    this.paddingTop,
    this.paddingBottom,
    this.horizontal,
    this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal != null || vertical != null)
      return Padding(
        padding: context.padData2(hor: horizontal, ver: vertical),
        child: child,
      );
    else
      return Padding(
        padding: context.padData4(
            left: paddingLeft ?? 0,
            top: paddingTop ?? 0,
            right: paddingRight ?? 0,
            bottom: paddingBottom ?? 0),
        child: child,
      );
  }
}

// enum WidgetTypeEnum { BUTTON, TEXT_FIELD, HEADER }
//
// class PaddingBuilder {
//
//   double paddingLeft, paddingRight, paddingTop, paddingBottom;
//
//   //LRTB
//
//   Map<String, double> _data;
//
//   PaddingBuilder setPadLeft(double value) {
//     this.paddingLeft = value;
//     return this;
//   }
//
//   PaddingBuilder setType(WidgetTypeEnum type) {
//     switch (type) {
//       case WidgetTypeEnum.BUTTON:
//         _data['l'] = 12;
//         _data['r'] = 10;
//         _data['t'] = 12;
//         _data['b'] = 10;
//         break;
//       case WidgetTypeEnum.TEXT_FIELD:
//       // TODO: Handle this case.
//         break;
//       case WidgetTypeEnum.HEADER:
//       // TODO: Handle this case.
//         break;
//     }
//   }
//
//   EdgeInsets renderUI() {
//     return EdgeInsets.only(left: _data['l'] ?? 0);
//   }
//
//   EdgeInsets buildPadding(WidgetTypeEnum type) {
//     return renderUI();
//   }
// }
