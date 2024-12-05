import 'package:flutter/material.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart'; // Ensure this path is correct.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class MyStarting4 extends StatefulWidget {
  const MyStarting4({super.key});

  @override
  State<MyStarting4> createState() => _MyStarting4State();
}

class _MyStarting4State extends State<MyStarting4> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addUserData() async {
    try {
      // Get the current user
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Generate a new player_id
      final playerId = await _generatePlayerId();
      
      // Add a new document to the 'player' collection
      await _firestore.collection('player').doc(user.uid).set({
        'uid': user.uid,
        'points': 0,
        'rank': 0,
        'trophy': 0,
        'player_id': playerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // If successful, navigate to home
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating player: $e')),
      );
    }
  }

  Future<String> _generatePlayerId() async {
    final querySnapshot = await _firestore.collection('player').get();
    final count = querySnapshot.docs.length;
    return (count + 1).toString().padLeft(4, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/1.png',
                    width: 350,
                    height: 350,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Now let's start",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 5.0,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "our journey here!",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 5.0,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  continueButton(
                    onPressed: () {
                      _addUserData();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
