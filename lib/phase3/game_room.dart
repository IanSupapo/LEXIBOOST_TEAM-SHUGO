import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/phase3/level/gamestart.dart';
import 'package:shugo/services/Firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GameRoom extends StatefulWidget {
  final String roomId;
  const GameRoom({super.key, required this.roomId});

  @override
  State<GameRoom> createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final user = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> get roomStream => FirebaseFirestore.instance
      .collection('game_rooms')
      .doc(widget.roomId)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _setupRoom();
  }

  Future<void> _setupRoom() async {
    // Get current room data
    final roomDoc = await FirebaseFirestore.instance
        .collection('game_rooms')
        .doc(widget.roomId)
        .get();

    final roomData = roomDoc.data();
    if (roomData != null) {
      final players = List<String>.from(roomData['players'] ?? []);
      
      // If this is the second player joining
      if (players.length == 2 && !players.contains(user!.uid)) {
        await FirebaseFirestore.instance
            .collection('game_rooms')
            .doc(widget.roomId)
            .update({
          'players': FieldValue.arrayUnion([user!.uid]),
          'status': 'ready',
        });
      }
    }
  }

  Future<void> _initializeGameState() async {
    try {
      final questions = await _fetchQuestionsFromAllLevels();
      final selectedQuestions = _selectRandomQuestions(questions, 8);
      final trophyReward = Random().nextInt(6) + 15;

      final roomDoc = await FirebaseFirestore.instance
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();

      final roomData = roomDoc.data();
      if (roomData != null) {
        final players = List<String>.from(roomData['players']);

        await FirebaseFirestore.instance
            .collection('game_rooms')
            .doc(widget.roomId)
            .update({
          'gameState': {
            'questions': selectedQuestions,
            'currentRound': 1,
            'playerProgress': {
              players[0]: {'score': 0, 'currentQuestion': 0},
              players[1]: {'score': 0, 'currentQuestion': 0},
            },
            'trophyReward': trophyReward,
            'winner': null,
            'isComplete': false,
            'startTime': FieldValue.serverTimestamp(),
          },
          'status': 'in_progress',
        });

        print('Game state initialized successfully');
      }
    } catch (e) {
      print('Error initializing game state: $e');
    }
  }

  void _startGame(List<String> players) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyGamer(
            roomId: widget.roomId,
            playerId: user!.uid,
          ),
        ),
      );
    }
  }

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
          final status = roomData['status'] as String?;

          // Handle game state transitions
          if (players.length == 2) {
            if (status == 'ready' && roomData['gameState'] == null) {
              // Initialize game when both players are ready
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeGameState();
              });
            } else if (status == 'in_progress' && roomData['gameState'] != null) {
              // Start game when initialized
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startGame(players);
              });
            }
          }

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
                      Text(
                        _getStatusMessage(players.length, status),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: players.length == 2 ? 20 : 16,
                          fontWeight: players.length == 2 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: players.length == 2 
                              ? Colors.green 
                              : Colors.grey,
                        ),
                      ),
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

  String _getStatusMessage(int playerCount, String? status) {
    if (playerCount < 2) return 'Waiting for opponent...';
    if (status == 'ready') return 'Game Ready!';
    if (status == 'in_progress') return 'Starting Game...';
    return 'Preparing Game...';
  }

  Future<List<Map<String, dynamic>>> _fetchQuestionsFromAllLevels() async {
    List<Map<String, dynamic>> allQuestions = [];
    
    for (int level = 1; level <= 3; level++) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('level$level')
          .get();
          
      final questions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      allQuestions.addAll(questions);
    }
    
    return allQuestions;
  }

  List<Map<String, dynamic>> _selectRandomQuestions(List<Map<String, dynamic>> questions, int count) {
    final random = Random();
    questions.shuffle(random);
    return questions.take(count).toList();
  }
} 