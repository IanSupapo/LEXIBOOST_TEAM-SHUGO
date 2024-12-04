import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

Widget customNavigationBar({
  required int currentIndex,
  required Function(int) onTap,
}) {
  return CurvedNavigationBar(
    backgroundColor: Colors.blue.shade400,
    animationDuration: const Duration(milliseconds: 300),
    index: currentIndex,
    onTap: onTap,
    items: [
      Image.asset(
        'assets/Rank1.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/Achievement.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/contact.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/homes.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/email.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/profile1.png',
        width: 30,
        height: 30,
      ),
      Image.asset(
        'assets/settings.png',
        width: 30,
        height: 30,
      ),
    ],
  );
}
