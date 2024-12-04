
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shugo/PP.dart';
import 'package:shugo/TS.dart';
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
import 'package:shugo/phase3/level/level1.dart';
import 'package:shugo/phase3/level/level2.dart';
import 'package:shugo/phase3/solo.dart';
import 'package:shugo/phase3/versus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAjlu_d1T3MBlNrpdefh2mMkycj0OJGWqs",
          authDomain: "lexiboost-7de91.firebaseapp.com",
          projectId: "lexiboost-7de91",
          storageBucket: "lexiboost-7de91.firebasestorage.app",
          messagingSenderId: "303696333249",
          appId: "1:303696333249:web:a999b16984515765d60740",
          measurementId: "G-54FTGB3MMZ"));

  if(Firebase.apps.isNotEmpty) {
    // ignore: avoid_print
    print("Firebase connected successfully");
  } else {
    // ignore: avoid_print
    print("Connection Error. Please check the Firebase Configuration and Try Again");
  }



  runApp(const MyApp());
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
        '/PP' : (context) => const PrivacyPolicyPage(),
        '/TS' : (context) => const  TermsOfServicePage(),
        '/profile' : (context) => const MyProfile(),
        '/contact' : (context) => const MyContact(),
        '/achievement' : (contact) => const MyContact(),
        '/settings' : (context) => const MySettings(),
        '/rank' : (context) => const MyRank(),
        '/mail' : (context) => const MyMail(notifications: [],),
        '/solo' : (context) => const MySolo(),
        '/versus' : (context) => const MyVersus(),
        '/level1' : (context) => const MyLevel1(),
        '/level2' : (context) => const MyLevel2(),



      },
    );
  }
}
