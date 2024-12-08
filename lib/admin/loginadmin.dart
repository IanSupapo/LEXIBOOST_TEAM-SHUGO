import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shugo/Reusable%20Widget/adminreusable.dart';
import 'package:shugo/admin/admindashboard.dart';

class MyAdmin extends StatefulWidget {
  const MyAdmin({super.key});

  @override
  State<MyAdmin> createState() => _MyAdminState();
}

class _MyAdminState extends State<MyAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> signInAdmin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First authenticate with Firebase
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // After authentication, check admin status
      DocumentSnapshot adminDoc = await _firestore
          .collection('Admin')
          .doc('Admin123')
          .get();

      if (!adminDoc.exists) {
        await _auth.signOut(); // Sign out if not admin
        throw 'Admin configuration not found';
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

      // Verify email matches
      String adminEmail = adminData['Account'];
      if (adminEmail != _emailController.text.trim()) {
        await _auth.signOut(); // Sign out if not admin
        throw 'Not authorized as admin';
      }

      // If we get here, user is authenticated and is admin
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'Admin account not found';
          break;
        case 'wrong-password':
          message = 'Invalid password';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = e.message ?? 'Authentication error';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
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