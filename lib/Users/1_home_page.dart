// ignore_for_file: depend_on_referenced_packages, file_names, use_build_context_synchronously, avoid_print

import 'package:box_booking_project/Drawer/drawer_page.dart';
import 'package:box_booking_project/Users/2_booking_page.dart';
import 'package:box_booking_project/Users/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
