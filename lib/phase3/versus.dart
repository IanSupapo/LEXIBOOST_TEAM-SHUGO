import 'package:flutter/material.dart';

class MyVersus extends StatelessWidget {
  const MyVersus({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Versus Mode!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
