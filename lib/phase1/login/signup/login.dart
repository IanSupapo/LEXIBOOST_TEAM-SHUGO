import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart';
import 'package:shugo/phase1/Starting/starting.dart';
import 'package:shugo/phase2/home.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key}); 

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isPasswordObscured = true;
  // ignore: unused_field
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  Future<void> _loginWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog("Error", "Please fill in both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null &&
              data['fullname'] != null &&
              data['gender'] != null &&
              data['birthday'] != null) {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const MyHome()),
            );
          } else {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const MyStarting()),
            );
          }
        } else {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const MyStarting()),
          );
        }
      }
    } catch (e) {
      _showDialog("Login Failed", "Invalid email or password.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleSignIn = GoogleSignIn(
        clientId: '303696333249-r224rooe08ra8vjfb8jmo06rnguv4g15.apps.googleusercontent.com',
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final userDoc = await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            final data = userDoc.data();
            if (data != null &&
                data['fullname'] != null &&
                data['gender'] != null &&
                data['birthday'] != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHome()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyStarting()),
              );
            }
          } else {
            await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'fullname': null,
            'gender': null,
            'birthday': null,
            'description': null,
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(), // Add the registration date
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyStarting()),
            );
          }
        }
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0486C7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 36,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4.0,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    reusableWidget(
                      textController: _emailController,
                      labelText: "Email",
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reusableWidget(
                          textController: _passwordController,
                          labelText: "Password",
                          isPassword: true,
                          isPasswordObscured: _isPasswordObscured,
                          onVisibilityToggle: _togglePasswordVisibility,
                          showEyeIcon: true,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot');
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    loginButton(onPressed: _loginWithEmailAndPassword),
                    const SizedBox(height: 25),
                    const Text(
                      "Or sign up with",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    socialSignUpButton(
                      onPressed: _loginWithGoogle,
                      imagePath: 'assets/google.png',
                      text: "Log in with Google",
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    signUpButton(onPressed: () => Navigator.pushNamed(context, '/signup')),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
