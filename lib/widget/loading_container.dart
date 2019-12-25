import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  LoadingContainer(
      {Key key, this.color = Colors.green, this.strokeWidth = 5.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(
        color,
      ),
    );
  }
}
