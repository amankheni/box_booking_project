// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Ensure you have this package in pubspec.yaml

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<List<BookedSlot>> _bookedSlotsStream;

  @override
  void initState() {
    super.initState();
    _bookedSlotsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookedSlot.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: StreamBuilder<List<BookedSlot>>(
        stream: _bookedSlotsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookedSlots = snapshot.data ?? [];

          if (bookedSlots.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0.sp),
            itemCount: bookedSlots.length,
            itemBuilder: (context, index) {
              final slot = bookedSlots[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0.sp),
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0.sp),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0.sp),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(
                      Icons.sports_cricket,
                      color: Colors.teal,
                      size: 30.sp,
                    ),
                  ),
                  title: Text(
                    slot.boxName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  subtitle: Text(
                    '${slot.timeSlot} - ${DateFormat('dd MMM yyyy').format(slot.date)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing:
                      const Icon(Icons.calendar_today, color: Colors.teal),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookedSlot {
  final String boxName;
  final String timeSlot;
  final DateTime date;

  BookedSlot({
    required this.boxName,
    required this.timeSlot,
    required this.date,
  });

  factory BookedSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookedSlot(
      boxName: data['boxName'],
      timeSlot: data['timeSlot'],
      date: DateTime.parse(data['date']),
    );
  }
}
