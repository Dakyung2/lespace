
import 'package:admanager_web/admanager_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lespace/pages/auth/auth_page.dart';
import 'firebase_options.dart';



//Below is the main page with home: SearchPage or Homepage(listview)

//1. package:firebase_core/firebase_core.dart
//2. firebase_options.dart;

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  AdManagerWeb.init();

  if (kIsWeb){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyC1qNDYtsK9jOsT2qerR3Yew--9C-EJ9pA",
            authDomain: "empyrean-surge-395513.firebaseapp.com",
            appId: "1:768970769332:web:f91f04050c50f6c13068e1",
            messagingSenderId: "768970769332",
            projectId: "empyrean-surge-395513",
            storageBucket: "gs://empyrean-surge-395513.appspot.com/"
        )
    );
  }else{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});


  @override
  Widget build(BuildContext context){
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      navigatorObservers: [
        ],
      
      //routes: {

      // '/homepagefirestore': (context) => const HomePageFirestore(),
      //'/communitypage': (context) => const CommunityPage(),
      //},
    );
  }
}

