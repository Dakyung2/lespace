import 'package:flutter/material.dart';

class ReviewTextField extends StatelessWidget {
  final inputformatters;

  final keyboardType;
  final controller;
  final myicon;
  final  mylabel;
//access what user typed in textfield
  final String messagehintText;
  final bool obscureText;


  const ReviewTextField({
    super.key,

    required this.controller,
    required this.messagehintText,
    required this.obscureText,
    this.myicon,
    this.keyboardType,
    this.inputformatters,
     this.mylabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
     child: Column(
       children: [
         TextField(
           keyboardType: keyboardType,
           inputFormatters: inputformatters,
           maxLines: null,
           controller: controller,
           obscureText: obscureText,
           decoration: InputDecoration(
             //contentPadding: EdgeInsets.all(4),
             isDense: true,
             contentPadding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              // contentPadding: ,
             label: mylabel,
               prefixIcon: myicon,
             enabledBorder: const OutlineInputBorder(
               borderSide: BorderSide(color: Colors.white),
             ),
             focusedBorder:const OutlineInputBorder(
               borderSide: BorderSide(color: Colors.grey),
             ),
             fillColor: Colors.white,
             filled: true,
             hintText: messagehintText,
             hintStyle: const TextStyle(fontSize: 18),
           ),
         ),
     
     
       ],
     )
    );
  }
}
