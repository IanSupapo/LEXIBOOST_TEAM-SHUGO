import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';

Widget topWhiteContainer() {
  return Container(
    width: double.infinity,
    height: 300,
    color: Colors.white,
    child: Stack(
      children: [
        Positioned(
          top: 10,
          right: 10,
          child: AnimatedButton(
            height: 40,
            width: 40,
            onPressed: () {
              print("Edit button pressed");
            },
            child: Image.asset(
              'assets/edit.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ],
    ),
  );
}
