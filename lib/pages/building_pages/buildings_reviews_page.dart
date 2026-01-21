import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lespace/pages/building_pages/buildings_reviews_page_notstudent.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page_studentwithaccess.dart';
import 'post_building_review.dart';

class BuildingsReviewPage extends StatefulWidget {
  const BuildingsReviewPage({super.key});

  @override
  State<BuildingsReviewPage> createState() => _BuildingsReviewPageState();
}

class _BuildingsReviewPageState extends State<BuildingsReviewPage> {
  // 1. 필요한 변수 선언
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts =
      FirebaseFirestore.instance.collection("User Posts");

  @override
  void initState() {
    super.initState();
    // 페이지가 열리자마자 검증 흐름 시작
    _initializeVerificationFlow();
  }

  /// [UX Flow] 사용자의 권한을 순차적으로 확인하고 페이지를 이동시킵니다.
  Future<void> _initializeVerificationFlow() async {
    // A. 학교 이메일인지 먼저 확인 (@korea.ac.kr)
    bool isStudent = currentUser.email.toString().endsWith("@korea.ac.kr");

    if (!isStudent) {
      // 학생이 아니면 즉시 차단 페이지로 이동
      _safeNavigate(const BuildingsReviewPageNotStudent());
      return;
    }

    // B. 학생이라면, 작성한 후기가 있는지 DB 조회 (User Posts 컬렉션)
    try {
      final querySnapshot = await _userPosts
          .where("UserEmail", isEqualTo: currentUser.email)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        // 학생이고 후기도 썼음 -> 메인 리스트 페이지로
        _safeNavigate(const BuildingsReviewPageStudentWithAccess());
      } else {
        // 학생인데 아직 후기를 안 썼음 -> 후기 작성 페이지로 (사용자님의 의도!)
        _safeNavigate(const PostBuildingReview());
      }
    } catch (e) {
      debugPrint("Error fetching user access: $e");
      // 에러 발생 시 안전하게 에러 페이지나 기본 페이지로 이동
      _safeNavigate(const BuildingsReviewPageNotStudent());
    }
  }

  /// 안전한 화면 전환을 위한 헬퍼 함수
  void _safeNavigate(Widget destinationPage) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 사용자가 검증 결과를 기다리는 동안 보여줄 로딩 화면 (UX 브릿지 페이지)
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xff8cb5e0),
            ),
            SizedBox(height: 24),
            Text(
              "Accessing your community...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
