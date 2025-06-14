import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/components/building_review_post/building_review_post.dart';
import 'package:lespace/sungshin/pages/add_review.dart';
import '../../components/text/text_style_1.dart';
import '../../pages/info_pages/my_page.dart';
import 'package:intl/intl.dart';

class SungshinReviewPosts extends StatefulWidget {
  const SungshinReviewPosts({super.key});


  @override
  State<SungshinReviewPosts> createState() => _SungshinReviewPostsState();
}

class _SungshinReviewPostsState extends State<SungshinReviewPosts>{


  //grab user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts = FirebaseFirestore.instance.collection("Sungshin");
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
  final textControllerAgencyReview = TextEditingController();
  //Access
  bool userHasAccess = false;

  //Sign out method
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }

  //function to check if the user has acccess
  Future<void> checkUserAccess()async{
    final userPostsQuery = _userPosts.where("UserEmail", isEqualTo: currentUser.email );
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
    //set userHasAccess to true or false accrodingly
  }


  //post message method: put data into the firestore
  void postMessage(){
    //only post if there is something in the textfield
    if (textControllerMessage.text.isNotEmpty){
      _userPosts.add({
        'Likes': [],
      });
      FirebaseFirestore.instance.collection("Users").add({
        'UserEmail': currentUser.email,
        'Reviewed': true}, );
    }
    //clear the textfield
    setState(() {
      textControllerMessage.clear();
      textControllerLocation.clear();
      textControllerAgency.clear();
    });
  }

  @override
  void initState(){
    super.initState();
    checkUserAccess();
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
                  const DrawerHeader(
                    child: Center(
                    ),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff8cb5e0),
            onPressed: (){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SungshinAddReview())
              );
            },
            //()=>_add(),
            child: const Icon(Icons.add_home_rounded,
              size: 28,),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: userHasAccess ?
          _buildContentWithAccess()
              : _buildContentWithoutAccess()
      ),
    );
  }

  Widget _buildContentWithAccess(){
    return currentUser.email.toString().contains("@sungshin.ac.kr")
        ? Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: "위치 검색",
                  ),
                  onChanged: (val){
                    setState(() {
                      location =val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12,),
            StreamBuilder<QuerySnapshot>(
              stream: (location != "")
                  ? _userPosts
                  .where("Location", isGreaterThanOrEqualTo: location)
                  .snapshots()
                  : _userPosts
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
                          //agencyReveiw: data.data().toString().contains("AgencyReview") ? data["AgencyReview"]: null,
                            //realEstateName: data.data().toString().contains("Agency") ? data["Agency"] : null,
                          sound: List<String>.from(data['Sound'] ?? []),
                          messageGood: data.data().toString().contains("Good") ? data["Good"] : null,
                            messageHard: data.data().toString().contains("Hard") ? data["Hard"] : null,
                            message: data.data().toString().contains("Message") ? data["Message"] : null,
                            location: data['Location'],
                            bugManagement: data.data().toString().contains("BugManagement") ? data["BugManagement"] : null,
                            leakage: data.data().toString().contains("Leakage") ? data["Leakage"] : null,
                            //electricFeePerUnit: data.data().toString().contains("ElectricFeePerUnit") ? data["ElectricFeePerUnit"] : null,
                            //gasFeePerUnit: data.data().toString().contains("GasFeePerUnit") ? data["GasFeePerUnit"]: null,
                            recommendation: data.data().toString().contains("Recommendation") ? data["Recommendation"]: null,
                            bugAppear: data.data().toString().contains("BugAppear") ? data["BugAppear"] : null,

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
    ) : const Center(
      child: TextStyle1(
          text: "현재 대학가 리뷰는 학교 학생들에게만 공개됩니다. "
              "대학가 및 기타 추가 요청 : 2dkroom@gmail.com"),
    );
  }

  Widget _buildContentWithoutAccess(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
        child: Column(
          children: [
            SizedBox(height: 56,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: "위치 검색",
                  ),
                  onChanged: (val){
                    setState(() {
                      location =val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12,),
            Expanded(
              child:StreamBuilder<QuerySnapshot>(
                stream: (location != "")
                    ? _userPosts
                    .where("Location", isGreaterThanOrEqualTo: location)
                    .snapshots()
                    : _userPosts
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot){
                  return (snapshot.connectionState ==
                      ConnectionState.waiting)
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      :ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index){
                      final data = snapshot.data!.docs[index];

                      String locationLower = data['Location'].toLowerCase();
                      String searchLower = location.toLowerCase();

                      Timestamp mytimestamp = data['TimeStamp'];
                      DateTime myDateTime = DateTime.parse(mytimestamp.toDate().toString());
                      String formattedDateTime = DateFormat('yy/MM/dd').format(myDateTime);


                      if (locationLower.contains(searchLower)){
                        return BuildingReviewPost(
                          messageHard:null ,
                          //agencyReveiw: null,
                            bugManagement: null,
                            bugAppear: null,
                            leakage: null,
                            messageGood: null,
                            //realEstateName: null,
                            recommendation: null,
                            sound: null,
                            message: "단 하나의 후기를 작성하고, 모든 내용을 보세요!",
                            location: data['Location'],
                            postId: data.id,
                            likes: List<String>.from(data['Likes'] ?? []),
                            timestamp: formattedDateTime);
                        //user: post['UserEmail'],

                      } else {
                        return Container();
                      }
                    },
                  );
                },
              ),
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