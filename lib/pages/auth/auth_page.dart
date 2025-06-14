import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import 'package:lespace/pages/auth/verify_email_page.dart';

//Page to check if the user is signed in or not
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //user is logged in
          if (snapshot.hasData){
            return const VerifyEmailPage();

          }
          //user is not logged in
          else{
            return const LoginOrRegisterPage();
          }
        },),
    );
  }
}
