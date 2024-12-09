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
  int maxRounds = 3;
  bool isGameComplete = false;
  String? winner;
  int trophyReward = 0;
  
  // Game state
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String currentAnswer = '';
  bool isCorrect = false;
  bool showAnswer = false;
  Color buttonColor = Colors.blue.shade400;

  // Add these variables
  late Stream<DocumentSnapshot> _gameStream;
  bool _isLoadingQuestions = true;
  bool _mounted = true;
  
  List<String> scrambledWords = [];
  List<String> correctWords = [];
  
  String scrambleWord(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    // Make sure the scrambled word is different from the original
    while (letters.join() == word && word.length > 1) {
      letters.shuffle();
    }
    return letters.join();
  }

  List<String> getFixedScrambledWords() {
    return [
      'suptooc',  // octopus
      'gnorad',   // dragon
      'htrome',   // mother
    ];
  }

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
    if (!mounted) return;
    
    try {
      final gameDoc = await _firestore
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();

      final gameData = gameDoc.data();
      if (gameData != null) {
        final gameState = gameData['gameState'] as Map<String, dynamic>?;
        
        if (gameState != null && gameState['questions'] != null) {
          questions = List<Map<String, dynamic>>.from(gameState['questions'] as List);
          correctWords = ['octopus', 'dragon', 'mother'];
          scrambledWords = getFixedScrambledWords();
        } else {
          // Use our predefined words
          correctWords = ['octopus', 'dragon', 'mother'];
          scrambledWords = getFixedScrambledWords();
          
          questions = correctWords.map((word) => {
            'word': word,
            'scrambled': scrambledWords[correctWords.indexOf(word)],
          }).toList();

          // Initialize game state for both players
          await _firestore.collection('game_rooms').doc(widget.roomId).update({
            'gameState': {
              'questions': questions,
              'playerProgress': {
                widget.playerId: {
                  'score': 0,
                  'currentQuestion': 0,
                },
                // Initialize other player's progress if they haven't joined yet
                'player2': {
                  'score': 0,
                  'currentQuestion': 0,
                }
              },
              'lastUpdated': FieldValue.serverTimestamp(),
              'winner': null,
              'isComplete': false,
            }
          });
        }

        // Initialize player progress if not exists
        final playerProgress = gameState?['playerProgress'] as Map<String, dynamic>?;
        if (playerProgress == null || !playerProgress.containsKey(widget.playerId)) {
          await _firestore.collection('game_rooms').doc(widget.roomId).update({
            'gameState.playerProgress.${widget.playerId}': {
              'score': 0,
              'currentQuestion': 0,
            }
          });
        }

        if (_mounted) {
          setState(() {
            _isLoadingQuestions = false;
            currentQuestionIndex = (playerProgress?[widget.playerId]?['currentQuestion'] as int?) ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error initializing game: $e');
      if (_mounted) {
        setState(() {
          _isLoadingQuestions = false;
        });
      }
    }
  }

  Future<void> _checkAnswer() async {
    if (!mounted) return;
    if (currentQuestionIndex >= correctWords.length) return;
    
    final correctWord = correctWords[currentQuestionIndex];
    final userAnswer = _answerController.text.trim().toLowerCase();

    setState(() {
      isCorrect = userAnswer == correctWord.toLowerCase();
      showAnswer = true;
      buttonColor = isCorrect ? Colors.green : Colors.red;
    });

    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Update player progress
      await _firestore.collection('game_rooms').doc(widget.roomId).update({
        'gameState.playerProgress.${widget.playerId}.currentQuestion': 
            FieldValue.increment(1),
        'gameState.playerProgress.${widget.playerId}.score': 
            FieldValue.increment(1),
      });

      // Get updated game state to check if player completed all rounds
      final gameDoc = await _firestore
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();
      
      final gameState = gameDoc.data()?['gameState'];
      final playerProgress = gameState?['playerProgress']?[widget.playerId];
      final currentScore = playerProgress?['score'] ?? 0;

      // Check if player has completed all 5 rounds
      if (currentScore >= maxRounds) {
        await _endGame();
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() {
        currentQuestionIndex++;
        currentRound++;
        _answerController.clear();
        showAnswer = false;
        buttonColor = Colors.blue.shade400;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incorrect! Try again.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        _answerController.clear();
        showAnswer = false;
        buttonColor = Colors.blue.shade400;
      });
    }
  }

  Future<void> _endGame() async {
    try {
      // Get the current game state
      final roomDoc = await _firestore
          .collection('game_rooms')
          .doc(widget.roomId)
          .get();

      final gameState = roomDoc.data()?['gameState'];
      
      // Only proceed if there's no winner yet
      if (gameState != null && gameState['winner'] == null) {
        // Mark the game as complete and set the winner
        await _firestore.collection('game_rooms').doc(widget.roomId).update({
          'gameState.winner': widget.playerId,
          'gameState.isComplete': true,
        });

        // Award trophies to the winner
        if (user != null) {
          final trophyReward = Random().nextInt(6) + 15; // 15-20 trophies
          
          // Get current trophies
          final userDoc = await _firestore.collection('users').doc(user!.uid).get();
          final currentTrophies = userDoc.data()?['trophy'] ?? 0;
          
          // Update trophies in Firestore
          await _firestore.collection('users').doc(user!.uid).update({
            'trophy': currentTrophies + trophyReward,
          });

          // Also update the game room with the trophy information
          await _firestore.collection('game_rooms').doc(widget.roomId).update({
            'gameState.trophyAwarded': trophyReward,
            'gameState.winnerUid': user!.uid,
          });

          setState(() {
            this.trophyReward = trophyReward;
            isGameComplete = true;
            winner = widget.playerId;
          });
        }
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
      resizeToAvoidBottomInset: true,
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

          // Check if game is complete
          if (gameState['isComplete'] == true) {
            final gameWinner = gameState['winner'];
            if (gameWinner != null) {
              // Show game complete screen for both players
              return _buildGameCompleteScreen(
                isWinner: gameWinner == widget.playerId
              );
            }
          }

          if (_isLoadingQuestions) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
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

          if (gameState == null || questions.isEmpty) {
            return const Center(
              child: Text(
                'Error loading game state',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            );
          }
          if (currentQuestionIndex >= questions.length) {
            return _buildGameCompleteScreen(isWinner: false);
          }

          return _buildQuestionScreen(questions[currentQuestionIndex]);
        },
      ),
    );
  }

  Widget _buildQuestionScreen(Map<String, dynamic> question) {
    final scrambledWord = scrambledWords[currentQuestionIndex];
    
    return Scrollbar(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add players' progress here
              StreamBuilder<DocumentSnapshot>(
                stream: _gameStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final gameData = snapshot.data!.data() as Map<String, dynamic>;
                  return _buildPlayersProgress(gameData['gameState']);
                },
              ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Fix the spelling:",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        scrambledWord,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Enter the correct spelling',
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
                    ),
                    const SizedBox(height: 20),
                    AnimatedButton(
                      onPressed: _checkAnswer,
                      height: 50,
                      width: 200,
                      color: buttonColor,
                      child: Text(
                        showAnswer ? (isCorrect ? 'Correct!' : 'Wrong!') : 'Submit',
                        style: const TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildGameCompleteScreen({required bool isWinner}) {
    return Scrollbar(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
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
                  'Finish!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: _gameStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'Loading results...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                        ),
                      );
                    }

                    final gameData = snapshot.data!.data() as Map<String, dynamic>;
                    final gameState = gameData['gameState'];
                    final trophyAwarded = gameState['trophyAwarded'] as int?;

                    return Text(
                      isWinner 
                        ? 'Congratulations! You won ${trophyAwarded ?? 0} trophies!'
                        : 'Game Over! Your opponent won.',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                      ),
                    );
                  },
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
        ),
      ),
    );
  }

  Widget _buildPlayersProgress(Map<String, dynamic> gameState) {
    final playerProgress = gameState['playerProgress'] as Map<String, dynamic>;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: playerProgress.entries.map((entry) {
          final isCurrentPlayer = entry.key == widget.playerId;
          final progress = entry.value as Map<String, dynamic>;
          final currentQuestion = progress['currentQuestion'] as int;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: isCurrentPlayer ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  isCurrentPlayer ? 'You' : 'Opponent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  'Question ${currentQuestion + 1}/5',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _mounted = false;
    _answerController.dispose();
    super.dispose();
  }
}