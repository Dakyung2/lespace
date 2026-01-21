import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class ReviewTextField extends StatelessWidget {
  final inputformatters;
  final keyboardType;
  final controller;
  final myicon;
  final mylabel;
  final String messagehintText;
  final bool obscureText;
  // [추가] 힌트 텍스트 사이즈와 색상을 조절하기 위한 변수
  final double hintFontSize; 

  const ReviewTextField({
    super.key,
    required this.controller,
    required this.messagehintText,
    required this.obscureText,
    this.myicon,
    this.keyboardType,
    this.inputformatters,
    this.mylabel,
    this.hintFontSize = 14.0, // 기본값을 14로 낮춰서 더 세련되게 설정
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // 외부 간격은 메인 페이지에서 조절하므로 0으로 최적화
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: inputformatters,
        maxLines: null,
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15), // 실제 입력되는 글자 크기
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // 상하 여백을 줘서 터치 영역 확보
          label: mylabel,
          prefixIcon: myicon,
          // 보더 디자인을 더 깔끔하게 (밑줄만 있거나 아예 없애는 추세 반영)
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent), // 테두리 없이 깔끔하게
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: messagehintText,
          // [수정] 힌트 스타일 최적화
          hintStyle: TextStyle(
            fontSize: hintFontSize, 
            color: Colors.black.withOpacity(0.3), // 연한 회색으로 고급스럽게
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/*
class ReviewTextField extends StatelessWidget {
  final inputformatters;

  final keyboardType;
  final controller;
  final myicon;
  final  mylabel;
//access what user typed in textfield
  final String messagehintText;
  final bool obscureText;
  final double hintFontSize;



  const ReviewTextField({
    super.key,

    required this.controller,
    required this.messagehintText,
    required this.obscureText,
    this.myicon,
    this.keyboardType,
    this.inputformatters,
     this.mylabel,
     this.hintFontSize = 14
     });

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
           style: const TextStyle(fontSize: 15),
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
             hintStyle: TextStyle(
              fontSize: hintFontSize,),
           ),
         ),
     
     
       ],
     )
    );
  }
}
*/