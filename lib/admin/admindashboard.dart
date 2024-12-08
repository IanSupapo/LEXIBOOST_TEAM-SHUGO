import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loginadmin');
    }
  }

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

  void _showNotificationsDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications for $userName'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Messages'),
                    Tab(text: 'Teacher Confirmations'),
                  ],
                  labelColor: Color(0xFF0486C7),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Messages Tab
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('mail')
                            .where('recipientId', isEqualTo: 'Admin123')
                            .where('senderId', isEqualTo: userId)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final messages = snapshot.data!.docs;
                          if (messages.isEmpty) {
                            return const Center(child: Text('No messages'));
                          }

                          return ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index].data() as Map<String, dynamic>;
                              final timestamp = message['timestamp'] as Timestamp?;
                              final formattedDate = timestamp != null
                                  ? DateFormat('MMM dd, yyyy HH:mm')
                                      .format(timestamp.toDate())
                                  : 'No date';

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  title: Text(
                                    message['message'] ?? 'No content',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (!message['isRead'])
                                        const Text(
                                          'New Message',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.reply),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showMessageDialog(userId, userName);
                                    },
                                  ),
                                  onTap: () async {
                                    await _firestore
                                        .collection('mail')
                                        .doc(messages[index].id)
                                        .update({'isRead': true});
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // Teacher Confirmations Tab
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('teacher_confirmations')
                            .where('userId', isEqualTo: userId)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final confirmations = snapshot.data!.docs;
                          if (confirmations.isEmpty) {
                            return const Center(
                                child: Text('No teacher confirmations'));
                          }

                          return ListView.builder(
                            itemCount: confirmations.length,
                            itemBuilder: (context, index) {
                              final confirmation =
                                  confirmations[index].data() as Map<String, dynamic>;
                              final timestamp = confirmation['timestamp'] as Timestamp?;
                              final formattedDate = timestamp != null
                                  ? DateFormat('MMM dd, yyyy HH:mm')
                                      .format(timestamp.toDate())
                                  : 'No date';

                              return ListTile(
                                title: Text(confirmation['status'] ?? 'Unknown status'),
                                subtitle: Text(formattedDate),
                                leading: Icon(
                                  confirmation['status'] == 'approved'
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: confirmation['status'] == 'approved'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Admin Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('mail')
                .where('recipientId', isEqualTo: 'Admin123')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading messages: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              }

              final messages = snapshot.data?.docs ?? [];
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                );
              }

              // Sort messages by timestamp
              messages.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime); // Descending order
              });

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index].data() as Map<String, dynamic>;
                  final senderId = message['senderId'] as String?;
                  final timestamp = message['timestamp'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat('MMM dd, yyyy HH:mm')
                          .format(timestamp.toDate())
                      : 'No date';

                  return FutureBuilder<DocumentSnapshot>(
                    future: senderId != null 
                        ? _firestore.collection('users').doc(senderId).get()
                        : null,
                    builder: (context, userSnapshot) {
                      String userName = 'Unknown User';
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        userName = (userSnapshot.data!.data() 
                            as Map<String, dynamic>)['fullname'] ?? 'Unknown User';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        color: message['isRead'] == true 
                            ? Colors.white 
                            : Colors.blue.shade50,
                        child: ListTile(
                          title: Text(
                            message['message'] ?? 'No content',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From: $userName',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              if (message['isRead'] != true)
                                const Text(
                                  'New Message',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: senderId != null ? IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () {
                              Navigator.pop(context);
                              _showMessageDialog(senderId, userName);
                            },
                          ) : null,
                          onTap: () async {
                            if (message['isRead'] != true) {
                              await _firestore
                                  .collection('mail')
                                  .doc(messages[index].id)
                                  .update({'isRead': true});
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
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
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF0486C7),
        actions: [
          // Notification Icon with Badge
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('mail')
                .where('recipientId', isEqualTo: 'Admin123')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => _showAdminNotifications(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Message Icon
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              // Add message functionality
            },
          ),
          // Settings Icon
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add settings functionality
            },
          ),
          // Logout Icon
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
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

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData = users[index].data() as Map<String, dynamic>;
                        final playerInfo = playerData[users[index].id] ?? {};
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF0486C7),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              userData['fullname'] ?? 'N/A',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['email'] ?? 'N/A',
                                  style: const TextStyle(fontFamily: 'Poppins'),
                                ),
                                Text(
                                  'Points: ${playerInfo['points'] ?? '0'} | Trophy: ${playerInfo['trophy'] ?? '0'}',
                                  style: const TextStyle(fontFamily: 'Poppins'),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.message),
                              color: const Color(0xFF0486C7),
                              onPressed: () => _showMessageDialog(
                                users[index].id,
                                userData['fullname'] ?? 'Unknown User',
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
        ],
      ),
    );
  }
}