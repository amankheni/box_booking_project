import 'package:flutter/material.dart';
import 'package:box_booking_project/network_and_database/firebase/database.dart'; // Update with the correct import path

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
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
                  Text('Name: $firstName $lastName',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Email: $email', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Phone Number: $phoneNumber',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
