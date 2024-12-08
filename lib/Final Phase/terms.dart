import 'package:flutter/material.dart';

class MyTerms extends StatefulWidget {
  const MyTerms({super.key});

  @override
  State<MyTerms> createState() => _MyTermsState();
}

class _MyTermsState extends State<MyTerms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to LEXI BOOST. By using our application and services, you agree to these terms of service.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Account Creation and Usage',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '• All students are welcome to create an account\n'
                '• Students must use their real names for proper identification\n'
                '• Users are responsible for maintaining account security\n'
                '• One account per student policy\n'
                '• Account sharing is not allowed to maintain individual progress tracking',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'User Content and Behavior',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '• Users retain ownership of their content\n'
                '• LEXI BOOST has license to use user content for service improvement\n'
                '• Inappropriate or offensive content is prohibited\n'
                '• Cheating or gaming the system is not allowed\n'
                '• Respect for other users is required',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Educational Services',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '• Content is tailored for different grade levels\n'
                '• Progress tracking and assessment features for student growth\n'
                '• Teacher accounts have additional features for student monitoring\n'
                '• Learning content aligned with educational standards\n'
                '• Achievement system to encourage student engagement',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Termination',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'LEXI BOOST reserves the right to terminate or suspend accounts that violate these terms, engage in fraudulent activity, or misuse the service.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Changes to Terms',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We may update these terms from time to time. Users will be notified of any material changes, and continued use of the service constitutes acceptance of the updated terms.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}