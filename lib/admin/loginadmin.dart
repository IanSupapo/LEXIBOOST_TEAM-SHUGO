import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/Reusable%20Widget/adminreusable.dart';

class MyAdmin extends StatefulWidget {
  const MyAdmin({super.key});

  @override
  State<MyAdmin> createState() => _MyAdminState();
}

class _MyAdminState extends State<MyAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Add admin credentials
  final String adminEmail = "AdminLexi@gmail.com";
  final String adminPassword = "AdminLexi321";

  Future<void> signInAdmin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check admin document
      QuerySnapshot adminSnapshot = await _firestore
          .collection('Admin')
          .where('Account', isEqualTo: _emailController.text.trim())
          .get();

      if (adminSnapshot.docs.isEmpty) {
        throw 'Not authorized as admin';
      }

      // Then try Firebase Auth
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw 'Admin account not found';
        } else if (e.code == 'wrong-password') {
          throw 'Invalid password';
        } else {
          throw 'Authentication error: ${e.message}';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xFF0486C7),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/Logotext.png',
                  height: 68,
                  width: 332,
                ),
                const SizedBox(height: 30),
                Text(
                  "Admin Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                adminReusableWidget(
                  textController: _emailController,
                  labelText: "Email",
                  context: context,
                ),
                const SizedBox(height: 20),
                adminReusableWidget(
                  textController: _passwordController,
                  labelText: "Password",
                  context: context,
                  isPassword: true,
                  isPasswordObscured: !_isPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : adminButton(
                        onPressed: signInAdmin,
                        text: "Sign In as Admin",
                        context: context,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}