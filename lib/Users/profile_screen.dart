import 'package:flutter/material.dart';
import 'package:box_booking_project/network_and_database/firebase/database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Update with the correct import path

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // Background image positioned at the bottom center
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/image/bg cricket.jpg',
                fit: BoxFit.cover,
                height: 400.sp, // Adjust the height as needed
                width: double.infinity,
              ),
            ),
          ),
          FutureBuilder<Map<String, dynamic>?>(
            future: UserInfoScreenFirebase.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No user data found.'));
              } else {
                var userData = snapshot.data!;
                String firstName = userData['firstName'] ?? 'N/A';
                String lastName = userData['lastName'] ?? 'N/A';
                String email = userData['email'] ?? 'N/A';
                String phoneNumber = userData['phoneNumber'] ?? 'N/A';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50.sp,
                              backgroundImage: const AssetImage(
                                  'assets/image/cricket-player- avetar.jpg'), // Replace with actual image path or use NetworkImage if fetching from a URL
                            ),
                            SizedBox(height: 10.sp),
                            Text(
                              '$firstName $lastName',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 5.sp),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),

                      // Profile Details
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16.0.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Phone Number', phoneNumber),
                            SizedBox(height: 10.sp),
                            _buildDetailRow('Email', email),
                            // Add more details as needed
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
