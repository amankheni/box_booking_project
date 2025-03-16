// ignore_for_file: depend_on_referenced_packages, file_names, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:box_booking_project/Drawer/drawer_page.dart';
import 'package:box_booking_project/Users/2_booking_page.dart';
import 'package:box_booking_project/Users/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomePageScreen5 extends StatefulWidget {
  final List<BookedSlot>? bookedSlots;

  const HomePageScreen5({
    super.key,
    this.bookedSlots,
  });

  @override
  State<HomePageScreen5> createState() => _HomePageScreen5State();
}

class _HomePageScreen5State extends State<HomePageScreen5> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<BookedSlot> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        drawer: const DrawerPage(),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
            child: Icon(
              Icons.menu_open_rounded,
              color: const Color.fromARGB(255, 13, 124, 120),
              size: 30.sp,
            ),
          ),
          title: Text(
            'Book My Box',
            style: TextStyle(
                fontSize: 23.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18.sp,
                backgroundImage:
                    const AssetImage('assets/image/cricket-player- avetar.jpg'),
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(
              width: 10.sp,
            )
          ],
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 5,
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 16.sp,
            left: 10.sp,
            right: 10.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 190.sp,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/image/criket.jpg'),
                  ),
                ),
              ),
              SizedBox(height: 15.sp),
              Text(
                'Your Booked Slot',
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(height: 2.sp),
              const Divider(),
              SizedBox(height: 8.sp),
              Expanded(
                child: _bookedSlots.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: Image(
                                height: 230.sp,
                                width: 230.sp,
                                image: const AssetImage(
                                    'assets/image/slot_book.jpg'),
                              ),
                            ),
                            Center(
                              child: Text(
                                'No bookings. Book a slot.',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(fontSize: 13.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _bookedSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _bookedSlots[index];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0.sp),
                            elevation: 5,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0.sp),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(
                                  Icons.event,
                                  color: Colors.white,
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16.sp,
                                ),
                              ),
                              // Add a cancel button
                              // trailing: IconButton(
                              //   icon: Icon(Icons.cancel,
                              //       color: Colors.red, size: 25.sp),
                              //   onPressed: () => _showCancelDialog(slot),
                              // ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 20.sp, right: 20.sp, bottom: 15.sp),
          child: MaterialButton(
            height: 40.sp,
            elevation: 10,
            color: const Color.fromARGB(255, 45, 167, 162),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingPage(),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 70.sp),
              child: Text(
                'Book now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchBookedSlots() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bookingsQuery = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

    final bookedSlots = bookingsQuery.docs
        .map((doc) {
          final data = doc.data();
          // Inside the map function in _fetchBookedSlots()
          return BookedSlot(
            boxName: data['boxName'],
            timeSlot: data['timeSlot'],
            date: DateTime.parse(data['date']),
            totalCost: data['totalCost'],
            paymentId: data['paymentId'], // Add this line
          );
        })
        .where((slot) => slot.date.isAfter(twoDaysAgo))
        .toList();

    setState(() {
      _bookedSlots = bookedSlots;
    });
  }

void _handlePaymentStatusError(BookedSlot slot) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.sp),
          height: 250.sp,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60.sp,
              ),
              SizedBox(height: 15.sp),
              Text(
                'Cancellation Failed',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                'The payment status should be captured for action to be taken',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20.sp),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // You can add additional error handling logic here
                  _retryPaymentCapture(slot);
                },
                child: Text(
                  'Retry Payment Capture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
// Add a method to attempt to recapture payment status
  Future<void> _retryPaymentCapture(BookedSlot slot) async {
    try {
      // Implement logic to verify or recapture payment status
      // This might involve calling Razorpay API or your backend service
      final paymentId = slot.paymentId;

      // Example of checking payment status
      final paymentStatus = await _verifyPaymentStatus(paymentId);

      if (paymentStatus == 'captured') {
        // If payment is captured, proceed with cancellation
        await _cancelBooking(slot);
      } else {
        Fluttertoast.showToast(
          msg: "Payment status still unresolved. Contact support.",
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      debugPrint("Error retrying payment capture: $e");
      Fluttertoast.showToast(
        msg: "Failed to verify payment status.",
        backgroundColor: Colors.red,
      );
    }
  }
  

// Show a confirmation dialog before cancellation
void _showCancelDialog(BookedSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(slot);
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }




// Add a method to verify payment status
  Future<String> _verifyPaymentStatus(String paymentId) async {
    try {
      final url = "https://api.razorpay.com/v1/payments/$paymentId";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('rzp_test_hQfkkexYy6Gxkp:ULxDv8ZB95pfAFc2RV5pf0Jh'))}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      debugPrint("Error verifying payment status: $e");
      return 'unknown';
    }
  }
  Future<bool> _verifyRefundStatus(String paymentId) async {
    try {
      final url = "https://api.razorpay.com/v1/payments/$paymentId/refunds";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('rzp_test_hQfkkexYy6Gxkp:ULxDv8ZB95pfAFc2RV5pf0Jh'))}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if refunds exist and their status
        if (data['items'] != null && data['items'].isNotEmpty) {
          // Check if any refund is in processed or completed status
          return data['items'].any((refund) =>
              refund['status'] == 'processed' ||
              refund['status'] == 'completed');
        }

        return false;
      }
      return false;
    } catch (e) {
      debugPrint("Error verifying refund status: $e");
      return false;
    }
  }

