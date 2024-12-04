import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLevel1 extends StatefulWidget {
  const MyLevel1({super.key});

  @override
  State<MyLevel1> createState() => _MyLevel1State();
}

class _MyLevel1State extends State<MyLevel1> {
  final PageController _pageController = PageController();
  int _currentRound = 0;
  int _hearts = 5;

  // Game data for 5 rounds (will shuffle later)
  final List<Map<String, dynamic>> _gameData = [
    {
      'question': 'Tap what you hear',
      'correctAnswer': ['Daniel', 'likes', 'comedy'],
      'words': ['Daniel', 'sometimes', 'likes', 'comedy', 'cool'],
    },
    {
      'question': 'Tap what you hear',
      'correctAnswer': ['He', 'is', 'funny'],
      'words': ['He', 'is', 'sometimes', 'funny', 'great'],
    },
    {
      'question': 'Tap what you hear',
      'correctAnswer': ['Comedy', 'is', 'great'],
      'words': ['Comedy', 'is', 'sometimes', 'great', 'fun'],
    },
    {
      'question': 'Tap what you hear',
      'correctAnswer': ['She', 'is', 'amazing'],
      'words': ['She', 'is', 'amazing', 'funny', 'likes'],
    },
    {
      'question': 'Tap what you hear',
      'correctAnswer': ['Funny', 'people', 'win'],
      'words': ['Funny', 'people', 'sometimes', 'win', 'great'],
    },
  ];

  List<Map<String, dynamic>> _shuffledGameData = [];
  List<String> _selectedWords = [];

  @override
  void initState() {
    super.initState();
    _shuffleGameData();
  }

  // Shuffle game data for random order
  void _shuffleGameData() {
    _shuffledGameData = List.from(_gameData);
    _shuffledGameData.shuffle(Random());
  }

  // Unlock Level 2 and update "First Journey" achievement
  Future<void> _unlockLevel2AndAwardAchievement() async {
    final prefs = await SharedPreferences.getInstance();

    // Unlock Level 2
    await prefs.setBool('level2Unlocked', true);

    // Retrieve and update achievements
    List<Map<String, dynamic>> achievements = prefs.getString('achievements') == null
        ? [
            {
              'title': 'First Journey',
              'description': 'Play for the first time in solo adventure.',
              'completed': false,
            },
            // Add other achievements here if needed
          ]
        : List<Map<String, dynamic>>.from(
            jsonDecode(prefs.getString('achievements')!).map((e) => Map<String, dynamic>.from(e)),
          );

    // Mark "First Journey" as completed
    for (var achievement in achievements) {
      if (achievement['title'] == 'First Journey') {
        achievement['completed'] = true;
        break;
      }
    }

    // Save updated achievements
    await prefs.setString('achievements', jsonEncode(achievements));

    print('Achievements updated: $achievements');
  }

  // Check if the selected words are correct
  void _checkAnswer() {
    final currentRoundData = _shuffledGameData[_currentRound];

    if (_selectedWords.join(' ') == currentRoundData['correctAnswer'].join(' ')) {
      if (_currentRound < _shuffledGameData.length - 1) {
        setState(() {
          _currentRound++;
          _selectedWords = [];
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // User wins: Unlock Level 2, award achievement, and navigate back to MySolo
        _unlockLevel2AndAwardAchievement();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text(
                'You have completed Level 1! Level 2 is now unlocked and "First Journey" achievement is awarded.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, '/solo'); // Return to MySolo
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Incorrect answer, lose a heart
      setState(() {
        _hearts--;
        _selectedWords = [];
      });

      if (_hearts == 0) {
        // User loses: Navigate back to MySolo
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Game Over'),
            content: const Text('You lost all your hearts!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, '/solo'); // Return to MySolo
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentRound + 1) / _shuffledGameData.length,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue.shade600,
          ),

          // Display hearts
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.favorite,
                  color: index < _hearts ? Colors.red : Colors.grey,
                  size: 30,
                ),
              ),
            ),
          ),

          // Game Content (PageView)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _shuffledGameData.length,
              itemBuilder: (context, index) {
                final roundData = _shuffledGameData[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question
                    Text(
                      roundData['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DragTarget
                    DragTarget<String>(
                      onAccept: (word) {
                        setState(() {
                          if (!_selectedWords.contains(word)) {
                            _selectedWords.add(word);
                          }
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          height: 50,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _selectedWords
                                  .map(
                                    (word) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Chip(
                                        label: Text(word),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedWords.remove(word);
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Draggable and Tappable Words
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: roundData['words']
                          .map<Widget>(
                            (word) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!_selectedWords.contains(word)) {
                                    _selectedWords.add(word);
                                  }
                                });
                              },
                              child: Draggable<String>(
                                data: word,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Chip(
                                    label: Text(word),
                                    backgroundColor: Colors.blue.shade300,
                                  ),
                                ),
                                childWhenDragging: Chip(
                                  label: Text(word),
                                  backgroundColor: Colors.grey.shade400,
                                ),
                                child: Chip(
                                  label: Text(word),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              },
            ),
          ),

          // Check Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: _selectedWords.isNotEmpty ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                'CHECK',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
