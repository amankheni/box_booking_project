// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLogoAtTop = false; // To track logo's position
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the logo animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Animation for fading in the logo
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _startAnimation();
    _checkUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(
        const Duration(seconds: 1)); // Delay before starting animation

    // Start moving the logo to the top
    setState(() {
      _isLogoAtTop = true;
    });

    // Start the fade animation
    _controller.forward();
  }

  Future<void> _checkUser() async {
    await Future.delayed(
        const Duration(seconds: 4)); // Simulate a delay for loading

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? 'user';

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/adminPanel');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        print('Error fetching user role: $e');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/sp stamp.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _isLogoAtTop
                ? 15.sp
                : MediaQuery.of(context).size.height / 2 - 50.sp,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Image.asset(
                  'assets/image/Book My Box App Logo.png', // Replace with your logo path
                  width: 220.sp,
                  height: 220.sp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30.sp,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      double scale = 1.0 +
                          (index == (_controller.value * 3).floor()
                              ? 0.5
                              : 0.0);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 7.sp,
                          height: 7.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == (_controller.value * 3).floor()
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
