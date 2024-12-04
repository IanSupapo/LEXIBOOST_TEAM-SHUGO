import 'package:flutter/material.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DividerButton(
                text: "Edit Profile",
                onTap: () {
                  // Add navigation or action here
                },
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              DividerButton(
                text: "Features",
                onTap: () {
                  // Add navigation or action here
                },
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              DividerButton(
                text: "Guidelines",
                onTap: () {
                  // Add navigation or action here
                },
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              DividerButton(
                text: "Account Settings",
                onTap: () {
                  // Add navigation or action here
                },
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              DividerButton(
                text: "Exit",
                onTap: () {
                  // Add navigation or action here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DividerButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const DividerButton({required this.text, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left-aligned text
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Right-aligned arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
