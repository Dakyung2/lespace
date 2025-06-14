import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/components/textfields/my_textfield.dart';
import 'package:lespace/components/buttons/singnin_button.dart';

class ForgotPasswordMailScreen extends StatefulWidget {

  const ForgotPasswordMailScreen({super.key});

  @override
  State<ForgotPasswordMailScreen> createState() => _ForgotPasswordMailScreenState();
}

class _ForgotPasswordMailScreenState extends State<ForgotPasswordMailScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
    }

  Future resetPassword() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),)
    );
    try{
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("비밀번호 재설정 이메일을 전송했습니다"), )

      );
    } on FirebaseAuthException catch (e){
      return Text("$e");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xffc2d3e5),
        title: const Text("비밀번호 재설정",),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25,),
                const Text(
                  "비밀번호 재설정을 위한 이메일을 받으세요",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18)),
                const SizedBox(height: 25,),
                MyTextField(
                    controller: emailController,
                    hintText: "등록 이메일",
                    obscureText: false),
                  //autovalidateMode: AutovalidateMode.onUserInteraction,
                  //validator: (email) =>
                    //email != null && !EmailValidator.validate,
                  const SizedBox(height: 25,),
                  SigninOrUpButton(
                      onTap: resetPassword,
                      icon: const Icon(Icons.email_outlined),
                      text: "비밀번호 재설정")

              ],
            ),
          ),
        ),
      ),
    );

    }
    }


