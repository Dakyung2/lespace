import 'package:flutter/material.dart';
import 'package:lespace/components/sliderthumb.dart';

class SliderField extends StatelessWidget {
  final String title;
  final double value;
  final String? label;
  final double max;
  final double min;
  final int division;
  final  function;
  final thumbIcon;


   const SliderField({
    required this.thumbIcon,
     required this.value,
     required this.label,
     required this.max,
     required this.min,
     required this.division,
    required this.title,
     required this.function,
    super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(title.toString(), style: const TextStyle(fontSize: 18),),
          ),
          Expanded(
            child: SliderTheme(
              data:  SliderThemeData(
                thumbColor: const Color(0xff91bae7),
                thumbShape: SliderThumbShape(
                  thumbRadius: 10,
                  thumbIcon: thumbIcon)),

              child: Slider(
                  max: max,
                  min: min,
                  value: value,
                  divisions: division,
                  label: label,
                  onChanged: function,
                  activeColor: const Color(0xff91bae7),
                  inactiveColor: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
