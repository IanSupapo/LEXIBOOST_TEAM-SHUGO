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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'uid': user.uid,
          'fullname': null,
          'description': null,
          'points': null,
          'trophy': null,
          'gender': null,
          'birthday': null,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show verification dialog
        _showVerificationDialog();
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

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verify Your Email"),
          content: const Text(
            "A verification link has been sent to your email address. Please verify your email to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _checkEmailVerification();
              },
              child: const Text("I've Verified My Email"),
            ),
            TextButton(
              onPressed: () {
                // Sign out the user and return to login
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Later"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reload the user to get the latest verification status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Update verification status in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });

        // Navigate to starting screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyStarting()),
        );
      } else {
        _showDialog(
          "Email Not Verified",
          "Please verify your email first. Check your inbox and spam folder.",
        );
      }
    } catch (e) {
      print("Error checking email verification: $e");
      _showDialog("Error", "An error occurred. Please try again.");
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
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    reusableWidget(
                      textController: _passwordController,
                      labelText: "Password",
                      isPassword: true,
                      isPasswordObscured: _isPasswordObscured,
                      onVisibilityToggle: _togglePasswordVisibility,
                      showEyeIcon: true,
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    reusableWidget(
                      textController: _confirmPasswordController,
                      labelText: "Confirm Password",
                      isPassword: true,
                      isPasswordObscured: _isPasswordObscured,
                      showEyeIcon: false,
                      context: context,
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : signUpButton(
                            onPressed: _signUpWithEmailAndPassword,
                            context: context,
                          ),
                    const SizedBox(height: 20),
                    Text(
                      "Or sign up with",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
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
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.02,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
