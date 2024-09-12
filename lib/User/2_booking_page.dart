// ignore_for_file: file_names

import 'package:box_booking_project/User/3_TimeSlotSelectionPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBoxList = [];

  @override
  void initState() {
    super.initState();
    _loadBoxDetails();
    _searchController.addListener(_filterBoxes);
  }

  Future<void> _loadBoxDetails() async {
    await BookingController.fetchBoxDetails();
    _filteredBoxList = BookingController.boxList;
    setState(() {});
  }

  void _filterBoxes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBoxList = BookingController.boxList.where((box) {
        final boxName = box['boxName'].toLowerCase();
        final area = box['area'].toLowerCase();
        return boxName.contains(query) || area.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text(
          'Box Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 3,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Container(
              height: 50.sp,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2.sp),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search Box nearby You',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.sp),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBoxList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredBoxList.length,
                    itemBuilder: (context, index) {
                      final box = _filteredBoxList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimeSlotSelectionPage(
                                boxName: box['boxName'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0.sp, vertical: 8.0.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: box['imageUrl'] != null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        NetworkImage(box['imageUrl']),
                                  )
                                : CircleAvatar(
                                    radius: 30.sp,
                                    backgroundImage: const AssetImage(
                                        'assets/box_placeholder.png'),
                                  ),
                            title: Text(
                              box['boxName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            subtitle: Text(
                              box['area'],
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BookingController {
  static List<Map<String, dynamic>> boxList = [];

  static Future<void> fetchBoxDetails() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('boxes').get();
    boxList = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }
}
