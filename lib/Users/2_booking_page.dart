// ignore_for_file: file_names

import 'package:box_booking_project/Controller/booking_controller.dart';
import 'package:box_booking_project/Users/3_TimeSlotSelectionPage.dart';
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
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _loadBoxDetails();
    _searchController.addListener(_filterBoxes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Box Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.sp),
                  boxShadow: [
                    BoxShadow(
                      color: _isSearchActive
                          ? Colors.teal.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.teal),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onTap: () {
                          setState(() {
                            _isSearchActive = true;
                          });
                        },
                        onEditingComplete: () {
                          setState(() {
                            _isSearchActive = false;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Boxes...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.sp),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _filterBoxes();
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBoxList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.teal,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          'Loading boxes...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )
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
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0.sp, vertical: 8.0.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.sp),
                          ),
                          elevation: 6,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.sp),
                            leading: box['imageUrl'] != null
                                ? CircleAvatar(
                                    radius: 35.sp,
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
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              box['area'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.teal,
                              size: 20.sp,
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
}
