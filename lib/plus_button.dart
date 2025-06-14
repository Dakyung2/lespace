import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final function;
  const PlusButton({super.key, this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: function,
      child:Container(
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.rectangle,
        ),
        child: const Center(
          child: Icon(Icons.location_on, color: Colors.white,
    ),
    ),
      ),
    );
    }
  }

