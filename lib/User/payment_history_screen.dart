import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Colors.blue.shade50,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No payment history available.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final boxName = booking['boxName'];
              final timeSlot = booking['timeSlot'];
              final date = booking['date'];
              final totalCost = booking['totalCost'];
              final paymentId = booking['paymentId']; // Add this field

              return ListTile(
                title: Text('Box: $boxName'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Slot: $timeSlot'),
                    Text('Date: $date'),
                    Text('Total Cost: ₹${totalCost.toStringAsFixed(2)}'),
                    Text('Payment ID: $paymentId'), // Display payment ID
                  ],
                ),
                isThreeLine: true,
                leading: const Icon(Icons.payment),
              );
            },
          );
        },
      ),
    );
  }
}
