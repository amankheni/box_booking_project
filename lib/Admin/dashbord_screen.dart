// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:box_booking_project/Auth/1_log_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserInfo2()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('bookings').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching bookings'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No bookings available'));
            }

            final bookings = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return BookedSlot(
                username: data['username'] ?? 'Unknown User',
                timeSlot: data['timeSlot'] ?? 'No Time Slot',
                date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
                totalCost: data['totalCost']?.toDouble(),
                phoneNumber:
                    data['phoneNumber'] ?? 'N/A', // Add phoneNumber field
              );
            }).toList();

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final slot = bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      slot.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${slot.timeSlot} - ${DateFormat('dd MMM yyyy').format(slot.date)}\nPhone: ${slot.phoneNumber}', // Display phone number
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    //  Uncomment and handle totalCost if needed
                    trailing: Text(
                      '₹ ${slot.totalCost?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Model class to represent a booked slot
class BookedSlot {
  final String username;
  final String timeSlot;
  final DateTime date;
  final double? totalCost;
  final String phoneNumber; // Add this field

  BookedSlot({
    required this.username,
    required this.timeSlot,
    required this.date,
    this.totalCost,
    required this.phoneNumber, // Add this parameter
  });
}
