import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'buildings_reviews_page.dart';
import '../../components/textfields/review_textfield.dart';
import "package:firebase_analytics/firebase_analytics.dart";

// 1. 커스텀 아이콘 핸들 (아이콘 크기와 슬라이더 트랙의 조화 최적화)
class IconSliderThumbShape extends SliderComponentShape {
  final IconData icon;
  final double thumbRadius;

  const IconSliderThumbShape({required this.icon, this.thumbRadius = 15.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    TextPainter textPainter = TextPainter(textDirection: textDirection);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
          fontSize: 22,
          fontFamily: icon.fontFamily,
          color: sliderTheme.thumbColor),
    );
    textPainter.layout();
    Offset textOffset = Offset(center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2));
    textPainter.paint(canvas, textOffset);
  }
}

// 2. CustomSliderField (여백과 폰트 무게감 조정)
class CustomSliderField extends StatefulWidget {
  final IconData thumbIcon;
  final String title;
  final double max;
  final double min;
  final double value;
  final int? division;
  final String label;
  final ValueChanged<double> function;
  final Color activeColor;

  const CustomSliderField(
      {Key? key,
      required this.thumbIcon,
      required this.title,
      required this.max,
      required this.min,
      required this.value,
      this.division,
      required this.label,
      required this.function,
      this.activeColor = const Color(0xFF4A90E2)})
      : super(key: key);

  @override
  _CustomSliderFieldState createState() => _CustomSliderFieldState();
}

class _CustomSliderFieldState extends State<CustomSliderField> {
  late double _currentValue;
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
          child: Text(widget.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A90E2).withOpacity(0.8),
              )),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.activeColor.withOpacity(0.3),
            inactiveTrackColor: widget.activeColor.withOpacity(0.08),
            thumbColor: widget.activeColor,
            thumbShape: IconSliderThumbShape(icon: widget.thumbIcon),
            trackHeight: 3.0,
            showValueIndicator: ShowValueIndicator.always,
            valueIndicatorColor: widget.activeColor,
            valueIndicatorTextStyle: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          ),
          child: Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.division,
            label: widget.label,
            onChanged: (newValue) {
              setState(() => _currentValue = newValue);
              widget.function(newValue);
            },
          ),
        ),
      ],
    );
  }
}

class PostBuildingReview extends StatefulWidget {
  const PostBuildingReview({super.key});
  @override
  State<PostBuildingReview> createState() => _PostBuildingReviewState();
}

class _PostBuildingReviewState extends State<PostBuildingReview> {
  String bugAppearLabel = "없음";
  String leakageLabel = "없음";
  double bugAppearValue = 0;
  double leakageValue = 0;
  List<String> selectedCategories = [];
  final List<String> _items = ["문", "복도", "옆방", "윗층", "외부", "기타", "없음"];

  //grab usr
  final User currentUser = FirebaseAuth.instance.currentUser!;

  final CollectionReference _userPosts =
      FirebaseFirestore.instance.collection("User Posts");

  // 컨트롤러