// Improved refund function with proper error handling
  Future<Map<String, dynamic>> _refundPayment(
      String paymentId, int amount) async {
    try {
      // Check if already refunded
      bool alreadyRefunded = await _verifyRefundStatus(paymentId);
      if (alreadyRefunded) {
        return {
          'status': 'processed',
          'message': 'Payment was already refunded'
        };
      }

      final url = "https://api.razorpay.com/v1/payments/$paymentId/refund";
      debugPrint("Attempting refund for payment: $paymentId, amount: $amount");

      // Handle possible zero amount
      if (amount <= 0) {
        debugPrint("Warning: Attempting to refund zero or negative amount");
        amount = 1; // Minimum amount for testing
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('rzp_test_hQfkkexYy6Gxkp:ULxDv8ZB95pfAFc2RV5pf0Jh'))}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"amount": amount * 100, "speed": "normal"}),
      );

      debugPrint("Refund API response status: ${response.statusCode}");
      debugPrint("Refund API response body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'status': 'processed'};
      } else {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        String errorMessage = "Unknown error";

        if (responseData.containsKey('error')) {
          final error = responseData['error'];
          if (error is Map && error.containsKey('description')) {
            errorMessage = error['description'].toString();
          } else if (error is String) {
            errorMessage = error;
          }
        }

        return {'status': 'failed', 'error': errorMessage};
      }
    } catch (e) {
      debugPrint("Exception during refund process: $e");
      return {'status': 'failed', 'error': e.toString()};
    }
  }

// Fixed cancellation function that properly handles UI state
 Future<void> _cancelBooking(BookedSlot slot) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the booking details
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('boxName', isEqualTo: slot.boxName)
          .where('timeSlot', isEqualTo: slot.timeSlot)
          .get();

      for (var doc in bookingsQuery.docs) {
        String paymentId = doc['paymentId'];
        double totalCost = doc['totalCost'];

        // Process Refund
        bool refundSuccess = await _processRefund(paymentId, totalCost);
        if (!refundSuccess) {
          Fluttertoast.showToast(
            msg: "Refund failed. Try again later!",
            backgroundColor: Colors.red,
          );
          return;
        }

        // Move booking to 'booking_cancell' collection
        await FirebaseFirestore.instance.collection('booking_cancell').add({
          'userId': userId,
          'boxName': slot.boxName,
          'timeSlot': slot.timeSlot,
          'date': slot.date,
          'totalCost': totalCost,
          'paymentId': paymentId,
          'canceledAt': Timestamp.now(),
        });

        // Delete from 'bookings' collection
        await doc.reference.delete();
      }

      setState(() {
        _bookedSlots.remove(slot);
      });

      Fluttertoast.showToast(
        msg: "Booking canceled and refund processed successfully!",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error canceling booking: $e",
        backgroundColor: Colors.red,
      );
    }
  }
  Future<bool> _processRefund(String paymentId, double amount) async {
    try {
      var response = await http.post(
        Uri.parse("https://api.razorpay.com/v1/payments/$paymentId/refund"),
        headers: {
          "Authorization":
              "Basic " + base64Encode(utf8.encode("YOUR_KEY:YOUR_SECRET")),
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "amount": (amount * 100).toInt(), // Convert to paise
        }),
      );

      if (response.statusCode == 200) {
        return true; // Refund successful
      } else {
        print("Refund failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Refund error: $e");
      return false;
    }
  }

 

// Add this function to retry a failed refund
  Future<void> _retryRefund(String paymentId, int amount) async {
    try {
      Fluttertoast.showToast(msg: "Retrying refund, please wait...");

      // Attempt the refund up to 3 times
      for (int i = 0; i < 3; i++) {
        final result = await _refundPayment(paymentId, amount);

        if (result['status'] == 'processed') {
          Fluttertoast.showToast(
            msg: "Refund successful on retry!",
            backgroundColor: Colors.green,
          );
          return;
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: 2));
      }

      // If we got here, all retries failed
      Fluttertoast.showToast(
        msg: "Refund failed after multiple attempts. Contact support.",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      debugPrint("Error during refund retry: $e");
      Fluttertoast.showToast(msg: "Refund retry failed: $e");
    }
  }



}

class BookedSlot {
  final String boxName;
  final String timeSlot;
  final DateTime date;
  final double totalCost;
  final String paymentId; // Add this line

  BookedSlot({
    required this.boxName,
    required this.timeSlot,
    required this.date,
    required this.totalCost,
    required this.paymentId, // Add this line
  });
}
