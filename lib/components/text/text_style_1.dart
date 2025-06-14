import 'package:flutter/material.dart';

class TextStyle1 extends StatelessWidget {
  final String text;

  const TextStyle1({
    super.key,
   required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
        text,
        style: const TextStyle(
          fontSize: 28
        ),);
  }
}
