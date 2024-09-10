// ignore_for_file: file_names

import 'package:box_booking_project/User/3_TimeSlotSelectionPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    _loadBoxDetails();
  }

  Future<void> _loadBoxDetails() async {
    await BookingController.fetchBoxDetails();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Box Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 3,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 50,
                width: 330,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Search Box near by You',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BookingController.boxList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: BookingController.boxList.length,
                    itemBuilder: (context, index) {
                      final box = BookingController.boxList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimeSlotSelectionPage(
                                //   boxId: box['id'], // Pass the correct boxId here
                                boxName: box['boxName'],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: box['imageUrl'] != null
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(box['imageUrl']),
                                )
                              : const CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      AssetImage('assets/box_placeholder.png'),
                                ),
                          title: Text(box['boxName']),
                          subtitle: Text(box['area']),
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
        'id': doc.id, // Include the document ID
        ...data,
      };
    }).toList();
  }
}
