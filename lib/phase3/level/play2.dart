import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:animated_button/animated_button.dart';

class MyPlay2 extends StatefulWidget {
  const MyPlay2({super.key});

  @override
  State<MyPlay2> createState() => _MyPlay2State();
}

class _MyPlay2State extends State<MyPlay2> {
  int health = 5;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  String? selectedAnswer;
  bool isLoading = true;
  OverlayEntry? overlayEntry;
  final AudioPlayer audioPlayer = AudioPlayer();
  Color _buttonColor = const Color(0xFFDAFEFC);
  

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('level2')
        .orderBy(FieldPath.documentId)
        .get();
    
    setState(() {
      questions = querySnapshot.docs.map((doc) => doc.data()).toList();
      isLoading = false;
    });
  }

  Future<void> playAudio(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      final source = BytesSource(bytes);
      await audioPlayer.play(source);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: SafeArea(
        child: Column(
          children: [
            // Health and Progress Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (index) => Icon(
                      index < health ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    )),
                  ),
                  Text('${currentQuestionIndex + 1}/${questions.length}'),
                ],
              ),
            ),

            const Text(
              'Tap what you hear',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Audio play buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      playAudio(questions[currentQuestionIndex]['audioBase64']);
                    },
                    icon: const Icon(Icons.volume_up),
                    iconSize: 48,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Answer options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: (questions[currentQuestionIndex]['options'] as List)
                      .map((option) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAnswer = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedAnswer == option
                                ? Colors.blue.shade700
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: selectedAnswer == option
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ))
                      .toList(),
                ),
              ),
            ),

            // Check button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedButton(
                onPressed: checkAnswer,
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.8,
                color: _buttonColor,
                child: const Text(
                  'Check',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAnswer() {
    if (selectedAnswer == null) return;

    if (selectedAnswer == questions[currentQuestionIndex]['correctWord']) {
      showCorrectOverlay();
      
      if (currentQuestionIndex == questions.length - 1) {
        // If it's the last question, claim achievement first then show completion modal
        _claimAchievement().then((_) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            showCompletionDialog();
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1200), () {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
          });
        });
      }
    } else {
      _wrongAnswerAnimation();
      setState(() {
        health--;
        if (health <= 0) {
          showExplanationModal();
        }
      });
    }
  }

  void showCorrectOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value > 0.5 ? 1.0 - value : value * 2,
                  child: Transform.scale(
                    scale: value * 1.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48, 
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Correct!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);

    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  // Simplified completion dialog without achievement UI
  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ve completed all questions!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/solo');
                  },
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.blue.shade300,
                  child: const Text(
                    'Back to Solo Mode',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showExplanationModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              questions[currentQuestionIndex]['explanation'] ?? 'Try again!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/solo');
              },
              child: const Text('Back to Solo Mode'),
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  void _wrongAnswerAnimation() {
    setState(() {
      _buttonColor = Colors.red;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _buttonColor = const Color(0xFFDAFEFC);
        });
      }
    });
  }

  Future<void> _claimAchievement() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get achievement document for "Newbie"
        final achievementQuery = await FirebaseFirestore.instance
            .collection('achievements')
            .where('title', isEqualTo: 'Newbie')
            .limit(1)  // Add limit to ensure we only get one document
            .get();

        if (achievementQuery.docs.isNotEmpty) {
          final achievementDoc = achievementQuery.docs.first;
          
          // Check if user hasn't already completed this achievement
          final completedBy = List<String>.from(achievementDoc.data()['completedBy'] ?? []);
          if (!completedBy.contains(user.uid)) {
            // Update achievement completion
            await achievementDoc.reference.update({
              'completedBy': FieldValue.arrayUnion([user.uid])
            });

            // Update player points
            final playerDoc = FirebaseFirestore.instance
                .collection('player')
                .doc(user.uid);
            
            final playerSnapshot = await playerDoc.get();
            final currentPoints = playerSnapshot.data()?['points'] ?? 0;
            
            await playerDoc.update({
              'points': currentPoints + 100
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Achievement unlocked: Newbie! +100 points'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } else {
          print('Achievement "Newbie" not found in Firestore');
        }
      }
    } catch (e) {
      print('Error claiming achievement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    audioPlayer.dispose();
    super.dispose();
  }
}