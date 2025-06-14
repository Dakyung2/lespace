import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:lespace/pages/agency_pages/agency_review_page.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import '../info_pages/my_page.dart';
import '../../read data/Buildings.dart';

class BuildingsReviewPageNotStudent extends StatefulWidget {
  const BuildingsReviewPageNotStudent({super.key});

  @override
  State<BuildingsReviewPageNotStudent> createState() => _BuildingsReviewPageNotStudentState();
}

class _BuildingsReviewPageNotStudentState extends State<BuildingsReviewPageNotStudent>{


  //grab user
  final User currentUser = FirebaseAuth.instance.currentUser!;
  
  
  //Agency
  final textControllerAgency = TextEditingController();
  //final textControllerAgencyReview = TextEditingController();
  //Access
  bool userHasAccess = false;
  bool userHasStudentAccess = false;

  bool consentGiven = false;
  bool privacyConsentGiven = false;
  bool usageConsentGiven = false;
  bool ageConsentGiven = false;

  String usagePolicyContext = "";
  String privacyPolicyContext = "";
  String privacyPolicyConsentContext = "";
  String ageRestrictionContext = "";


  //Sign out method
  void signUserOut()async{
     await FirebaseAuth.instance.signOut();
     Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => const LoginOrRegisterPage()));
  }

  @override
  void initState(){
    super.initState();
    checkUserDocExists(currentUser.email.toString());
     FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_notstudentpage1',
      parameters: {
        'firebase_screen': "NotStudentPage1",
        'firebase_screen_class': "NotStudentPage1"
      });
  }

  Future<void> fetchUsagePolicy()async{
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("servicePolicy")
          .get();

      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      String context = data["Context"];
      setState(() {
        usagePolicyContext = context;
      });
    }catch(error){
    }
  }

  Future<void> fetchPrivacyPolicy()async{
    try{
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
    }catch(error){
    }
  }

  Future<void> fetchPrivacyPolicyConsent()async{
    try{
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
    }catch(error){
    }
  }

  Future<void> fetchAgeRestrictionContext()async{
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore
          .instance
          .collection("Legal")
          .doc("ageRestriction")
          .get();

      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      String context = data["Context"];
      setState(() {
        ageRestrictionContext = context;
      });
    }catch(error){
    }
  }


  Future<void> checkUserDocExists(String userEmail) async{
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userEmail).get();
      if(!documentSnapshot.exists){
         await Future.wait([
           fetchAgeRestrictionContext(),
          fetchUsagePolicy(),
          fetchPrivacyPolicy(),
          fetchPrivacyPolicyConsent(),]);

        showConsentDialog();
      }
    }catch(e){
    }
  }

  Future<void>showConsentDialog() async {
    showDialog(
      barrierColor: const Color.fromARGB(146, 255, 255, 255),
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("개인정보 수집 및 이용, 서비스이용약관 동의 안내", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  contentPadding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
                  content:
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        const SizedBox(height: 5,),
                        const Text("이용자의 개인정보를 존중하기 위해 개인정보 수집 및 이용 동의서, 개인정보처리방침, 서비스이용약관을 개정했습니다."
                            "\n아래의 개인정보 수집 및 이용 동의서, 개인정보처리방침, 서비스이용약관, 만14세 이상 확인 동의서를 모두 확인하신 후, 동의 및 미동의 의사를 밝혀주세요", style: TextStyle(fontSize: 14),),
                        const SizedBox(height: 8,),
                        const Text("*모든 이용자는 개인정보 수집 및 이용, 서비스이용약관, 개인정보처리방침에 동의하지 않을 권리가 있으며, 거부할 경우 서비스 이용이 제한됩니다.",style: TextStyle(fontSize: 14), ),
                        const Text("*개정약관의 적용일자(2024.01.01)까지 회원이 거부 의사를 표시하지 아니할 경우 약관의 개정에 동의한 것으로 간주합니다.", style: TextStyle(fontSize: 14),),
                        const SizedBox(height: 10,),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                                value: usageConsentGiven,
                                onChanged: (newValue) {
                                  setState(()  {
                                    usageConsentGiven = !usageConsentGiven;
                                  });
                                }
                            ),
                            const SizedBox(width: 2,),
                            Expanded(
                              child: ExpansionTile(

                                title: const Text("서비스이용약관 동의(필수)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                    ),
                                    height: MediaQuery.of(context).size.height*0.15,

                                    child: SingleChildScrollView(
                                      child: Text(usagePolicyContext, style: const TextStyle(fontSize: 12),),
                                    ),
                                  )
                                ],),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            Checkbox(
                                value: privacyConsentGiven,
                                onChanged: (newValue) {
                                  setState(()  {
                                    privacyConsentGiven = !privacyConsentGiven;
                                  });
                                }
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: ExpansionTile(

                                title: const Text("개인정보 수집 및 이용 동의(필수)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                children: [SizedBox(
                                  height: MediaQuery.of(context).size.height*0.15,

                                  child: SingleChildScrollView(
                                    child: Text(privacyPolicyConsentContext, style: const TextStyle(fontSize: 12),),
                                  ),
                                )],),

                            ),
                          ],
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ExpansionTile(
                                title: const Text("개인정보처리방침", style: TextStyle(fontSize: 14),),
                                children: [SizedBox(
                                  height: MediaQuery.of(context).size.height*0.15,

                                  child: SingleChildScrollView(
                                    child: Text(privacyPolicyContext, style: const TextStyle(fontSize: 12),),
                                  ),
                                )],),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Checkbox(
                                value: ageConsentGiven,
                                onChanged: (newValue) {
                                  setState(()  {
                                    ageConsentGiven = !ageConsentGiven;
                                  });
                                }
                            ),
                            const SizedBox(width: 5,),

                            Expanded(
                              child: ExpansionTile(
                                title: const Text("만 14세 이상입니다", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                children: [SizedBox(
                                  height: MediaQuery.of(context).size.height*0.04,
                                  child: SingleChildScrollView(
                                    child: Text(ageRestrictionContext, style: const TextStyle(fontSize: 12),),
                                  ),
                                )],),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("위의 모든 내용을 확인했으며, \n이에 모두 동의합니다", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                              const SizedBox(width: 5,),
                              Checkbox(
                                  value: consentGiven,
                                  onChanged: (newValue) {
                                    setState(()  {
                                      consentGiven = !consentGiven;
                                    });
                                  }
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  actions: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: ()async {
                              //Navigator.pop(context);
                              await FirebaseAuth.instance.currentUser!.delete();
                              await FirebaseAuth.instance.signOut();
                              showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    content: Text("탈퇴 완료. 다음에 뵙겠습니다"),
                                  ));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()));

                              Navigator.pop(context);
                            },
                            child: const Text("비동의 및 회원탈퇴")),
                        TextButton(
                            onPressed: () async{
                              Navigator.pop(context);
                              if(consentGiven && privacyConsentGiven){
                                await FirebaseFirestore
                                    .instance
                                    .collection("Users")
                                    .doc(currentUser.email)
                                    .set({
                                  "privacyConsent": privacyConsentGiven,
                                  "ageConsent": ageConsentGiven,
                                  "usageConsent": consentGiven,
                                });
                                //Sign out
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                      content: Text("이용자는 위의 약관에 동의하지 않을 권리가 있으며, 거부할 경우 서비스 이용이 제한됩니다."),
                                    ));
                              }
                            },
                            child: const Text("동의")
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

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xe0d9e0e7),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: AppBar(
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: const Icon(Icons.logout,)
                ,),
            ],
            backgroundColor: const Color(0xffc2d3e5),
            iconTheme: const IconThemeData(size:18, color: Colors.white70 ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white70,
            child: ListView(
              children: [
                const DrawerHeader(
                    child: Center(

                    ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_open_outlined),
                  title: const Text(
                    "공개 부동산 후기 보기",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=>  const AgencyReviewPage())
                    );
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_home_rounded),
                  title: const Text(
                      "건물 주민과 소통하기",
                  style: TextStyle(fontSize: 15),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)=> const ReadBuilding())
                    );
                   // Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text(
                    "내 페이지",
                    style: TextStyle(fontSize: 15),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MyPage())
                    );
                  },
                ),
              ],
            ),
          ),
        ),

      
        body: _buildContentWithoutAccess()
      ),
    );
    }

  

    Widget _buildContentWithoutAccess(){
      return Padding(
        padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("자취방 후기는 인증된 학교 학생에게만 공개됩니다", style: TextStyle(fontSize: 15, color: Colors.black45),),
          const SizedBox(height: 10,),
          const Text("우리 대학가도 자취방 후기가 필요해요!", style: TextStyle(fontSize: 18, color: Colors.black87),),
          const Text("추가 방법:", style: TextStyle(fontSize: 15, color: Colors.black87),),
          const Text("1. https://lespaceapp.blogspot.com/  - 메뉴 아이콘 - 이메일: 대학 이메일", style: TextStyle(fontSize: 18, color: Colors.black),),
          const Text("2.  2dkroom@gmail.com - 요청 이메일 작성하기",style: TextStyle(fontSize: 18, color: Colors.black)  ),
          const SizedBox(height: 20,),
          ElevatedButton(
              onPressed: ()async{
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=>  const AgencyReviewPage())
                );
                 Navigator.of(context).pop();
              },
            style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(const Color(0xffc2d3e5))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("공개된 부동산 후기 보러가기", style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent),),
                    Icon(Icons.lock_open_outlined, size: 18,), ],
                ),
              )
          ),

          const SizedBox(height: 25,),
              //logged in as
              Padding(
                padding: const EdgeInsets.only(bottom: 0.5),
                child: Text(
                  "${currentUser.email!}님",
                  style: TextStyle(
                      fontSize: 8, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      );

    }
  }

