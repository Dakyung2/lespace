
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:lespace/components/text/text_style_1.dart';
import '../../components/slider.dart';
import 'buildings_reviews_page.dart';
import '../../components/textfields/review_textfield.dart';
import "package:firebase_analytics/firebase_analytics.dart";

class PostBuildingReview extends StatefulWidget {
  const PostBuildingReview({super.key});

  @override
  State<PostBuildingReview> createState() => _PostBuildingReviewState();
}

class _PostBuildingReviewState extends State<PostBuildingReview> {

  //String? bugManagementLabel = "없음" ;

  String? bugAppearLabel="없음";

  //String? recommendationLabel = "비추천";
  String? leakageLabel ="없음";

  //double bugManagementValue = 0;

  double bugAppearValue = 0;
  //double recommendationValue = 0;
  double leakageValue = 0;

  //grab user
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts = FirebaseFirestore.instance.collection("User Posts");

  //Building
  final textControllerMessage = TextEditingController();
  final textControllerLocation = TextEditingController();


  final textControllerHardMessage = TextEditingController();
  final textControllerGoodMessage = TextEditingController();


  //Agency
  final textControllerAgencyReview = TextEditingController();
  final textControllerRealEstate = TextEditingController();

  //Sound
  TextEditingController textControllerSound = TextEditingController();

  List <String>? selectedCategories = [];
   final List<String>  _items = [
    "문 여닫음",
     "복도",
    "이웃의 대화",
    "물",
    "윗층의 움직임",
     "윗층의 대화",
    "외부",
    "기타",
    "없음",

  ];
  TextEditingController searchController = TextEditingController();

  bool hasLived = false;
  bool copyMessage = false;



  @override
  void initState()  {
    super.initState();
    leakageValue = 0;
    bugAppearValue = 0;
  FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': "PostBuildingReviewPage",
        'firebase_screen_class': "PostBuildingReviewPage"
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xe0d9e0e7),
      body: SafeArea(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ReviewTextField(
                            mylabel:const Text("거주지가 어디인가요?", style: TextStyle(fontSize: 16),) ,
                            myicon: const Icon(Icons.add_location_alt_rounded, size: 18,),
                            controller: textControllerLocation,
                            messagehintText: '도로명 주소',
                            obscureText: false,
                          ),
                        ),
                      
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const Divider(
                        indent: 12.0,
                        endIndent: 12.0,
                        thickness: 1,
                        color: Colors.black12
                    ),
                    const SizedBox(height: 10,),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          StatefulBuilder(
                            builder: (context,state) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock_outline_rounded, size: 10,),
                                        SizedBox(width: 5,),
                                        Text("아래에 작성하는 후기는 학교인증된 분만 봅니다", style: TextStyle(fontSize: 10, color: Colors.grey),)
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  //후기 작성
                                  ReviewTextField(
                                    mylabel: const Text("가장 힘들었던 경험이 무엇인가요?"),
                                    myicon: const Icon(Icons.sentiment_dissatisfied_rounded, size: 18),
                                    controller: textControllerHardMessage,
                                    messagehintText: '이야기하기',
                                    obscureText: false,
                                  ),
                                  const SizedBox(height: 10,),
                                  ReviewTextField(
                                    mylabel: const Text("가장 감사했던 경험이 무엇인가요?"),
                                    myicon: const Icon(Icons.emoji_emotions_outlined, size:18),
                                    controller: textControllerGoodMessage,
                                    messagehintText: '이야기하기',
                                    obscureText: false,
                                  ),
                                  
                                  const Divider(
                                      indent: 12.0,
                                      endIndent: 12.0,
                                      thickness: 1,
                                      color: Colors.black12
                                  ),
                                  const SizedBox(height: 10,),

