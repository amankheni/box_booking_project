// ignore_for_file: use_build_context_synchronously, file_names

import 'package:box_booking_project/Auth/3_otp_mobileno_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({Key? key}) : super(key: key);

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _selectedRole = 'user'; // Default role

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  _buildTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 10.sp),
                  _buildTextField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 10.sp),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10.sp),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 10.sp),
                  // Dropdown for role selection
                  // DropdownButtonFormField<String>(
                  //   value: _selectedRole,
                  //   items: const [
                  //     DropdownMenuItem(
                  //       value: 'user',
                  //       child: Text('User'),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: 'admin',
                  //       child: Text('Admin'),
                  //     ),
                  //   ],
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       _selectedRole = newValue!;
                  //     });
                  //   },
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12.sp),
                  //       borderSide: const BorderSide(color: Colors.black),
                  //     ),
                  //     labelText: 'Select Role',
                  //     contentPadding: EdgeInsets.symmetric(
                  //         horizontal: 16.sp, vertical: 14.sp),
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //   ),
                  // ),
                  SizedBox(height: 20.sp),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.sp, vertical: 15.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // Forgot Password function

  // Account creation function
  Future<void> _createAccount() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Please enter all details.',
        labelTextStyle: TextStyle(fontSize: 15.sp),
      );
      return;
    }

    try {
      // Create user using Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Storing user details (excluding password) in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'role': _selectedRole, // Storing role in Firestore
        'createdAt': Timestamp.now(), // Optionally, store creation time
      });

      // Display success message
      // IconSnackBar.show(
      //   context,
      //   snackBarType: SnackBarType.success,
      //   label: 'Account created successfully!',
      //   labelTextStyle: TextStyle(fontSize: 15.sp),
      // );

      // Navigate to OTP sending screen
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
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'An unknown error occurred.';
      }

      // Display error message
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: message,
        labelTextStyle: TextStyle(fontSize: 15.sp),
      );
    } catch (e) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Error: $e',
        backgroundColor: Colors.red,
        labelTextStyle: TextStyle(fontSize: 15.sp),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black), // Black border
        ),
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal[600]),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        filled: true,
        fillColor: Colors.white,
       // labelStyle: TextStyle(color: Colors.teal[600]),
      ),
    );
  }
}
