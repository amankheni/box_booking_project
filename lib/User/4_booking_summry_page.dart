// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '5_payment_screen.dart';

class BookingSummaryPage extends StatefulWidget {
  final String boxName;
  final String timeSlot;
  final DateTime date;

  const BookingSummaryPage({
    Key? key,
    required this.boxName,
    required this.timeSlot,
    required this.date,
  }) : super(key: key);

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  double _pricePerHour = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBoxPrice();
  }

  Future<void> _fetchBoxPrice() async {
    try {
      // Fetch box details based on boxName
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boxes')
          .where('boxName', isEqualTo: widget.boxName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          setState(() {
            _pricePerHour = (data['pricePerHour'] ?? 0.0).toDouble();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Handle the case where no document was found
        setState(() {
          _isLoading = false;
        });
        print('No box found with the given name.');
      }
    } catch (e) {
      print('Error fetching box price: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.timeSlot.split(' - ');
    final startTime = DateFormat('hh:mm a').parse(parts[0]);
    final endTime = DateFormat('hh:mm a').parse(parts[1]);
    final duration = endTime.difference(startTime).inHours;

    final totalCost = duration * _pricePerHour;

    // Formatting the selected date
    final formattedDate = DateFormat('dd MMM yyyy').format(widget.date);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Column(
            children: [
              Text(
                widget.boxName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
          elevation: 4,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slot Details
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Slot Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.timeSlot,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.boxName,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹ ${totalCost.toStringAsFixed(2)} /-',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Booking Summary
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow('Sport', 'Box Cricket'),
                          const SizedBox(height: 10),
                          _buildSummaryRow('Slot Price',
                              '₹ ${totalCost.toStringAsFixed(2)}/-'),
                          const SizedBox(height: 10),
                          _buildSummaryRow('Convenience Fees', '-'),
                          const SizedBox(height: 10),
                          const Divider(thickness: 1),
                          _buildSummaryRow(
                            'Total',
                            '₹ ${totalCost.toStringAsFixed(2)}/-',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Container(
          height: 60,
          width: double.infinity,
          color: Colors.teal.shade100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '₹ ${totalCost.toStringAsFixed(2)}/-',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          boxName: widget.boxName,
                          timeSlot: widget.timeSlot,
                          date: widget
                              .date, // Ensure this is not null and properly initialized
                          totalCost: totalCost,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Proceed To Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
