import 'package:box_booking_project/Auth/3_otp_verification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                  'Please enter a valid mobile number',
                  style: TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntlPhoneField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      // No need to manually update the controller here
                    },
                  ),
                ),
                const Text('By proceeding, you agree to the'),
                const Text.rich(
                  TextSpan(
                      text: 'Terms and Conditions',
                      style:
                          TextStyle(color: Color.fromARGB(255, 45, 167, 162)),
                      children: [
                        TextSpan(
                            text: ' and ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Privacy Policy')
                      ]),
                ),
                const SizedBox(height: 25),
                MaterialButton(
                  color: const Color.fromARGB(255, 45, 167, 162),
                  onPressed: () async {
                    final phoneNumber = _phoneNumberController.text.trim();
                    if (phoneNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your phone number'),
                        ),
                      );
                      return;
                    }

                    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter a valid 10-digit phone number'),
                        ),
                      );
                      return;
                    }

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Store phone number in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'phoneNumber': phoneNumber,
                        });
                      }

                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+91 $phoneNumber',
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {
                          // Auto sign-in using the phone auth credential
                          await FirebaseAuth.instance
                              .signInWithCredential(credential);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Phone number verified and signed in'),
                            ),
                          );
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Verification failed: ${e.message}'),
                            ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An error occurred: $e'),
                        ),
                      );
                    }
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