                                  SliderField(
                                    thumbIcon: Icons.bug_report,
                                    title: "벌레 있었나요?",
                                    max: 12,
                                    min: 0,
                                    value: bugAppearValue,
                                    division: 12,
                                    label: bugAppearLabel.toString(),
                                    function: (value) => setState(() {
                                      bugAppearValue = value;
                                      if (bugAppearValue != 0){
                                        setState((){
                                          bugAppearLabel = "6개월 동안 $bugAppearValue번";
                                        });
                                      }else{
                                        setState((){
                                          bugAppearLabel = "0";
                                        });
                                      }
                                    })
                                    ,
                                  ),
                                  //bug management slider
                                  const SizedBox(height: 15,),
                                  SliderField(
                                    thumbIcon: Icons.water_drop_rounded,
                                      value: leakageValue,
                                      label: leakageLabel.toString(),
                                      max: 2,
                                      min: 0,
                                      division: 2,
                                      title: "누수 있었나요?",
                                      function: (value) =>
                                          setState(() {
                                            leakageValue = value;
                                            if(leakageValue == 0){
                                              setState((){
                                                leakageLabel= "없음";
                                              });
                                            }
                                            else if(leakageValue == 1){
                                              setState((){
                                                leakageLabel= "1번";
                                              });
                                            }
                                            else if(leakageValue ==2){
                                              setState((){
                                                leakageLabel = "2번 이상";
                                              });
                                            }

                                          })),
                                  const SizedBox(height: 15,),
                                  //sound
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("소음 있었나요?", style: TextStyle(fontSize: 16),),
                                        ),
                                        Expanded(
                                          child: MultiSelectDialogField(
                                            backgroundColor: Colors.white,
                                            searchable: true,
                                            searchHint: textControllerSound.text,
                                            items: _items.map((e) => MultiSelectItem(e, e)).toList(),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            buttonText:
                                            const Text(
                                              "선택", style: TextStyle(fontSize: 12, color: Colors.grey),),
                                              selectedColor: const Color.fromARGB(255, 217, 224, 231),
                                              selectedItemsTextStyle:const TextStyle(color: Colors.black87),
                                            buttonIcon: const Icon(Icons.arrow_circle_down_rounded,),
                                            listType: MultiSelectListType.CHIP,
                                            onConfirm: (values) {
                                              setState(() {
                                                selectedCategories = List<String>.from(values);
                                                textControllerSound.text= selectedCategories!.join(",");
                                              });
                                            },
                                            initialValue: selectedCategories!.toList(),
                                            chipDisplay: MultiSelectChipDisplay(
                                              onTap: (value){
                                                setState((){
                                                  selectedCategories!.remove(value);
                                                  textControllerSound.text = selectedCategories!.join(",");
                                                });
                                              },
                                            ),
                                            title: const Text("Select", style: TextStyle(color: Colors.black54, fontSize: 18),),
                                            confirmText: const Text("확인", style: TextStyle(color: Colors.black87),),
                                            cancelText: const Text("취소", style: TextStyle(color: Colors.black54),),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              
                                  const SizedBox(height: 10,),
                    /*
                                  const Divider(
                                      indent: 12.0,
                                      endIndent: 12.0,
                                      thickness: 1,
                                      color: Colors.black54
                                  ),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: ExpansionTile(
                                      // backgroundColor: Color(0x94d9e0e7),
                                      iconColor: Colors.black,
                                      expandedAlignment: const Alignment(0, 0),
                                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                      title: const Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "중개 받았나요?",
                                            style: TextStyle(
                                                fontSize: 18,
                                            ),),
                                        ],
                                      ),
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.lock_open_outlined, size: 10,),
                                              SizedBox(width: 5,),
                                              Text("아래에 작성하는 피드백은 모두에게 공유됩니다", style: TextStyle(fontSize: 10, color: Colors.grey),)

                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10,),

                                        ReviewTextField(
                                          mylabel: const Text("중개사가 어딘가요", style: TextStyle(fontSize: 16),),
                                          myicon: const Icon(Icons.real_estate_agent_outlined, size: 18),
                                          controller: textControllerRealEstate,
                                          messagehintText: '부동산/중개사 이름',
                                          obscureText: false,
                                        ),
                                        const SizedBox(height: 10,),
                                        ReviewTextField(
                                          mylabel:const Text("가장 기대에 만족/만족하지 않은 점이 무엇인가요?", style: TextStyle(fontSize: 16),),
                                          myicon: const Icon(Icons.emoji_emotions_outlined, size: 18),
                                          controller: textControllerAgencyReview,
                                          messagehintText: '',
                                          obscureText: false,
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                          child: Row(
                                            children: [

                                              const Text("위의 거주후기 붙여넣기", style: TextStyle(fontSize: 10, ),
                                              ),
                                              Checkbox(
                                                value: copyMessage,
                                                onChanged: (value){
                                                  setState((){
                                                    copyMessage = value!;
                                                    if (copyMessage){
                                                      textControllerAgencyReview.text = textControllerGoodMessage.text;
                                                    }
                                                  });
                                                },
                                                checkColor: Colors.white,
                                                visualDensity: VisualDensity.compact,
                                                activeColor: const Color(0xe0d9e0e7),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10,),
                                        //SizedBox(height: 10,)
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  const Divider(
                                      indent: 12.0,
                                      endIndent: 12.0,
                                      thickness: 1,
                                      color: Colors.black12
                                  ),*/

                                ],
                              );
                            }
                        ),]
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(217, 145, 187, 231),
                              ),
                              onPressed: ()async {
                                await showDialog(
                                  context: context, 
                                  builder: (context)=> const AlertDialog(
                                    content: Text(
                                      "나의 경험을 공유하고 다른 사람들도 공유한 후기를 모두 보세요:)", 
                                      style: TextStyle(
                                        fontSize: 18, color: Colors.black87
                                        ),
                                        ),
                                        )
                                        );
                                 Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const BuildingsReviewPage())
                                );
                              },
                              child: const Text(
                              "뒤로", style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20,),

                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff91bae7)
                                ),
                                onPressed: () async {
                                  final String location = textControllerLocation.text;
                                  final String message = textControllerMessage.text;
                              
                                  final String messageGood = textControllerGoodMessage.text;
                                  final String messageHard = textControllerHardMessage.text;

                                  if (location.isNotEmpty){
                                   await _userPosts.add({
                                      //Building
                                      "Location": location,
                                      if(messageGood.isNotEmpty)
                                        "Good": messageGood,
                                        if(messageHard.isNotEmpty)
                                        "Hard": messageHard,
                                      if(message.isNotEmpty)
                                        "Message": message,
                                      if(bugAppearLabel != null && bugAppearLabel!.isNotEmpty)
                                      "BugAppear": bugAppearLabel.toString(),
                                      if(leakageLabel !=null && leakageLabel!.isNotEmpty)
                                      "Leakage": leakageLabel.toString(),
                                      if(selectedCategories!.isNotEmpty)
                                        "Sound": selectedCategories,
                                      
                                      //User
                                      "UserEmail": currentUser.email,
                                      //"Lived": hasLived,
                                      //Post info
                                      "Likes": [],
                                      "TimeStamp": Timestamp.now()});
                                      /*

                                    if(agency.isNotEmpty){
                                      DocumentReference userPostsRef = _userPosts.doc(userPostsDocRef.id);
                                      await FirebaseFirestore.instance.collection("Agency").add({
                                        "Agency": agency.toString(),
                                        if(agencyReview.isNotEmpty)
                                          "AgencyReview": agencyReview.toString(),
                                        "UserEmail": currentUser.email,
                                        "PostId": userPostsRef,
                                        "Location": location.toString(),
                                        "TimeStamp": Timestamp.now(),
                                        "Likes": []
                                      });
                                    }*/

                                    await FirebaseAnalytics.instance.logEvent(
                                      name: "post_building_review");


                                  } else {
                                    return showDialog(
                                        context: context,
                                        builder: (context) => const AlertDialog(
                                          content: TextStyle1(
                                            text: "위치를 작성하세요",
                                          ),
                                        )
                                    );
                                  }
                                   await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const BuildingsReviewPage()
                                  )
                                  );
                                  
                                },
                                child: const Text(
                                   "완료", style: TextStyle(fontSize: 16, color: Colors.white),
                                )),
                          ),

                        ],
                      ),
                    )
                  ],

                    ),
              );
            }
        ),
      ),
    );
  }

 
}
