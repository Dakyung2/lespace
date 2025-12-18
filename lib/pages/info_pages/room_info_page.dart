import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page.dart';

import 'my_page.dart';
import '../../components/text/text_style_1.dart';
import '../../read data/Buildings.dart';

class RoomInfoPage extends StatefulWidget {
  const RoomInfoPage({super.key});

  @override
  State<RoomInfoPage> createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  final TextEditingController _managementTitle = TextEditingController();
  final TextEditingController _managementCost = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference _userPosts =
      FirebaseFirestore.instance.collection("User Posts");
  final CollectionReference _managerPosts =
      FirebaseFirestore.instance.collection("Manager Posts");
//Access
  bool userHasAccess = false;
  bool managerHasAccess = false;
  //Sign out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  //function to check if the user has acccess
  Future<void> checkUserAccess() async {
    final userPostsQuery =
        _userPosts.where("UserEmail", isEqualTo: currentUser.email);
    final querySnapshot = await userPostsQuery.get();

    //check if the user has access
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userHasAccess = true;
      });
    } else {
      setState(() {
        userHasAccess = false;
      });
    }
    //set userHasAccess to true or false accrodingly
  }

  Future<void> checkManagerAccess() async {
    final managerPostsQuery =
        _managerPosts.where("ManagerEmail", isEqualTo: currentUser.email);
    final querySnapshot = await managerPostsQuery.get();

    //check if the user has access
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        managerHasAccess = true;
      });
    } else {
      setState(() {
        managerHasAccess = false;
      });
    }
    //set userHasAccess to true or false accrodingly
  }

  void add() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                children: [
                  const Text("관리 항목"),
                  TextField(
                    controller: _managementTitle,
                  ),
                  const Text("세대당 비용"),
                  TextField(
                    controller: _managementCost,
                  ),
                  TextButton(
                      onPressed: () {
                        if (_managementTitle.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection("Manager Posts")
                              .doc(currentUser.email)
                              .collection("Management")
                              .add(
                            {
                              "Title": _managementTitle.text,
                              "Cost": _managementCost.text,
                            },
                          );
                        }
                        //clear the textfield
                        setState(() {
                          _managementTitle.clear();
                          _managementCost.clear();
                        });
                      },
                      child: const Text("추가"))
                ],
              ),
            )); //only post if there is something in the textfield
  }

  @override
  void initState() {
    checkUserAccess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: const Color(0xe0d9e0e7),
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: signUserOut,
                  icon: const Icon(
                    Icons.logout,
                    size: 20,
                  ),
                ),
              ],
              title: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add_home_sharp,
                      color: Color(0xffC62828),
                      size: 30,
                    ),
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
                      child: Center(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_home_rounded),
                      title: const Text(
                        "소중한 후기들",
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const BuildingsReviewPage()));
                        // Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_home_rounded),
                      title: const Text(
                        "건물 주민과 소통하기",
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ReadBuilding()));
                        // Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: const Text(
                        "내 페이지",
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: userHasAccess
                ? _buildContentWithUserAccess()
                : managerHasAccess
                    ? _buildContentWithManagerAccess()
                    : _buildContentWithoutAccess()));
  }

  Widget _buildContentWithManagerAccess() {
    String? finalAmount = "";
    String? address = "";
    String contactNumber = "";

    final TextEditingController AddressTextController = TextEditingController();
    final TextEditingController ContactTextController = TextEditingController();

    void addAddress() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Column(
                  children: [
                    const Text("주소 추가하기"),
                    TextField(
                      controller: AddressTextController,
                      decoration: const InputDecoration(
                          hintText: "우리 건물 주소",
                          prefixIcon: Icon(Icons.location_on_rounded)),
                    ),
                    TextButton(
                        onPressed: () {
                          if (AddressTextController.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Info")
                                .add(
                              {
                                "Address": AddressTextController.text,
                              },
                            );
                          }
                          //clear the textfield
                          setState(() {
                            AddressTextController.clear();
                          });
                        },
                        child: const Text("추가"))
                  ],
                ),
              )); //only post if there is something in the textfield
    }

    void addContactNumber() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Column(
                  children: [
                    const Text("연락처 추가하기"),
                    TextField(
                      controller: ContactTextController,
                      decoration: const InputDecoration(
                          hintText: "우리 건물 관리자 연락처",
                          prefixIcon: Icon(Icons.contacts_rounded)),
                    ),
                    TextButton(
                        onPressed: () {
                          if (AddressTextController.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Info")
                                .add(
                              {
                                "Contact": ContactTextController.text,
                              },
                            );
                          }
                          //clear the textfield
                          setState(() {
                            ContactTextController.clear();
                          });
                        },
                        child: const Text("추가"))
                  ],
                ),
              )); //only post if there is something in the textfield
    }

    return managerHasAccess == true
        //currentUser.email.toString().contains("@korea.ac.kr")
        ? Padding(
            padding:
                const EdgeInsets.only(top: 20, right: 12, left: 12, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "우리집 관리비",
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: add,
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded),
                        Text(
                          "내역 추가",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(address),
                        TextButton(
                            onPressed: addAddress, child: const Text("주소 추가")),
                        Row(
                          children: [
                            Text("총$finalAmount원"),
                          ],
                        ),
                        Text(contactNumber),
                        TextButton(
                            onPressed: addContactNumber,
                            child: const Text("연락처 추가"))
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Management")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: TextStyle1(
                                      text: "Error: ${snapshot.error}"),
                                );
                              }
                              final docs = snapshot.data?.docs;
                              if (docs == null || docs.isEmpty) {
                                return const Center(
                                  child: Text("No data available"),
                                );
                              }

                              return Center(
                                child: Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 50,
                                            child: Text(
                                              "관리 항목",
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          SizedBox(
                                              width: 80,
                                              height: 50,
                                              child: Text(
                                                "세대당 비용",
                                                style: TextStyle(fontSize: 24),
                                              )),
                                        ],
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: docs.length,
                                        itemBuilder: (context, index) {
                                          final data = docs[index];
                                          final title =
                                              data.get("Title").toString();
                                          final cost =
                                              data.get("Cost").toString();
                                          return Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    height: 50,
                                                    child: Text(
                                                      title,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 50,
                                                    child: Text(
                                                      cost,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        : const Center(
            child: TextStyle1(
                text: "현재 관리자 페이지는 등록된 건물 관리자에게만 공개됩니다"
                    "관리자 추가 요청 : 2dkroom@gmail.com"),
          );
  }

  Widget _buildContentWithUserAccess() {
    String? finalAmount = "";
    String? address = "";
    String contactNumber = "";

    final TextEditingController AddressTextController = TextEditingController();
    final TextEditingController ContactTextController = TextEditingController();

    void addAddress() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Column(
                  children: [
                    const Text("주소 추가하기"),
                    TextField(
                      controller: AddressTextController,
                      decoration: const InputDecoration(
                          hintText: "우리 건물 주소",
                          prefixIcon: Icon(Icons.location_on_rounded)),
                    ),
                    TextButton(
                        onPressed: () {
                          if (AddressTextController.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Info")
                                .add(
                              {
                                "Address": AddressTextController.text,
                              },
                            );
                          }
                          //clear the textfield
                          setState(() {
                            AddressTextController.clear();
                          });
                        },
                        child: const Text("추가"))
                  ],
                ),
              )); //only post if there is something in the textfield
    }

    void addContactNumber() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Column(
                  children: [
                    const Text("연락처 추가하기"),
                    TextField(
                      controller: ContactTextController,
                      decoration: const InputDecoration(
                          hintText: "우리 건물 관리자 연락처",
                          prefixIcon: Icon(Icons.contacts_rounded)),
                    ),
                    TextButton(
                        onPressed: () {
                          if (AddressTextController.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Info")
                                .add(
                              {
                                "Contact": ContactTextController.text,
                              },
                            );
                          }
                          //clear the textfield
                          setState(() {
                            ContactTextController.clear();
                          });
                        },
                        child: const Text("추가"))
                  ],
                ),
              )); //only post if there is something in the textfield
    }

    return checkUserAccess() == true
        //currentUser.email.toString().contains("@korea.ac.kr")
        ? Padding(
            padding:
                const EdgeInsets.only(top: 20, right: 12, left: 12, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "우리집 관리비",
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(address),
                        Row(
                          children: [
                            Text("총$finalAmount원"),
                          ],
                        ),
                        Text(contactNumber),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Manager Posts")
                                .doc(currentUser.email)
                                .collection("Management")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: TextStyle1(
                                      text: "Error: ${snapshot.error}"),
                                );
                              }
                              final docs = snapshot.data?.docs;
                              if (docs == null || docs.isEmpty) {
                                return const Center(
                                  child: Text("No data available"),
                                );
                              }

                              return Center(
                                child: Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 50,
                                            child: Text(
                                              "관리 항목",
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          SizedBox(
                                              width: 80,
                                              height: 50,
                                              child: Text(
                                                "세대당 비용",
                                                style: TextStyle(fontSize: 24),
                                              )),
                                        ],
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: docs.length,
                                        itemBuilder: (context, index) {
                                          final data = docs[index];
                                          final title =
                                              data.get("Title").toString();
                                          final cost =
                                              data.get("Cost").toString();
                                          return Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    height: 50,
                                                    child: Text(
                                                      title,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 50,
                                                    child: Text(
                                                      cost,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        : const Center(
            child: TextStyle1(
                text: "현재 관리내역 페이지는 권한 접근이 혀용된 사용자에게만 공개됩니다. "
                    "관리자에게 권한 접근 허용을 요청하세요"
                    "기타 문의 : 2dkroom@gmail.com"),
          );
  }

  Widget _buildContentWithoutAccess() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 8),
      child: Column(children: [
        const Text(
            "단 하나의 후기를 작성하고, 1). 방을 볼 때 무엇을 알아야하는지 2). 좋은 방을 어떻게 알아보는지 3). 소중한 후기 를 모두 보세요"),
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0.5),
          child: Text(
            "${currentUser.email!}님",
            style: TextStyle(fontSize: 8, color: Colors.grey[400]),
          ),
        ),
      ]),
    )
        //logged in as

        );
  }
}
