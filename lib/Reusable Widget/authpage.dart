import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/phase1/Starting/starting.dart';
import 'package:shugo/phase2/home.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // User already logged in
      await _navigateBasedOnProfile(user);
    } else {
      // Prompt user to sign in
      _googleSignInAndAuthenticate();
    }
  }

  Future<void> _googleSignInAndAuthenticate() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;
        if (user != null) {
          await _navigateBasedOnProfile(user);
        }
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  Future<void> _navigateBasedOnProfile(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists &&
        userDoc.data()?['fullname'] != null &&
        userDoc.data()?['birthday'] != null &&
        userDoc.data()?['gender'] != null) {
      // User has completed profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHome()),
      );
    } else {
      // User has not completed profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyStarting()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
