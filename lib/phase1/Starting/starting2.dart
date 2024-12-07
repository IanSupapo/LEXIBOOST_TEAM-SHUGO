import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shugo/Reusable%20Widget/other_widget.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart';

class MyStarting2 extends StatefulWidget {
  const MyStarting2({super.key});

  @override
  State<MyStarting2> createState() => _MyStarting2State();
}

class _MyStarting2State extends State<MyStarting2> {
  final TextEditingController fullNameController = TextEditingController();
  String? selectedGender = 'Male';
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: const Alignment(0, -1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/4.png',
                    width: constraints.maxWidth * 0.8,
                    height: constraints.maxHeight * 0.3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04),
                    child: Text(
                      "Could you please tell us who you are?",
                      style: TextStyle(
                        fontSize: constraints.maxHeight * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 5.0,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  reusableWidget(
                    textController: fullNameController,
                    labelText: 'Full Name',
                    isPassword: false,
                    context: context,
                  ),
                  reusableDropdown(
                    labelText: 'Gender',
                    dropdownValue: selectedGender,
                    dropdownOptions: ['Male', 'Female'],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGender = newValue;
                      });
                    },
                    context: context,
                  ),
                  reusableDatePicker(
                    context: context,
                    labelText: 'Birthday',
                    selectedDate: selectedDate,
                    onDateChanged: (DateTime? newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : continueButton(
                          onPressed: _saveUserData,
                          context: context,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveUserData() async {
    // Validate input fields
    if (fullNameController.text.isEmpty ||
        selectedGender == null ||
        selectedDate == null) {
      _showDialog("Error", "Please fill out all fields.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in.");
      }

      // Prepare data to save
      final userData = {
        'fullname': fullNameController.text.trim(),
        'gender': selectedGender,
        'birthday': selectedDate!.toIso8601String(),
      };

      // Save data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Navigate to the next path
      Navigator.pushNamed(context, '/starting3');
    } catch (e) {
      print("Error saving user data: $e");
      _showDialog("Error", "Failed to save data. Please try again.");
    } finally {
      setState(() {
        isLoading = false; // Corrected the placement of parenthesis
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }
}
