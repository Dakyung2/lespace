import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lespace/components/building_review_post/building_review_field_card.dart';
import 'package:lespace/components/text/text_style_1.dart';

import '../../components/buttons/comment_button.dart';
import '../../components/buttons/like_button.dart';
import '../../components/comment_card.dart';
import 'package:lespace/helper/helper_methods.dart';

//All reviews
class AgencyReviewPost extends StatefulWidget {

  final String postId;

  final String? location;

  final String? realEstateName;
  final String? agencyReveiw;

  final String? timestamp;

  final List<String> likes;

  const AgencyReviewPost({
    super.key,
    required this.realEstateName,
    required this.agencyReveiw,
    required this.location,
    required this.timestamp,
    required this.likes,
    required this.postId,
  });

  @override
  State<AgencyReviewPost> createState() => _AgencyReviewPostState();
}

class _AgencyReviewPostState extends State<AgencyReviewPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }
  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference docRef = FirebaseFirestore.instance.collection('Agency').doc(widget.postId);

    if (isLiked){
      //add the user's email to the "likes" filed
      docRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    }else{
      docRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText){
    //write the comment to firestore under the comment collection
    FirebaseFirestore.instance
        .collection("Agency")
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
  void showCommentDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextStyle1(text: "댓글",),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "댓글을 입력하세요",
          ),
          maxLines: null,
        ),
        actions: [
          //cancel button
          TextButton(
              onPressed: (){
                Navigator.pop(context);
                //clear controller
                _commentTextController.clear();
              } ,
              child: const TextStyle1(
                text: "취소",
              )),
          //save button
          TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              } ,
              child: const TextStyle1(
                text: "완료",
              )),
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
            margin: const EdgeInsets.only(top:14, left:14, right:14),
            padding: const EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //location
                if(widget.location !=null && widget.location!.isNotEmpty)
                Text(widget.location!,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.grey,
                  ),),
                //realEstate
                if(widget.realEstateName != null)
                  Text("${widget.realEstateName!} 중개",
                    style: const TextStyle(fontSize: 18,
                        color: Colors.grey),),
                const SizedBox(width: 10,),
        if(widget.agencyReveiw != null)
          ReviewFieldCard(text: widget.agencyReveiw!.toString()),

        //Comments under post
      ],
    )
        ),
        Container(
            decoration:
            BoxDecoration(
                color: const Color(0xedd9e0e7),
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only( left:14, right:14),
            padding: const EdgeInsets.only(top: 14, left: 14, right: 14,),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //Like
                  Column(
                    children:
                    [LikeButton
                      (
                      onTap: toggleLike,
                      isLiked: isLiked,
                    ),
                      const SizedBox(height: 1,),
                      Text(widget.likes.length.toString(),
                        style: const TextStyle(color: Colors.grey,
                            fontSize: 10),),
                    ],
                  ),
                  const SizedBox(width: 10,),
                  //Comment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentButton(
                            onTap: showCommentDialog),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Agency")
                                .doc(widget.postId)
                                .collection("Comments")
                                .orderBy("CommentTime", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              //show loading circle
                              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty ){
                                return ListTileTheme(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  horizontalTitleGap: 5,
                                  minLeadingWidth: 0,
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.all(0),
                                    expandedCrossAxisAlignment:CrossAxisAlignment.start ,
                                    expandedAlignment: Alignment.topLeft,
                                    title: const Text("댓글 보기",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    children: [
                                      ListView(
                                        shrinkWrap: true,
                                        children:
                                        snapshot.data!.docs.map((doc) {
                                          //get comment from firebase
                                          final commentData = doc.data() as Map<String, dynamic>;
                                          //return
                                          return CommentCard(
                                            text: commentData["CommentText"],
                                            //user: commentData["CommentedBy"],
                                            time: formatData(commentData["CommentTime"]),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                );
                              }else{
                                return Container();
                              }
                            }
                        ),

                      ],
                    ),
                  ),

                  //Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if(widget.timestamp !=null)
                        Text(widget.timestamp!.toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),),
                    ],
                  ),
                ]
            )
        ),
      ]);
  }
}

