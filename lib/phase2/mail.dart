import 'package:flutter/material.dart';

class MyMail extends StatelessWidget {
  final List<String> notifications;

  const MyMail({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Mail",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No new notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      notifications[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
