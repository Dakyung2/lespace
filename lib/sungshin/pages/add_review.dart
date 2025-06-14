import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/components/keyboards/keyboard.dart';
import 'package:lespace/components/text/text_style_1.dart';
import 'package:lespace/sungshin/pages/review_posts.dart';
import '../../components/textfields/review_textfield.dart';
import '../../components/text/text_style_2.dart';

class SungshinAddReview extends StatefulWidget {
  const SungshinAddReview({super.key});

  @override
  State<SungshinAddReview> createState() => _SungshinAddReviewState();
}

class _SungshinAddReviewState extends State<SungshinAddReview> {

  String? bugManagementLabel;
  String? recommendationLabel;
  String? leakageLabel;

  double bugManagementValue = 0;
  double recommendationValue = 0;
  double leakageValue = 0;

  //grab user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts = FirebaseFirestore.instance.collection("Sungshin");

  //Building
  final textControllerMessage = TextEditingController();
  final textControllerLocation = TextEditingController();

  final textControllerGasFee = TextEditingController();
  final textControllerGasUsage = TextEditingController();

  final textControllerElectricFee = TextEditingController();
  final textControllerElectricUsage = TextEditingController();

  //Agency
  final textControllerAgency = TextEditingController();
  final textControllerAgencyReview = TextEditingController();

  bool hasLived = false;

