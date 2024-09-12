// ignore_for_file: file_names, use_build_context_synchronously, avoid_print, prefer_const_constructors_in_immutables

import 'package:box_booking_project/Auth/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:box_booking_project/User/1_home_page.dart';
import 'package:box_booking_project/Auth/2_sign_up_screen.dart';
import 'package:box_booking_project/Admin/admin_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class SingInScreen1 extends StatefulWidget {
  SingInScreen1({Key? key}) : super(key: key);

  @override
  _SingInScreen1State createState() => _SingInScreen1State();
}

class _SingInScreen1State extends State<SingInScreen1> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'role': 'user',
            });
          }

          String role = userDoc['role'] ?? 'user';

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePageScreen5()),
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
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: errorMessage,
          labelTextStyle: TextStyle(fontSize: 15.sp),
        );
      } catch (e) {
        print('Error logging in: $e');
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          labelTextStyle: TextStyle(fontSize: 15.sp),
          label: 'Email or password are incorrect',
        );
      }
    } else {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Please fill in all fields correctly.',
        labelTextStyle: TextStyle(fontSize: 15.sp),
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
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.sp),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Text(
                    'Login to your account',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.teal[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.sp),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.teal[600]),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.sp, vertical: 15.sp),
                    ),
                  ),
                  SizedBox(height: 15.sp),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.teal[600]),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.sp, vertical: 15.sp),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 5.sp,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.teal[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.sp, vertical: 15.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey, fontSize: 15.sp),
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
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Colors.teal[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ],
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
