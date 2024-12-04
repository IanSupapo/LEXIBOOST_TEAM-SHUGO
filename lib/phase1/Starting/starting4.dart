import 'package:flutter/material.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart'; // Ensure this path is correct.

class MyStarting4 extends StatefulWidget {
  const MyStarting4({super.key});

  @override
  State<MyStarting4> createState() => _MyStarting4State();
}

class _MyStarting4State extends State<MyStarting4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/1.png',
                    width: 350,
                    height: 350,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Now let's start",
                    style: TextStyle(
                      fontSize: 36,
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
                  const Text(
                    "our journey here!",
                    style: TextStyle(
                      fontSize: 36,
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
                  const SizedBox(height: 30),
                  continueButton(
                    onPressed: ()  {
                      Navigator.pushNamed(context, '/home');
                    }, // Functionality is removed as requested
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
