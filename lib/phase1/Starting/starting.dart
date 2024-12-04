import 'package:flutter/material.dart';

class MyStarting extends StatefulWidget {
  const MyStarting({super.key});

  @override
  State<MyStarting> createState() => _MyStartingState();
}

class _MyStartingState extends State<MyStarting> {
  String userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: TextButton(
              onPressed: ()  {
                Navigator.pushNamed(context, '/starting2');
              }, // Removed all functionality
              child: const Text(
                "Next >",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/2.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 70),
            const Text(
              "Hello Learner!",
              style: TextStyle(
                fontSize: 48,
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
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Let us help you to improve your reading and writing skills in a fundamental way!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
