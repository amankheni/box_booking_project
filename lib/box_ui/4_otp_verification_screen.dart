// ignore_for_file: file_names, avoid_print, use_build_context_synchronously
import 'dart:developer';

import 'package:box_booking_project/box_ui/3_otp_mobileno_screen.dart';
import 'package:box_booking_project/box_ui/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen4 extends StatefulWidget {
  static String? verify;

  const OtpVerificationScreen4({super.key});

  @override
  State<OtpVerificationScreen4> createState() => _OtpVerificationScreen4State();
}

class _OtpVerificationScreen4State extends State<OtpVerificationScreen4> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController txtotp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
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
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Please enter the OTP sent to ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const Text(
                'your number ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Pinput(
                controller: txtotp,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (value) {
                  txtotp.text = value;
                  setState(() {});
                },
                length: 6,
              ),
              MaterialButton(
                onPressed: () async {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: OtpsendingScreen3.verify,
                    smsCode: txtotp.text,
                  );

                  log(txtotp.text.toString());

                  // Sign the user in (or link) with the credential
                  await auth.signInWithCredential(credential).then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ));
                    const SnackBar(content: Text('verified sucsscesfully'));
                  }).onError((error, stackTrace) {
                    print(error.toString());
                  });
                },
                child: const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
