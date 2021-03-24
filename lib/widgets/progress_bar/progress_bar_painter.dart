import 'package:chat_chit/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Draws the progress bar.
class CircleProgressBarPainter extends CustomPainter {
  final double currentProgress;

  CircleProgressBarPainter({this.currentProgress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint outsideCircle = Paint()
      ..strokeWidth = 5.0
      ..color = AppPalleteColor.BLACK_COLOR
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 5.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2) -
        5.0; // Minus the stroke width

    canvas.drawCircle(center, radius, outsideCircle); // background circle

    double angle = 2 * math.pi * (this.currentProgress / 100);
    canvas.drawArc(Rect.fromCircle(radius: radius, center: center),
        -math.pi / 2, angle, false, completeArc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
