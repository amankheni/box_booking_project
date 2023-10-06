// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:box_booking_project/box_ui/3_otp_mobileno_screen.dart';
import 'package:box_booking_project/network_and_database/firebase/2user_infoscreen_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key});

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  TextEditingController firstNameTxtController = TextEditingController();
  TextEditingController lastNameTxtController = TextEditingController();
  TextEditingController emailTxtController = TextEditingController();
  TextEditingController passwordTxtController = TextEditingController();

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
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: firstNameTxtController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Name';
                      }
                      if (value.length >= 20) {
                        return 'Please enter a maximum 20 charecter name';
                      }
                      // if (RegExp("[^p{L}ds_]").hasMatch(value)) {
                      //   return "special charecter is not valid";
                      // }

                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: lastNameTxtController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Name';
                      }
                      if (value.length >= 20) {
                        return 'Please enter a maximum 20 charecter name';
                      }
                      // if (RegExp("[^p{L}ds_]").hasMatch(value)) {
                      //   return "special charecter is not valid";
                      // }

                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: emailTxtController,
                    validator: (value) {
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordTxtController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    color: const Color.fromARGB(255, 45, 167, 162),
                    onPressed: () {
                      UserInfoScreenFirebase.addUser(
                        firstName: firstNameTxtController.text,
                        lastName: lastNameTxtController.text,
                        email: emailTxtController.text,
                        password: passwordTxtController.text,
                      );
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: emailTxtController.text,
                              password: passwordTxtController.text)
                          .then(
                            (value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OtpsendingScreen3(),
                              ),
                            ),
                          )
                          .onError((error, stackTrace) {
                        print(error.toString());
                      });
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
