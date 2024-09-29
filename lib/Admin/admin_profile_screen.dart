// ignore_for_file: use_build_context_synchronously

import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _fetchAdminDetails();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SingInScreen1()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.sp),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'First Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 15.sp),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 15.sp),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                enabled: false,
              ),
            ),
            SizedBox(height: 15.sp),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                enabled: false,
              ),
            ),
            SizedBox(height: 20.sp),
            Center(
              child: ElevatedButton(
                onPressed: _updateAdminDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Background color
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.sp, vertical: 15.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.sp), // Button border radius
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAdminDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _phoneNumberController.text = data['phoneNumber'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
    }
  }

  Future<void> _updateAdminDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'email': _emailController.text.trim(),
        });
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.success,
          label: 'Profile updated successfully.',
          labelTextStyle: TextStyle(fontSize: 15.sp),
        );
      } catch (e) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          label: 'Error updating profile: $e',
          labelTextStyle: TextStyle(fontSize: 15.sp),
        );
      }
    }
  }
}
