import 'package:flutter/material.dart';

class MyContact extends StatelessWidget {
  const MyContact({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> contacts = []; // Assuming a list of contacts

    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: contacts.isEmpty
          ? const Center(
              child: Text(
                "No Contact",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    contacts[index],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new contact functionality
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}
