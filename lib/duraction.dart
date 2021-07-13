import 'package:flutter/material.dart';

class DurationText extends StatelessWidget {
  final String text;
  const DurationText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 25.0),
    );
  }
}
