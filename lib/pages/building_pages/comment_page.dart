import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../components/textfields/review_textfield.dart';

class CommentPage extends StatefulWidget {
  final String documentId;

  const CommentPage({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final CollectionReference _buildingsCollection =
      FirebaseFirestore.instance.collection("Buildings");
  final currentUser = FirebaseAuth.instance.currentUser!;
  String? address;
  final textControllerComment = TextEditingController();

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void postComment() async {
    _buildingsCollection.doc(widget.documentId);
    //only post if there is something in the textfield
    if (textControllerComment.text.isNotEmpty) {
      await _buildingsCollection
          .doc(widget.documentId)
          .collection("Building Comments")
          .add({
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
    return Scaffold(
      backgroundColor: const Color(0xe0d9e0e7),
      appBar: AppBar(
        /*actions: [
            IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=> ReadBuilding())
                );
                // Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20,)
              ,),
          ],*/

        title: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.add_home_sharp,
                color: Color(0xffC62828),
                size: 30,
              ),
              Text(
                '살아봄',
                style: TextStyle(
                    color: Color(0xffC62828),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
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
            const SizedBox(
              height: 15,
            ),
            const Center(

                //child: Text("환영합니다! $address 주민들과 소통하세요")
                ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: _buildingsCollection
                      .doc(widget.documentId.toString())
                      .collection("Building Comments")
                      .snapshots(),
                  builder: (context, Snapshot) {
                    return (Snapshot.connectionState == ConnectionState.waiting)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            itemCount: Snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot commentdocumentSnapshot =
                                  Snapshot.data!.docs[index];
                              // final commentText = commentdocumentSnapshot["BuildingCommentText"];
                              Timestamp commentTime = commentdocumentSnapshot[
                                  "BuildingCommentedTime"];
                              DateTime commentDateTime = DateTime.parse(
                                  commentTime.toDate().toString());
                              String commentFormattedDateTime =
                                  DateFormat('yy/MM/dd')
                                      .format(commentDateTime);

                              return Card(
                                margin: const EdgeInsets.all(12),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 1, left: 3, right: 3, bottom: 1),
                                  child: ListTile(
                                    title: Text(commentdocumentSnapshot[
                                            "BuildingCommentText"]
                                        .toString()),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(commentFormattedDateTime),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                    child: ReviewTextField(
                  mylabel: const Text("나도 소통하기"),
                  myicon: const Icon(Icons.rate_review_rounded, size: 14),
                  controller: textControllerComment,
                  messagehintText: "메시지를 입력하세요",
                  obscureText: false,
                )),
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  width: 35,
                  margin: const EdgeInsets.only(right: 13),
                  child: IconButton(
                    onPressed: postComment,
                    icon: const Icon(
                      Icons.arrow_upward_rounded,
                      size: 35,
                      color: Color(0xffC62828),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0.5),
              child: Text(
                "${currentUser.email!}님",
                style: TextStyle(fontSize: 8, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
