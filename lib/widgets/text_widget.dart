import 'package:flutter/material.dart';

class AppTextWidget extends StatelessWidget {
  final String textContent;
  final double fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int textMaxLine;

  AppTextWidget({
    @required this.textContent,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
    this.textMaxLine,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      this.textContent,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: textMaxLine ?? 1000,
      style: TextStyle(
        fontWeight: this.fontWeight ?? null,
        fontSize: this.fontSize ?? null,
        color: this.textColor ?? null,
      ),
    );
  }
}
