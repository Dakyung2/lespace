import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:lespace/components/textfields/my_textfield.dart';
import 'package:lespace/components/buttons/singnin_button.dart';

import 'forgot_password_mail_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );},
        );
    //try sign in
    try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text);
    //get rid of circle
    Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      //Wrong Email
      if (e.code == 'user-not-found'){
        //Show error to user
        showErrorMessage(
            '인증된 학교 이메일로 시도해주세요!');
        //Wrong password
      } else if (e.code == 'wrong-password'){
        //show error to user
        showErrorMessage('앗 비밀번호가 다릅니다');
      }
    }
  }


  //error message to show user
  void showErrorMessage(String message){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.blueAccent,
            title: Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
          ),
            ),
          );
        },
    );
  }


  @override
  void initState(){
    super.initState();
        FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_loginpage',
      parameters: {
        'firebase_screen': "LoginPage",
        'firebase_screen_class': "LoginPage"
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
     
      body:
        SafeArea(
          child:Center(
            child: SingleChildScrollView(
            child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15,),
                    const Icon(
                      Icons.lock_open_rounded,
                      size: 90,
                      color: Color(0xffbbceee),
                    ),

                    const SizedBox(height: 25,),
                    //welcome back
                    const Text(
                      "환영합니다!",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                      ),
                    ),

                    const SizedBox(height: 25,),
                    //user name text field
                    MyTextField(
                      controller: emailController,
                      hintText: '학교 이메일',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10,),
                    //password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: '비밀번호',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10,),
                    //forgot password?
                    const SizedBox(height: 25,),
                    //sign in button
                    SigninOrUpButton(
                      onTap: signUserIn,
                      text: "로그인",
                    ),

                    const SizedBox(height: 50,),
                    //naver sign in
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                          ),
                        ],
                      ),
                    ),

                    //Naver sign in buttons
                   /* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      SquareTile(imagePath: 'lib/assets/naver.png'),
                        //naver button
                      ],
                    ),

                    const SizedBox(height: 50,),*/

                    //not a member? register now
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0, top: 8, left:25, right: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('멤버가 아니신가요?',
                              style: TextStyle(color: Colors.grey, fontSize: 16),),
                              const SizedBox(height: 2,),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Center(
                                  child: Text(
                                    ' 등록하기',
                                    style: TextStyle(color:Colors.blueAccent ,fontSize: 16),),
                                ),
                      ),
                            ],
                          ),
                          const SizedBox(height: 15,),

                          GestureDetector(
                            
                            child: const Text("비밀번호를 잊으셨나요?", style: TextStyle(color: Colors.grey, fontSize: 12),),
                            onTap: (){
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordMailScreen())
                              );
                            },
                          ),
                          
                          

                  ],
    ),
                    ),
    ],
    ),
    ),
    ),
        ),
    );
  }
  }

