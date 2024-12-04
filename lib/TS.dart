import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.blue, // Customize color as needed
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding:  EdgeInsets.all(16.0),
        child: Text(
          'Your Terms of Service Here\n\n'
          'These terms and conditions outline the rules and regulations for the use of Company Name\'s Website, located at Website.com.\n\n'
          'By accessing this website we assume you accept these terms and conditions. Do not continue to use Website if you do not agree to take all of the terms and conditions stated on this page.\n\n'
          'The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: "Client", "You" and "Your" refers to you, the person log on this website and compliant to the Company’s terms and conditions. "The Company", "Ourselves", "We", "Our" and "Us", refers to our Company. "Party", "Parties", or "Us", refers to both the Client and ourselves.\n\n'
          'Cookies\n'
          'We employ the use of cookies. By accessing Website, you agreed to use cookies in agreement with the Company Name\'s Privacy Policy.\n\n'
          'License\n'
          'Unless otherwise stated, Company Name and/or its licensors own the intellectual property rights for all material on Website. All intellectual property rights are reserved. You may access this from Website for your own personal use subjected to restrictions set in these terms and conditions.\n\n'
          // Add more sections as needed...
          '--- End of Terms of Service ---',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