  @override
  void initState() {
    super.initState();
    bugManagementValue = 0;
    recommendationValue = 0;
    leakageValue = 0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 20, left: 20, right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom +20
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ReviewTextField(
                                    mylabel:'거주/중개받는 방',
                                    myicon: const Icon(Icons.add_location_alt_rounded, size: 14,),
                                    controller: textControllerLocation,
                                    messagehintText: '도로명 주소',
                                    obscureText: false,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: ()  {
                                    setState(()  {
                                      hasLived = !hasLived;// Toggle the user's choice
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "거주 여부 : ",
                                        style: TextStyle(
                                          fontSize: 28, fontWeight: FontWeight.normal,
                                        ),),
                                      Checkbox(
                                          onChanged: (newValue)=>{
                                            setState((){
                                              hasLived = !hasLived;
                                            })
                                          },
                                          value: hasLived),
                                    ],
                                  ),
                                  //style: ElevatedButton.styleFrom(
                                  // Change button color based on choice
                                  //backgroundColor: hasLived ? const Color(0xff8cb5e0) : const Color(0x94d9e0e7),
                                  //),
                                )
                              ],
                            ),
                            StatefulBuilder(
                                builder: (context,state) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: Column(
                                      children: [
                                        //bug management slider
                                        Row(
                                          children: [
                                            const Expanded(
                                                child: TextStyle2(
                                                    text: "해충 관리 주기")),
                                            Expanded(
                                              flex: 3,
                                              child: Slider(
                                                  max: 12,
                                                  min: 0,
                                                  value: bugManagementValue,
                                                  divisions: 12,
                                                  label: bugManagementLabel.toString(),
                                                  onChanged: (value)=>
                                                      setState(() {
                                                        bugManagementValue = value;
                                                        if (bugManagementValue != 0){
                                                          setState((){
                                                            bugManagementLabel = "$bugManagementValue개월 마다";
                                                          });
                                                        }else{
                                                          setState((){
                                                            bugManagementLabel = "없음";
                                                          });
                                                        }
                                                      })
                                              ),
                                            )
                                          ],
                                        ),
                                        //leakage
                                        Row(
                                          children: [
                                            const Expanded(
                                                child: TextStyle2(
                                                    text: "누수 횟수")),
                                            Expanded(
                                              flex: 3,
                                              child: Slider(
                                                  value: leakageValue,
                                                  label: leakageLabel.toString(),
                                                  divisions: 2,
                                                  min: 0,
                                                  max: 2,
                                                  onChanged: (value) =>
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

                                                      })
                                              ),
                                            )
                                          ],
                                        ),
                                        //추천 여부
                                        Row(
                                          children: [
                                            const Expanded(
                                                child: TextStyle2(
                                                    text: "추천 여부")),
                                            Expanded(
                                              flex: 3,
                                              child: Slider(
                                                  value: recommendationValue,
                                                  label: recommendationLabel,
                                                  divisions: 2,
                                                  min: 0,
                                                  max: 2,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                        recommendationValue = value;
                                                        if(recommendationValue == 0){
                                                          setState((){
                                                            recommendationLabel= "비추천";
                                                          });
                                                        }
                                                        else if(recommendationValue == 1){
                                                          setState((){
                                                            recommendationLabel= "추천";
                                                          });
                                                        }
                                                        else if(recommendationValue ==2){
                                                          setState((){
                                                            recommendationLabel = "적극 추천";
                                                          });
                                                        }
                                                      })
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                            const SizedBox(height: 10,),

                            ExpansionTile(
                              backgroundColor: Colors.white70,
                              iconColor: Colors.black,
                              title: const TextStyle2(
                                text: "관리비 어땠나요?",
                              ),
                              children: [
                                ReviewTextField(
                                  keyboardType: KeyboardTypeNum().keyboardTypeNum,
                                  inputformatters: KeyboardTypeNum().inputFormattersNum,
                                  mylabel: '전기 사용량',
                                  myicon: const Icon(Icons.gas_meter_rounded, size: 24),
                                  controller: textControllerElectricUsage,
                                  messagehintText: '월 최대 사용량(kWh)',
                                  obscureText: false,
                                ),
                                ReviewTextField(
                                  keyboardType: KeyboardTypeNum().keyboardTypeNum,
                                  inputformatters: KeyboardTypeNum().inputFormattersNum,
                                  mylabel: '전기세',
                                  myicon: const Icon(Icons.attach_money_rounded, size: 24),
                                  controller: textControllerElectricFee,
                                  messagehintText: '당월 전기세(원)',
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10,),
                                ReviewTextField(
                                  keyboardType: KeyboardTypeNum().keyboardTypeNum,
                                  inputformatters: KeyboardTypeNum().inputFormattersNum,
                                  mylabel: '가스 사용량',
                                  myicon: const Icon(Icons.gas_meter_rounded, size: 24),
                                  controller: textControllerGasUsage,
                                  messagehintText: '월 최대 사용량(㎥)',
                                  obscureText: false,
                                ),
                                ReviewTextField(
                                  keyboardType: KeyboardTypeNum().keyboardTypeNum,
                                  inputformatters: KeyboardTypeNum().inputFormattersNum,
                                  mylabel: '가스(난방)비',
                                  myicon: const Icon(Icons.attach_money_rounded, size: 24),
                                  controller: textControllerGasFee,
                                  messagehintText: '당월 가스비(원)',
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10,)
                              ],),
                            const SizedBox(height: 20,),
                            ReviewTextField(
                              mylabel: '하고싶은 말',
                              myicon: const Icon(Icons.rate_review_rounded, size: 24),
                              controller: textControllerMessage,
                              messagehintText: '공익을 위한 후기!(욕설 및 과도한 언행은 금지)',
                              obscureText: false,
                            ),
                            const SizedBox(height: 30),
                            ExpansionTile(
                              // backgroundColor: Color(0x94d9e0e7),
                              iconColor: Colors.black,
                              title: const Text(
                                "중개를 통하셨나요?",
                                style: TextStyle(
                                    fontSize: 24
                                ),),
                              children: [
                                ReviewTextField(
                                  mylabel: '중개사',
                                  myicon: const Icon(Icons.real_estate_agent_rounded, size: 24),
                                  controller: textControllerAgency,
                                  messagehintText: '중개업소명',
                                  obscureText: false,
                                ),
                                ReviewTextField(
                                  mylabel: '후기',
                                  myicon: const Icon(Icons.rate_review_rounded, size: 24),
                                  controller: textControllerAgencyReview,
                                  messagehintText: '글 작성',
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10,)
                              ],
                            )//Agency Review

                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              onPressed: ()  {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const SungshinReviewPosts())
                                );
                              },
                              child: const TextStyle1(
                                text: "뒤로",
                              ),
                            ),
                          ),
                          const SizedBox(width: 20,),

                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue
                                ),
                                onPressed: () async {
                                  final String location = textControllerLocation.text;
                                  final String message = textControllerMessage.text;
                                  final String agency = textControllerAgency.text;
                                  final String agencyReview = textControllerAgencyReview.text;

                                  final double? gasUsage = double.tryParse(textControllerGasUsage.text);
                                  final double? gasFee = double.tryParse(textControllerGasFee.text);

                                  final double? electricUsage = double.tryParse(textControllerElectricUsage.text);
                                  final double? electricFee = double.tryParse(textControllerElectricFee.text);

                                  if (location.isNotEmpty){
                                    await _userPosts.add({
                                      //Building
                                      "Location": location,
                                      if(message.isNotEmpty)
                                        "Message": message,
                                      "BugManagement" : bugManagementLabel.toString(),
                                      "Recommendation" : recommendationLabel.toString(),
                                      "Leakage": leakageLabel.toString(),
                                      if(gasFee !=null && gasUsage != null && gasFee.toString().isNotEmpty && gasUsage.toString().isNotEmpty)
                                        "GasFeePerUnit": gasUsage/gasFee,
                                      if(electricFee != null && electricUsage != null && electricFee.toString().isNotEmpty && electricUsage.toString().isNotEmpty)
                                        "ElectricFeePerUnit": electricUsage/electricFee,

                                      //User
                                      "UserEmail": currentUser.email,
                                      "Lived": hasLived,
                                      //Post info
                                      "Likes": [],
                                      "TimeStamp": Timestamp.now()});

                                    if (agency.isNotEmpty){
                                      await FirebaseFirestore.instance.collection("Agency").add({
                                        "AgencyName": agency,
                                        "AgencyReview": agencyReview,
                                        "postRef": _userPosts.id}
                                      );
                                    }

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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const SungshinReviewPosts()
                                  )
                                  );
                                },
                                child: const TextStyle1(
                                  text: "추가",
                                )),
                          ),

                        ],
                      )
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
