
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class JoinTripForm extends StatefulWidget {
  final String tripId;

  JoinTripForm({required this.tripId});

  @override
  _JoinTripFormState createState() => _JoinTripFormState();
}

class _JoinTripFormState extends State<JoinTripForm> {
  
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _contactNumber = '';
  String _selectedCountryCode = '+1';
  String _tripExperience = 'Never';
  String _skillLevel = 'Low';
  List<String> _languages = [];
  String _previousTrip = 'No';
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  final ImagePicker _picker = ImagePicker();



  
  Future<void> _joinTrip() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      _formKey.currentState!.save();
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      

      try {
        // Upload image if selected
        if (_selectedImage != null) {
          String fileName = 'trip_${widget.tripId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef = FirebaseStorage.instance.ref().child('trip_ids/$fileName');

          await storageRef.putFile(_selectedImage!);
          _uploadedImageUrl = await storageRef.getDownloadURL();
        }

        // Save participant details in Firestore
        await FirebaseFirestore.instance
            .collection('GroupTrips')
            .doc(widget.tripId)
            .collection('participants')
            .doc(userId)
            .set({
          'participantId': userId,
          'firstName': _firstName,
          'lastName': _lastName,
          'contactNumber': '$_selectedCountryCode $_contactNumber',
          'tripExperience': _tripExperience,
          'skillLevel': _skillLevel,
          'languages': _languages,
          'previousTrip': _previousTrip,
          'idProofUrl': _uploadedImageUrl ?? '',
          'status': 'Pending',
          'joinedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully joined the trip!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing request: $e")),
        );
      }

      setState(() {
        _isUploading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Reducing image quality to optimize storage
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEAE7D8),
      title: const Text("Join Trip", style: TextStyle(color: Color(0xFF2A3A26))),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? "Enter your first name" : null,
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Enter your last name" : null,
                onSaved: (value) => _lastName = value!,
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedCountryCode,
                    items: ['+1', '+44', '+966', '+971']
                        .map((code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountryCode = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Contact Number"),
                      validator: (value) => value!.isEmpty ? "Enter your contact number" : null,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _contactNumber = value!,
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _tripExperience,
                decoration: const InputDecoration(labelText: "How many trips have you joined before?"),
                items: ['Never', '1-10', 'More than 10'].map((exp) {
                  return DropdownMenuItem<String>(
                    value: exp,
                    child: Text(exp),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tripExperience = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _skillLevel,
                decoration: const InputDecoration(labelText: "Skill Level"),
                items: ['Low', 'Intermediate', 'High'].map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _skillLevel = value!;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Languages you speak (comma separated)"),
                onSaved: (value) {
                  _languages = value!.split(',').map((e) => e.trim()).toList();
                },
              ),
              DropdownButtonFormField<String>(
                value: _previousTrip,
                decoration: const InputDecoration(labelText: "Did you join me on another trip before?"),
                items: ['Yes', 'No'].map((ans) {
                  return DropdownMenuItem<String>(
                    value: ans,
                    child: Text(ans),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _previousTrip = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : const Text("No image selected"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload ID Image "),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _joinTrip,
                      child: const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A3A26),
                        foregroundColor: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
