// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SpecificSlotScreen6 extends StatefulWidget {
  const SpecificSlotScreen6({super.key});

  @override
  State<SpecificSlotScreen6> createState() => _SpecificSlotScreen6State();
}

class _SpecificSlotScreen6State extends State<SpecificSlotScreen6> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _timeSlots = [];

  Future<void> _fetchTimeSlots() async {
    try {
      // Assuming boxId is available (you need to pass it from previous screen)
      String boxId = 'someBoxId'; // Replace with actual box ID
      DocumentSnapshot doc =
          await _firestore.collection('boxes').doc(boxId).get();
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        List<dynamic> slots = data['timeSlots'] ?? [];
        setState(() {
          _timeSlots = slots.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print('Error fetching time slots: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch the time slots when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios_new),
          title: const Text('Available Slots'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Divider(
                indent: 20,
                endIndent: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _timeSlots.length,
                  itemBuilder: (context, index) {
                    final slot = _timeSlots[index];
                    final startTime =
                        DateTime.parse(slot['startTime']).toLocal();
                    final endTime = DateTime.parse(slot['endTime']).toLocal();
                    return ListTile(
                      title: Text(
                          '${startTime.toString()} - ${endTime.toString()}'),
                      onTap: () {
                        // Handle slot selection
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
