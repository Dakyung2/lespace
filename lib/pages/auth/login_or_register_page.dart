import 'package:flutter/material.dart';
import 'package:lespace/pages/auth/login_page.dart';
import 'package:lespace/pages/auth/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage ({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  //initially show register page
  bool showRegisterPage = true;
  //toggel between login and register page
  void togglePages(){
    setState(() {
      showRegisterPage = !showRegisterPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showRegisterPage){
      return RegisterPage(
        onTap: togglePages,
      );
    }else {
      return LoginPage(
        onTap: togglePages,);
    }
  }
}
