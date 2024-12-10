import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:animated_button/animated_button.dart';

class MyPlay3 extends StatefulWidget {
  const MyPlay3({super.key});

  @override
  State<MyPlay3> createState() => _MyPlay3State();
}

class _MyPlay3State extends State<MyPlay3> {
  int health = 5;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  String? selectedAnswer;
  bool isLoading = true;
  OverlayEntry? overlayEntry;
  Color _buttonColor = const Color(0xFFDAFEFC);

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('level3')
          .orderBy(FieldPath.documentId)
          .get();
      
      setState(() {
        questions = querySnapshot.docs.map((doc) {
          final data = doc.data();
          print('Question ${doc.id} data:');
          print('Options length: ${(data['options'] as List?)?.length}');
          if (data['options'] != null) {
            for (var i = 0; i < (data['options'] as List).length; i++) {
              print('Option $i imageBase64 exists: ${(data['options'][i]['imageBase64'] != null)}');
            }
          }
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['options'] as List?;
    
    if (options == null || options.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Text(
            'Error loading question data',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 18,
            ),
          ),
        ),
      );
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

            // Question Text
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                currentQuestion['question'] ?? 'No question available',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Image Options in 2x2 Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          currentQuestionIndex == 2 ? 3 : 4, 
                          (index) {
                            final options = questions[currentQuestionIndex]['options'] as List;
                            final option = index < options.length ? options[index] : null;
                            
                            if (currentQuestionIndex == 2 && index == 2) {
                              return Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: _buildOptionContainer(option),
                                ),
                              );
                            }
                            
                            return _buildOptionContainer(option);
                          }
                        ),
                      ),
                    ),
                  ),
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

    if (selectedAnswer == questions[currentQuestionIndex]['correctAnswer']) {
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

  Future<void> _claimAchievement() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('achievements')
            .doc('ac1C1EOZ61X9t6GMmVzw')
            .update({
          'completedBy': FieldValue.arrayUnion([user.uid])
        });

        final playerDoc = FirebaseFirestore.instance
            .collection('player')
            .doc(user.uid);
        
        final playerSnapshot = await playerDoc.get();
        final currentPoints = playerSnapshot.data()?['points'] ?? 0;
        
        await playerDoc.update({
          'points': currentPoints + 300
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Achievement unlocked! +300 points'),
              backgroundColor: Colors.green,
            ),
          );
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

  void showExplanationModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Try again!',
              style: TextStyle(
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

  Widget _buildOptionContainer(Map<String, dynamic>? option) {
    return GestureDetector(
      onTap: option != null ? () {
        setState(() {
          selectedAnswer = option['id'];
        });
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: selectedAnswer == option?['id'] ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: selectedAnswer == option?['id']
                ? Colors.green.shade700
                : Colors.transparent,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: option != null && option['imageBase64'] != null 
              ? Image.memory(
                  base64Decode(option['imageBase64']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }
}