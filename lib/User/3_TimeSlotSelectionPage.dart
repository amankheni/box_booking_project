// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:box_booking_project/User/4_booking_summry_page.dart';

class TimeSlotSelectionPage extends StatefulWidget {
  final String boxName;

  const TimeSlotSelectionPage({super.key, required this.boxName});

  @override
  _TimeSlotSelectionPageState createState() => _TimeSlotSelectionPageState();
}

class _TimeSlotSelectionPageState extends State<TimeSlotSelectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _timeSlots = [];
  Set<String> _bookedSlots = {};
  DateTime _selectedDate = DateTime.now();
  String? _boxImageUrl;
  String? _boxLocation;
  double? _boxLength;
  double? _boxWidth;
  double? _boxHeight;
  double? _pricePerHour;
  String? _adminFirstName;
  String? _adminLastName;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateTimeSlots();
  }

  Future<void> _fetchAndGenerateTimeSlots() async {
    try {
      final boxQuery = await _firestore
          .collection('boxes')
          .where('boxName', isEqualTo: widget.boxName)
          .get();

      if (boxQuery.docs.isNotEmpty) {
        final boxData = boxQuery.docs.first.data() as Map<String, dynamic>;
        final List<dynamic> fetchedTimeSlots = boxData['timeSlots'];

        List<Map<String, dynamic>> generatedSlots = [];

        for (var slot in fetchedTimeSlots) {
          DateTime startTime = DateTime.parse(slot['startTime']);
          DateTime endTime = DateTime.parse(slot['endTime']);

          while (startTime.isBefore(endTime)) {
            final nextTime = startTime.add(const Duration(minutes: 60));
            if (nextTime.isAfter(endTime)) break;

            generatedSlots.add({
              'startTime': startTime,
              'endTime': nextTime,
            });
            startTime = nextTime;
          }
        }

        // Fetch additional box details
        setState(() {
          _timeSlots = generatedSlots;
          _boxImageUrl = boxData['imageUrl']; // Fetch box image URL
          _boxLocation = boxData['location']; // Fetch box location
          _boxLength = boxData['length']; // Fetch box length
          _boxWidth = boxData['width']; // Fetch box width
          _boxHeight = boxData['height']; // Fetch box height
          _pricePerHour = boxData['pricePerHour']; // Fetch price per hour
        });

        // Fetch admin details from 'users' collection
        final adminQuery = await _firestore
            .collection('users')
            .doc(boxData['adminId']) // Assuming boxData contains adminId
            .get();

        if (adminQuery.exists) {
          final adminData = adminQuery.data() as Map<String, dynamic>;
          setState(() {
            _adminFirstName = adminData['firstName'];
            _adminLastName = adminData['lastName'];
          });
        }

        // Fetch booked slots
        final bookingsQuery = await _firestore
            .collection('bookings')
            .where('boxName', isEqualTo: widget.boxName)
            .where('date', isEqualTo: _selectedDate.toIso8601String())
            .get();

        final bookedSlots = bookingsQuery.docs.map((doc) {
          final data = doc.data();
          final startTime = DateTime.parse(data['startTime']);
          final endTime = DateTime.parse(data['endTime']);
          return '${startTime.toIso8601String()} - ${endTime.toIso8601String()}';
        }).toSet();

        setState(() {
          _bookedSlots = bookedSlots;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No time slots found for ${widget.boxName}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching time slots: $e')),
      );
    }
  }

  void _selectTimeSlot(Map<String, dynamic> timeSlot) {
    final DateFormat formatter = DateFormat('hh:mm a');
    final String formattedTimeSlot =
        '${formatter.format(timeSlot['startTime'])} - ${formatter.format(timeSlot['endTime'])}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryPage(
          boxName: widget.boxName,
          timeSlot: formattedTimeSlot,
          date: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Slot for ${widget.boxName}'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_boxImageUrl != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.network(
                  _boxImageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_boxLocation != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Location: $_boxLocation',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_boxLength != null &&
                _boxWidth != null &&
                _boxHeight != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Dimensions: ${_boxLength}ft x ${_boxWidth}ft x ${_boxHeight}ft',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_pricePerHour != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Price : ₹${_pricePerHour!.toStringAsFixed(2)} (Per Hour)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_adminFirstName != null && _adminLastName != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Owner : $_adminFirstName $_adminLastName',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: _timeSlots.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final timeSlot = _timeSlots[index];
                        final DateFormat formatter = DateFormat('hh:mm a');
                        final String formattedTimeSlot =
                            '${formatter.format(timeSlot['startTime'])} - ${formatter.format(timeSlot['endTime'])}';

                        final isBooked = _bookedSlots.contains(
                            '${timeSlot['startTime'].toIso8601String()} - ${timeSlot['endTime'].toIso8601String()}');

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            title: Text(
                              formattedTimeSlot,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            tileColor: isBooked ? Colors.grey : Colors.white,
                            onTap: isBooked
                                ? null
                                : () => _selectTimeSlot(timeSlot),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No time slots available.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
