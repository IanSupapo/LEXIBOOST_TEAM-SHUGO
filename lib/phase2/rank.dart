import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

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
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: containerHeight * 0.05,
                  horizontal: screenWidth * 0.025,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final fullName = user['fullname'] ?? 'No Name';
                  final userId = users[index].id;
                  final imageBase64 = user['image'] ?? '';

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('player')
                        .where('uid', isEqualTo: userId)
                        .get(),
                    builder: (context, playerSnapshot) {
                      String playerId = 'No ID';
                      int points = 0;
                      int trophy = 0;

                      if (playerSnapshot.connectionState == ConnectionState.done) {
                        if (playerSnapshot.hasData && playerSnapshot.data!.docs.isNotEmpty) {
                          final playerData = playerSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                          playerId = playerData['player_id']?.toString() ?? 'No ID';
                          points = playerData['points'] ?? 0;
                          trophy = playerData['trophy'] ?? 0;
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: screenWidth * 0.95,
                          height: containerHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                      child: imageBase64.isNotEmpty
                                          ? CircleAvatar(
                                              radius: imageSize / 2,
                                              backgroundImage: MemoryImage(
                                                base64Decode(imageBase64.split(',').last),
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
                                      fullName,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      'ID: $playerId',
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
                                          '$points',
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
                                          '$trophy',
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
