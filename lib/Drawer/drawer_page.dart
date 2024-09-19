// drawer_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:box_booking_project/Drawer/box_book_info_screen.dart';
import 'package:box_booking_project/Drawer/history_screen.dart';
import 'package:box_booking_project/Drawer/payment_history_screen.dart';
import 'package:box_booking_project/Users/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270.sp,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Image(
            height: 220.sp,
            image: const AssetImage('assets/image/Book My Box App Logo.png'),
          ),
          Divider(height: 1.sp, color: Colors.grey),
          SizedBox(height: 10.sp),
          _buildMenuItem(
            context,
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            text: 'Box Book Info',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BoxBookInfoScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person_2_outlined,
            text: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            text: 'History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.wallet_rounded,
            text: 'Payment',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PaymentHistoryScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout_outlined,
            text: 'Log out',
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
        child: Row(
          children: [
            Icon(icon, size: 30.sp, color: Colors.teal),
            SizedBox(width: 15.sp),
            Text(
              text,
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          content: Text('Are you sure you want to log out?',
              style: TextStyle(fontSize: 16.sp, color: Colors.black54)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          elevation: 10,
          actionsPadding:
              EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (Navigator.canPop(context)) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SingInScreen1()),
                    (route) => false,
                  );
                }
              },
              child: Text('Log Out',
                  style: TextStyle(color: Colors.red[700], fontSize: 16.sp)),
            ),
          ],
        );
      },
    );
  }
}
