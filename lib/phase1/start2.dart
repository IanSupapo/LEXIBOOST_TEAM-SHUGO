import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shugo/phase1/Starting/starting.dart';
import 'package:shugo/phase2/home.dart';
import 'package:shugo/admin/loginadmin.dart';
import 'package:shugo/phase1/login/signup/login.dart';
import 'package:shugo/admin/admindashboard.dart';

class MyStart2 extends StatefulWidget {
  const MyStart2({super.key});

  @override
  State<MyStart2> createState() => _MyStart2State();
}

class _MyStart2State extends State<MyStart2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserState();
  }

  Future<void> _checkUserState() async {
    await Future.delayed(const Duration(seconds: 5));

    if (kIsWeb) {
      // Web platform - check only authentication
      User? user = _auth.currentUser;
      if (user != null) {
        // If authenticated, go directly to admin dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyDashboard()),
          );
        }
      } else {
        // If not authenticated, go to admin login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyAdmin()),
          );
        }
      }
    } else {
      // Mobile platform - check full profile
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          final DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;
            if (data != null &&
                data['fullname'] != null &&
                data['gender'] != null &&
                data['birthday'] != null) {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHome()),
                );
              }
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyStarting()),
              );
            }
          }
        } catch (e) {
          print("Error checking user profile: $e");
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyStarting()),
            );
          }
        }
      } else {
        // Not signed in, go to mobile login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyLogin()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0486C7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Logotext.png',
                height: 68,
                width: 332,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                kIsWeb ? 'Admin Portal' : 'Mobile App',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
