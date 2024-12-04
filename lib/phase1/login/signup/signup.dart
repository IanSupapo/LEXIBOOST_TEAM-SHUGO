import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shugo/Reusable%20Widget/reusable_widget.dart'; 
import 'package:shugo/phase1/Starting/starting.dart';
import 'package:shugo/phase2/home.dart';

class MySignup extends StatefulWidget {
  const MySignup({super.key});

  @override
  State<MySignup> createState() => _MySignupState();
}

class _MySignupState extends State<MySignup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  Future<void> _signUpWithEmailAndPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Check if all fields are empty
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showDialog("Incomplete Form", "Please fill up the account information first.");
      return;
    }

    // Check if the email is valid
    if (!email.contains("@") || !email.endsWith("@gmail.com")) {
      _showDialog("Invalid Email", "The email you entered is not a valid email address.");
      return;
    }

    // Check if password and confirm password match
    if (password != confirmPassword) {
      _showDialog("Password Mismatch", "The password and confirm password didn't match.");
      return;
    }

    // Check if the password is too short
    if (password.length < 6) {
      _showDialog("Weak Password", "The password should be at least 6 characters long.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        final String uid = user.uid;

        // Add createdAt field with the current timestamp
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'uid': uid.isNotEmpty ? uid : "TestUID",
          'fullname': null,
          'description': null,
          'points': null,
          'trophy': null,
          'gender': null,
          'birthday': null,
          'createdAt': FieldValue.serverTimestamp(),
           // Add the registration date
        });

        // Navigate to MyStarting screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyStarting()),
        );
      }
    } catch (e) {
      print("Error during Email Sign-Up: $e");
      _showDialog("Sign-Up Error", "An error occurred during sign-up. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '303696333249-r224rooe08ra8vjfb8jmo06rnguv4g15.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User closed the Google sign-in popup
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print("Sign in successful: ${user.uid}");

        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
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
            'fullname': null,
            'gender': null,
            'birthday': null,
            'createdAt': FieldValue.serverTimestamp(), // Add the registration date
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyStarting()),
          );
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

  void _showDialog(String title, String message, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDismiss != null) onDismiss();
            },
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
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign up",
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
                    reusableWidget(
                      textController: _passwordController,
                      labelText: "Password",
                      isPassword: true,
                      isPasswordObscured: _isPasswordObscured,
                      onVisibilityToggle: _togglePasswordVisibility,
                      showEyeIcon: true,
                    ),
                    const SizedBox(height: 20),
                    reusableWidget(
                      textController: _confirmPasswordController,
                      labelText: "Confirm Password",
                      isPassword: true,
                      isPasswordObscured: _isPasswordObscured,
                      showEyeIcon: false,
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : signUpButton(
                            onPressed: _signUpWithEmailAndPassword,
                          ),
                    const SizedBox(height: 20),
                    const Text(
                      "Or sign up with",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    socialSignUpButton(
                      onPressed: signInWithGoogle,
                      imagePath: 'assets/google.png',
                      text: "Sign up with Google",
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    loginButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
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
