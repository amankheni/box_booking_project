import 'package:box_booking_project/Auth/2_otp_mobileno_screen.dart';
import 'package:box_booking_project/User/profile_screen.dart';
import 'package:box_booking_project/network_and_database/firebase/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key});

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'user'; // Default role

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    obscureText: true, // Hide the password text
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Role',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    color: const Color.fromARGB(255, 45, 167, 162),
                    onPressed: () async {
                      if (_firstNameController.text.isEmpty ||
                          _lastNameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        _showSnackBar("Please fill in all the fields.");
                        return;
                      }

                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        // Add user info to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user?.uid)
                            .set({
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'email': _emailController.text,
                          'role': _selectedRole,
                        });

                        // Navigate to OtpsendingScreen3
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OtpsendingScreen3(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        String message;
                        if (e.code == 'weak-password') {
                          message = 'The password provided is too weak.';
                        } else if (e.code == 'email-already-in-use') {
                          message =
                              'The account already exists for that email.';
                        } else if (e.code == 'invalid-email') {
                          message = 'The email address is not valid.';
                        } else {
                          message = 'An unknown error occurred.';
                        }
                        _showSnackBar(message);
                      } catch (e) {
                        _showSnackBar('Error: $e');
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
