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
  
  late Stream<DocumentSnapshot> gameStream;

  @override
  void initState() {
    super.initState();
    gameStream = FirebaseFirestore.instance
        .collection('game_rooms')
        .doc(widget.roomId)
        .snapshots();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Fetch random questions from all levels
    final allQuestions = await _fetchQuestionsFromAllLevels();
    questions = _selectRandomQuestions(allQuestions, maxRounds);
    trophyReward = Random().nextInt(6) + 15; // Random between 15-20
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchQuestionsFromAllLevels() async {
    List<Map<String, dynamic>> allQuestions = [];
    
    // Fetch from all levels
    for (int level = 1; level <= 3; level++) {
      final QuerySnapshot snapshot = await _firestore
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

  Future<void> _checkAnswer() async {
    if (currentQuestionIndex >= questions.length) return;
    
    final question = questions[currentQuestionIndex];
    final correctAnswer = question['answer'].toString().toLowerCase();
    final userAnswer = _answerController.text.trim().toLowerCase();

    if (userAnswer == correctAnswer) {
      // Update progress in Firestore
      await FirebaseFirestore.instance
          .collection('game_rooms')
          .doc(widget.roomId)
          .update({
        'gameState.playerProgress.${widget.playerId}.currentQuestion': 
            FieldValue.increment(1),
        'gameState.playerProgress.${widget.playerId}.score': 
            FieldValue.increment(1),
      });

      _answerController.clear();

      // Check if player won
      final doc = await FirebaseFirestore.instance
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();
      
      final gameState = doc.data()?['gameState'];
      if (gameState != null) {
        final myProgress = gameState['playerProgress'][widget.playerId];
        if (myProgress['currentQuestion'] >= 8) {
          // Player won - update game state and award trophies
          await FirebaseFirestore.instance
              .collection('game_rooms')
              .doc(widget.roomId)
              .update({
            'gameState.winner': widget.playerId,
            'gameState.isComplete': true,
          });

          if (user != null) {
            final userDoc = await _firestore.collection('users').doc(user!.uid).get();
            final currentTrophies = userDoc.data()?['trophy'] ?? 0;
            await _firestore.collection('users').doc(user!.uid).update({
              'trophy': currentTrophies + gameState['trophyReward'],
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        stream: gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          
          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final gameState = gameData['gameState'];
          final myProgress = gameState['playerProgress'][widget.playerId];
          final otherPlayer = gameState['playerProgress']
              .keys
              .firstWhere((id) => id != widget.playerId);
          final otherProgress = gameState['playerProgress'][otherPlayer];

          return Column(
            children: [
              // Show both players' progress
              _buildProgressIndicator(myProgress, otherProgress),
              
              // Show current question
              if (!gameState['isComplete'])
                _buildQuestionContainer(
                  gameState['questions'][myProgress['currentQuestion']]
                ),
                
              // Show game complete screen if there's a winner
              if (gameState['winner'] != null)
                _buildGameCompleteScreen(
                  gameState['winner'] == widget.playerId,
                  gameState['trophyReward']
                ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildQuestionContainer(Map<String, dynamic> question) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCompleteScreen(bool isWinner, int trophies) {
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
            Text(
              isWinner ? 'You Won!' : 'Game Over',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (isWinner) Text(
              'You won $trophies trophies!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Return to Menu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> myProgress, Map<String, dynamic> otherProgress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPlayerProgress('You', myProgress['currentQuestion']),
          _buildPlayerProgress('Opponent', otherProgress['currentQuestion']),
        ],
      ),
    );
  }

  Widget _buildPlayerProgress(String player, int questionsDone) {
    return Column(
      children: [
        Text(
          player,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          '$questionsDone/8',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}