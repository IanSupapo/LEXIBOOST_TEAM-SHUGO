

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_button/animated_button.dart';

class MyPlay1 extends StatefulWidget {
  const MyPlay1({super.key});

  @override
  State<MyPlay1> createState() => _MyPlay1State();
}

class _MyPlay1State extends State<MyPlay1> {
  int health = 5;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String> selectedAnswers = [];
  bool isLoading = true;
  OverlayEntry? overlayEntry;
  Color _buttonColor = const Color(0xFFDAFEFC);

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('level1')
        .get();
    
    setState(() {
      questions = querySnapshot.docs.map((doc) => doc.data()).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.blue,
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
              'Fill in the blank',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Sentence with blanks
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSentenceWithBlanks(),
            ),

            // Draggable answer options
            Expanded(
              child: buildDraggableAnswers(),
            ),

            // Check button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedButton(
                onPressed: checkAnswer,
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.8,
                color: _buttonColor, // Use animated color
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

  Widget buildSentenceWithBlanks() {
    List<Widget> sentenceParts = [];
    final parts = questions[currentQuestionIndex]['sentenceParts'];
    
    for (int i = 0; i < parts.length; i++) {
      sentenceParts.add(Text(
        parts[i],
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ));
      
      if (i < parts.length - 1) {
        sentenceParts.add(const SizedBox(width: 8));
        sentenceParts.add(DragTarget<String>(
          onAccept: (data) {
            setState(() {
              if (selectedAnswers.length > i) {
                selectedAnswers[i] = data;
              } else {
                selectedAnswers.add(data);
              }
            });
          },
          onWillAccept: (data) => true,
          builder: (context, candidateData, rejectedData) {
            return selectedAnswers.length > i 
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAnswers.removeAt(i);
                      });
                    },
                    child: Draggable<String>(
                      data: selectedAnswers[i],
                      onDraggableCanceled: (velocity, offset) {
                        setState(() {});
                      },
                      onDragCompleted: () {
                        setState(() {
                          selectedAnswers.removeAt(i);
                        });
                      },
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: _buildBlankContainer(selectedAnswers[i]),
                      ),
                      childWhenDragging: _buildBlankContainer(''),
                      child: _buildBlankContainer(selectedAnswers[i]),
                    ),
                  )
                : _buildBlankContainer('');
          },
        ));
        sentenceParts.add(const SizedBox(width: 8));
      }
    }
    
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: sentenceParts.take((sentenceParts.length / 2).ceil()).toList(),
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: sentenceParts.skip((sentenceParts.length / 2).ceil()).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlankContainer(String text) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        minHeight: 35,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildDraggableAnswers() {
    final blanks = questions[currentQuestionIndex]['blanks'];
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(blanks.length, (index) {
            final answer = blanks[index];
            final isUsed = selectedAnswers.contains(answer);
            
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () {
                  if (isUsed) {
                    // Remove from selected answers if already used
                    setState(() {
                      selectedAnswers.remove(answer);
                    });
                  } else {
                    // Find first empty slot and add the answer
                    final correctAnswers = questions[currentQuestionIndex]['correctAnswer'] ?? 
                                         questions[currentQuestionIndex]['correctAnswers'];
                    if (correctAnswers != null && selectedAnswers.length < correctAnswers.length) {
                      setState(() {
                        selectedAnswers.add(answer);
                      });
                    }
                  }
                },
                child: Draggable<String>(
                  data: answer,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUsed ? Colors.grey[400] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isUsed ? Colors.grey[600] : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
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

    // Remove the overlay after animation completes
    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  void showCompletionModal() {
    // First handle achievement claiming
    _handleAchievement();

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
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                      ),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAchievement() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final achievementQuery = await FirebaseFirestore.instance
            .collection('achievements')
            .where('title', isEqualTo: 'The Starter')
            .get();

        if (achievementQuery.docs.isNotEmpty) {
          final achievement = achievementQuery.docs.first;
          final completedBy = List<String>.from(achievement['completedBy'] ?? []);

          if (!completedBy.contains(user.uid)) {
            // Update achievement
            await achievement.reference.update({
              'completedBy': FieldValue.arrayUnion([user.uid])
            });

            // Add points to player
            final playerDoc = FirebaseFirestore.instance
                .collection('player')
                .doc(user.uid);
            
            final playerSnapshot = await playerDoc.get();
            final currentPoints = playerSnapshot.data()?['points'] ?? 0;
            
            await playerDoc.update({
              'points': currentPoints + 100
            });

            // Show notification
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Achievement Unlocked: The Starter',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '+100 points',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error handling achievement: $e');
    }
  }

  void checkAnswer() async {
    final correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    final correctAnswers = questions[currentQuestionIndex]['correctAnswers'];

    final correctList = correctAnswer ?? correctAnswers;
    if (correctList == null) {
      print('Error: correctAnswer(s) is null');
      return;
    }

    List<String> correctAnswersList = List<String>.from(correctList);
    
    if (selectedAnswers.length != correctAnswersList.length) {
      return;
    }

    if (listEquals(selectedAnswers, correctAnswersList)) {
      // Show correct overlay
      showCorrectOverlay();
      
      // Add points to player's score
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final playerRef = FirebaseFirestore.instance
              .collection('player')
              .where('uid', isEqualTo: user.uid)
              .limit(1);
              
          final playerSnapshot = await playerRef.get();
          
          if (playerSnapshot.docs.isNotEmpty) {
            final playerDoc = playerSnapshot.docs.first;
            final currentPoints = playerDoc.data()['points'] ?? 0;
            
            // Add 50 points
            await playerDoc.reference.update({
              'points': currentPoints + 50
            });
          }
        }
      } catch (e) {
        print('Error updating points: $e');
      }
      
      if (currentQuestionIndex == questions.length - 1) {
        // Wait for "Correct!" overlay to finish
        await Future.delayed(const Duration(milliseconds: 1200));
        showCompletionModal();
      } else {
        await Future.delayed(const Duration(milliseconds: 1200));
        setState(() {
          currentQuestionIndex++;
          selectedAnswers.clear();
        });
      }
    } else {
      _wrongAnswerAnimation(); // Add shake and color change
      setState(() {
        health--;
        if (health <= 0) {
          showExplanationModal();
        }
      });
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
            Text(
              questions[currentQuestionIndex]['explanation'],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal
                Navigator.pushReplacementNamed(context, '/solo'); // Navigate to solo.dart
                // Alternative if you're not using named routes:
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MySolo()),
                // );
              },
              child: Text(""),
            ),
          ],
        ),
      ),
      isDismissible: false, // Prevent dismissing by tapping outside
      enableDrag: false, // Prevent dismissing by dragging down
    );
  }

  // Add shake animation method
  void _wrongAnswerAnimation() {
    setState(() {
      _buttonColor = Colors.red;
    });
    
    // Only color change animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _buttonColor = const Color(0xFFDAFEFC);
        });
      }
    });
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }
}
