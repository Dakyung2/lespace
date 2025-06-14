
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lespace/pages/auth/login_or_register_page.dart';
//import 'buildings_reviews_page.dart';
import '../../components/textfields/review_textfield.dart';

class ReviewCommunicationRoom extends StatefulWidget {
  final String address;
  const ReviewCommunicationRoom({
    Key? key,
    required this.address
  }) : super(key:key);

  @override
  State<ReviewCommunicationRoom> createState() => _ReviewCommunicationRoomState();
}

class _ReviewCommunicationRoomState extends State<ReviewCommunicationRoom> {
  //UserPosts>doc>Field:Address
  //pass "Address" field value of current post-> Find the same address inside the "Buildings" collection->Enter the Room
  //If there is no same collection called "Buildings", make a new one
  final CollectionReference _buildingsCollection = FirebaseFirestore.instance.collection("Buildings");
  //String? userStatus;
  final User currentUser = FirebaseAuth.instance.currentUser!;
  String? address;
  final textControllerComment = TextEditingController();
  bool currentUserIncluded = false ;
  late String? userStatus;




  @override
  void initState(){
    super.initState();
    _getOrCreateDocument();
    _getAllDocs().then((isCurrentUserIncluded){
      setState(() {
        if(isCurrentUserIncluded){
          userStatus = "경험자";
        } else{
          userStatus = "";
        }
      });

    });
  }
  Future<void> _getOrCreateDocument()async{
    //Ref to collection
    CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection("Buildings");
    //check if a document exists
    DocumentReference<Map<String, dynamic>> documentRef =
    collection.doc(widget.address);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentRef.get();
    //If exist, return. Or else, create new doc
    if(!documentSnapshot.exists){
      //create new doc
      await collection.doc(widget.address).set({
        "Address": widget.address
      });//return newDoc;
    }
  }

  Future <bool>_getAllDocs()async{
    //Ref to collection
    CollectionReference<Map<String, dynamic>> collection =
    FirebaseFirestore.instance.collection("User Posts");

    //get current user's email
     final String? currentUserEmail = currentUser.email;
    //check if a document exists
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await collection.where('Location', isEqualTo: widget.address).get();
    //If exist, return. Or else, create new doc
   bool isCurrentUserIncluded = false;

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs){
      var docData= document.data();
      //check if currentUser email is included in the doc
      isCurrentUserIncluded = docData["UserEmail"]?.contains(currentUserEmail) ?? false;
      if(isCurrentUserIncluded){
        break;
      }
    }
    return isCurrentUserIncluded;
    //return  bool currentUserIncluded;
  }



  void signUserOut(){
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => LoginOrRegisterPage()));
  }

  void postComment() async {
    _buildingsCollection.doc(widget.address);
    //only post if there is something in the textfield
    if (textControllerComment.text.isNotEmpty){
      await _buildingsCollection.doc(widget.address).collection("Building Comments")
          .add({
        "UserStatus": userStatus.toString(),
        'BuildingCommentedBy': currentUser.email,
        'BuildingCommentText': textControllerComment.text,
        'BuildingCommentedTime': Timestamp.now(),
        'Likes': [],
      });
    }
    //clear the textfield
    setState(() {
      textControllerComment.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xe0d9e0e7),
      appBar: AppBar(
        actions: [
            IconButton(
              onPressed: signUserOut,
              icon: Icon(Icons.logout_rounded, size: 12,)
              ,),
          ],

        title: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.add_home_sharp, color:Color(0xffC62828), size: 30,),
              //Text('살아봄', style: TextStyle(color: Color(0xffC62828), fontSize: 14, fontWeight: FontWeight.w500),),
            ],
          ),
        ),
        backgroundColor: const Color(0xffc2d3e5),
      ),
      /*drawer: Drawer(
          child: Container(
            color: Colors.white70,
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Center(
                      child: Text(
                        "살 아 봄",
                        style: TextStyle(fontSize: 35),)
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.add_home_rounded),
                  title: Text(
                    "소중한 후기들",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> BuildingsReviewPage())
                    );
                    // Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),

         */
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15,),
            Center(
              child: Text(" ${widget.address} 경험자분들과의 Q&A")
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder(
                  stream:
                  _buildingsCollection
                      .doc(widget.address)
                      .collection("Building Comments")
                      .snapshots(),
                  builder: (context, Snapshot){
                    if (Snapshot.connectionState ==
                        ConnectionState.waiting){
                     return const Center(child: CircularProgressIndicator(),);
                    }
                    if(Snapshot.hasData && Snapshot.data!.docs.isNotEmpty){
                      return ListView.builder(
                          itemCount: Snapshot.data!.docs.length,
                          itemBuilder: (context, index){
                            final DocumentSnapshot commentdocumentSnapshot = Snapshot.data!.docs[index];
                            // final commentText = commentdocumentSnapshot["BuildingCommentText"];
                            Timestamp commentTime = commentdocumentSnapshot["BuildingCommentedTime"];
                            DateTime commentDateTime = DateTime.parse(commentTime.toDate().toString());
                            String commentFormattedDateTime = DateFormat('yy/MM/dd').format(commentDateTime);
                            return Card(
                              margin: const EdgeInsets.all(12),
                              child:
                              Padding(
                                padding: const EdgeInsets.only(top: 1, left: 3, right: 3, bottom: 1),
                                child: ListTile(
                                  title: Text(commentdocumentSnapshot["BuildingCommentText"].toString()),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if(commentdocumentSnapshot["UserStatus"] != null )
                                        Text(commentdocumentSnapshot["UserStatus"].toString(), style: const TextStyle(color: Colors.blueAccent),),
                                      const SizedBox(width: 8,),
                                      Text(commentTime != null ? commentFormattedDateTime : " "),
                                    ],
                                  ),

                                ),
                              ),
                            );
                          }
                      );
                    }else{
                      return const Center(child: Text("질문을 보내보세요"),);
                    }

                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  children: [
                    Expanded(
                        child:
                        ReviewTextField(
                          mylabel: const Text("나도 소통하기"),
                          myicon: const Icon(Icons.rate_review_rounded, size: 14),
                          controller: textControllerComment,
                          messagehintText: "메시지를 입력하세요",
                          obscureText: false,
                        )
                    ),
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      width: 35,
                      margin: const EdgeInsets.only(right: 13),
                      child: IconButton(
                        onPressed: postComment,
                        icon: const Icon(Icons.arrow_upward_rounded, size: 35,color:Color(0xffC62828),),
                      ),
                    ),
                  ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0.5),
              child: Text(
                "${currentUser.email}님",
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
