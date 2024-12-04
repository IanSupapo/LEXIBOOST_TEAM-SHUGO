import 'package:flutter/material.dart';

class MyRank extends StatelessWidget {
  const MyRank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: const Center(
        child: Text(
          "Rank Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
