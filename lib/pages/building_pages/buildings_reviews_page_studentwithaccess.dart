import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/components/building_review_post/building_review_post.dart';
import 'package:lespace/pages/agency_pages/agency_review_page.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import '../../components/text/text_style_1.dart';
import 'post_building_review.dart';
import '../info_pages/my_page.dart';
import 'package:intl/intl.dart';
import '../../read data/Buildings.dart';

class BuildingsReviewPageStudentWithAccess extends StatefulWidget {
  const BuildingsReviewPageStudentWithAccess({super.key});


  @override
  State<BuildingsReviewPageStudentWithAccess> createState() => _BuildingsReviewPageStudentWithAccessState();
}

class _BuildingsReviewPageStudentWithAccessState extends State<BuildingsReviewPageStudentWithAccess>{


  //grab user
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts = FirebaseFirestore.instance.collection("User Posts");
  
  
  //Building
  final textControllerMessage = TextEditingController();

  final textControllerLocation = TextEditingController();
  String location ="";

  final textControllerGasFee = TextEditingController();
  final textControllerGasUsage = TextEditingController();

  final textControllerElectricFee = TextEditingController();
  final textControllerElectricUsage = TextEditingController();

  double bugManagementValue = 0;
  String bugManagementLabel = "관리 없음";

  String recommendationLabel = "비추천";
  double recommendationValue = 0;

  String leakageLabel = "없음";
  double leakageValue = 0;

  //Agency
  final textControllerAgency = TextEditingController();
  //final textControllerAgencyReview = TextEditingController();
  //Access
  bool userHasAccess = true;
  bool userHasStudentAccess = true;

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

  //post message method: put data into the firestore
  void postMessage()async{
    //only post if there is something in the textfield
    if (textControllerMessage.text.isNotEmpty){
      _userPosts.add({
        'Likes': [],
      });
       await FirebaseFirestore.instance.collection("Users").add({
          'UserEmail': currentUser.email,
          'Reviewed': true}, );
    }
    //clear the textfield
    setState(() {
      textControllerMessage.clear();
      textControllerLocation.clear();
    });
  }

  @override
  void initState(){
    super.initState();   
    checkUserAccess();
    checkUserDocExists(currentUser.email.toString());
     FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_studentaccesspage1',
      parameters: {
        'firebase_screen': "StudentAccessPage1",
        'firebase_screen_class': "StudentAccessPage1"
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

Future<void> checkUserAccess()async{
    final userPostsQuery = _userPosts.where("UserEmail", isEqualTo: currentUser.email);
    final querySnapshot = await userPostsQuery.get();
    //check if the user has access
    if(querySnapshot.docs.isNotEmpty){
      setState(() {
        userHasAccess = true;
      });
    }
    else {
      setState(() {
        userHasAccess = false;
      });
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
        floatingActionButton:
          FloatingActionButton(
            backgroundColor: const Color(0xff8cb5e0),
            onPressed: (){
               Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const  PostBuildingReview())
              );
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_home_rounded,
            size: 28, color: Colors.white70,),
            Text(
              "나도 공유", 
              style: TextStyle(fontSize: 8, color: Colors.white70),
              )
            ],
        )),

        floatingActionButtonLocation: 
          FloatingActionButtonLocation.centerFloat,
        body: _buildContentWithAccess()
      ),
    );
    }

    Widget _buildContentWithAccess(){
          if (userHasAccess){
            return Center(
          child: Padding(
          padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:12.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),),
                    color: Colors.white,
                  child: Padding(
                    padding:  const EdgeInsets.symmetric(horizontal:8),
                    child: TextField(
                      style: const TextStyle(height: 1, fontSize: 15),
                      decoration:  const InputDecoration(
                        suffixIcon: Icon(Icons.search_rounded, size: 14,color: Colors.black87, ),
                        hintText: "주소를 검색하세요", hintStyle: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w100),
                        isDense: true,
                        constraints: BoxConstraints(maxHeight:20),
                        border: InputBorder.none,

                        ),
                      textAlign: TextAlign.end,
                      textAlignVertical: TextAlignVertical.center,
                      cursorOpacityAnimates: true,
                      showCursor: true,

                      cursorColor: Colors.black54,
                      cursorRadius: const Radius.circular(8),
                      cursorHeight: 12,
                      onChanged: (val){
                        setState(() {
                          location =val;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8,),
               StreamBuilder<QuerySnapshot>(
                stream: (location != "")
                    ? FirebaseFirestore.instance
                    .collection("User Posts")
                    .where("Location", isGreaterThanOrEqualTo: location)
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot){
                   if  (snapshot.connectionState == ConnectionState.waiting){
                     return const Center(
                         child: CircularProgressIndicator(),
                     );
                   }
                   if (snapshot.hasError){
                     return Center(
                       child: TextStyle1(
                         text: "Error: ${snapshot.error}"
                       ),
                     );
                   }
                   final docs = snapshot.data?.docs;

                   if(docs == null || docs.isEmpty ){
                     return const Center(
                       child: Text("No data available"),
                     );
                   }
                   return Expanded(
                     child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index){
                        final data = docs[index];
                        String locationLower = data['Location'].toLowerCase();
                        String searchLower = location.toLowerCase();

                        Timestamp mytimestamp = data['TimeStamp'];
                        DateTime myDateTime = DateTime.parse(mytimestamp.toDate().toString());
                        String formattedDateTime = DateFormat('yy/MM/dd').format(myDateTime);

                        if (locationLower.contains(searchLower)){
                          return BuildingReviewPost(
                            //agencyReveiw: data.data().toString().contains("AgencyReview") ? data["AgencyReview"] : null,
                            //realEstateName: data.data().toString().contains("Agency") ? data["Agency"] : null,
                            bugAppear: data.data().toString().contains("BugAppear") ? data["BugAppear"] : null,
                            messageGood: data.data().toString().contains("Good") ? data["Good"] : null,
                              messageHard: data.data().toString().contains("Hard") ? data["Hard"] : null,
                              sound: data.data().toString().contains("Sound") ? List<String>.from(data["Sound"] ?? []): [],
                              message: data.data().toString().contains("Message") ? data["Message"] : null,
                              location: data['Location'],
                              bugManagement: data.data().toString().contains("BugManagement") ? data["BugManagement"] : null,
                              leakage: data.data().toString().contains("Leakage") ? data["Leakage"] : null,
                              //electricFeePerUnit: data.data().toString().contains("ElectricFeePerUnit") ? data["ElectricFeePerUnit"] : null,
                              //gasFeePerUnit: data.data().toString().contains("GasFeePerUnit") ? data["GasFeePerUnit"]: null,
                              recommendation: data.data().toString().contains("Recommendation") ? data["Recommendation"]: null,

                              postId: data.id,
                              likes: List<String>.from(data['Likes'] ?? []),
                              timestamp: formattedDateTime);
                          //user: post['UserEmail'],

                        } else {
                          return Container();
                        }

                      },
                  ),
                   );
                },
              ),
              const SizedBox(height: 16,),
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
      ) ;
      } else{
        return const PostBuildingReview();
      }
      }
      }