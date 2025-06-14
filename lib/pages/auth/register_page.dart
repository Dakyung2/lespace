import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:lespace/components/textfields/my_textfield.dart';
import 'package:lespace/helper/iframe_view.dart';
import 'package:lespace/loading_circle.dart';


class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
 // final confirmController = TextEditingController();

  bool consentGiven = false;
  bool privacyConsentGiven = false;
  bool ageConsentGiven = false;

   String usagePolicyContext = "";
   String privacyPolicyContext= "";
   String privacyPolicyConsentContext ="" ;
   String ageRestrictionContext="" ;

  Timer? timer;



  @override
  void initState(){
    super.initState();
    fetchUsagePolicy();
    fetchPrivacyPolicy();
    fetchPrivacyPolicyConsent();
    fetchAgeRestrictionContext();

        FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_registerpage',
      parameters: {
        'firebase_screen': "RegisterPage",
        'firebase_screen_class': "RegisterPage"
      });
    /*if( FirebaseAuth.instance.currentUser == null){
      timer = Timer.periodic(
          Duration(seconds:1),
              (_) => FirebaseAuth.instance.currentUser!.reload());
    }*/

  }


  Future <void> fetchUsagePolicy() async{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("servicePolicy")
          .get();
      Map<String, dynamic> data =  documentSnapshot.data() as Map<String, dynamic>;

      String context =  data["Context"];
      setState(() {
         usagePolicyContext = context;
      });
  
  }

  Future <void> fetchPrivacyPolicy()async{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("personalInfoPolicy")
          .get();

      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      String context = data["Context"];
      setState(() {
        privacyPolicyContext = context;
      });

  }

  Future <void> fetchPrivacyPolicyConsent()async{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("personalInfoConsent")
          .get();

      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      String context = data["Context"];
      setState(() {
        privacyPolicyConsentContext = context;
      });
   
  }

  Future <void> fetchAgeRestrictionContext()async {
    
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("ageRestriction")
          .get();

      Map<String, dynamic> data =  documentSnapshot.data() as Map<String, dynamic>;
      String context = await data["Context"];
       setState(() {
        ageRestrictionContext = context;
      });
  
  }

  
  Future<void>showConsentDialog() async {
     showCupertinoModalPopup(
      barrierColor: const Color.fromARGB(160, 255, 255, 255),
      //barrierDismissible: true,
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(236, 231, 238, 246),
              title: const Text("약관 동의", style: TextStyle(fontSize: 20),),
              content:
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                            title: const Text("서비스이용약관", style: TextStyle(fontSize: 15, color: Colors.black87),),
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                            ),
                            height: MediaQuery.of(context).size.height*0.15,
                            child: SingleChildScrollView(
                           
                              child: Text( usagePolicyContext.toString(), 
                              style: const TextStyle(fontSize: 12, color: Colors.black54),),
                            ),
                          )
                        ],),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: ExpansionTile(

                                  title: const Text("개인정보 수집 및 이용 동의*", style: TextStyle(fontSize: 15, color: Colors.black87),),
                              children: [
                                SizedBox(
                                height: MediaQuery.of(context).size.height*0.15,
                    
                                child: SingleChildScrollView(
                                  child: Text(privacyPolicyConsentContext, style: const TextStyle(fontSize: 12, color: Colors.black54),),
                                ),
                              )],),
                            ),
                            Checkbox(
                              fillColor: MaterialStateProperty.all(Colors.white),
                                focusColor: const Color(0xe0d9e0e7),
                            
                                checkColor:const Color(0xe0d9e0e7),
                                value: privacyConsentGiven,
                                onChanged: (newValue) {
                                  setState(()  {
                                    privacyConsentGiven = !privacyConsentGiven;
                                  });
                                }
                            ),
                          ],
                        ),
                    
                        ExpansionTile(
                          
                          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                          title: const Text(
                            "개인정보처리방침", style: TextStyle(fontSize: 12, color: Colors.black87),),
                          children: [
                            SizedBox(
                            height: MediaQuery.of(context).size.height*0.15,
                        
                            child: SingleChildScrollView(
                              child: Text(privacyPolicyContext.toString(), style: const TextStyle(fontSize: 12, color: Colors.black54),),
                            ),
                          )],),
                    
                        const SizedBox(height: 10,),
                    
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ExpansionTile(

                                title: const Text("만 14세 이상입니다", style: TextStyle(fontSize: 15, color: Colors.black87),),
                                children: [
                                  SizedBox(
                                  //height: MediaQuery.of(context).size.height*0.2,
                                  child: SingleChildScrollView(
                                    child: Text(ageRestrictionContext, style: const TextStyle(fontSize: 12, color: Colors.black54),),
                                  ),
                                )],),
                            ),
                            Checkbox(
                                value: ageConsentGiven,
                                fillColor: MaterialStateProperty.all(Colors.white),
                                focusColor: const Color(0xe0d9e0e7),
                            
                                checkColor:const Color(0xe0d9e0e7),
                                onChanged: (newValue) {
                                  setState(()  {
                                    ageConsentGiven = !ageConsentGiven;
                                  });
                                }
                            ),
                    
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          children: [
                            const Expanded(
                                child: Text("위의 내용을 확인했으며 이에 모두 동의합니다.", style: TextStyle(color: Colors.black87),)),
                            Checkbox(
                              fillColor: MaterialStateProperty.all(Colors.white),
                                focusColor: const Color(0xe0d9e0e7),
                            
                                checkColor:const Color(0xe0d9e0e7),
                                value: consentGiven,
                                onChanged: (newValue) {
                                  setState(()  {
                                    consentGiven = !consentGiven;
                                  });
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    TextButton(
                        onPressed: ()async {
                          Navigator.pop(context);
                          await FirebaseAnalytics.instance.logEvent(
                              name: 'consent_registerpolicies_false',
                              parameters: {
                                "consent": false
                              }
                             );
                       showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                content: Text("이전 페이지로 돌아갑니다."),
                              ));
                          
                          Navigator.of(context).pop();

                        },
                        child: const Text("뒤로", style: TextStyle(fontSize: 18, color: Colors.white70),)),
                      const SizedBox(width: 10,),

                    TextButton(
                    
                        onPressed: () async{
                          Navigator.pop(context);
                          if(consentGiven && privacyConsentGiven){
                            await FirebaseFirestore
                                .instance
                                .collection("Users")
                                .doc(emailController.text.toString())
                                .set({
                              "privacyConsent": privacyConsentGiven,
                              "ageConsent": ageConsentGiven,
                              "usageConsent": consentGiven,
                            });
                            await signUserUp();


                            await FirebaseAnalytics.instance.logEvent(
                              name: 'consent_registerpolicies',
                              parameters: {
                                "consent":true

                              }
                             );
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  content: Text("이용자는 위의 약관에 동의하지 않을 권리가 있으며, 거부할 경우 회원가입이 불가합니다.", style: TextStyle(fontSize: 16, color: Colors.black87),),
                                ));
                          }
                        },
                        autofocus:true ,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(223, 0, 114, 228),),),
                        child: const Text("완료", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),)
                    ),
                  ],
                )
    ],
            );
          }
        );
      }
        );
      }


  //sign user in method
  Future<void> signUserUp() async {
    
    //show loading circle
    //try creating user
    try{
      if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty && consentGiven) {
        showDialog(context: context, 
        builder: (context) => Center(child: CircularProgressIndicator()));
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
        
          email: emailController.text,
          password: passwordController.text,);
        
        
       Navigator.pop(context);
      } else {
                Navigator.pop(context);
                showErrorMessage("이메일과 비밀번호를 입력하세요");
      }
    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder:(context) => AlertDialog(
            title: Text("$e"),
              )
      );
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
                //logo
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 80,
                    color: Color(0xffbbceee)
                ),

                const SizedBox(height: 20,),

                //welcome back
                const Text(
                  "처음인가요? 지금 본인 인증하고 멤버가 되세요",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                  ),
                ),

                const SizedBox(height: 20,),

                //user name text field
                MyTextField(
                  controller: emailController,
                  hintText: '학교 이메일',
                  obscureText: false,
                ),

                const SizedBox(height: 8,),

                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: '비밀번호 생성',
                  obscureText: true,
                ),
                const SizedBox(height: 8,),
              
                const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:48.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    overlayColor:MaterialStateProperty.all(const Color.fromARGB(255, 182, 203, 240)) ,
                    backgroundColor:MaterialStateProperty.all(const Color(0xffbbceee)),
                     ),
                     
                    onPressed: (){
                        showConsentDialog();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("다음", style: TextStyle(color: Colors.white, fontSize: 18),),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16)
                      ],
                    )),
              ),
               
                const SizedBox(height: 8,),
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Sign Up 완료 시, 로그아웃(우상단 아이콘 클릭) 후 재로그인 해주세요.",
                    style: TextStyle(
                        color: Colors.grey,),),
                ),

                 */
                const SizedBox(height: 20,),
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

    
            
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, top: 8, left:25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('멤버인가요',
                        style: TextStyle(color: Colors.grey, fontSize: 16),),

                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Row(
                          children: [
                            Text(
                              '  로그인하기',
                              style: TextStyle(color: Colors.blueAccent, fontSize: 16),),
                              Icon(Icons.lock_open_rounded, size: 14, color: Colors.blueAccent,)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  height: 50,
                  width: 320,
                  child: IframeView(
                    source: "https://ads-partners.coupang.com/widgets.html?id=748208&template=banner&trackingCode=AF7078222&subId=&width=320&height=50"),
                )
              
                
              ],
            ),
          ),
        ),
      ),
    );
  }  }

