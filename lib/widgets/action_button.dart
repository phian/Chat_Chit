import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class AppActionsButton extends StatelessWidget {
  final String buttonContent;
  final Color buttonColor;
  final Color borderSideColor;
  final Function onPressed;

  AppActionsButton({
    this.buttonContent,
    this.buttonColor,
    this.borderSideColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      height: 60.0,
      minWidth: MediaQuery.of(context).size.width,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: borderSideColor != null
            ? BorderSide(color: borderSideColor)
            : BorderSide(),
      ),
      color: buttonColor ?? Colors.transparent,
      child: AppTextWidget(
        textContent: buttonContent,
        textColor: buttonColor == null
            ? borderSideColor
            : AppPalleteColor.WHITE_COLOR,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      ),
    );
  }
}