  final textControllerLocation = TextEditingController();
  final textControllerGoodMessage = TextEditingController();
  //final textControllerHardMessage = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 5) {
        // 5픽셀만 내려가도 감지
        if (!_isScrolled) setState(() => _isScrolled = true);
      } else {
        if (_isScrolled) setState(() => _isScrolled = false);
      }
    });
    // 페이지 진입 분석 로그
    FirebaseAnalytics.instance.logEvent(name: 'screen_view', parameters: {
      'firebase_screen': "PostBuildingReviewPage",
      'firebase_screen_class': "PostBuildingReviewPage"
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("로그인이 필요합니다. 다시 로그인해주세요."),
        ),
      );
      return;
    }

    final String location = textControllerLocation.text.trim();
    final String messageGood = textControllerGoodMessage.text.trim();

    if (location.isNotEmpty) {
      try {
        // 에러 방지: 함수 내부에서 직접 참조
        final collection = FirebaseFirestore.instance.collection("User Posts");

        await collection.add({
          "Location": location,
          "Good": messageGood,
          // 이전 코드의 라벨링 방식 유지
          "BugAppear": bugAppearLabel,
          "Leakage": leakageLabel,
          "Sound": selectedCategories,
          "UserEmail": user.email,
          "Likes": [],
          "TimeStamp": FieldValue.serverTimestamp(), // 서버 시간 사용 권장
        });

        await FirebaseAnalytics.instance.logEvent(name: "post_building_review");

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const BuildingsReviewPage()),
          );
        }
      } catch (e) {
        print("Error adding review: $e");
      }
    } else {
      // 위치 미입력 시 이전 코드의 알림 로직
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("위치를 작성하세요"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // 조금 더 맑은 아이콘 톤의 배경색으로 변경
      appBar: AppBar(
        title: Text("후기 작성",
            style: TextStyle(
                color: Color(0xFF4A90E2).withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        backgroundColor: _isScrolled ? Colors.white : const Color(0xffc2d3e5),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(
              color: _isScrolled
                  ? Colors.black.withOpacity(0.05)
                  : Colors.transparent,
              height: 1.0), // 아주 얇은 구분선
        ),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(), // 아이폰 특유의 탄성 스크롤
          padding:
              const EdgeInsets.fromLTRB(30, 30, 30, 40), // 하단 여백 대폭 추가 (40)
          children: [
            //_buildMinimalSectionTitle("위치"),
            _buildCardContainer(
              child: ReviewTextField(
                controller: textControllerLocation,
                messagehintText: '도로명 주소',
                obscureText: false,
                hintFontSize: 13,
                myicon: Icon(Icons.location_pin,
                    size: 22, color: Color(0xFF4A90E2)),
              ),
            ),
            const SizedBox(height: 28),

            // _buildMinimalSectionTitle("환경"),
            _buildCardContainer(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //벌레
                    CustomSliderField(
                      thumbIcon: Icons.pest_control_outlined,
                      title: "벌레",
                      max: 10,
                      min: 0,
                      value: bugAppearValue,
                      division: 10,
                      label: bugAppearLabel,
                      function: (val) => setState(() {
                        bugAppearValue = val;
                        bugAppearLabel = val == 0 ? "없음" : "${val.toInt()}회";
                      }),
                    ),
                    const SizedBox(height: 24),
                    // 누수
                    CustomSliderField(
                      thumbIcon: Icons.water_drop_outlined,
                      title: "누수",
                      max: 1,
                      min: 0,
                      value: leakageValue,
                      division: 1,
                      label: leakageLabel,
                      function: (val) => setState(() {
                        leakageValue = val;
                        leakageLabel = val == 0 ? "없음" : "있음";
                      }),
                    ),
                    const SizedBox(height: 24),
                    // 소음 섹션
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                      child: Text("소음",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A90E2).withOpacity(0.8))),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Icon(Icons.volume_up_rounded,
                              size: 22,
                              color: const Color(0xFF4A90E2).withOpacity(0.8)),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _items.map((item) {
                              final isSelected =
                                  selectedCategories.contains(item);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(item),
                                  labelPadding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        if (item == "없음") {
                                          selectedCategories = ["없음"];
                                        } else {
                                          selectedCategories.remove("없음");
                                          selectedCategories.add(item);
                                        }
                                      } else {
                                        selectedCategories.remove(item);
                                      }
                                    });
                                  },
                                  selectedColor: const Color(0xFF4A90E2),
                                  backgroundColor: const Color(0xFFF2F4F7),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide.none,
                                  showCheckmark: false,
                                  elevation: isSelected ? 2 : 0,
                                  shadowColor:
                                      const Color(0xFF4A90E2).withOpacity(0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ))

                        /*
                        child: MultiSelectDialogField(
                          items:
                              _items.map((e) => MultiSelectItem(e, e)).toList(),
                          listType: MultiSelectListType.CHIP,
                          buttonText: Text("소음 종류를 선택하세요",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.3),
                                  fontSize: 13)),
                          onConfirm: (values) => setState(() =>
                              selectedCategories = List<String>.from(values)),
                          chipDisplay: MultiSelectChipDisplay(
                            alignment: Alignment.centerLeft,
                            chipColor:
                                const Color(0xFF4A90E2).withOpacity(0.08),
                            textStyle: const TextStyle(
                                color: Color(0xFF4A90E2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          decoration: const BoxDecoration(),
                        ),
                      ),
                   */
                      ],
                    ),
                  ]),
            ),

            const SizedBox(height: 28),

            // _buildMinimalSectionTitle("상세 후기"),
            _buildCardContainer(
              child: ReviewTextField(
                controller: textControllerGoodMessage,
                messagehintText: '자유롭게 적어주세요',
                obscureText: false,
                hintFontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // 등록 버튼 (Shadow를 추가하여 입체감 부여)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text("공유",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            // 하단 잘림 방지용 여백
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black)),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20), // 패딩을 20으로 늘려 여유 공간 확보
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 더 둥글게 만들어 아이폰 감성 적용
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: child,
    );
  }
}

