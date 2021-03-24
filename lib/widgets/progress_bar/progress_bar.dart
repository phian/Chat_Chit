import 'package:flutter/material.dart';
import 'progress_bar_painter.dart';
import 'dart:math' as math;

/// Draws a circular animated progress bar.
class CircleProgressBar extends StatefulWidget {
  final Duration animationDuration;
  final double value;

  const CircleProgressBar({
    Key key,
    this.animationDuration,
    this.value,
  }) : super(key: key);

  @override
  CircleProgressBarState createState() {
    return CircleProgressBarState();
  }
}

class CircleProgressBarState extends State<CircleProgressBar>
    with SingleTickerProviderStateMixin {
  // Used in tweens where a backgroundColor isn't given.
  static const TRANSPARENT = Color(0x00000000);
  AnimationController _progressAniController;
  Animation<double> _progressBarAni;

  @override
  void initState() {
    super.initState();

    _progressAniController = AnimationController(
      duration: this.widget.animationDuration ?? Duration(seconds: 1),
      vsync: this,
    );

    _progressBarAni = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(
            curve: Curves.fastOutSlowIn, parent: _progressAniController))
      ..addListener(
        () {
          setState(() {});
        },
      );

    _progressAniController.forward();
  }

  @override
  void didUpdateWidget(CircleProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _progressAniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: CircleProgressBarPainter(
        currentProgress: _progressBarAni.value,
      ),
    );
  }
}
