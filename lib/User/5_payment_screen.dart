// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:box_booking_project/User/1_home_page.dart';

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
  Razorpay? _razorpay;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _start = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

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
    _razorpay?.clear(); // Removes all listeners
    _timer?.cancel(); // Cancel the timer
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
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
    final userData = userDoc.data();

    final username = userData?['firstName'] ?? 'Unknown User';
    final phoneNumber = userData?['phoneNumber'] ?? 'N/A';

    // Save booking details including payment ID to Firestore
    await FirebaseFirestore.instance.collection('bookings').add({
      'boxName': widget.boxName,
      'timeSlot': widget.timeSlot,
      'date': widget.date.toIso8601String(),
      'userId': userId,
      'username': username,
      'phoneNumber': phoneNumber,
      'totalCost': widget.totalCost,
      'paymentId': response.paymentId, // Store the payment ID
    });

    // Show the payment success dialog
    _showPaymentSuccessDialog();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed');
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Payment Successful'),
          content: const Text('Your payment was processed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to HomePage or another screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Payment Options'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Cards, UPI & More',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 330,
              width: 360,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Row(
                      children: [
                        Image(
                          height: 45,
                          width: 45,
                          image: AssetImage('assets/image/credit.png'),
                        ),
                        SizedBox(width: 25),
                        Text(
                          'Card',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Row(
                      children: [
                        Image(
                          height: 45,
                          width: 45,
                          image: AssetImage('assets/image/UPI Logo.png'),
                        ),
                        SizedBox(width: 25),
                        Text(
                          'UPI',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/net banking.png'),
                    ),
                    title: Text('Netbanking'),
                    subtitle: Text('All Indian Banks'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/wallet.png'),
                    ),
                    title: Text('Wallet'),
                    subtitle: Text('PhonePe & More'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
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
            const SizedBox(
              height: 10,
            ),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(50),
              minHeight: 7,
              value:
                  _animation.value, // Use animation value for smooth progress
              backgroundColor: const Color.fromARGB(255, 217, 249, 218),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 50),
                Text('Secured by'),
                Image(
                  height: 50,
                  width: 130,
                  image: AssetImage('assets/image/RazorPay.png'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        width: double.infinity,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹ ${widget.totalCost.toStringAsFixed(2)}/-',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MaterialButton(
                color: const Color.fromARGB(255, 45, 167, 162),
                onPressed: () async {
                  // Fetch user details from Firestore
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
                  final userData = userDoc.data();

                  // Extract details
                  final contactNumber = userData?['phoneNumber'] ?? 'N/A';
                  final email = userData?['email'] ?? 'test@razorpay.com';
                  final userName = userData?['firstName'] ?? 'Acme Corp.';

                  // Payment options
                  var options = {
                    'key': 'rzp_test_r6BrEFcR4X4ecz',
                    'amount': (widget.totalCost * 100)
                        .toInt(), // Amount is in paise, so multiply by 100
                    'name': userName,
                    'description': 'Booking for ${widget.boxName}',
                    'prefill': {'contact': contactNumber, 'email': email}
                  };

                  // Open Razorpay with the options
                  _razorpay?.open(options);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
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
}
