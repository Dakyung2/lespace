
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/textfields/review_textfield.dart';



class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage>{

  //grab user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textControllerLocation = TextEditingController();

  void signUserOut(){
    FirebaseAuth.instance.signOut();

  }

  //post message method: put data into the firestore
  void postLocation(){
    //only post if there is something in the textfield
    if (textControllerLocation.text.isNotEmpty){
      FirebaseFirestore.instance.collection("Locations").add({
        'UserEmail': currentUser.email,
        'Location': textControllerLocation.text,
        'TimeStamp': Timestamp.now(),
      });
    }
    //clear the textfield
    textControllerLocation.clear();
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: const Color(0xe0d9e0e7),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut, icon: const Icon(Icons.logout,),)],
        title: const Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Icon(Icons.add_home_sharp, color:Color(0xffC62828), size: 40,),
              //Text('살아봄', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),),
            ],
          ),
        ),
        backgroundColor: const Color(0x94d9e0e7),
      ),
      body: Center(
        child: Column(
          children: [
            //the wall: collect data from firestore
            Expanded(
              child:
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("Locations").orderBy(
                  "TimeStamp",
                  descending: false,).snapshots(),
                builder: (context, snapshot){
                  if (snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        //get the locations
                        final post = snapshot.data!.docs[index];
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(top:25, left:25, right:25),
                          padding: const EdgeInsets.all(25),
                          child: Row(
                            children: [
                              Container(
                                decoration:
                                const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                padding: const EdgeInsets.all(3),
                                child: const Icon(Icons.location_on_rounded, color: Color(0xe0d9e0e7)),
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10,),
                                    Text(post['Location'].toString()),
                                  ],
                                ),
                              ),//comment
                            ],
                          ),
                        );
                             },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            //post Location
            Padding(
              padding: const EdgeInsets.only(top:25.0, right: 25, left: 25, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child:
                    Column(
                      children: [
                        ReviewTextField(
                          mylabel:'리뷰할 위치 추가하기' ,
                          myicon: const Icon(Icons.add_location_alt_rounded),
                          controller: textControllerLocation,
                          messagehintText: '도로명 주소',
                          obscureText: false,
                        ),
                      ],
                    ),
                  ),

                  //post button
                  IconButton(
                    onPressed: postLocation,
                    icon: const Icon(Icons.add_rounded, size: 45,color:Color(
                        0xff7f1515),),
                  ),
                  //SizedBox(width: 10,)
                ],
              ),
            ),
            //logged in as
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "${currentUser.email!}로 활동 중",
                style: TextStyle(
                    fontSize: 15, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

