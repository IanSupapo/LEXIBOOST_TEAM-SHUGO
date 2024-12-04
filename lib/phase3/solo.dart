import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:shugo/phase3/level/solo_reusable.dart';

class MySolo extends StatefulWidget {
  const MySolo({super.key});

  @override
  State<MySolo> createState() => _MySoloState();
}

class _MySoloState extends State<MySolo> {
  final PageController _pageController = PageController(); // PageController to manage slides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Stack(
        children: [
          // PageView for sliding between containers
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
            children: [
              // First container
              Center(
                child: CustomReusable(
                  levelText: 'Level 1',
                  descriptionText: 'Beginner',
                  gifPath: 'assets/toy.gif',
                  modalText: "Welcome to Level 1!",
                  onPlayPressed: () {
                    showModal(context, "Welcome to Level 1!");
                  },
                ).build(context),
              ),
              // Second container
              Center(
                child: CustomReusable(
                  levelText: 'Level 2',
                  descriptionText: 'Beginner II',
                  gifPath: 'assets/cubes.gif',
                  modalText: "Prepare for Level 2!",
                  onPlayPressed: () {
                    showModal(context, "Prepare for Level 2!");
                  },
                ).build(context),
              ),
              // Third container
              Center(
                child: CustomReusable(
                  levelText: 'Level 3',
                  descriptionText: 'Boss',
                  gifPath: 'assets/bear.gif',
                  modalText: "Get ready for the Boss Level!",
                  onPlayPressed: () {
                    showModal(context, "Get ready for the Boss Level!");
                  },
                ).build(context),
              ),
            ],
          ),

          // Back button at the top-left corner
          Positioned(
            top: 10,
            left: 10,
            child: AnimatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home'); // Navigate to home
              },
              height: 70,
              width: 120,
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/back.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Left arrow button (rotated)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 10,
            child: AnimatedButton(
              onPressed: () {
                if (_pageController.page! > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              height: 70,
              width: 70,
              color: Colors.transparent,
              child: Transform.rotate(
                angle: 3.1416, // Rotate 180 degrees (π radians)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/arrows.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Right arrow button
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: 10,
            child: AnimatedButton(
              onPressed: () {
                if (_pageController.page! < 2) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              height: 70,
              width: 70,
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/arrows.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showModal(BuildContext context, String modalText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  modalText,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the modal
                  },
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.3,
                  color: Colors.blue.shade300,
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
