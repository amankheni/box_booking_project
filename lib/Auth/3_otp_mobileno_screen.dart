// ignore_for_file: use_build_context_synchronously, file_names

import 'package:box_booking_project/Auth/4_otp_verification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class OtpsendingScreen3 extends StatefulWidget {
  const OtpsendingScreen3({Key? key}) : super(key: key);

  @override
  State<OtpsendingScreen3> createState() => _OtpsendingScreen3State();
}

class _OtpsendingScreen3State extends State<OtpsendingScreen3> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome!',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800]),
                  ),
                ),
                SizedBox(height: 10.sp),
                Text(
                  'Please enter your mobile number to receive an OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle:
                        TextStyle(fontSize: 16.sp, color: Colors.teal[600]),
                  ),
                ),
                SizedBox(height: 30.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: IntlPhoneField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.teal[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide(color: Colors.teal[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide(color: Colors.teal[600]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                        borderSide: BorderSide(color: Colors.teal[300]!),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    initialCountryCode: 'IN',
                    onChanged: (phone) {},
                  ),
                ),
                SizedBox(height: 20.sp),
                Text(
                  'By proceeding, you agree to the',
                  style: GoogleFonts.poppins(
                    textStyle:
                        TextStyle(fontSize: 14.sp, color: Colors.teal[600]),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                        color: Colors.teal[800], fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(color: Colors.teal[600]),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.sp),
                ElevatedButton(
                  onPressed: () async {
                    final phoneNumber = _phoneNumberController.text.trim();
                    if (phoneNumber.isEmpty) {
                      IconSnackBar.show(
                        context,
                        snackBarType: SnackBarType.alert,
                        label: 'Please enter your phone number',
                        backgroundColor: Colors.red,
                        labelTextStyle: TextStyle(fontSize: 15.sp),
                      );

                      return;
                    }

                    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
                      IconSnackBar.show(
                        context,
                        snackBarType: SnackBarType.alert,
                        label: 'Please enter a valid 10-digit phone number',
                        labelTextStyle: TextStyle(fontSize: 15.sp),
                      );

                      return;
                    }

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'phoneNumber': phoneNumber,
                        });
                      }
                      //  final user = FirebaseAuth.instance.currentUser;
                      // if (user != null) {
                      //   await FirebaseFirestore.instance
                      //       .collection('users')
                      //       .doc(user
                      //           .uid) // Fetches the document with the current user's UID
                      //       .update({
                      //     'phoneNumber':
                      //         phoneNumber, // Updates the 'phoneNumber' field in the document
                      //   });
                      // }

                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+91 $phoneNumber',
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {
                          await FirebaseAuth.instance
                              .signInWithCredential(credential);
                          IconSnackBar.show(
                            context,
                            snackBarType: SnackBarType.success,
                            label: 'Phone number verified and signed in',
                            labelTextStyle: TextStyle(fontSize: 15.sp),
                          );
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          IconSnackBar.show(
                            context,
                            snackBarType: SnackBarType.fail,
                            label: 'Verification failed: ${e.message}',
                            labelTextStyle: TextStyle(fontSize: 15.sp),
                          );
                        },
                        codeSent: (verificationId, forceResendingToken) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen4(
                                verificationId: verificationId,
                                phoneNumber: phoneNumber,
                              ),
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                    } catch (e) {
                      IconSnackBar.show(
                        context,
                        snackBarType: SnackBarType.alert,
                        label: 'An error occurred: $e',
                        labelTextStyle: TextStyle(fontSize: 15.sp),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 14.sp, horizontal: 50.sp),
                  ),
                  child: Text(
                    'Get OTP',
                    style: GoogleFonts.poppins(
                      textStyle:
                          TextStyle(color: Colors.white, fontSize: 18.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
