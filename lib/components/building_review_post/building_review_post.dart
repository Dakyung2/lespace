import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lespace/components/building_review_post/building_review_field_card.dart';
import 'package:lespace/components/text/text_style_1.dart';
import 'package:lespace/pages/review_communication_room.dart';

import '../buttons/like_button.dart';
import '../comment_card.dart';
import 'package:lespace/helper/helper_methods.dart';
import '../buttons/comment_button.dart';

//All reviews
class BuildingReviewPost extends StatefulWidget {
  final String? message;
  final String location;
  final String timestamp;
  final String postId;
  final List<String> likes;

  final String? bugManagement;
  final String? bugAppear;
  final String? recommendation;
  final String? leakage;

  // final String? realEstateName;
  //final String? agencyReveiw;

  //final double? gasFeePerUnit;
  //final double? electricFeePerUnit;

  //sound
  final List<String>? sound;

  //messages
  final String? messageHard;
  final String? messageGood;

  const BuildingReviewPost({
    super.key,
    //required this.realEstateName,
    //required this.agencyReveiw,

    required this.messageGood,
    required this.message,
    required this.location,
    required this.messageHard,
    required this.bugManagement,
    required this.bugAppear,
    required this.recommendation,
    required this.leakage,
    required this.sound,
    required this.timestamp,
    required this.likes,
    required this.postId,
  });

  @override
  State<BuildingReviewPost> createState() => _BuildingReviewPostState();
}

class _BuildingReviewPostState extends State<BuildingReviewPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      //add the user's email to the "likes" filed
      docRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      docRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText) {
    //write the comment to firestore under the comment collection
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        //add new doc
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  //show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextStyle1(
          text: "댓글",
        ),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(
            hintText: "댓글을 입력하세요",
          ),
          maxLines: null,
        ),
        actions: [
          //cancel button
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                //clear controller
                _commentTextController.clear();
              },
              child: const Text(
                "뒤로",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              )),
          //save button
          TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              },
              child: const Text("전송",
                  style: TextStyle(fontSize: 16, color: Colors.black))),
        ],
      ),
    );
  }

  //Display it
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: const Color(0xecffffff),
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(top: 14, left: 14, right: 14),
            padding:
                const EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.location,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.grey,
                          ),
                        ),

                        /*  if(widget.realEstateName != null && widget.realEstateName!.isNotEmpty)
                          Text("${widget.realEstateName!.toString()} 중개",
                          style: const TextStyle(fontSize: 12,
                          color: Colors.grey),)
                          */
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            0.15, // Set to half of the screen width
                      ),
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                          onPressed: () async {
                            final address = widget.location;
                            if (address.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ReviewCommunicationRoom(
                                      address: address);
                                }),
                              );
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xff91bae7)),
                              minimumSize:
                                  WidgetStateProperty.all(const Size(0, 0)),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 0.5))

                              //MaterialStateProperty.all<Color>(Color(0xe0d9e0e7) ,),
                              ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Q&A",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.question_answer_outlined,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ],
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 9,
                ),
                if (widget.messageHard != null)
                  ReviewFieldCard(
                    text: widget.messageHard!.toString(),
                  ),
                if (widget.messageGood != null)
                  ReviewFieldCard(text: widget.messageGood!.toString()),
                if (widget.bugManagement != null)
                  ReviewFieldCard(text: "벌레관리: ${widget.bugManagement!}"),
                if (widget.bugAppear != null)
                  ReviewFieldCard(text: "벌레 ${widget.bugAppear!}"),
                const SizedBox(height: 3),
                if (widget.sound != null && widget.sound!.isNotEmpty)
                  const Divider(
                      indent: 0.0,
                      endIndent: 0.0,
                      thickness: 1.5,
                      color: Color(0xe0d9e0e7)),
                if (widget.sound != null && widget.sound!.isNotEmpty)
                  Row(
                    children: [
                      const Text(
                        "소음: ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.sound!
                              .map((sound) => Row(
                                    children: [
                                      Text(
                                        sound.toString(),
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      const Text(", "),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                if (widget.message != null)
                  ReviewFieldCard(text: widget.message!.toString()),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  iconColor: Colors.black87,
                  title: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "더보기",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  children: [
                    Column(
                      children: [
                        if (widget.leakage != null)
                          ReviewFieldCard(text: "누수: ${widget.leakage!}"),
                        if (widget.recommendation != null)
                          ReviewFieldCard(
                              text: widget.recommendation!.toString()),
                      ],
                    )
                  ],
                ),
              ],
            )),
        Container(
            decoration: BoxDecoration(
                color: const Color(0xedd9e0e7),
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(left: 14, right: 14),
            padding: const EdgeInsets.only(
              top: 14,
              left: 14,
              right: 14,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Like
                  Column(
                    children: [
                      LikeButton(
                        onTap: toggleLike,
                        isLiked: isLiked,
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        widget.likes.length.toString(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  //Comment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentButton(onTap: showCommentDialog),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("User Posts")
                                .doc(widget.postId)
                                .collection("Comments")
                                .orderBy("CommentTime", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              //show loading circle
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                return ListTileTheme(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  horizontalTitleGap: 5,
                                  minLeadingWidth: 0,
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    expandedCrossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    expandedAlignment: Alignment.topLeft,
                                    title: const Text(
                                      "댓글 보기",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    children: [
                                      ListView(
                                        shrinkWrap: true,
                                        //physics: const NeverScrollableScrollPhysics(),
                                        children:
                                            snapshot.data!.docs.map((doc) {
                                          //get comment from firebase
                                          final commentData = doc.data()
                                              as Map<String, dynamic>;
                                          //return
                                          return CommentCard(
                                            text: commentData["CommentText"],
                                            //user: commentData["CommentedBy"],
                                            time: formatData(
                                                commentData["CommentTime"]),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.timestamp,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ])),
        //Comments under post
      ],
    );
  }
}
