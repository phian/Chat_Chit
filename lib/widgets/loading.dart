import 'package:chat_chit/widgets/progress_bar/progress_bar.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double value;
  LoadingWidget({this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircleProgressBar(
          value: value,
          animationDuration: Duration(milliseconds: 1000),
        ),
        width: 80.0,
        height: 80.0,
      ),
    );
  }
}
