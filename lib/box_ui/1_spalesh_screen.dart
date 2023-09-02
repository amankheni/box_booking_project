// ignore_for_file: file_names
import 'package:box_booking_project/assets/spalesh_screen_controller.dart';
import 'package:flutter/material.dart';

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image(
            height: 852,
            fit: BoxFit.fill,
            image: AssetImage(SplashScreenController.bgImage),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 300,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(SplashScreenController.logoImage),
                    ),
                  ),
                ),
                const Text(
                  'Hello Criketers',
                  style: TextStyle(
                    color: Color.fromARGB(255, 144, 207, 221),
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
