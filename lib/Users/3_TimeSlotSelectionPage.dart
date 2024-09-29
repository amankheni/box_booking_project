// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_null_comparison, depend_on_referenced_packages, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:box_booking_project/Users/4_booking_summry_page.dart';

class TimeSlotSelectionPage extends StatefulWidget {
  final String boxName;

  const TimeSlotSelectionPage({super.key, required this.boxName});

  @override
  _TimeSlotSelectionPageState createState() => _TimeSlotSelectionPageState();
}

class _TimeSlotSelectionPageState extends State<TimeSlotSelectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _todaySlots = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Slot for ${widget.boxName}'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_boxImageUrl != null) ...[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0.sp),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _boxImageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
              if (_boxLocation != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_pin,
                      size: 25.sp,
                    ),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: Text(
                        '$_boxLocation',
                        style: TextStyle(fontSize: 16.sp),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
              ],
              if (_boxLength != null &&
                  _boxWidth != null &&
                  _boxHeight != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.fit_screen_outlined,
                      size: 25.sp,
                    ),
                    SizedBox(
                      width: 8.sp,
                    ),
                    Text(
                      '${_boxLength}ft x ${_boxWidth}ft x ${_boxHeight}ft',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
              ],
              if (_pricePerHour != null) ...[
                Row(
                  children: [
                    Text(
                      ' ₹ ',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(
                      width: 8.sp,
                    ),
                    Text(
                      ' ${_pricePerHour!.toStringAsFixed(2)} (Per Hour)',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10.sp),
              ],
              if (_adminFirstName != null && _adminLastName != null) ...[
                Text(
                  'Owner : $_adminFirstName $_adminLastName',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
              SizedBox(height: 3.sp),
              const Divider(
                color: Colors.grey,
              ),
              SizedBox(height: 3.sp),
              Text(
                'Available Time Slots',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8.sp),
              if (_todaySlots.isNotEmpty) ...[
                Text(
                  'Today (${DateFormat('yyyy-MM-dd').format(DateTime.now())})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 8.sp),
                // Update in build method where time slots are displayed
                ..._todaySlots.map((timeSlot) {
                  final DateFormat formatter = DateFormat('hh:mm a');
                  final String formattedTimeSlot =
                      '${formatter.format(timeSlot['startTime'])} - ${formatter.format(timeSlot['endTime'])}';

                  // Create the slot key to compare with booked slots
                  final String slotKey =
                      '${timeSlot['startTime'].toIso8601String()} - ${timeSlot['endTime'].toIso8601String()}';

                  // Check if this time slot is already booked
                  final bool isBooked = _bookedSlots.contains(slotKey);

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.sp),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                      title: Text(
                        formattedTimeSlot,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tileColor: isBooked
                          ? Colors.grey.shade300
                          : Colors.white, // Grey out booked slots
                      onTap: isBooked
                          ? null
                          : () => _selectTimeSlot(
                              timeSlot['startTime'],
                              timeSlot[
                                  'endTime']), // Disable tap for booked slots
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 16.sp),
              ] else ...[
                Text(
                  'No slots available for today.',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchAndGenerateTimeSlots() async {
    try {
      final boxQuery = await _firestore
          .collection('boxes')
          .where('boxName', isEqualTo: widget.boxName)
          .limit(1)
          .get();

      if (boxQuery.docs.isNotEmpty) {
        final boxData = boxQuery.docs.first.data();

        // Check if timeSlots exist and are valid maps
        final todaySlot =
            boxData['timeSlots']?['today'] as Map<String, dynamic>?;

        if (todaySlot != null) {
          List<Map<String, dynamic>> todayGeneratedSlots =
              _generateHourlySlots(todaySlot);

          // Fetch additional box details
          setState(() {
            _todaySlots = todayGeneratedSlots;
            _boxImageUrl = boxData['imageUrl'];
            _boxLocation = boxData['location'];
            _boxLength = (boxData['length'] as num?)?.toDouble();
            _boxWidth = (boxData['width'] as num?)?.toDouble();
            _boxHeight = (boxData['height'] as num?)?.toDouble();
            _pricePerHour = (boxData['pricePerHour'] as num?)?.toDouble();
          });

          // Fetch admin details from 'users' collection
          if (boxData['adminId'] != null) {
            await _fetchAdminDetails(boxData['adminId']);
          }

          // Fetch booked slots
          await _fetchBookedSlots();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('No valid time slots found for ${widget.boxName}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No box data found for ${widget.boxName}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching time slots: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _generateHourlySlots(
      Map<String, dynamic> slotData) {
    List<Map<String, dynamic>> generatedSlots = [];
    if (slotData['startTime'] != null && slotData['endTime'] != null) {
      DateTime startTime = DateTime.parse(slotData['startTime']);
      DateTime endTime = DateTime.parse(slotData['endTime']);

      // Ensure startTime is not in the past
      DateTime now = DateTime.now();
      if (startTime.isBefore(now)) {
        // Round up to the next hour
        startTime = DateTime(now.year, now.month, now.day, now.hour + 1);
        if (startTime.isAfter(endTime)) {
          // No available slots for today
          return generatedSlots;
        }
      }

      while (startTime.isBefore(endTime)) {
        final nextTime = startTime.add(const Duration(hours: 1));
        if (nextTime.isAfter(endTime)) break;

        generatedSlots.add({
          'startTime': startTime,
          'endTime': nextTime,
        });
        startTime = nextTime;
      }
    }
    return generatedSlots;
  }

  Future<void> _fetchAdminDetails(String adminId) async {
    try {
      final adminQuery =
          await _firestore.collection('users').doc(adminId).get();
      if (adminQuery.exists) {
        final adminData = adminQuery.data() as Map<String, dynamic>;
        setState(() {
          _adminFirstName = adminData['firstName'] ?? '';
          _adminLastName = adminData['lastName'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching admin details: $e');
      // Optionally, show a SnackBar or other UI feedback
    }
  }

  // Update in _fetchBookedSlots function to store booked slots properly
  Future<void> _fetchBookedSlots() async {
    try {
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('boxName', isEqualTo: widget.boxName)
          .where('date',
              isEqualTo: DateFormat('yyyy-MM-dd')
                  .format(_selectedDate)) // Match the date format
          .get();

      final bookedSlots = bookingsQuery.docs.map((doc) {
        final data = doc.data();
        final startTime = DateTime.parse(data['startTime']);
        final endTime = DateTime.parse(data['endTime']);

        // Store booked slot as a string
        return '${startTime.toIso8601String()} - ${endTime.toIso8601String()}';
      }).toSet();

      setState(() {
        _bookedSlots = bookedSlots;
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
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
}
