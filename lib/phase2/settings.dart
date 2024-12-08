import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_button/animated_button.dart';
import 'package:shugo/Final%20Phase/privacy.dart'; // Import AnimatedButton package
import 'package:shugo/Final%20Phase/terms.dart'; // Import Terms package

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Center(
        child: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: false,
          thickness: 0,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Settings buttons                   
                      const SizedBox(height: 15),
                      AnimatedDividerButton(
                        text: "Account Settings",
                        onTap: () {
                          Navigator.pushNamed(context, '/account');
                        },
                      ),
                      const SizedBox(height: 15),
                      AnimatedDividerButton(
                        text: "Privacy Policy",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyPrivacy(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      AnimatedDividerButton(
                        text: "Terms of Service",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyTerms()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      AnimatedDividerButton(
                        text: "Exit",
                        onTap: () {
                          _showExitConfirmation(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Function to show exit confirmation modal
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit App',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Close the app
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class AnimatedDividerButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AnimatedDividerButton({required this.text, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onTap,
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
