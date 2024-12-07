import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class MyRank extends StatelessWidget {
  const MyRank({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final containerHeight = screenHeight * 0.1;
    final imageSize = containerHeight * 0.6;
    final titleFontSize = containerHeight * 0.20;
    final subtitleFontSize = containerHeight * 0.15;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.05),
        child: Align(
          alignment: Alignment.topCenter,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              final users = snapshot.data!.docs;
              
              // Create a list to store user data with their points and trophies
              List<Future<Map<String, dynamic>>> userDataFutures = users.map((user) async {
                final userData = user.data() as Map<String, dynamic>;
                final userId = user.id;
                
                // Get player data
                final playerSnapshot = await FirebaseFirestore.instance
                    .collection('player')
                    .where('uid', isEqualTo: userId)
                    .get();
                
                int points = 0;
                int trophy = 0;
                String playerId = 'No ID';
                
                if (playerSnapshot.docs.isNotEmpty) {
                  final playerData = playerSnapshot.docs.first.data();
                  points = playerData['points'] ?? 0;
                  trophy = playerData['trophy'] ?? 0;
                  playerId = playerData['player_id']?.toString() ?? 'No ID';
                }

                return {
                  'userId': userId,
                  'fullName': userData['fullname'] ?? 'No Name',
                  'imageBase64': userData['image'] ?? '',
                  'points': points,
                  'trophy': trophy,
                  'playerId': playerId,
                };
              }).toList();

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: Future.wait(userDataFutures),
                builder: (context, usersDataSnapshot) {
                  if (!usersDataSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Sort users by points (descending) and then by trophies (descending)
                  final sortedUsers = usersDataSnapshot.data!..sort((a, b) {
                    int pointsCompare = b['points'].compareTo(a['points']);
                    if (pointsCompare != 0) return pointsCompare;
                    return b['trophy'].compareTo(a['trophy']);
                  });

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: containerHeight * 0.05,
                      horizontal: screenWidth * 0.02,
                    ),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      final userData = sortedUsers[index];
                      final isCurrentUser = userData['userId'] == currentUserId;
                      
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: screenWidth * 0.99,
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: isCurrentUser ? Colors.green.shade200 : Colors.white,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: SizedBox(
                              height: containerHeight * 0.8,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentUser ? Colors.black : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: imageSize,
                                        height: imageSize,
                                        child: userData['imageBase64'].isNotEmpty
                                            ? CircleAvatar(
                                                radius: imageSize / 2,
                                                backgroundImage: MemoryImage(
                                                  base64Decode(userData['imageBase64'].split(',').last),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: imageSize / 2,
                                                backgroundColor: Colors.grey,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: imageSize * 0.6,
                                                ),
                                              ),
                                      ),
                                      title: Text(
                                        userData['fullName'],
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'ID: ${userData['playerId']}',
                                        style: TextStyle(
                                          fontSize: subtitleFontSize,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                            'assets/medal.png',
                                            height: imageSize * 0.5,
                                            width: imageSize * 0.5,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${userData['points']}',
                                            style: TextStyle(
                                              fontSize: subtitleFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Image.asset(
                                            'assets/Trophy2.png',
                                            height: imageSize * 0.5,
                                            width: imageSize * 0.5,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${userData['trophy']}',
                                            style: TextStyle(
                                              fontSize: subtitleFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
