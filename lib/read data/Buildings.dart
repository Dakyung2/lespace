
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lespace/pages/building_pages/buildings_reviews_page.dart';
import 'package:lespace/pages/building_pages/comment_page.dart';

import '../pages/info_pages/my_page.dart';
import '../pages/info_pages/room_info_page.dart';
class ReadBuilding extends StatefulWidget {
  const ReadBuilding({super.key});

  @override
  State<ReadBuilding> createState() => _ReadBuildingState();
}

class _ReadBuildingState extends State<ReadBuilding> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _addressController = TextEditingController();

  final CollectionReference _buildings = FirebaseFirestore.instance.collection("Buildings");
  String? buildingId;

  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }

  Future <void> _update([DocumentSnapshot? documentSnapshot]) async{
    //grab current value from documentSnapshot
    if (documentSnapshot != null){
      _addressController.text = documentSnapshot["Address"];
    }
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx){
          return Padding(
            padding: EdgeInsets.only(
              top: 20, left: 20, right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom +20
            ),
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "주소"),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String address = _addressController.text;
                      if (address.isNotEmpty){
                        await _buildings
                            .doc(documentSnapshot!.id) //pass the id
                            .update({"Address": address});
                        _addressController.text = "";
                      }
                },
                    child: const Text("추가"))
              ],
            ),
          );
        });
  }
  Future <void> _add([DocumentSnapshot? documentSnapshot]) async{
    //grab current value from documentSnapshot
    if (documentSnapshot != null){
      _addressController.text = documentSnapshot["Address"];
    }
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx){
          return Padding(
            padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom +20
            ),
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "주소"),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String address = _addressController.text;
                      if (address.isNotEmpty){
                        await _buildings.add({"Address": address});
                        _addressController.text = "";
                      }
                    },
                    child: const Text("추가"))
              ],
            ),
          );
        });
  }

  Future<void> _delete(String buildingId) async{
    await _buildings.doc(buildingId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("성공적으로 삭제했습니다")));}

  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xe0d9e0e7),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff8cb5e0),
        onPressed: ()=> _add(),
        child: const Icon(Icons.add_home_rounded,
         ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
             // Icon(Icons.add_home_sharp, color:Color(0xffC62828), size: 30,),
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
              ListTile(
                leading: const Icon(Icons.add_home_rounded),
                title: const Text(
                  "소중한 후기",
                  style: TextStyle(fontSize: 15),
                ),
                onTap: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)=>  const BuildingsReviewPage())
                  );
                  // Navigator.pop(context);
                },
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

              ListTile(
                leading: const Icon(Icons.add_home_rounded),
                title: const Text(
                  "좋은 집, 어떻게 판단해요? (beta)",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)=> const RoomInfoPage())
                  );
                  // Navigator.pop(context);
                },
              ),

            ],
          ),
        ),

      ),
      body:
      SafeArea(
        child: StreamBuilder(
            stream: _buildings.snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot> streamSnapshot){
              if (streamSnapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (streamSnapshot.hasData){
                return ListView.builder(
                  shrinkWrap: true,
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index){
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return Container(
                        decoration: BoxDecoration(
                            color: const Color(0xecffffff),
                            borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.only(top:14, left:14, right:14),
                        padding: const EdgeInsets.only(top: 4, left: 14, right: 8, bottom: 4),
                        child:
                          ListTile(
                            title: Text(documentSnapshot["Address"]),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  /*IconButton(
                                      onPressed: () =>
                                      _update(documentSnapshot),
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () =>
                                          _delete(documentSnapshot.id),
                                      icon: const Icon(Icons.delete)),*/
                                 IconButton(
                                     onPressed: () async {
                                       final buildingId = documentSnapshot.id;
                                       if (buildingId.isNotEmpty){
                                         Navigator.of(context).push(
                                           MaterialPageRoute(
                                               builder: (context){
                                             return CommentPage(
                                                 documentId: buildingId);
                                           }
                                           ),
                                         );
                                       }
                                     },
                                     icon: const Icon(Icons.transit_enterexit_rounded,),
                                   ),
                                     const Expanded(child: Text("입장"))
                                ],
                              ),
                            )
                          ),
                      );
                    }
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
    ),
      ),
    );
  }
}


