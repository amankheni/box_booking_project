import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  late TextEditingController _locationController; // Controller for Box Location
  late TextEditingController _lengthController; // Controller for Length
  late TextEditingController _widthController; // Controller for Width
  late TextEditingController _heightController; // Controller for Height
  late DateTime _startTime;
  late DateTime _endTime;
  String? _boxId; // To store the ID of the existing box, if any
  File? _imageFile; // To store the selected image
  String? _imageUrl; // To store the uploaded image URL

  final DateFormat _timeFormat =
      DateFormat('h a'); // Format for hours with AM/PM

  @override
  void initState() {
    super.initState();
    _boxNameController = TextEditingController();
    _areaController = TextEditingController();
    _priceController = TextEditingController();
    _locationController =
        TextEditingController(); // Initialize the new controller
    _lengthController = TextEditingController(); // Initialize Length controller
    _widthController = TextEditingController(); // Initialize Width controller
    _heightController = TextEditingController(); // Initialize Height controller
    _startTime = DateTime.now();
    _endTime = _startTime.add(const Duration(hours: 1)); // default 1-hour slot
    _loadBoxDetails(); // Load box details if editing an existing box
  }

  @override
  void dispose() {
    _boxNameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _locationController.dispose(); // Dispose the new controller
    _lengthController.dispose(); // Dispose Length controller
    _widthController.dispose(); // Dispose Width controller
    _heightController.dispose(); // Dispose Height controller
    super.dispose();
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
          final boxData = boxQuery.docs.first.data() as Map<String, dynamic>;
          setState(() {
            _boxId = boxQuery.docs.first.id;
            _boxNameController.text = boxData['boxName'] ?? '';
            _areaController.text = boxData['area'] ?? '';
            _priceController.text = (boxData['pricePerHour'] ?? 0.0).toString();
            _locationController.text =
                boxData['location'] ?? ''; // Load Box Location
            _lengthController.text =
                (boxData['length'] ?? '').toString(); // Load Length
            _widthController.text =
                (boxData['width'] ?? '').toString(); // Load Width
            _heightController.text =
                (boxData['height'] ?? '').toString(); // Load Height
            _startTime = DateTime.parse(boxData['timeSlots'][0]['startTime']);
            _endTime = DateTime.parse(boxData['timeSlots'][0]['endTime']);
            _imageUrl = boxData['imageUrl'];
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading box details: $e')),
        );
      }
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

  Future<void> _saveBoxDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String? imageUrl = await _uploadImage();

        final boxData = {
          'boxName': _boxNameController.text.trim(),
          'area': _areaController.text.trim(),
          'pricePerHour': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'location': _locationController.text.trim(), // Save Box Location
          'length': double.tryParse(_lengthController.text.trim()) ??
              0.0, // Save Length
          'width': double.tryParse(_widthController.text.trim()) ??
              0.0, // Save Width
          'height': double.tryParse(_heightController.text.trim()) ??
              0.0, // Save Height
          'timeSlots': [
            {
              'startTime': _startTime.toIso8601String(),
              'endTime': _endTime.toIso8601String(),
            }
          ],
          'adminId': user.uid,
          'createdDate': FieldValue.serverTimestamp(), // Store the current date
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
        _locationController.clear(); // Clear the new field
        _lengthController.clear(); // Clear Length field
        _widthController.clear(); // Clear Width field
        _heightController.clear(); // Clear Height field
        setState(() {
          _boxId = null; // Reset box ID after saving
          _imageFile = null; // Clear selected image
          _imageUrl = null; // Clear image URL
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving box details: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
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
          _startTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            picked.hour,
            0, // Set minutes to 0
          );
          _endTime =
              _startTime.add(const Duration(hours: 1)); // default 1-hour slot
        } else {
          _endTime = DateTime(
            _endTime.year,
            _endTime.month,
            _endTime.day,
            picked.hour,
            0, // Set minutes to 0
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Box Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: _imageFile == null
                      ? Center(
                          child: _imageUrl != null
                              ? Image.network(_imageUrl!)
                              : Text('Select Image'))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _boxNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Box Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Area',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Price Per Hour',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller:
                    _locationController, // New TextField for Box Location
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Location',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lengthController, // New TextField for Length
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Length (ft)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _widthController, // New TextField for Width
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Width (ft)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _heightController, // New TextField for Height
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Height (ft)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text("Start Time: ${_timeFormat.format(_startTime)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, isStartTime: true),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text("End Time: ${_timeFormat.format(_endTime)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, isStartTime: false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBoxDetails,
                child: Text(_boxId != null ? 'Update Box' : 'Add Box'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
