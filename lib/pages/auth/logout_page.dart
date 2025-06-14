import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//A page with log_out button
class LogoutPage extends StatelessWidget{
  LogoutPage ({super.key});
  //user info
  final user = FirebaseAuth.instance.currentUser!;
//SignUserOutmethod
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(
            onPressed: signUserOut, icon: const Icon(Icons.logout))],),
      body: Center(
        child: Text("${user.email!}로 로그인 완료!",),
      ),
    );
  }

}