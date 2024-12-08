import 'package:flutter/material.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_button/animated_button.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:shugo/phase1/login/signup/login.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String? selectedAddress;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _addresseeController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  bool _isPasswordObscured = true;

  // Add validation function
  void validateFields() {
    List<String> emptyFields = [];
    
    if (_schoolNameController.text.isEmpty) {
      emptyFields.add('School Name');
    }
    if (_teacherIdController.text.isEmpty) {
      emptyFields.add('Teacher ID Number');
    }
    if (_addresseeController.text.isEmpty) {
      emptyFields.add('Address');
    }

    if (emptyFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Required Fields Empty',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            content: Text(
              'Please fill in the following fields:\n\n${emptyFields.join('\n')}',
              style: const TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // All required fields are filled
      print('All fields valid, sending data...');
      // Add your send functionality here
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final username = user.email!.split('@')[0];
        final hashedPassword = hashPassword(currentPassword);
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .get();
        
        return userDoc.data()?['password'] == hashedPassword;
      }
      return false;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  Future<void> updatePassword() async {
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final isCurrentPasswordValid = await verifyCurrentPassword(_currentPasswordController.text);
    if (!isCurrentPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Update password in Firebase Auth
        await user.updatePassword(_newPasswordController.text);

        // Update password in Firestore
        final username = user.email!.split('@')[0];
        final hashedPassword = hashPassword(_newPasswordController.text);
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({'password': hashedPassword});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      reusableWidget(
                        textController: _currentPasswordController,
                        labelText: "Current Password",
                        context: context,
                        isPassword: true,
                        isPasswordObscured: _isPasswordObscured,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      reusableWidget(
                        textController: _newPasswordController,
                        labelText: "New Password",
                        context: context,
                        isPassword: true,
                        isPasswordObscured: _isPasswordObscured,
                        showEyeIcon: false,
                      ),
                      const SizedBox(height: 20),
                      reusableWidget(
                        textController: _confirmPasswordController,
                        labelText: "Confirm Password",
                        context: context,
                        isPassword: true,
                        isPasswordObscured: _isPasswordObscured,
                        showEyeIcon: false,
                      ),
                      const SizedBox(height: 30),
                      AnimatedButton(
                        onPressed: updatePassword,
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: const Color(0xFFDAFEFC),
                        child: const Center(
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
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
                      const SizedBox(height: 20),
                      AnimatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: SingleChildScrollView(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              "Teacher Registration",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                reusableWidget(
                                                  textController: _schoolNameController,
                                                  labelText: "School Name",
                                                  context: context,
                                                  isPassword: false,
                                                  labelColor: Colors.blue,
                                                ),
                                                const SizedBox(height: 20),
                                                reusableWidget(
                                                  textController: _teacherIdController,
                                                  labelText: "Teacher ID Number",
                                                  context: context,
                                                  isPassword: false,
                                                  labelColor: Colors.blue,
                                                ),
                                                const SizedBox(height: 20),
                                                reusableWidget(
                                                  textController: _addresseeController,
                                                  labelText: "Address",
                                                  context: context,
                                                  isPassword: false,
                                                  labelColor: Colors.blue,
                                                ),
                                                const SizedBox(height: 20),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Description",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.6,
                                                      height: MediaQuery.of(context).size.height * 0.2,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(color: Colors.black),
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: TextField(
                                                        controller: _descriptionController,
                                                        maxLines: null,
                                                        expands: true,
                                                        maxLength: 120,
                                                        textAlignVertical: TextAlignVertical.top,
                                                        decoration: const InputDecoration(
                                                          contentPadding: EdgeInsets.all(15),
                                                          border: InputBorder.none,
                                                          hintText: 'Enter description (max 120 words)...',
                                                          hintStyle: TextStyle(
                                                            fontFamily: 'Poppins',
                                                            color: Colors.grey,
                                                          ),
                                                          counterText: '',
                                                        ),
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                        onChanged: (text) {
                                                          final words = text.split(' ');
                                                          if (words.length > 120) {
                                                            _descriptionController.text = words.take(120).join(' ');
                                                            _descriptionController.selection = TextSelection.fromPosition(
                                                              TextPosition(offset: _descriptionController.text.length),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    AnimatedButton(
                                                      onPressed: validateFields,
                                                      height: MediaQuery.of(context).size.height * 0.07,
                                                      width: MediaQuery.of(context).size.width * 0.5,
                                                      color: Colors.green,
                                                      child: const Center(
                                                        child: Text(
                                                          'Send',
                                                          style: TextStyle(
                                                            fontFamily: 'Poppins',
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: AnimatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            height: MediaQuery.of(context).size.height * 0.06,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            color: Colors.blue.shade400,
                                            child: const Center(
                                              child: Text(
                                                'Close',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
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
                                ),
                              );
                            },
                          );
                        },
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            "I'm a Teacher",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
                      const SizedBox(height: 20),
                      AnimatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      // Navigate to login page and remove all previous routes
                                      if (mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MyLogin()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
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
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _teacherIdController.dispose();
    _addresseeController.dispose();
    _streetController.dispose();
    _subdivisionController.dispose();
    _postalCodeController.dispose();
    _descriptionController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }
}