// ignore_for_file: depend_on_referenced_packages, file_names, use_build_context_synchronously, avoid_print

import 'package:box_booking_project/Auth/1_log_in_screen.dart';
import 'package:box_booking_project/User/2_booking_page.dart';
import 'package:box_booking_project/User/history_screen.dart';
import 'package:box_booking_project/User/payment_history_screen.dart';
import 'package:box_booking_project/User/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        drawer: Drawer(
          width: 300,
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
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
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/image/cricket-player- avetar.jpg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 10),
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
                onTap: () {},
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
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 10,
                        actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
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
                                        const UserInfo2(), // Replace with your actual screen
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 16,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(
                      Icons.menu_open_rounded,
                      color: Color.fromARGB(255, 13, 124, 120),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 40),
                  const Text(
                    'Box Cricket Booking',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 3),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/image/criket.jpg'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Booked Slot',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _bookedSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _bookedSlots[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.event,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            slot.boxName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            '${slot.timeSlot} - ${DateFormat('dd MMM yyyy').format(slot.date)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24.0),
          child: MaterialButton(
            color: const Color.fromARGB(255, 45, 167, 162),
            colorBrightness: Brightness.light,
            focusElevation: 2,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingPage(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 70, right: 70),
              child: Text(
                'Book now',
                style: TextStyle(
                  color: Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.teal),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
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
