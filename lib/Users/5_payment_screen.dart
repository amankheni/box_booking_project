// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:box_booking_project/Users/1_home_page.dart';
import 'package:intl/intl.dart';

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
                height: 320.sp,
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
              SizedBox(height: 10.sp),
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
      'key': 'rzp_test_hQfkkexYy6Gxkp',
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

  Future<void> _sendWhatsAppNotification(
      String phoneNumber, String boxName, String timeSlot, String date) async {
    try {
      // Format the phone number (remove '+' if present and ensure it has country code)
      String formattedPhone = phoneNumber;
      if (formattedPhone.startsWith('+')) {
        formattedPhone = formattedPhone.substring(1);
      }
      if (!formattedPhone.startsWith('91') && formattedPhone.length == 10) {
        formattedPhone =
            '91$formattedPhone'; // Add India country code if not present
      }

      // Create message text
      final messageText = 'Your booking has been confirmed!\n\n'
          'Box: $boxName\n'
          'Date: $date\n'
          'Time: $timeSlot\n\n'
          'Thank you for using Book My Box!';

      // You'll need to replace these with your actual WhatsApp Business API credentials
      const accountSid = 'YOUR_ACCOUNT_SID';
      const authToken = 'YOUR_AUTH_TOKEN';
      const whatsappNumber = 'YOUR_WHATSAPP_BUSINESS_PHONE_NUMBER';

      // For WhatsApp Business API using Twilio (as an example)
      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': 'whatsapp:+$formattedPhone',
          'From': 'whatsapp:$whatsappNumber',
          'Body': messageText,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('WhatsApp notification sent successfully');
      } else {
        print('Failed to send WhatsApp notification: ${response.body}');
        // Consider using a fallback method like SMS if WhatsApp fails
      }
    } catch (e) {
      print('Exception when sending WhatsApp notification: $e');
      // Error handling - log the error but don't block the booking process
    }
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

    // Format the date for better readability
    final formattedDate = DateFormat('dd MMM yyyy').format(widget.date);

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
      'bookingTime': FieldValue.serverTimestamp(),
    });

    // Send WhatsApp notification
    await _sendWhatsAppNotification(
        phoneNumber, widget.boxName, widget.timeSlot, formattedDate);

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
