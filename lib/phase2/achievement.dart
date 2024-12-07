import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

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
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
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
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('achievements')
            .orderBy('position', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No achievements available",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: RawScrollbar(
              thumbVisibility: false,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final achievement = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final achievementId = snapshot.data!.docs[index].id;
                  final bool isClaimable = achievement['isClaimable'] ?? false;
                  final bool isCompleted = achievement['completedBy']?.contains(userId) ?? false;

                  return Container(
                    width: 400,
                    height: 110,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 2),
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
                            color: isCompleted ? Colors.green : Colors.blue.shade100,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: achievement['imageBase64'] != null && achievement['imageBase64'].isNotEmpty
                                ? Image.memory(
                                    base64Decode(achievement['imageBase64']),
                                    fit: BoxFit.contain,
                                  )
                                : Icon(Icons.emoji_events, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Text section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                achievement['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                achievement['description'] ?? 'No Description',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Points section
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${achievement['points']} pts',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Only show checkmark if completed
                            if (isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
