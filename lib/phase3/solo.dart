import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySolo extends StatefulWidget {
  const MySolo({super.key});

  @override
  State<MySolo> createState() => _MySoloState();
}

class _MySoloState extends State<MySolo> {
  // Level unlock status; Level 1 is always unlocked
  final List<bool> levelUnlocked = [true, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _loadUnlockStatus();
  }

  // Load the unlock status from SharedPreferences
  void _loadUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      levelUnlocked[1] = prefs.getBool('level2Unlocked') ?? false; // Level 2
      // You can add more levels here if needed
    });
  }

  // Show confirmation dialog when a level is selected
  void _showConfirmationDialog(BuildContext context, int level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Level $level"),
          content: const Text("Do you want to play this level?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the corresponding level page
                if (level == 1) {
                  Navigator.pushNamed(context, '/level1');
                } else if (level == 2) {
                  Navigator.pushNamed(context, '/level2'); // Implement Level 2 page
                } else {
                  // Add logic for other levels when implemented
                  print("Navigating to Level $level");
                }
              },
              child: const Text("Play"),
            ),
          ],
        );
      },
    );
  }

  // Build the level button widgets
  Widget _buildLevelButton(int levelIndex) {
    int displayLevel = levelIndex + 1; // Levels start from 1
    bool isUnlocked = levelUnlocked[levelIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          AnimatedButton(
            onPressed: () {
              if (isUnlocked) {
                _showConfirmationDialog(context, displayLevel);
              } else {
                // Do nothing or show a message for locked levels
                print("Level $displayLevel is locked.");
              }
            },
            height: 110,
            width: 110,
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background image
                ClipOval(
                  child: Image.asset(
                    'assets/badge.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay padlock image if level is locked
                if (!isUnlocked)
                  Center(
                    child: Image.asset(
                      'assets/padlock.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Level $displayLevel',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Stack(
        children: [
          // Back button at the top-left corner
          Positioned(
            top: 10,
            left: 10,
            child: AnimatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home'); // Navigate to home
              },
              height: 70,
              width: 120,
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/back.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content: Game levels
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => _buildLevelButton(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
