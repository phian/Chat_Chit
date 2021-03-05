import 'package:chat_chit/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:chat_chit/utils/extensions.dart';

class CustomContainer extends StatelessWidget {
  final double width, height;
  final Widget child;

  CustomContainer({@required this.child, @required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? context.getScreenHeight(context),
      width: width ?? context.getScreenWidth(context),
      child: child,
      decoration: BoxDecoration(
        color: AppPalleteColor.WHITE_COLOR,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
    );
  }
}
