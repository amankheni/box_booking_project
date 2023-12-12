// ignore_for_file: file_names
import 'package:box_booking_project/box_ui/4_otp_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class OtpsendingScreen3 extends StatefulWidget {
  const OtpsendingScreen3({super.key});
  // static String verify = '';

  @override
  State<OtpsendingScreen3> createState() => _OtpsendingScreen3State();
}

class _OtpsendingScreen3State extends State<OtpsendingScreen3> {
  TextEditingController phonrNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi There!',
                  style: GoogleFonts.yatraOne(
                    textStyle: const TextStyle(fontSize: 40),
                  ),
                ),
                const Text(
                  'Please enter a 10-digit vaild mobile',
                  style: TextStyle(fontSize: 19),
                ),
                const Text(
                  'number to recive OTP',
                  style: TextStyle(fontSize: 19),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntlPhoneField(
                    controller: phonrNumber,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    initialCountryCode: 'IN',
                    onSubmitted: (p0) {
                      phonrNumber.text = p0;
                      setState(() {});
                    },
                  ),
                ),
                const Text('By proceeding. you agree to the'),
                const Text.rich(
                  TextSpan(
                      text: 'Terms and condition',
                      style: TextStyle(
                        color: Color.fromARGB(255, 45, 167, 162),
                      ),
                      children: [
                        TextSpan(
                            text: '  and  ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Privacy Policy')
                      ]),
                ),
                const SizedBox(
                  height: 25,
                ),
                MaterialButton(
                  color: const Color.fromARGB(255, 45, 167, 162),
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+91 ${phonrNumber.text}',
                      verificationCompleted:
                          (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException e) {},
                      codeSent: (verificationId, forceResendingToken) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen4(
                                verificationId: verificationId,
                              ),
                            ));
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 80),
                    child: Text(
                      'Get OTP',
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
