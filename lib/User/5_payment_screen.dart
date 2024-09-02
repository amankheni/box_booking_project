import 'package:box_booking_project/User/1_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
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
                    builder: (context) => HomePageScreen5(),
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
        backgroundColor: Colors.blue.shade50,
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
              height: 410,
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
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/loan.png'),
                    ),
                    title: Text('EMI'),
                    subtitle: Text('EMI via cards & axio'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            const Divider(),
            const Row(
              children: [
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.grey,
                ),
                Text('This page will time out in a few minutes')
              ],
            ),
            const Divider(thickness: 7),
            const Row(
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(Icons.arrow_drop_up),
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

  @override
  void dispose() {
    _razorpay?.clear(); // Removes all listeners
    super.dispose();
  }
}
