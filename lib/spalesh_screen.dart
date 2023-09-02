// ignore_for_file: file_names
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
          const Image(
            height: 852,
            fit: BoxFit.fill,
            image: AssetImage("assets/image/splash screen.jpeg"),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 300,
                  width: 200,
                  color: Colors.red,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
