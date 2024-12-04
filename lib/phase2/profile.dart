import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_button/animated_button.dart'; // For the animated button
import 'package:intl/intl.dart'; // For date formatting

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: currentUser == null
          ? const Center(
              child: Text(
                'No user logged in',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile container
                    Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.white,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double circleSize = constraints.maxWidth * 0.4;
                            return Container(
                              width: circleSize,
                              height: circleSize,
                              margin: const EdgeInsets.symmetric(vertical: 20.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Profile details
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid) // Fetch data for the logged-in user
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                              child: Text(
                                "Profile data not found",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          // Extract fields with null-aware operator
                          final fullName = userData['fullname'] ?? 'No Name';
                          final description = userData ['description'] ?? 'No Description';
                          final email = userData['email'] ?? 'No Email';
                          final gender = userData['gender'] ?? 'No Gender';

                          // Format the creation date
                          final Timestamp? createdAt =
                              userData['createdAt'] as Timestamp?;
                          final String formattedDate = createdAt != null
                              ? DateFormat.yMMMMd().format(createdAt.toDate())
                              : 'Unknown';

                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$fullName',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$description',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$email',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Color.fromARGB(195, 255, 255, 255),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$gender',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Color.fromARGB(195, 255, 255, 255),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Joined: $formattedDate',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Color.fromARGB(195, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Add AnimatedButton in the upper-right corner
                Positioned(
                  top: 20,
                  right: 20,
                  child: AnimatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            
                            
                            elevation: 16,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Fullname',
                                        border: OutlineInputBorder(),
                                      ),
                                      controller: TextEditingController(), // Use a controller to manage input
                                      style: TextStyle(fontSize: 16),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    height: 50,
                    width: 50,
                    child: Image.asset(
                      'assets/edit.png',
                      width: 30,
                      height: 30,
                    ),
                    color: Colors.blueAccent,
                    shadowDegree: ShadowDegree.dark,
                  ),
                ),
              ],
            ),
    );
  }
}
