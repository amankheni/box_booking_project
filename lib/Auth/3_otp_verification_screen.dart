// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:box_booking_project/Auth/1_log_in_screen.dart';
import 'package:box_booking_project/User/1_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen4 extends StatefulWidget {
  const OtpVerificationScreen4({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpVerificationScreen4> createState() => _OtpVerificationScreen4State();
}

class _OtpVerificationScreen4State extends State<OtpVerificationScreen4> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'OTP Verification',
                style: GoogleFonts.notoSans(
                  textStyle: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter the OTP sent to your number',
                style: TextStyle(fontSize: 16),
              ),
              Pinput(
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                length: 6,
              ),
              MaterialButton(
                onPressed: () async {
                  String otp = _otpController.text.trim();

                  if (otp.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter the OTP')),
                    );
                    return;
                  }

                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otp,
                    );

                    await _auth
                        .signInWithCredential(credential)
                        .then((value) async {
                      // Store phone number in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(value.user?.uid)
                          .set({
                        'phoneNumber': widget.phoneNumber,
                        // Add other user details here if needed
                      }, SetOptions(merge: true));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserInfo2(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verified successfully')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Verification failed: $error')),
                      );
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An error occurred: $e')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
