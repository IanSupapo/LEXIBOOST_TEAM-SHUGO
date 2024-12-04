import 'package:flutter/material.dart';

class MyStarting3 extends StatefulWidget {
  const MyStarting3({super.key});

  @override
  State<MyStarting3> createState() => _MyStarting3State();
}

class _MyStarting3State extends State<MyStarting3> {
  String userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: TextButton(
              onPressed: ()  {
                Navigator.pushNamed(context, '/starting4');
              }, // Removed navigation functionality
              child: const Text(
                "Next >",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins', // Corrected fontFamily
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
              'assets/4.png',
              width: 350,
              height: 350,
            ),
            const Text(
              "Great!",
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
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Let us help you improve your reading and writing skills in a fundamental way!",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
