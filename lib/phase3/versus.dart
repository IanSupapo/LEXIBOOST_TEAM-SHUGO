import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shugo/phase3/game_room.dart';
import 'package:shugo/services/Firestore.dart';

class MyVersus extends StatelessWidget {
  const MyVersus({super.key});

  Future<void> _findMatch(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );

      // Check for available rooms
      final availableRooms = await FirebaseFirestore.instance
          .collection('game_rooms')
          .where('status', isEqualTo: 'waiting')
          .where('players', arrayContains: 1)
          .limit(1)
          .get();

      String roomId;
      final firestoreServices = FirestoreServices();

      if (availableRooms.docs.isEmpty) {
        // Create new room if none available
        roomId = await firestoreServices.createGameRoom(user.uid);
      } else {
        // Join existing room
        roomId = availableRooms.docs.first.id;
        await firestoreServices.joinGameRoom(roomId, user.uid);
      }

      // Navigate to game room
      if (context.mounted) {
        Navigator.pop(context); // Remove loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameRoom(roomId: roomId),
          ),
        );
      }
    } catch (e) {
      print('Error in matchmaking: $e');
      if (context.mounted) {
        Navigator.pop(context); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text(
          'Versus Mode',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: AnimatedButton(
            height: 40,
            width: 40,
            color: Colors.transparent,
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Image.asset(
              'assets/back.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Versus Mode",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    child: Image.asset(
                      'assets/award.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedButton(
            height: screenHeight * 0.08,
            width: screenWidth * 0.7,
            color: const Color.fromARGB(255, 206, 247, 160),
            onPressed: () => _findMatch(context),
            child: const Text(
              "Find Player",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "or",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedButton(
            height: screenHeight * 0.08,
            width: screenWidth * 0.7,
            color: const Color.fromARGB(255, 206, 247, 160),
            onPressed: () {
              Navigator.pushNamed(context, '/gameselect');
            },
            child: const Text(
              "Play with friend",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
