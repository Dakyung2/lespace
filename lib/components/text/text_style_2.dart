import 'package:flutter/material.dart';

class TextStyle2 extends StatelessWidget {
  final String text;

  const TextStyle2({
    super.key,
    required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 20
      ),);
  }
}