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
import 'package:shugo/Reusable%20Widget/reusable_widget.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final _fullNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _profileImageUrl;
  String? _backgroundImageUrl;
  bool _isUploadingImage = false;

  Future<void> _uploadImage({bool isBackground = false}) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 50,
      );
      
      if (image == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      final cleanBase64 = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          isBackground ? 'backgroundImage' : 'image': cleanBase64,
        });

        setState(() {
          if (isBackground) {
            _backgroundImageUrl = cleanBase64;
          } else {
            _profileImageUrl = cleanBase64;
          }
        });
      }

    } catch (e) {
      print('Error picking/uploading image: $e');
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
        _profileImageUrl = userData['image'];
      });
    }
    if (userData['backgroundImage'] != null) {
      setState(() {
        _backgroundImageUrl = userData['backgroundImage'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
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
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: (userData?['backgroundImage'] != null || _backgroundImageUrl != null)
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(
                                        (_backgroundImageUrl ?? userData?['backgroundImage'] ?? '')
                                            .replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '')
                                      ),
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
                                    image: (userData?['image'] != null || _profileImageUrl != null)
                                        ? DecorationImage(
                                            image: MemoryImage(
                                              base64Decode(
                                                (_profileImageUrl ?? userData?['image'] ?? '')
                                                    .replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '')
                                              ),
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
                                    const SizedBox(height: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      child: const Divider(
                                        color: Colors.white,
                                        thickness: 1,
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
                                  height: MediaQuery.of(context).size.height * 0.9,
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
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: RawScrollbar(
                                          thumbColor: Colors.blue.withOpacity(0.6),
                                          radius: const Radius.circular(20),
                                          thickness: 5,
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 10.0,
                                            ),
                                            child: Column(
                                              children: [
                                                reusableWidget(
                                                  textController: _fullNameController,
                                                  labelText: "Full Name",
                                                  context: context,
                                                  isPassword: false,
                                                  labelColor: Colors.blue,
                                                ),
                                                const SizedBox(height: 20),
                                                reusableWidget(
                                                  textController: _descriptionController,
                                                  labelText: "Description",
                                                  context: context,
                                                  isPassword: false,
                                                  labelColor: Colors.blue,
                                                  isDescription: true,
                                                ),
                                                const SizedBox(height: 20),
                                                AnimatedButton(
                                                  onPressed: _isUploadingImage 
                                                      ? () {} 
                                                      : () => _uploadImage(isBackground: false),
                                                  height: MediaQuery.of(context).size.height * 0.08,
                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                  color: Colors.blue.shade400,
                                                  child: _isUploadingImage 
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                            'Profile Image',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(height: 20),
                                                AnimatedButton(
                                                  onPressed: _isUploadingImage 
                                                      ? () {} 
                                                      : () => _uploadImage(isBackground: true),
                                                  height: MediaQuery.of(context).size.height * 0.08,
                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                  color: Colors.blue.shade400,
                                                  child: _isUploadingImage 
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                            'Background Image',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: AnimatedButton(
                                          onPressed: () async {
                                            try {
                                              final firestore = FirebaseFirestore.instance;
                                              final updates = {
                                                'fullname': _fullNameController.text,
                                                'description': _descriptionController.text,
                                              };
                                              
                                              if (_profileImageUrl != null) {
                                                updates['image'] = _profileImageUrl!;
                                              }
                                              if (_backgroundImageUrl != null) {
                                                updates['backgroundImage'] = _backgroundImageUrl!;
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
                                          height: MediaQuery.of(context).size.height * 0.08,
                                          width: MediaQuery.of(context).size.width * 0.6,
                                          color: Colors.green,
                                          child: const Center(
                                            child: Text(
                                              'Save Changes',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
