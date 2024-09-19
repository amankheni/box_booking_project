// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                MaterialPageRoute(builder: (context) => SingInScreen1()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
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
                phoneNumber: data['phoneNumber'] ?? 'N/A',
              );
            }).toList();

            // Sort bookings by date and time slot in descending order
            bookings.sort((a, b) {
              final dateComparison = b.date
                  .compareTo(a.date); // Reverse comparison for descending order
              if (dateComparison != 0) {
                return dateComparison;
              }
              return b.timeSlot.compareTo(
                  a.timeSlot); // Reverse comparison for descending order
            });

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final slot = bookings[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0.sp),
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0.sp),
                    title: Text(
                      slot.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    subtitle: Text(
                      '${slot.timeSlot} \n${DateFormat('dd MMM yyyy').format(slot.date)}\nPhone: ${slot.phoneNumber}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                      ),
                    ),
                    trailing: Text(
                      '₹ ${slot.totalCost?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
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
  final String phoneNumber;

  BookedSlot({
    required this.username,
    required this.timeSlot,
    required this.date,
    this.totalCost,
    required this.phoneNumber,
  });
}
