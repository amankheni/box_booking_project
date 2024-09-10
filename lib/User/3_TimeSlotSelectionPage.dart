// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, file_names

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
  List<Map<String, dynamic>> _todaySlots = [];
  List<Map<String, dynamic>> _tomorrowSlots = [];
  Set<String> _bookedSlots = {};
  final DateTime _selectedDate = DateTime.now();
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
        final boxData = boxQuery.docs.first.data();

        // Fetch time slots
        final todaySlot = boxData['timeSlots']['today'] as Map<String, dynamic>;
        final tomorrowSlot =
            boxData['timeSlots']['tomorrow'] as Map<String, dynamic>;

        List<Map<String, dynamic>> todayGeneratedSlots = [];
        List<Map<String, dynamic>> tomorrowGeneratedSlots = [];

        // Process today's slots
        DateTime todayStart = DateTime.parse(todaySlot['startTime']);
        DateTime todayEnd = DateTime.parse(todaySlot['endTime']);
        while (todayStart.isBefore(todayEnd)) {
          final nextTime = todayStart.add(const Duration(minutes: 60));
          if (nextTime.isAfter(todayEnd)) break;

          todayGeneratedSlots.add({
            'startTime': todayStart,
            'endTime': nextTime,
          });
          todayStart = nextTime;
        }

        // Process tomorrow's slots
        DateTime tomorrowStart = DateTime.parse(tomorrowSlot['startTime']);
        DateTime tomorrowEnd = DateTime.parse(tomorrowSlot['endTime']);
        while (tomorrowStart.isBefore(tomorrowEnd)) {
          final nextTime = tomorrowStart.add(const Duration(minutes: 60));
          if (nextTime.isAfter(tomorrowEnd)) break;

          tomorrowGeneratedSlots.add({
            'startTime': tomorrowStart,
            'endTime': nextTime,
          });
          tomorrowStart = nextTime;
        }

        // Fetch additional box details
        setState(() {
          _todaySlots = todayGeneratedSlots;
          _tomorrowSlots = tomorrowGeneratedSlots;
          _boxImageUrl = boxData['imageUrl'];
          _boxLocation = boxData['location'];
          _boxLength = boxData['length'];
          _boxWidth = boxData['width'];
          _boxHeight = boxData['height'];
          _pricePerHour = boxData['pricePerHour'];
        });

        // Fetch admin details from 'users' collection
        final adminQuery =
            await _firestore.collection('users').doc(boxData['adminId']).get();

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

  void _selectTimeSlot(DateTime startTime, DateTime endTime) {
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    final String formattedTimeSlot =
        '${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryPage(
          boxName: widget.boxName,
          timeSlot: formattedTimeSlot,
          date: _selectedDate, // Pass the DateTime object directly
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
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                children: [
                  if (_todaySlots.isNotEmpty) ...[
                    Text(
                      'Today (${DateFormat('yyyy-MM-dd').format(DateTime.now())})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._todaySlots.map((timeSlot) {
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
                              : () => _selectTimeSlot(
                                  timeSlot['startTime'], timeSlot['endTime']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  if (_tomorrowSlots.isNotEmpty) ...[
                    Text(
                      'Tomorrow (${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)))})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._tomorrowSlots.map((timeSlot) {
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
                              : () => _selectTimeSlot(
                                  timeSlot['startTime'], timeSlot['endTime']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
