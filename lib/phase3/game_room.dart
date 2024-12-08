import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/services/Firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameRoom extends StatefulWidget {
  final String roomId;
  const GameRoom({super.key, required this.roomId});

  @override
  State<GameRoom> createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  Stream<DocumentSnapshot> get roomStream => FirebaseFirestore.instance
      .collection('game_rooms')
      .doc(widget.roomId)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text(
          'Game Room',
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: roomStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>;
          final players = List<String>.from(roomData['players'] ?? []);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Image.asset(
                          'assets/patience.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Players: ${players.length}/2',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (players.length < 2)
                        const Text(
                          'Waiting for opponent...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      if (players.length == 2)
                        const Text(
                          'Game Ready!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 