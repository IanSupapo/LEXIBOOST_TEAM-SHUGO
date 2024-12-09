import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/phase3/level/gamestart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GameRoom extends StatefulWidget {
  final String roomId;
  const GameRoom({super.key, required this.roomId});

  @override
  State<GameRoom> createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final user = FirebaseAuth.instance.currentUser;
  
  Stream<DocumentSnapshot> get roomStream => FirebaseFirestore.instance
      .collection('game_rooms')
      .doc(widget.roomId)
      .snapshots();

  late final _matchRef = FirebaseFirestore.instance
      .collection('game_rooms')
      .doc(widget.roomId)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data() ?? {},
        toFirestore: (data, _) => data,
      );

  StreamSubscription? _gameStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupRoom();
    _listenToGameState();
  }

  void _listenToGameState() {
    _gameStateSubscription = _matchRef.snapshots().listen((snapshot) {
      if (!mounted) return;

      final gameState = snapshot.data()?['gameState'];
      final status = snapshot.data()?['status'] as String?;
      final players = List<String>.from(snapshot.data()?['players'] ?? []);

      if (players.length == 2 && status == 'ready' && gameState == null) {
        _initializeGameState();
      } else if (status == 'in_progress' && gameState != null) {
        _startGame();
      }
    });
  }

  Future<void> _setupRoom() async {
    final roomDoc = await _matchRef.get();
    final roomData = roomDoc.data();
    
    if (roomData != null) {
      if (!roomData.containsKey('roomCode')) {
        final roomCode = _generateRoomCode();
        await _matchRef.update({
          'roomCode': roomCode,
        });
      }

      final players = List<String>.from(roomData['players'] ?? []);
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
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level1')
          .get();

      final allQuestions = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
      
      allQuestions.shuffle(Random());
      final selectedQuestions = allQuestions.take(3).toList();
      final trophyReward = Random().nextInt(6) + 15;

      await FirebaseFirestore.instance
          .collection('game_rooms')
          .doc(widget.roomId)
          .update({
        'gameState': {
          'questions': selectedQuestions,
          'currentRound': 1,
          'playerProgress': {
            user!.uid: {'score': 0, 'currentQuestion': 0},
          },
          'trophyReward': trophyReward,
          'winner': null,
          'isComplete': false,
        },
        'status': 'in_progress',
      });

    } catch (e) {
      print('Error initializing game state: $e');
    }
  }

  void _startGame() {
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

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    super.dispose();
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
          final roomCode = roomData['roomCode'] as String?;

          if (players.length == 2) {
            if (status == 'ready' && roomData['gameState'] == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeGameState();
              });
            } else if (status == 'in_progress' && roomData['gameState'] != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startGame();
              });
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Image.asset(
                          'assets/patience.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (roomCode != null) ...[
                        const Text(
                          'Room Code:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          roomCode,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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