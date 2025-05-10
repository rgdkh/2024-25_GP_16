import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddTripForm extends StatefulWidget {
  final Map<String, dynamic>? tripData; // Existing trip data (for editing)
  final String? tripId; // ID of the trip (for updating)

  AddTripForm({this.tripData, this.tripId});

  @override
  _AddTripFormState createState() => _AddTripFormState();
}

class _AddTripFormState extends State<AddTripForm> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedTripType;
  String? _selectedTrail;
  String? _selectedAgeLimit;
  DateTime? _selectedDateTime;
  XFile? _selectedImage;
  final List<String> _tripTypes = ['Only Men', 'Only Women', 'Men & Women'];
  List<Map<String, dynamic>> _trailList = [];
  final List<String> _ageLimits = [
    "No Limit",
    "18+",
    "21+",
    "25+",
    "30+",
    "40+"
  ];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrails();
    // If tripData is provided, pre-fill the form fields
    if (widget.tripData != null) {
      _selectedTrail = widget.tripData!['trailName'];
      _selectedTripType = widget.tripData!['tripType'];
      _selectedAgeLimit = widget.tripData!['ageLimit'];
      _descriptionController.text = widget.tripData!['description'] ?? "";
      _selectedDateTime = (widget.tripData!['timestamp'] as Timestamp).toDate();
    }
  }

  Future<void> _fetchTrails() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('trails').get();
    setState(() {
      _trailList = snapshot.docs
          .map((doc) => {
                'name': doc['Name'] as String,
                'city': doc['City'] as String,
                'region': doc['Region'] as String,
              })
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      String fileName = 'trip_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('group_trip_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(File(_selectedImage!.path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();
    DateTime minDateTime = now.add(Duration(hours: 24)); // 24 hours from now

    // Show date picker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: minDateTime, // Start from 24 hours ahead
      firstDate: minDateTime, // Disable past 24 hours
      lastDate: DateTime(2100), // Set a far future limit
    );

    if (pickedDate == null) return; // User canceled

    // Show time picker
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return; // User canceled

    // Combine picked date and time
    DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Ensure selected time is at least 24 hours ahead
    if (selectedDateTime.isBefore(minDateTime)) {
      _showErrorDialog(); // Show error inside the form
      return;
    }

    setState(() {
      _selectedDateTime = selectedDateTime;
    });
  }

// Function to show an error dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Invalid Date & Time"),
        content:
            Text("Please select a date & time at least 24 hours from now."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final description = _descriptionController.text.trim();
    final tripType = _selectedTripType;
    final ageLimit = _selectedAgeLimit;
    final dateTime = _selectedDateTime;
    final user = FirebaseAuth.instance.currentUser;

    if (_selectedTrail == null ||
        tripType == null ||
        dateTime == null ||
        ageLimit == null ||
        user == null) {
      setState(() {
        _errorMessage = "Please fill all required fields!";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final selectedTrailData =
        _trailList.firstWhere((trail) => trail['name'] == _selectedTrail);
 // Upload image and get URL
    final tripImageUrl = await _uploadImage();

    final tripData = {
      
      'trailName': _selectedTrail,
      'city': selectedTrailData['city'],
      'region': selectedTrailData['region'],
      'tripType': tripType,
      'timestamp': Timestamp.fromDate(dateTime), // Trip Date
      'organizerId': user.uid,
      'description': description,
      'ageLimit': ageLimit,
     'tripImageUrl': tripImageUrl ?? '',
      'lastUpdated': Timestamp.now(), // Track last update
    };

    if (widget.tripId != null) {
      // If editing, update the trip and modify "lastUpdated"
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.tripId)
          .update(tripData);
    } else {
      // If adding, save a new trip
      await FirebaseFirestore.instance.collection('GroupTrips').add(tripData);
    }

    Navigator.of(context).pop(); // Close form after submission
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Add a New Trip"),
      backgroundColor: const Color(0xFF2A3A26),
    ),
    backgroundColor: const Color(0xFFEAE7D8),
    body: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
              ),
            const SizedBox(height: 10),
            _buildDropdown(
              "Trail Name",
              _trailList.map((trail) => trail['name'] as String).toList(),
              (value) => setState(() => _selectedTrail = value),
            ),
            const SizedBox(height: 25),
            _buildDropdown("Trip Type", _tripTypes,
                (value) => setState(() => _selectedTripType = value)),
            const SizedBox(height: 25),
            _buildDropdown("Age Limit", _ageLimits,
                (value) => setState(() => _selectedAgeLimit = value)),
            const SizedBox(height: 25),
            ListTile(
              title: Text(
                _selectedDateTime == null
                    ? "Pick Date & Time"
                    : _formatFullDateTime(_selectedDateTime!),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today, color: Color(0xFF2A3A26)),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 25),
            _buildTextField("Description (Optional)", _descriptionController,
                maxLines: 3),
            const SizedBox(height: 25),
            _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text(
                    "No image selected",
                    style: TextStyle(color: Colors.grey),
                  ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Upload Photo"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7A22C)),
                child: const Text("Add Trip",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDropdown(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      items: options
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  String _formatFullDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
