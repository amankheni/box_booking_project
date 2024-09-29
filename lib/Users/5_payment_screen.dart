// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:box_booking_project/Users/1_home_page.dart';

class PaymentScreen extends StatefulWidget {
  final String boxName;
  final String timeSlot;
  final DateTime date;
  final double totalCost;

  const PaymentScreen({
    Key? key,
    required this.boxName,
    required this.timeSlot,
    required this.date,
    required this.totalCost,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _start = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _start),
    );

    // Create a linear animation from 0 to 1 over the duration of the timer
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {}); // Update the progress bar value smoothly
      });

    _controller.forward(); // Start the animation
    startTimer(); // Start the countdown timer
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    _timer?.cancel(); // Cancel the timer
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Payment Options'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Cards, UPI & More',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.sp),
              Container(
                height: 300.sp,
                width: 360.sp,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(7.0.sp),
                      child: Row(
                        children: [
                          Image(
                            height: 45.sp,
                            width: 45.sp,
                            image: const AssetImage('assets/image/credit.png'),
                          ),
                          SizedBox(width: 25.sp),
                          Text(
                            'Card',
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.all(7.0.sp),
                      child: Row(
                        children: [
                          Image(
                            height: 45.sp,
                            width: 45.sp,
                            image:
                                const AssetImage('assets/image/UPI Logo.png'),
                          ),
                          SizedBox(width: 25.sp),
                          Text(
                            'UPI',
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Image(
                        height: 45.sp,
                        width: 45.sp,
                        image: const AssetImage('assets/image/net banking.png'),
                      ),
                      title: const Text('Netbanking'),
                      subtitle: const Text('All Indian Banks'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Image(
                        height: 45.sp,
                        width: 45.sp,
                        image: const AssetImage('assets/image/wallet.png'),
                      ),
                      title: const Text('Wallet'),
                      subtitle: const Text('PhonePe & More'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.sp),
              const Divider(),
              Row(
                children: [
                  const Icon(
                    Icons.watch_later_outlined,
                    color: Colors.grey,
                  ),
                  Text('This page will time out in $_start seconds'),
                ],
              ),
              SizedBox(height: 10.sp),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(50.sp),
                minHeight: 7,
                value:
                    _animation.value, // Use animation value for smooth progress
                backgroundColor: const Color.fromARGB(255, 217, 249, 218),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 50.sp),
                  const Text('Secured by'),
                  Image(
                    height: 50.sp,
                    width: 130.sp,
                    image: const AssetImage('assets/image/RazorPay.png'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50.sp,
        width: double.infinity,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹ ${widget.totalCost.toStringAsFixed(2)}/-',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MaterialButton(
                color: const Color.fromARGB(255, 45, 167, 162),
                onPressed: () async {
                  await _initiatePayment();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.sp),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initiatePayment() async {
    // Fetch user details from Firestore
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userDoc.data();

    // Extract details
    final contactNumber = userData?['phoneNumber'] ?? 'N/A';
    final email = userData?['email'] ?? 'test@razorpay.com';
    final userName = userData?['firstName'] ?? 'Acme Corp.';

    // Payment options
    var options = {
      'key': 'rzp_test_ajzWxbRdWdbBA4',
      'amount': (widget.totalCost * 100).toInt(), // Amount is in paise
      'name': userName,
      'description': 'Booking for ${widget.boxName}',
      'prefill': {'contact': contactNumber, 'email': email}
    };

    // Open Razorpay with the options
    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _showTimeoutDialog(); // Show timeout dialog or navigate back
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Session Timeout'),
          content: const Text('Your session has timed out. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePageScreen5(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Show a toast for feedback
    Fluttertoast.showToast(msg: 'Payment Successful');

    // Fetch the user ID
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user details from the 'users' collection
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final username = userDoc.data()?['firstName'] ?? 'Unknown';
    final phoneNumber = userDoc.data()?['phoneNumber'] ?? 'Unknown';

    // Save booking details to Firestore
    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': userId,
      'username': username,
      'phoneNumber': phoneNumber,
      'boxName': widget.boxName,
      'timeSlot': widget.timeSlot,
      'date': widget.date.toIso8601String(),
      'totalCost': widget.totalCost,
      'paymentId': response.paymentId,
    });

    // Navigate to home page after successful payment
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePageScreen5(),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.code} | ${response.message}",
    );
  }
}
