import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              child: ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8,
                      MediaQuery.of(context).size.height * 0.1),
                ),
                child: const Text('Check'),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Correct!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);

    // Remove the overlay after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  void showCompletionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.6,
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
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ve completed all questions!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('achievements')
                      .where('title', isEqualTo: 'The Starter')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    
                    final achievement = snapshot.data!.docs.first;
                    final completedBy = List<String>.from(achievement['completedBy'] ?? []);
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                    
                    // Only show if user hasn't claimed it yet
                    if (!completedBy.contains(currentUserId)) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Achievement Unlocked!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The Starter',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Complete your first level',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    // Update achievement
                                    await achievement.reference.update({
                                      'completedBy': FieldValue.arrayUnion([user.uid])
                                    });

                                    // Add 100 points to player
                                    final playerDoc = FirebaseFirestore.instance
                                        .collection('player')
                                        .doc(user.uid);
                                    
                                    final playerSnapshot = await playerDoc.get();
                                    final currentPoints = playerSnapshot.data()?['points'] ?? 0;
                                    
                                    await playerDoc.update({
                                      'points': currentPoints + 100
                                    });

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Achievement claimed! +100 points'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Navigate back to solo screen
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(context, '/solo');
                                    }
                                  }
                                } catch (e) {
                                  print('Error claiming achievement: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Claim Achievement',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/solo');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Back to Solo Mode',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  void checkAnswer() async {
    final correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    final correctAnswers = questions[currentQuestionIndex]['correctAnswers'];

    // Determine which field to use
    final correctList = correctAnswer ?? correctAnswers;
    if (correctList == null) {
      print('Error: correctAnswer(s) is null');
      return;
    }

    // Convert to List<String> and compare
    List<String> correctAnswersList = List<String>.from(correctList);
    
    if (selectedAnswers.length != correctAnswersList.length) {
      // If not all blanks are filled
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

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }
}
