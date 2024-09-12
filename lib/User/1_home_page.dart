// ignore_for_file: depend_on_referenced_packages, file_names, use_build_context_synchronously, avoid_print

import 'package:box_booking_project/Admin/add_box_screen.dart';
import 'package:box_booking_project/Auth/1_sing_in_screen.dart';
import 'package:box_booking_project/User/2_booking_page.dart';
import 'package:box_booking_project/User/box_book_info_screen.dart';
import 'package:box_booking_project/User/history_screen.dart';
import 'package:box_booking_project/User/payment_history_screen.dart';
import 'package:box_booking_project/User/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

//-----------

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
          return BookedSlot(
            boxName: data['boxName'],
            timeSlot: data['timeSlot'],
            date: DateTime.parse(data['date']),
          );
        })
        .where((slot) => slot.date.isAfter(twoDaysAgo))
        .toList();

    setState(() {
      _bookedSlots = bookedSlots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          width: 300.sp,
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 50.sp, left: 16.sp, right: 16.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.teal.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
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
                        radius: 50.sp,
                        backgroundImage: const AssetImage(
                            'assets/image/cricket-player- avetar.jpg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    SizedBox(height: 20.sp),
                  ],
                ),
              ),
              Divider(height: 1.sp, color: Colors.grey),
              SizedBox(height: 10.sp),
              _buildMenuItem(
                context,
                icon: Icons.home_outlined,
                text: 'Home',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                text: 'Box Book Info',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BoxBookInfoScreen(),
                      ));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.history,
                text: 'History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.wallet_rounded,
                text: 'Payment',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.logout_outlined,
                text: 'Log out',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black54,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 10,
                        actionsPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp, vertical: 12.sp),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SingInScreen1(), // Replace with your actual screen
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        key: scaffoldKey,
        body: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    child: Icon(
                      Icons.menu_open_rounded,
                      color: const Color.fromARGB(255, 13, 124, 120),
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(width: 13.sp),
                  Text(
                    'Book My Box',
                    style:
                        TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 7.sp),
              Divider(thickness: 2.sp),
              SizedBox(height: 7.sp),
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
                              opacity: 0.7.sp,
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(24.sp),
          child: MaterialButton(
            color: const Color.fromARGB(255, 45, 167, 162),
            colorBrightness: Brightness.light,
            focusElevation: 2.sp,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingPage(),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 70.sp, right: 70.sp),
              child: Text(
                'Book now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
        child: Row(
          children: [
            Icon(icon, size: 30.sp, color: Colors.teal),
            SizedBox(width: 15.sp),
            Text(
              text,
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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
    double? totalCost,
  });
}
