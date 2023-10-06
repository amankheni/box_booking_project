import 'package:box_booking_project/box_ui/1_spalesh_screen.dart';
import 'package:box_booking_project/box_ui/2_user_info.dart';
import 'package:box_booking_project/box_ui/3_otp_mobileno_screen.dart';
import 'package:box_booking_project/box_ui/sign_up_screen.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SignUpScreen2(),
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
    );
  }
}