/*
class PostBuildingReview extends StatefulWidget {
  const PostBuildingReview({super.key});

  @override
  State<PostBuildingReview> createState() => _PostBuildingReviewState();
}

class _PostBuildingReviewState extends State<PostBuildingReview> {
 //상태 변후 관리
  String? bugAppearLabel = "없음";
  //String? recommendationLabel = "비추천";
  String? leakageLabel = "없음";

  double bugAppearValue = 0;
  //double recommendationValue = 0;
  double leakageValue = 0;

  //grab user
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts =
      FirebaseFirestore.instance.collection("User Posts");

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

  List<String>? selectedCategories = [];
  final List<String> _items = [
    "문",
    "복도",
    "대화",
    "물",
    "윗층",
    "외부",
    "기타",
    "없음",
  ];
  TextEditingController searchController = TextEditingController();

  bool hasLived = false;
  bool copyMessage = false;

  @override
  void initState() {
    super.initState();
    leakageValue = 0;
    bugAppearValue = 0;
    FirebaseAnalytics.instance.logEvent(name: 'screen_view', parameters: {
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
                        mylabel: const Text(
                          "거주지가 어디인가요?",
                          style: TextStyle(fontSize: 16),
                        ),
                        myicon: const Icon(
                          Icons.add_location_alt_rounded,
                          size: 18,
                        ),
                        controller: textControllerLocation,
                        messagehintText: '도로명 주소',
                        obscureText: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                    indent: 12.0,
                    endIndent: 12.0,
                    thickness: 1,
                    color: Colors.black12),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView(shrinkWrap: true, children: [
                    StatefulBuilder(builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 10,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "아래에 작성하는 후기는 학교인증된 분만 봅니다",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //후기 작성
                          //ReviewTextField(
                          //mylabel: const Text("가장 힘들었던 경험이 무엇인가요?"),
                          //  myicon: const Icon(Icons.sentiment_dissatisfied_rounded, size: 18),
                          //  controller: textControllerHardMessage,
                          //  messagehintText: '이야기하기',
                          //obscureText: false,
                          // ),
                          //const SizedBox(height: 10,),
                          // ReviewTextField(
                          // mylabel: const Text("가장 감사했던 경험이 무엇인가요?"),
                          // myicon: const Icon(Icons.emoji_emotions_outlined, size:18),
                          //  controller: textControllerGoodMessage,
                          //  messagehintText: '이야기하기',
                          //   obscureText: false,
                          // ),

                          const Divider(
                              indent: 12.0,
                              endIndent: 12.0,
                              thickness: 1,
                              color: Colors.black12),
                          const SizedBox(
                            height: 10,
                          ),

                          SliderField(
                            thumbIcon: Icons.bug_report,
                            title: "벌레",
                            max: 12,
                            min: 0,
                            value: bugAppearValue,
                            division: 12,
                            label: bugAppearLabel.toString(),
                            function: (value) => setState(() {
                              bugAppearValue = value;
                              if (bugAppearValue != 0) {
                                setState(() {
                                  bugAppearLabel = "1년 동안 $bugAppearValue번";
                                });
                              } else {
                                setState(() {
                                  bugAppearLabel = "0";
                                });
                              }
                            }),
                          ),
                          //bug management slider
                          const SizedBox(
                            height: 15,
                          ),
                          SliderField(
                              thumbIcon: Icons.water_drop_rounded,
                              value: leakageValue,
                              label: leakageLabel.toString(),
                              max: 1,
                              min: 0,
                              division: 1,
                              title: "누수",
                              function: (value) => setState(() {
                                    leakageValue = value;
                                    if (leakageValue == 0) {
                                      setState(() {
                                        leakageLabel = "없음";
                                      });
                                    } else if (leakageValue == 1) {
                                      setState(() {
                                        leakageLabel = "있음";
                                      });
                                    } else if (leakageValue == 2) {
                                      setState(() {
                                        leakageLabel = "2번 이상";
                                      });
                                    }
                                  })),
                          const SizedBox(
                            height: 15,
                          ),
                          //sound
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "소음",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: MultiSelectDialogField(
                                    backgroundColor: Colors.white,
                                    searchable: true,
                                    searchHint: textControllerSound.text,
                                    items: _items
                                        .map((e) => MultiSelectItem(e, e))
                                        .toList(),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    buttonText: const Text(
                                      "선택",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    selectedColor: const Color.fromARGB(
                                        255, 217, 224, 231),
                                    selectedItemsTextStyle:
                                        const TextStyle(color: Colors.black87),
                                    buttonIcon: const Icon(
                                      Icons.arrow_circle_down_rounded,
                                    ),
                                    listType: MultiSelectListType.CHIP,
                                    onConfirm: (values) {
                                      setState(() {
                                        selectedCategories =
                                            List<String>.from(values);
                                        textControllerSound.text =
                                            selectedCategories!.join(",");
                                      });
                                    },
                                    initialValue: selectedCategories!.toList(),
                                    chipDisplay: MultiSelectChipDisplay(
                                      onTap: (value) {
                                        setState(() {
                                          selectedCategories!.remove(value);
                                          textControllerSound.text =
                                              selectedCategories!.join(",");
                                        });
                                      },
                                    ),
                                    title: const Text(
                                      "Select",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 18),
                                    ),
                                    confirmText: const Text(
                                      "확인",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    cancelText: const Text(
                                      "취소",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
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
                    }),
                  ]),
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
                            backgroundColor:
                                const Color.fromARGB(217, 145, 187, 231),
                          ),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      content: Text(
                                        "나의 경험을 공유하고 다른 사람들도 공유한 후기를 모두 보세요:)",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87),
                                      ),
                                    ));
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const BuildingsReviewPage()));
                          },
                          child: const Text(
                            "뒤로",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff91bae7)),
                            onPressed: () async {
                              final String location =
                                  textControllerLocation.text;
                              final String message = textControllerMessage.text;

                              final String messageGood =
                                  textControllerGoodMessage.text;
                              final String messageHard =
                                  textControllerHardMessage.text;

                              if (location.isNotEmpty) {
                                await _userPosts.add({
                                  //Building
                                  "Location": location,
                                  if (messageGood.isNotEmpty)
                                    "Good": messageGood,
                                  if (messageHard.isNotEmpty)
                                    "Hard": messageHard,
                                  if (message.isNotEmpty) "Message": message,
                                  if (bugAppearLabel != null &&
                                      bugAppearLabel!.isNotEmpty)
                                    "BugAppear": bugAppearLabel.toString(),
                                  if (leakageLabel != null &&
                                      leakageLabel!.isNotEmpty)
                                    "Leakage": leakageLabel.toString(),
                                  if (selectedCategories!.isNotEmpty)
                                    "Sound": selectedCategories,

                                  //User
                                  "UserEmail": currentUser.email,
                                  //"Lived": hasLived,
                                  //Post info
                                  "Likes": [],
                                  "TimeStamp": Timestamp.now()
                                });
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

                                await FirebaseAnalytics.instance
                                    .logEvent(name: "post_building_review");
                              } else {
                                return showDialog(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                          content: TextStyle1(
                                            text: "위치를 작성하세요",
                                          ),
                                        ));
                              }
                              await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BuildingsReviewPage()));
                            },
                            child: const Text(
                              "완료",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
*/
