import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shugo/Final%20Phase/account.dart';
import 'package:shugo/Final%20Phase/privacy.dart';
import 'package:shugo/Final%20Phase/terms.dart';
import 'package:shugo/admin/admindashboard.dart';
import 'package:shugo/admin/loginadmin.dart';
import 'package:shugo/admin/manage.dart';

import 'package:shugo/phase1/Starting/starting.dart';
import 'package:shugo/phase1/Starting/starting2.dart';
import 'package:shugo/phase1/Starting/starting3.dart';
import 'package:shugo/phase1/Starting/starting4.dart';
import 'package:shugo/phase1/login/signup/forgot.dart';
import 'package:shugo/phase1/login/signup/login.dart';
import 'package:shugo/phase1/login/signup/signup.dart';
import 'package:shugo/phase1/start.dart';
import 'package:shugo/phase1/start2.dart';
import 'package:shugo/phase2/contact.dart';
import 'package:shugo/phase2/home.dart';
import 'package:shugo/phase2/mail.dart';
import 'package:shugo/phase2/profile.dart';
import 'package:shugo/phase2/rank.dart';
import 'package:shugo/phase2/settings.dart';
import 'package:shugo/phase3/level/gameselect.dart';
import 'package:shugo/phase3/level/gamestart.dart';
import 'package:shugo/phase3/level/play1.dart';
import 'package:shugo/phase3/level/play2.dart';
import 'package:shugo/phase3/level/play3.dart';
import 'package:shugo/phase3/solo.dart';
import 'package:shugo/phase3/versus.dart';
import 'package:flutter/foundation.dart';
import 'package:shugo/services/Firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  // Remove the multiplayer initialization for now
  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    // For Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAjlu_d1T3MBlNrpdefh2mMkycj0OJGWqs",
        authDomain: "lexiboost-7de91.firebaseapp.com",
        projectId: "lexiboost-7de91",
        storageBucket: "lexiboost-7de91.firebasestorage.app",
        messagingSenderId: "303696333249",
        appId: "1:303696333249:web:a999b16984515765d60740",   
        measurementId: "G-54FTGB3MMZ",
      ),
    );  
    debugPrint("Firebase successfully initialized to Web.");
  } else {
    await Firebase.initializeApp();
    debugPrint("Firebase successfully initialized to Mobile.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "LEXIBOOST",
    
      debugShowCheckedModeBanner: false,
      initialRoute: '/start',
      routes: {
        '/start': (context) => const MyStart(),
        '/start2': (context) => const MyStart2(),
        '/signup': (context) => const MySignup(),
        '/login': (context) => const MyLogin(),
        '/forgot': (context) => const MyForgot(),
        '/starting': (context) => const MyStarting(),
        '/starting2': (context) => const MyStarting2(),
        '/starting3': (context) => const MyStarting3(),
        '/starting4': (context) => const MyStarting4(),
        '/home' : (context) => const MyHome(),
        '/profile' : (context) => const MyProfile(),
        '/contact' : (context) => const MyContact(),
        '/achievement' : (contact) => const MyContact(),
        '/settings' : (context) => const MySettings(),
        '/rank' : (context) => const MyRank(),
        '/mail' : (context) => const MyMail(notifications: [],),
        '/solo' : (context) => const MySolo(),
        '/versus' : (context) => const MyVersus(),
        '/play1' : (context) => const MyPlay1(),
        '/play2' : (context) => const MyPlay2(),
        '/play3' : (context) => const MyPlay3(),
        '/account' : (context) => const MyAccount(),
        '/privacy' : (context) => const MyPrivacy(),
        '/terms' : (context) => const MyTerms(),
        '/gameselect' : (context) => const MySelect(),
        '/loginadmin' : (context) => const MyAdmin(),
        '/dashboard' : (context) => const MyDashboard(),
        '/manage' : (context) => const MyManage(),


      },
    );
  }
}
