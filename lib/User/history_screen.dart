import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Ensure you have this package in pubspec.yaml

class HistoryScreen extends StatefulWidget {
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
        title: const Text('Booking History'),
        centerTitle: true,
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

          return ListView.builder(
            itemCount: bookedSlots.length,
            itemBuilder: (context, index) {
              final slot = bookedSlots[index];
              return ListTile(
                title: Text(slot.boxName),
                subtitle: Text(
                    '${slot.timeSlot} - ${DateFormat('dd MMM yyyy').format(slot.date)}'),
                trailing: const Icon(Icons.calendar_today),
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
