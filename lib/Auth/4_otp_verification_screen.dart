// ignore_for_file: use_build_context_synchronously, file_names

import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.sp,
      height: 56.sp,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: Colors.teal,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.teal.shade400),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.teal.shade50,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OTP Verification',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  'Please enter the OTP sent to your number',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  '+91 ${widget.phoneNumber}',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.sp),
                // OTP Input Field
                Pinput(
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  length: 6,
                  onCompleted: (pin) {
                    // You can auto-submit when all digits are entered
                    // or leave this empty if you prefer manual submit
                  },
                ),
                SizedBox(height: 40.sp),
                // Submit Button
                _isLoading
                    ? CircularProgressIndicator(color: Colors.teal)
                    : ElevatedButton(
                        onPressed: () async {
                          String otp = _otpController.text.trim();

                          if (otp.isEmpty) {
                            IconSnackBar.show(
                              context,
                              snackBarType: SnackBarType.fail,
                              label: 'Please enter the OTP',
                              labelTextStyle: const TextStyle(fontSize: 15),
                            );
                            return;
                          }

                          if (otp.length != 6) {
                            IconSnackBar.show(
                              context,
                              snackBarType: SnackBarType.fail,
                              label: 'Please enter a valid 6-digit OTP',
                              labelTextStyle: const TextStyle(fontSize: 15),
                            );
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: otp,
                            );

                            await _auth.signInWithCredential(credential).then(
                              (value) async {
                                if (value.user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(value.user?.uid)
                                      .set({
                                    'phoneNumber': widget.phoneNumber,
                                    'verified': true,
                                    'lastLoginAt': FieldValue.serverTimestamp(),
                                    // Add other user details here if needed
                                  }, SetOptions(merge: true));

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SingInScreen1(),
                                    ),
                                  );

                                  IconSnackBar.show(
                                    context,
                                    snackBarType: SnackBarType.success,
                                    label: 'Verified successfully',
                                    labelTextStyle: TextStyle(fontSize: 15.sp),
                                  );
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  IconSnackBar.show(
                                    context,
                                    snackBarType: SnackBarType.fail,
                                    label: 'Verification failed: User is null',
                                    labelTextStyle: TextStyle(fontSize: 15.sp),
                                  );
                                }
                              },
                            ).catchError((error) {
                              setState(() {
                                _isLoading = false;
                              });
                              IconSnackBar.show(
                                context,
                                snackBarType: SnackBarType.fail,
                                label: 'Verification failed: ${error.message}',
                                labelTextStyle: TextStyle(fontSize: 15.sp),
                              );
                            });
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            IconSnackBar.show(
                              context,
                              snackBarType: SnackBarType.fail,
                              label: 'An error occurred: $e',
                              labelTextStyle: TextStyle(fontSize: 15.sp),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.sp,
                            horizontal: 50.sp,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 20.sp),
                if (!_isLoading)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Change Phone Number',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
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
