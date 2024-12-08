import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class MyGamer extends StatefulWidget {
  final String roomId;
  final String playerId;
  
  const MyGamer({
    super.key,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<MyGamer> createState() => _MyGamerState();
}

class _MyGamerState extends State<MyGamer> {
  final TextEditingController _answerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  
  int currentRound = 1;
  int maxRounds = 8;
  bool isGameComplete = false;
  String? winner;
  int trophyReward = 0;
  
  // Game state
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String currentAnswer = '';
  bool isCorrect = false;

  // Add these variables
  late Stream<DocumentSnapshot> _gameStream;
  bool _isLoadingQuestions = true;
  
  @override
  void initState() {
    super.initState();
    _gameStream = _firestore
        .collection('game_rooms')
        .doc(widget.roomId)
        .snapshots();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      // Fetch questions in parallel using Future.wait
      final futures = await Future.wait([
        _firestore.collection('level1')
            .limit(10)  // Limit the number of documents
            .get(),
        _firestore.collection('level2')
            .limit(10)  // Limit the number of documents
            .get(),
      ]);

      final level1Questions = futures[0].docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((data) => data['question'] != null && data['answer'] != null)
          .toList();

      final level2Questions = futures[1].docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((data) => data['question'] != null && data['answer'] != null)
          .toList();

      final allQuestions = [...level1Questions, ...level2Questions];
      questions = _selectRandomQuestions(allQuestions, maxRounds);
      trophyReward = Random().nextInt(6) + 15;

      // Cache the questions in the game room document
      await _firestore.collection('game_rooms').doc(widget.roomId).update({
        'gameState.questions': questions,
      });

      setState(() {
        _isLoadingQuestions = false;
      });
    } catch (e) {
      print('Error initializing game: $e');
    }
  }

  List<Map<String, dynamic>> _selectRandomQuestions(List<Map<String, dynamic>> questions, int count) {
    if (questions.isEmpty) return [];
    
    final random = Random();
    questions.shuffle(random);
    return questions.take(count).toList();
  }

  Future<void> _checkAnswer() async {
    if (currentQuestionIndex >= questions.length) return;
    
    final question = questions[currentQuestionIndex];
    final correctAnswer = question['answer'].toString().toLowerCase();
    final userAnswer = _answerController.text.trim().toLowerCase();

    setState(() {
      isCorrect = userAnswer == correctAnswer;
    });

    if (isCorrect) {
      // Show correct answer feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Update progress in Firestore
      await _firestore
          .collection('game_rooms')
          .doc(widget.roomId)
          .update({
        'gameState.playerProgress.${widget.playerId}.currentQuestion': 
            FieldValue.increment(1),
        'gameState.playerProgress.${widget.playerId}.score': 
            FieldValue.increment(1),
      });

      setState(() {
        currentQuestionIndex++;
        currentRound++;
        _answerController.clear();

        if (currentRound > maxRounds) {
          _endGame();
        }
      });
    } else {
      // Show incorrect answer feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect! The answer is: $correctAnswer'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      _answerController.clear();
    }
  }

  Future<void> _endGame() async {
    try {
      final roomDoc = await _firestore
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();

      final gameState = roomDoc.data()?['gameState'];
      if (gameState != null) {
        // Award trophies to winner
        if (user != null) {
          final userDoc = await _firestore.collection('users').doc(user!.uid).get();
          final currentTrophies = userDoc.data()?['trophy'] ?? 0;
          
          await _firestore.collection('users').doc(user!.uid).update({
            'trophy': currentTrophies + trophyReward,
          });
        }

        setState(() {
          isGameComplete = true;
          winner = widget.playerId;
        });
      }
    } catch (e) {
      print('Error ending game: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text(
          'Versus Game',
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
        stream: _gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final gameState = gameData['gameState'];

          if (_isLoadingQuestions) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading questions...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (gameState == null) {
            return const Center(child: Text('Waiting for game to start...'));
          }

          if (isGameComplete) {
            return _buildGameCompleteScreen();
          }

          if (currentQuestionIndex >= questions.length) {
            return const Center(child: Text('Loading questions...'));
          }

          return _buildQuestionScreen(questions[currentQuestionIndex]);
        },
      ),
    );
  }

  Widget _buildQuestionScreen(Map<String, dynamic> question) {
    // Add null check for question
    if (question['question'] == null) {
      return const Center(
        child: Text(
          'Error loading question',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Round $currentRound/$maxRounds',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Question container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Question text
                Text(
                  question['question'].toString(),  // Convert to string
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Answer input
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: 'Enter your answer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _checkAnswer(),
                ),
                const SizedBox(height: 20),
                // Submit button
                AnimatedButton(
                  onPressed: _checkAnswer,
                  height: 50,
                  width: 200,
                  color: Colors.blue.shade400,
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCompleteScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Complete!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You won $trophyReward trophies!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) => route.isFirst || route.settings.name == '/versus'
                );
              },
              height: 50,
              width: 200,
              color: Colors.blue,
              child: const Text(
                'Return to Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}