import 'package:flutter/services.dart';

class KeyboardTypeNum{
  final keyboardTypeNum = const TextInputType.numberWithOptions(decimal: true);
  final inputFormattersNum  = <TextInputFormatter> [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
  ];
}