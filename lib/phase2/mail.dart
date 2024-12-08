import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyMail extends StatelessWidget {
  final List<String> notifications;

  const MyMail({super.key, required this.notifications});

  Future<void> _updateMessageStatus(String messageId, bool isRead) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('mail')
          .doc(messageId)
          .update({
            'isRead': isRead,
          });
    } catch (e) {
      print('Error updating message status: $e');
      // Silently fail - don't affect user experience
    }
  }

  Future<void> _showMessageDialog(BuildContext context, Map<String, dynamic> messageData, String messageId) async {
    try {
      final timestamp = messageData['timestamp'] as Timestamp?;
      final formattedDate = timestamp != null
          ? DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate())
          : 'No date';

      // Try to update read status but don't wait for it
      _updateMessageStatus(messageId, true);

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 500,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Message from Admin',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            messageData['message']?.toString() ?? 'No message content',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sent on: $formattedDate',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (messageData['recipientId'] != null) // Only show buttons if recipient exists
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('mail')
                                      .doc(messageId)
                                      .delete();
                                  
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Message deleted'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting message: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text(
                                'Reply',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                String? senderId = messageData['senderId'] as String?;
                                Navigator.of(dialogContext).pop();
                                _showReplyDialog(context, senderId);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing message dialog: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error displaying message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReplyDialog(BuildContext context, String? senderId) {
    final TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reply to Admin',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Type your reply...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a message'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  throw 'User not authenticated';
                }

                // Get admin document ID
                final adminDoc = await FirebaseFirestore.instance
                    .collection('Admin')
                    .doc('Admin123')
                    .get();

                if (!adminDoc.exists) {
                  throw 'Admin not found';
                }

                // Create new message
                await FirebaseFirestore.instance.collection('mail').add({
                  'message': replyController.text,
                  'recipientId': 'Admin123', // Send to admin
                  'senderId': currentUser.uid,
                  'timestamp': FieldValue.serverTimestamp(),
                  'isRead': false,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('Error sending reply: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending reply: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0486C7),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Mail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                "Please sign in to view messages",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mail')
                  .where('recipientId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No new messages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                messages.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final messageId = messages[index].id;
                    final isRead = messageData['isRead'] ?? false;
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate())
                        : 'No date';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: isRead ? Colors.white : Colors.blue.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.mail,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                        title: Text(
                          'Message from Admin',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                        trailing: isRead
                            ? null
                            : const Icon(
                                Icons.fiber_new,
                                color: Colors.blue,
                              ),
                        onTap: () async {
                          try {
                            await _showMessageDialog(context, messageData, messageId);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

