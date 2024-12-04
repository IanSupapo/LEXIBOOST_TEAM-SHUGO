import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';

class MySolo extends StatefulWidget {
  const MySolo({super.key});

  @override
  State<MySolo> createState() => _MySoloState();
}

class _MySoloState extends State<MySolo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Stack(
        children: [
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

          // Centered container
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Center(
                child: Text(
                  'Level 1',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
