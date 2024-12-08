import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:animated_button/animated_button.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final _fullNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isUploadingImage = false;

  Future<void> _uploadImage({bool isBackground = false}) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      // Read image bytes and convert to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Update Firestore with base64 string
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          isBackground ? 'backgroundImage' : 'image': base64Image,
        });

        setState(() {
          if (!isBackground) {
            _imageUrl = base64Image;
          }
        });
      }

    } catch (e) {
      print('Error picking/uploading image: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _initializeControllers(Map<String, dynamic> userData) {
    _fullNameController.text = userData['fullname'] ?? '';
    _descriptionController.text = userData['description'] ?? '';
    if (userData['image'] != null) {
      setState(() {
        _imageUrl = userData['image'];
      });
    }
    if (userData['backgroundImage'] != null) {
      setState(() {
        _imageUrl = userData['backgroundImage'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final storedImage = userData?['image'] as String?;

                // Debug print to check the stored image
                print('Stored image exists: ${storedImage != null}');
                
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: (userData?['backgroundImage'] != null || _imageUrl != null)
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(_imageUrl ?? storedImage!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
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
                                    image: (storedImage != null || _imageUrl != null)
                                        ? DecorationImage(
                                            image: MemoryImage(
                                              base64Decode(_imageUrl ?? storedImage!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
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

                              final fullName = userData['fullname'] ?? 'No Name';
                              final description =
                                  userData['description'] ?? 'No Description';
                              final email = userData['email'] ?? 'No Email';
                              final gender = userData['gender'] ?? 'No Gender';

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
                                      fullName,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        color: Color.fromARGB(195, 255, 255, 255),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      gender,
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
                    Positioned(
                      top: 20,
                      right: 20,
                      child: AnimatedButton(
                        onPressed: () {
                          // Reset controllers
                          _fullNameController.clear();
                          _descriptionController.clear();
                          
                          // Get current user data
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get()
                              .then((doc) {
                            if (doc.exists) {
                              _initializeControllers(doc.data() as Map<String, dynamic>);
                            }
                          });

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                elevation: 16,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25.0),
                                    boxShadow: const [
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
                                      children: [
                                        const Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _fullNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Full Name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _descriptionController,
                                          decoration: const InputDecoration(
                                            labelText: 'Description',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _isUploadingImage 
                                              ? null 
                                              : () => _uploadImage(isBackground: false),
                                          child: _isUploadingImage 
                                              ? const CircularProgressIndicator() 
                                              : const Text('Upload Profile Image'),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _isUploadingImage 
                                              ? null 
                                              : () => _uploadImage(isBackground: true),
                                          child: _isUploadingImage 
                                              ? const CircularProgressIndicator() 
                                              : const Text('Upload Background Image'),
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final firestore = FirebaseFirestore.instance;
                                              final updates = {
                                                'fullname': _fullNameController.text,
                                                'description': _descriptionController.text,
                                              };
                                              
                                              if (_imageUrl != null) {
                                                updates['image'] = _imageUrl!;
                                              }
                                              if (_imageUrl != null) {
                                                updates['backgroundImage'] = _imageUrl!;
                                              }

                                              await firestore
                                                  .collection('users')
                                                  .doc(currentUser.uid)
                                                  .update(updates);

                                              print('Profile updated successfully');
                                              if (mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            } catch (e) {
                                              print('Error updating profile: $e');
                                            }
                                          },
                                          child: const Text('Save Changes'),
                                        ),
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
                        color: Colors.blueAccent,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
