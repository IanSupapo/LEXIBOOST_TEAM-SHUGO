import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAchievement extends StatelessWidget {
  MyAchievement({super.key});

  // Firebase Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Method to build an achievement card
  Widget buildAchievementCard({
    required String imagePath,
    required String title,
    required String description,
    required bool completed,
  }) {
    return Container(
      width: 400,
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: completed ? Colors.green.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circle container for the image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? Colors.green : Colors.blue.shade100,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 20), // Spacing between image and text
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.w800, // ExtraBold
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Checkmark for completed tasks
          if (completed)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 30,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Achievements",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: const Center(
        child: Text(
          "No achievements available",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
