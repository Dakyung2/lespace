import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page.dart';
import '../../read data/Buildings.dart';
import '../../components/building_review_post/building_review_post.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int? numberOfDocs;
  final User user = FirebaseAuth.instance.currentUser!;
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection("User Posts");

  @override
  void initState()  {
    super.initState();
      countReviews();
      FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_mypage',
      parameters: {
        'firebase_screen': "MyPage",
        'firebase_screen_class': "MyPage"
      });
  }


  void countReviews() async{
    QuerySnapshot querySnapshot = await
    postsCollection
        .where("UserEmail", isEqualTo: user.email)
        .get();
    setState(() {
      numberOfDocs = querySnapshot.docs.length;
    });
  }
  void signUserOut()async{
   await  FirebaseAuth.instance.signOut();
         Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => const LoginOrRegisterPage()));

  }




  @override
  Widget build(BuildContext context) {
    String? userEmail = user.email;
    
    return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xe0d9e0e7),
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: const Icon(Icons.logout, size: 20,)
                ,),
            ],
            title: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add_home_sharp, color:Color(0xffC62828), size: 30,),
                  Text('살아봄', style: TextStyle(color: Color(0xffC62828), fontSize: 14, fontWeight: FontWeight.w500),),
                ],
              ),
            ),
            backgroundColor: const Color(0xffc2d3e5),
          ),
          drawer: Drawer(
            child: Container(
              color: Colors.white70,
              child: ListView(
                children: [
                  /*
                  const DrawerHeader(
                    child: Center(
                        child: Text(
                          "살 아 봄",// "살 아 봄",
                          style: TextStyle(fontSize: 35),)
                    ),
                  ),
                  */
                  ListTile(
                    leading: const Icon(Icons.add_home_rounded),
                    title: const Text(
                      "후기 모음",
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const BuildingsReviewPage())
                      );
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


                ],
              ),
            ),
          ),

          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
              child: Column(
                children: [
                  const SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white70),
                                child: const Icon(Icons.person, size: 80,),
                              ),
                              Text("$userEmail 님", style: const TextStyle(fontSize: 12),),
                            ],
                          ),

                          const SizedBox(width: 10,),
                          Text("경험치 ${numberOfDocs.toString()}년", style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  const Text("나의 경험들", style: TextStyle(fontSize: 18),),
                  const SizedBox(height: 15,),
                  Expanded(
                    child: StreamBuilder <QuerySnapshot>(
                        stream: postsCollection
                            .where("UserEmail", isEqualTo: user.email)
                            //.orderBy("TimeStamp")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData){
                            return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index){
                                  final data = snapshot.data!.docs[index];

                                  Timestamp mytimestamp = data['TimeStamp'];
                                  DateTime myDateTime = DateTime.parse(mytimestamp.toDate().toString());
                                  String formattedDateTime = DateFormat('yy/MM/dd').format(myDateTime);
                                    return BuildingReviewPost(
                                       // agencyReveiw: null,
                                        //realEstateName: data.data().toString().contains("Agency") ? data["Agency"] : null,
                                        bugAppear: null,
                                        messageGood: data.data().toString().contains("Good") ? data["Good"] : null,
                                        messageHard: data.data().toString().contains("Hard") ? data["Hard"] : null,
                                        sound: null,
                                        message: data.data().toString().contains("Message") ? data["Message"] : null,
                                        location: data['Location'],
                                        bugManagement: null,
                                        leakage:  null,
                                        //electricFeePerUnit: data.data().toString().contains("ElectricFeePerUnit") ? data["ElectricFeePerUnit"] : null,
                                        //gasFeePerUnit: data.data().toString().contains("GasFeePerUnit") ? data["GasFeePerUnit"]: null,
                                        recommendation: data.data().toString().contains("Recommendation") ? data["Recommendation"]: null,
                                        postId: data.id,
                                        likes: List<String>.from(data['Likes'] ?? []),
                                        timestamp: formattedDateTime);

                                },
                            );
                          } else if(snapshot.hasError){
                            return Text("Error: ${snapshot.error}");
                          } else{
                            return Container();
                          }
                        },
                    ),
                  ),
                  const SizedBox(height: 25,),
                  //logged in as
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.5),
                    child: Text(
                      "${user.email}님",
                      style: TextStyle(
                          fontSize: 8, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

