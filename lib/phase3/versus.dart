import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';

class MyVersus extends StatelessWidget {
  const MyVersus({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Stack(
        children: [
          // Back button at the upper-left corner
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedButton(
              height: 70,
              width: 120,
              color: Colors.transparent,
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Image.asset(
                'assets/back.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Versus Mode",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.2,
                        child: Image.asset(
                          'assets/award.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                height: screenHeight * 0.08,
                width: screenWidth * 0.7,
                color: Colors.white,
                onPressed: () {
                  print("Find Player button pressed");
                },
                child: const Text(
                  "Find Player",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "or",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                height: screenHeight * 0.08,
                width: screenWidth * 0.7,
                color: Colors.white,
                onPressed: () {
                  print("Play with friends button pressed");
                },
                child: const Text(
                  "Play with friends",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
