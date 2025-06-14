import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import 'package:lespace/sungshin/pages/review_posts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class VerifyEmailPage extends StatefulWidget {

   const VerifyEmailPage({
    super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  //Put timer a variable inside the state
  Timer? timer;

  @override
  void initState()  {
    super.initState();
    final currentUser =  FirebaseAuth.instance.currentUser;
    if (currentUser !=null){
      isEmailVerified =  currentUser.emailVerified;
      if(!isEmailVerified){
         sendVerificationEmail();
        timer =  Timer.periodic(
          const Duration(seconds:1),
              (_) => checkEmailVerified(),
        );
      }else if(isEmailVerified){

         checkEmailVerified();
      }
      }
     FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_verifyemailpage',
      parameters: {
        'firebase_screen': "VerifyEmailPage",
        'firebase_screen_class': "VerifyEmailPage"
      });
  }

  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async{
    final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null){
    //reload the user after email verification! Cause statues can change
    await currentUser.reload();
     setState(()  {
       isEmailVerified =  currentUser.emailVerified;
    });
    if (isEmailVerified) {
       timer?.cancel();
      //direct to the school page!
      if (currentUser.email!.endsWith("korea.ac.kr")){
         return Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BuildingsReviewPage()));
         
      }else if(currentUser.email!.endsWith("sungshin.ac.kr")){
        return Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SungshinReviewPosts()));
      }else{
        return Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BuildingsReviewPage()));
      }
    }
  }
  }

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

  Future sendVerificationEmail() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      await currentUser.sendEmailVerification();
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Center(
              child: Text("인증에 성공하면 자동으로 플랫폼으로 이동합니다", 
              style: TextStyle(fontSize: 16, color: Colors.black87),
              )),
            actions: [
              IconButton(
                onPressed: (){
                  Navigator.of(context).pop();},

          icon: const Icon(Icons.cancel_rounded))
            ],
          );
        });

      //setState(()=> canResendEmail = false);
      //await Future.delayed(Duration(seconds: 5));
      //setState(()=> canResendEmail = true);
    } catch (e){
      showErrorMessage('$e로그아웃 후 다시 로그인하세요');
      Navigator.pop(context);
  }
  
  }

  void _launchURL() async{
    
  final Uri _url = Uri(scheme:'https', host:'mail.worksmobile.com', path: '',
  );
    if (!await launchUrl(_url,
                   mode: LaunchMode.externalApplication)) {
                   throw 'Could not launch $_url';
        }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const BuildingsReviewPage()
      : Scaffold(
        backgroundColor: const Color(0xe0b3cee5),
      
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const Text(
                   '이메일에서 인증요청을 확인하세요',
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                   textAlign: TextAlign.center,
                 ),
                 const Text(
             "본인 인증으로 안전하게 이용할 수 있습니다.",
             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
                       ),
      
                       const SizedBox(height: 24,),
            TextButton(
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size.fromHeight(50),
                      
                    ),
                      onPressed:_launchURL,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_email_unread_rounded, size: 20, color: Colors.black87,),
                          SizedBox(width: 5,),

                          Text(
                            "네이버웍스로 이동",
                          style: TextStyle(fontSize: 18, color:Colors.black87 ),),
                        ],
                      ) ),
                       
               ],
             ),
             const SizedBox(height: 24,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
              style: ElevatedButton.styleFrom(
                maximumSize: const Size.fromHeight(50),
              ),
                child: const Text(
                  '취소',
                style: TextStyle(fontSize: 20, color: Colors.black45 ),),
                onPressed: ()async{
                  const AlertDialog(content: Text("본인 인증이 취소됩니다. 취소하시는 이유가 있다면 2dkroom@gmail.com 로 피드백 부탁드립니다:)", style: TextStyle(fontSize: 16, color: Colors.black87),),);
                  await FirebaseAuth.instance.currentUser!.delete();
                 await Navigator.pushReplacement(
                      context,
                       MaterialPageRoute(
                          builder: (context) => const LoginOrRegisterPage()),
                  );
                } ),
                      TextButton(
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size.fromHeight(50),
                  ),
                    onPressed: sendVerificationEmail,
                    child: const Text(
                      "재전송",
                    style: TextStyle(fontSize: 20, color:Colors.black54 ),) ),
                  
              ],
            ),
      
            ],
        ),
      ),
    ),
        );
}
