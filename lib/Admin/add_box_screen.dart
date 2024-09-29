// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminAddBoxScreen extends StatefulWidget {
  const AdminAddBoxScreen({Key? key}) : super(key: key);

  @override
  _AdminAddBoxScreenState createState() => _AdminAddBoxScreenState();
}

class _AdminAddBoxScreenState extends State<AdminAddBoxScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _boxNameController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late DateTime _startTimeToday;
  late DateTime _endTimeToday;
  String? _boxId;
  File? _imageFile;
  String? _imageUrl;

  final DateFormat _timeFormat = DateFormat('h a');

  @override
  void initState() {
    super.initState();
    _boxNameController = TextEditingController();
    _areaController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _lengthController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();

    _initializeTimeSlots();
    _loadBoxDetails();
  }

  @override
  void dispose() {
    _boxNameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add or Edit Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateBoxDetails,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: ListView(
          children: [
            Container(
              height: 200.sp,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      fit: BoxFit
                          .cover, // Adjusts the image to cover the container
                    )
                  : _imageUrl != null
                      ? Image.network(
                          _imageUrl!,
                          fit: BoxFit
                              .cover, // Adjusts the image to cover the container
                        )
                      : Container(), // Empty container if no image
            ),
            SizedBox(
              height: 10.sp,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: GestureDetector(
                onTap: () => _pickImage(),
                child: Container(
                  height: 35.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          blurStyle: BlurStyle.outer,
                          blurRadius: 3),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Pick image',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 13.sp,
            ),
            TextField(
              controller: _boxNameController,
              decoration: const InputDecoration(labelText: 'Box Name'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _areaController,
              decoration: const InputDecoration(labelText: 'Area'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price Per Hour'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _lengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Length'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Width'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height'),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                const Text('Today\'s Time Slots'),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _selectTime(context, isStartTime: true, isToday: true),
                  child: Text(
                    'Start: ${_timeFormat.format(_startTimeToday)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _selectTime(context, isStartTime: false, isToday: true),
                  child: Text(
                    'End: ${_timeFormat.format(_endTimeToday)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: GestureDetector(
                onTap: () => _updateBoxDetails(),
                child: Container(
                  height: 35.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          blurStyle: BlurStyle.outer,
                          blurRadius: 3),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Update Box',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeTimeSlots() {
    final now = DateTime.now();
    _startTimeToday = DateTime(now.year, now.month, now.day, now.hour);
    _endTimeToday = DateTime(now.year, now.month, now.day, 23, 59);
  }

  Future<void> _loadBoxDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final boxQuery = await _firestore
            .collection('boxes')
            .where('adminId', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (boxQuery.docs.isNotEmpty) {
          final boxData = boxQuery.docs.first.data();
          setState(() {
            _boxId = boxQuery.docs.first.id;
            _boxNameController.text = boxData['boxName'] ?? '';
            _areaController.text = boxData['area'] ?? '';
            _priceController.text = (boxData['pricePerHour'] ?? 0.0).toString();
            _locationController.text = boxData['location'] ?? '';
            _lengthController.text = (boxData['length'] ?? '').toString();
            _widthController.text = (boxData['width'] ?? '').toString();
            _heightController.text = (boxData['height'] ?? '').toString();
            _startTimeToday =
                DateTime.parse(boxData['timeSlots']['today']['startTime']);
            _endTimeToday =
                DateTime.parse(boxData['timeSlots']['today']['endTime']);

            _imageUrl = boxData['imageUrl'];
            _updateTimeSlots(); // Update the time slots based on the current time
          });
        }
      } catch (e) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          label: 'Error loading box details: $e',
          labelTextStyle: TextStyle(fontSize: 15.sp),
        );
      }
    }
  }

  void _updateTimeSlots() {
    final now = DateTime.now();

    // Update only today’s time slots if the current time is past the end time
    if (_endTimeToday.isBefore(now)) {
      _startTimeToday = now;
      _endTimeToday = DateTime(now.year, now.month, now.day, 23, 59);
    }
  }

  Future<void> _updateBoxDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Only upload a new image if one was selected; otherwise, keep the current imageUrl
        String? imageUrl =
            _imageFile != null ? await _uploadImage() : _imageUrl;

        final boxData = {
          'boxName': _boxNameController.text.trim(),
          'area': _areaController.text.trim(),
          'pricePerHour': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'location': _locationController.text.trim(),
          'length': double.tryParse(_lengthController.text.trim()) ?? 0.0,
          'width': double.tryParse(_widthController.text.trim()) ?? 0.0,
          'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
          'timeSlots': {
            'today': {
              'startTime': _startTimeToday.toIso8601String(),
              'endTime': _endTimeToday.toIso8601String(),
            },
          },
          'adminId': user.uid,
          'createdDate': FieldValue.serverTimestamp(),
          'imageUrl': imageUrl,
        };

        if (_boxId != null) {
          // Update existing box
          await _firestore.collection('boxes').doc(_boxId).update(boxData);
          IconSnackBar.show(
            context,
            snackBarType: SnackBarType.success,
            label: 'Box updated successfully',
            labelTextStyle: TextStyle(fontSize: 15.sp),
          );
        } else {
          // Add new box

          await _firestore.collection('boxes').add(boxData);
          IconSnackBar.show(
            context,
            snackBarType: SnackBarType.success,
            label: 'Box added successfully',
            labelTextStyle: TextStyle(fontSize: 15.sp),
          );
        }

        // Clear the form and reset state
        _boxNameController.clear();
        _areaController.clear();
        _priceController.clear();
        _locationController.clear();
        _lengthController.clear();
        _widthController.clear();
        _heightController.clear();
        setState(() {
          _boxId = null;
          _imageFile = null;
          _imageUrl = null;
        });
      } catch (e) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          label: 'Error updating box details: $e',
          labelTextStyle: TextStyle(fontSize: 15.sp),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageRef = _storage
          .ref()
          .child('box_images/${user.uid}/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        label: 'Error uploading image: $e',
        labelTextStyle: TextStyle(fontSize: 15.sp),
      );
      return null;
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime, required bool isToday}) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(isStartTime
        ? (isToday
            ? _startTimeToday
            : DateTime.now()) // default to now if not today
        : (isToday
            ? _endTimeToday
            : DateTime.now())); // default to now if not today

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      barrierColor: Colors.black54,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.teal, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.teal, // Button text color (e.g., Cancel, OK)
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Ensure the minutes are always set to zero (00)
        DateTime newTime = DateTime(
          isToday ? _startTimeToday.year : DateTime.now().year,
          isToday ? _startTimeToday.month : DateTime.now().month,
          isToday ? _startTimeToday.day : DateTime.now().day,
          picked.hour,
          0, // Always set minutes to zero
        );

        if (isStartTime) {
          if (isToday) {
            _startTimeToday = newTime;
            _endTimeToday = _startTimeToday.add(const Duration(hours: 1));
          }
        } else {
          if (isToday) {
            _endTimeToday = newTime;
          }
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
}
