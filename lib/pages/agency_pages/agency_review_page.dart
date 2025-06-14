import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page.dart';
import '../../components/text/text_style_1.dart';
import '../info_pages/my_page.dart';
import 'package:intl/intl.dart';
import 'package:lespace/pages/agency_pages/agency_review_post.dart';
import '../../read data/Buildings.dart';
import '../building_pages/post_building_review.dart';

class AgencyReviewPage extends StatefulWidget {
  const AgencyReviewPage({super.key});


  @override
  State<AgencyReviewPage> createState() => _AgencyReviewPageState();
}

class _AgencyReviewPageState extends State<AgencyReviewPage>{


  //grab user
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _agencyPosts = FirebaseFirestore.instance.collection("Agency");
  //Content
  final textControllerMessage = TextEditingController();
  final textControllerLocation = TextEditingController();
  String location ="";

  //Agency
  final textControllerAgency = TextEditingController();
  final textControllerAgencyReview = TextEditingController();
  //Access
  bool userHasAccess = false;
  bool userHasStudentAccess = false;


  //Sign out method
  void signUserOut() async {
     await FirebaseAuth.instance.signOut();
     Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => const LoginOrRegisterPage()));
     
  }

  //function to check if the user has acccess
  Future<void> checkUserAccess()async{
    final userPostsQuery =  FirebaseFirestore.instance.collection("User Posts").where("UserEmail", isEqualTo: currentUser.email);
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

  Future<void> checkUserIsStudent()async{
    if(currentUser.email.toString().endsWith("@korea.ac.kr")){
      setState(() {
        userHasStudentAccess = true;
      });
    }else{
      setState(() {
        userHasStudentAccess = false;
      });
    }

  }

  //post message method: put data into the firestore
  void postMessage(){
    //only post if there is something in the textfield
    if (textControllerMessage.text.isNotEmpty){
      _agencyPosts.add({
        'Likes': [],
      });
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
    checkUserIsStudent();
    checkUserAccess();
      FirebaseAnalytics.instance.logEvent(
      name: 'screen_view_agencyreviewpage1',
      parameters: {
        'firebase_screen': "AgencyReviewPage1",
        'firebase_screen_class': "AgencyReviewPage1"
      });

  }


  @override
  Widget build(BuildContext context){
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
                  //Icon(Icons.add_home_sharp, color:Color(0xffC62828), size: 30,),
                  //Text('살아봄', style: TextStyle(color: Color(0xffC62828), fontSize: 14, fontWeight: FontWeight.w500),),
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
                  if(userHasStudentAccess)
                  ListTile(
                    leading: const Icon(Icons.add_home_rounded),
                    title: const Text(
                      "소중한 후기 보기",
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> const BuildingsReviewPage())
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.comment_rounded),
                    title: const Text(
                      "건물 주민과 소통하기",
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=> const ReadBuilding())
                      );
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
              //if user has student access
          userHasStudentAccess?
          FloatingActionButton(
            backgroundColor: const Color(0xff8cb5e0),
            onPressed: (){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PostBuildingReview())
              );
            },
            //()=>_add(),
            child: const Icon(Icons.add_home_rounded,
              size: 28,),
          )
              : Container(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body:
          _buildContentWithAccess()
      ),
    );
  }

  Widget _buildContentWithAccess(){
   return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
        child: Column(
          children: [
            /*SizedBox(
              height: 56,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: "검색",
                  ),
                  onChanged: (val){
                    setState(() {
                      location =val;
                    });
                  },
                ),
              ),
            ),*/
            const SizedBox(height: 12,),
            StreamBuilder<QuerySnapshot>(
              stream: (location != "")
                  ? FirebaseFirestore.instance
                  .collection("Agency")
                  //.where("Location", isGreaterThanOrEqualTo: location)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection("Agency")
                  //.orderBy("TimeStamp", descending: true)
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
                      //String locationLower = data['Location'].toLowerCase();
                      //String searchLower = location.toLowerCase();

                        Timestamp? mytimestamp = data['TimeStamp'];
                        DateTime? myDateTime = DateTime.parse(mytimestamp!.toDate().toString());
                        final String formattedDateTime = DateFormat('yy/MM/dd').format(myDateTime);


                      if (data.exists
                      //locationLower.contains(searchLower)
                      ){
                        return AgencyReviewPost(
                            agencyReveiw: data.data().toString().contains("AgencyReview") ? data["AgencyReview"] : null,
                            realEstateName: data.data().toString().contains("Agency") ? data["Agency"] : null,
                            location: data.data().toString().contains("Location")? data['Location'] : null,
                            postId: data.id,
                            likes: data.data().toString().contains("Likes") ? List<String>.from(data['Likes'] ?? []) : [],
                            timestamp: data.data().toString().contains("TimeStamp") ? formattedDateTime : null);
                        //user: post['UserEmail'],

                      } else {
                        return Container();
                      }

                    },
                  ),
                );
              },
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
    ) ;

  }  }







