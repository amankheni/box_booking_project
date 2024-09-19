// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey[100], // Light background color
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.w), // Updated for ScreenUtil
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon or Image to enhance visuals
                    Icon(
                      Icons.lock_reset,
                      size: 80.sp, // Updated for ScreenUtil
                      color: Colors.teal[800], // Dark teal color for the icon
                    ),
                    SizedBox(height: 20.h), // Updated for ScreenUtil
                    Text(
                      'Forgot Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 30.sp, // Updated for ScreenUtil
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.teal[800], // Dark teal for better contrast
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h), // Updated for ScreenUtil
                    Text(
                      'Enter your email to reset password',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp, // Updated for ScreenUtil
                        color: Colors.teal[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.h), // Updated for ScreenUtil
                    // Form card
                    Card(
                      elevation: 8,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.r), // Updated for ScreenUtil
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w), // Updated for ScreenUtil
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon:
                                    Icon(Icons.email, color: Colors.teal[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.r), // Updated for ScreenUtil
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20.h), // Updated for ScreenUtil
                            ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[600],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50.w,
                                    vertical: 15.h), // Updated for ScreenUtil
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.r), // Updated for ScreenUtil
                                ),
                              ),
                              child: Text(
                                'Reset Password',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18.sp, // Updated for ScreenUtil
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Positioned back arrow button in top right
          Positioned(
            top: 40.h, // Updated for ScreenUtil
            left: 5.w, // Updated for ScreenUtil
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.teal[800],
                  size: 28.sp), // Updated for ScreenUtil
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Please enter an email address.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.success,
        label: 'Password reset email sent!',
      );
      Navigator.pop(context); // Navigate back after success
    } catch (e) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Error: $e',
      );
    }
  }
}
