// ignore_for_file: use_build_context_synchronously

import 'package:box_booking_project/User/1_home_page.dart';
import 'package:box_booking_project/Auth/sign_up_screen.dart';
import 'package:box_booking_project/Admin/admin_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo2 extends StatefulWidget {
  const UserInfo2({super.key});

  @override
  State<UserInfo2> createState() => _UserInfo2State();
}

class _UserInfo2State extends State<UserInfo2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Authenticate with Firebase
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Fetch user document from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // Create a new document if it doesn't exist
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'role': 'user', // Default role for new users
            });
          }

          // Fetch role and navigate to the appropriate screen
          String role = userDoc['role'] ?? 'user';

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePageScreen5()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown error occurred.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        print('Error logging in: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging in: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'We\'re all Set',
                  style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(height: 35),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email cannot be empty";
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password cannot be empty";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters long";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                MaterialButton(
                  color: const Color.fromARGB(255, 45, 167, 162),
                  onPressed: _login,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    child: Text(
                      'Let\'s Go',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen2(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style:
                            TextStyle(color: Color.fromARGB(255, 45, 167, 162)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
