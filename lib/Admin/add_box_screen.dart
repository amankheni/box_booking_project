// ignore_for_file: unused_field, depend_on_referenced_packages, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  late DateTime _startTimeTomorrow;
  late DateTime _endTimeTomorrow;
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

  void _initializeTimeSlots() {
    final now = DateTime.now();
    _startTimeToday = DateTime(now.year, now.month, now.day, now.hour);
    _endTimeToday = DateTime(now.year, now.month, now.day, 23, 59);
    _startTimeTomorrow = DateTime(now.year, now.month, now.day + 1, now.hour);
    _endTimeTomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59);
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
            _startTimeTomorrow =
                DateTime.parse(boxData['timeSlots']['tomorrow']['startTime']);
            _endTimeTomorrow =
                DateTime.parse(boxData['timeSlots']['tomorrow']['endTime']);
            _imageUrl = boxData['imageUrl'];
            _updateTimeSlots(); // Update the time slots based on the current time
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading box details: $e')),
        );
      }
    }
  }

  void _updateTimeSlots() {
    final now = DateTime.now();

    // Update only today’s time slots
    if (_endTimeToday.isBefore(now)) {
      _startTimeToday = now;
      _endTimeToday = DateTime(now.year, now.month, now.day, 23, 59);
    }

    // Keep tomorrow’s time slots as set by the admin
  }

  Future<void> _updateBoxDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String? imageUrl = await _uploadImage();

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
            'tomorrow': {
              'startTime': _startTimeTomorrow.toIso8601String(),
              'endTime': _endTimeTomorrow.toIso8601String(),
            },
          },
          'adminId': user.uid,
          'createdDate': FieldValue.serverTimestamp(),
          'imageUrl': imageUrl,
        };

        if (_boxId != null) {
          // Update existing box
          await _firestore.collection('boxes').doc(_boxId).update(boxData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Box updated successfully')),
          );
        } else {
          // Add new box
          await _firestore.collection('boxes').add(boxData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Box added successfully')),
          );
        }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating box details: $e')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime, required bool isToday}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime
          ? (isToday ? _startTimeToday : _startTimeTomorrow)
          : (isToday ? _endTimeToday : _endTimeTomorrow)),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          if (isToday) {
            _startTimeToday = DateTime(
              _startTimeToday.year,
              _startTimeToday.month,
              _startTimeToday.day,
              picked.hour,
              0,
            );
            _endTimeToday = _startTimeToday.add(const Duration(hours: 1));
          } else {
            _startTimeTomorrow = DateTime(
              _startTimeTomorrow.year,
              _startTimeTomorrow.month,
              _startTimeTomorrow.day,
              picked.hour,
              0,
            );
            _endTimeTomorrow = _startTimeTomorrow.add(const Duration(hours: 1));
          }
        } else {
          if (isToday) {
            _endTimeToday = DateTime(
              _endTimeToday.year,
              _endTimeToday.month,
              _endTimeToday.day,
              picked.hour,
              0,
            );
          } else {
            _endTimeTomorrow = DateTime(
              _endTimeTomorrow.year,
              _endTimeTomorrow.month,
              _endTimeTomorrow.day,
              picked.hour,
              0,
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Box'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _boxNameController,
                decoration: const InputDecoration(labelText: 'Box Name'),
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Hour'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _lengthController,
                decoration: const InputDecoration(labelText: 'Length'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10.sp,
              ),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                  'Today: ${_timeFormat.format(_startTimeToday)} - ${_timeFormat.format(_endTimeToday)}'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context,
                          isStartTime: true, isToday: true),
                      child: const Text('Select Today Start Time'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context,
                          isStartTime: false, isToday: true),
                      child: const Text('Select Today End Time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                  'Tomorrow: ${_timeFormat.format(_startTimeTomorrow)} - ${_timeFormat.format(_endTimeTomorrow)}'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context,
                          isStartTime: true, isToday: false),
                      child: const Text('Select Tomorrow Start Time'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context,
                          isStartTime: false, isToday: false),
                      child: const Text('Select Tomorrow End Time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateBoxDetails,
                child: const Text('Save Box Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
