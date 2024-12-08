import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shugo/services/user_management.dart';


class MyManage extends StatefulWidget {
  const MyManage({super.key});

  @override
  State<MyManage> createState() => _MyManageState();
}

class _MyManageState extends State<MyManage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showMessageDialog(String userId, String userName) {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message to $userName'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Enter your message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                await _firestore.collection('mail').add({
                  'message': messageController.text,
                  'recipientId': userId,
                  'timestamp': FieldValue.serverTimestamp(),
                  'isRead': false,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent successfully')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0486C7),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF0486C7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('player').snapshots(),
              builder: (context, playerSnapshot) {
                if (playerSnapshot.hasError) {
                  return Center(child: Text('Error: ${playerSnapshot.error}'));
                }

                if (playerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = userSnapshot.data!.docs;
                final players = playerSnapshot.data!.docs;

                Map<String, Map<String, dynamic>> playerData = {};
                for (var player in players) {
                  final data = player.data() as Map<String, dynamic>;
                  if (data['uid'] != null) {
                    playerData[data['uid']] = data;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 20,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Full Name',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Email',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Gender',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Player ID',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Points',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Trophy',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Created At',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Message',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: users.map((userDoc) {
                                  final userData = userDoc.data() as Map<String, dynamic>;
                                  final playerInfo = playerData[userDoc.id] ?? {};
                                  
                                  String createdAt = 'N/A';
                                  if (playerInfo['createdAt'] != null) {
                                    Timestamp timestamp = playerInfo['createdAt'];
                                    createdAt = DateFormat('dd/MM/yyyy HH:mm')
                                        .format(timestamp.toDate());
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(userData['fullname'] ?? 'N/A')),
                                      DataCell(Text(userData['email'] ?? 'N/A')),
                                      DataCell(Text(userData['gender'] ?? 'N/A')),
                                      DataCell(Text(playerInfo['player_id']?.toString() ?? 'N/A')),
                                      DataCell(Text(playerInfo['points']?.toString() ?? '0')),
                                      DataCell(Text(playerInfo['trophy']?.toString() ?? '0')),
                                      DataCell(Text(createdAt)),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.message),
                                          color: const Color(0xFF0486C7),
                                          onPressed: () => _showMessageDialog(
                                            userDoc.id,
                                            userData['fullname'] ?? 'Unknown User',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}