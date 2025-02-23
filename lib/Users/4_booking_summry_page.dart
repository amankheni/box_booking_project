// ignore_for_file: avoid_print, depend_on_referenced_packages, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
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
                padding: EdgeInsets.all(16.0.sp),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Slot Details
                      Container(
                        padding: EdgeInsets.all(16.0.sp),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8.sp),
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
                            Text(
                              'Slot Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 10.sp),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.sp),
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
                                padding: EdgeInsets.all(16.0.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.timeSlot,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.sp),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.boxName,
                                          style: TextStyle(fontSize: 16.sp),
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
                                    SizedBox(height: 8.sp),
                                    Text(
                                      '₹ ${totalCost.toStringAsFixed(2)} /-',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      // Booking Summary
                      Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 10.sp),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 16.sp),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryRow('Sport', 'Box Cricket'),
                            SizedBox(height: 10.sp),
                            _buildSummaryRow('Slot Price',
                                '₹ ${totalCost.toStringAsFixed(2)}/-'),
                            SizedBox(height: 10.sp),
                            _buildSummaryRow('Convenience Fees', '-'),
                            SizedBox(height: 10.sp),
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
              ),
        bottomNavigationBar: Container(
          height: 60.sp,
          width: double.infinity,
          color: Colors.teal.shade100,
          child: Padding(
            padding: EdgeInsets.all(8.0.sp),
            child: Row(
              children: [
                Text(
                  '₹ ${totalCost.toStringAsFixed(2)}/-',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PaymentScreen(
                    //       boxName: widget.boxName,
                    //       timeSlot: widget.timeSlot,
                    //       date: widget
                    //           .date, // Ensure this is not null and properly initialized
                    //       totalCost: totalCost,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Proceed To Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Icon(Icons.arrow_forward, size: 20.sp),
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
            fontSize: 16.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
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
}
