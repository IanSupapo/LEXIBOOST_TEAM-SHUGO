import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/phase3/game_room.dart';

class MySelect extends StatefulWidget {
  const MySelect({super.key});

  @override
  State<MySelect> createState() => _MySelectState();
}

class _MySelectState extends State<MySelect> {
  final TextEditingController _roomCodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _createRoom() async {
    try {
      // Create a new room
      final roomRef = await _firestore.collection('game_rooms').add({
        'hostId': user!.uid,
        'players': [user!.uid],
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'gameType': 'friend',
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameRoom(roomId: roomRef.id),
          ),
        );
      }
    } catch (e) {
      print('Error creating room: $e');
    }
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room code')),
      );
      return;
    }

    try {
      // Find the room document by room code
      final querySnapshot = await _firestore
          .collection('game_rooms')
          .where('roomCode', isEqualTo: roomCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room not found')),
          );
        }
        return;
      }

      final roomDoc = querySnapshot.docs.first;
      final roomData = roomDoc.data();
      final players = List<String>.from(roomData['players'] ?? []);

      // Check if room is full
      if (players.length >= 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room is full')),
          );
        }
        return;
      }

      // Check if player is not already in the room
      if (!players.contains(user!.uid)) {
        // Add player to room
        await _firestore
            .collection('game_rooms')
            .doc(roomDoc.id)
            .update({
          'players': FieldValue.arrayUnion([user!.uid]),
          'status': 'ready',
        });
      }

      // Navigate to game room
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameRoom(roomId: roomDoc.id),
          ),
        );
      }
    } catch (e) {
      print('Error joining room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text(
          'Play with Friend',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Create Room Button
            AnimatedButton(
              height: 50,
              width: 200,
              color: const Color.fromARGB(255, 206, 247, 160),
              onPressed: _createRoom,
              child: const Text(
                'Create Room',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'OR',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            // Join Room Section
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _roomCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Room Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedButton(
                    height: 50,
                    width: 200,
                    color: const Color.fromARGB(255, 206, 247, 160),
                    onPressed: _joinRoom,
                    child: const Text(
                      'Join Room',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }
}