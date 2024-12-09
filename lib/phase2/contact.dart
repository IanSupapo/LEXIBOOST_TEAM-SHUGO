import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyContact extends StatelessWidget {
  const MyContact({super.key});

  static final TextEditingController _teacherIdController = TextEditingController();

  Future<void> _sendTeacherRequest(BuildContext context, String teacherId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      // First, verify if the teacher exists
      final teacherQuery = await FirebaseFirestore.instance
          .collection('teachers')
          .where('teacherId', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (teacherQuery.docs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher ID not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if trying to add self
      final teacherDoc = teacherQuery.docs.first;
      final teacherData = teacherDoc.data();
      final teacherUserId = teacherData['userId'];
      
      if (teacherUserId == currentUser.uid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You cannot add yourself as a contact'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check if contact already exists
      final existingContact = await FirebaseFirestore.instance
          .collection('contacts')
          .where('teacherId', isEqualTo: teacherId)
          .where('studentId', isEqualTo: currentUser.uid)
          .get();

      if (existingContact.docs.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already have this teacher in your contacts'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get current user's data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final userData = userDoc.data();
      final userName = userData?['fullname'] ?? 'Unknown User';

      // Create a unique contact ID
      final contactId = '${currentUser.uid}_${teacherUserId}';

      // Create contact document with a specific ID to prevent duplicates
      await FirebaseFirestore.instance.collection('contacts').doc(contactId).set({
        'teacherId': teacherId,
        'studentId': currentUser.uid,
        'teacherUserId': teacherUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send mail to teacher
      await FirebaseFirestore.instance.collection('mail').add({
        'message': '$userName would like to add you as their teacher.',
        'recipientId': teacherUserId,
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'teacher_request',
        'teacherId': teacherId,
      });

      if (context.mounted) {
        Navigator.pop(context); // Close the modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent to teacher'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeContact(BuildContext context, String contactId) async {
    try {
      // Show confirmation dialog
      final bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Remove Contact',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: const Text(
            'Are you sure you want to remove this contact?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      // Delete the contact document
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(contactId)
          .delete();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Contacts',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contacts')
            .where('studentId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final contacts = snapshot.data?.docs ?? [];

          if (contacts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Contacts Yet",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Add a teacher to get started",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final contactData = contact.data() as Map<String, dynamic>;
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('teachers')
                    .where('teacherId', isEqualTo: contactData['teacherId'])
                    .get()
                    .then((value) => value.docs.first),
                builder: (context, teacherSnapshot) {
                  if (!teacherSnapshot.hasData) {
                    return const Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: CircularProgressIndicator(),
                        ),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  final teacherData = teacherSnapshot.data!.data() as Map<String, dynamic>;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Text(
                        teacherData['fullName'] ?? 'Unknown Teacher',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherData['schoolName'] ?? 'Unknown School',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Teacher ID: ${teacherData['teacherId']}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeContact(context, contact.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Add Teacher",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _teacherIdController,
                        decoration: InputDecoration(
                          labelText: "Teacher's ID",
                          hintText: "Enter your teacher's ID",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_teacherIdController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a Teacher ID"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _sendTeacherRequest(context, _teacherIdController.text.trim());
                          },
                          icon: const Icon(Icons.person_add, color: Colors.white),
                          label: const Text(
                            "Send Request",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Add Teacher',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
    );
  }
}
