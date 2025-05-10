import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class JoinTripForm extends StatefulWidget {
  final String tripId;

  const JoinTripForm({super.key, required this.tripId});

  @override
  _JoinTripFormState createState() => _JoinTripFormState();
}

class _JoinTripFormState extends State<JoinTripForm> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _contactNumber = '';
  String _selectedCountryCode = '+966';
  String _tripExperience = 'Never';
  String _skillLevel = 'Low';
  List<String> _languages = [];
  String _previousTrip = 'No';
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _joinTrip() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isUploading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      // Upload ID image if selected
      if (_selectedImage != null) {
        final fileName =
            'trip_${widget.tripId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef =
            FirebaseStorage.instance.ref().child('trip_ids/$fileName');
        await storageRef.putFile(_selectedImage!);
        _uploadedImageUrl = await storageRef.getDownloadURL();
      }

      // Save participant data
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
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing request: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text("Join Trip"),
        backgroundColor: const Color(0xFF2A3A26),
         leading: IconButton(                          // instead, add your own
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  ), // no back arrow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // First / Last Name
                TextFormField(
                  decoration: const InputDecoration(labelText: "First Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  onSaved: (v) => _firstName = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Last Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  onSaved: (v) => _lastName = v!,
                ),
                const SizedBox(height: 12),
                // Contact Number
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCountryCode,
                      items: ['+966', '+1', '+44', '+971']
                          .map((code) =>
                              DropdownMenuItem(value: code, child: Text(code)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCountryCode = v!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Contact Number"),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => _contactNumber = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Trip Experience
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: "Trip Experience"),
                  value: _tripExperience,
                  items: ['Never', '1-10', 'More than 10']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _tripExperience = v!),
                ),
                const SizedBox(height: 12),
                // Skill Level
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Skill Level"),
                  value: _skillLevel,
                  items: ['Low', 'Intermediate', 'High']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _skillLevel = v!),
                ),
                const SizedBox(height: 12),
                // Languages
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Languages you speak"),
                  onSaved: (v) => _languages =
                      v!.split(',').map((e) => e.trim()).toList(),
                ),
                const SizedBox(height: 12),
                // Joined before?
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: "Did you join me before?"),
                  value: _previousTrip,
                  items: ['Yes', 'No']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _previousTrip = v!),
                ),
                const SizedBox(height: 20),
                // ID Image
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 150),
                Text(
                  _selectedImage == null ? 'No image selected' : '',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload ID Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3A26),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                // Submit
                _isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton(
                          onPressed: _joinTrip,
                          child: const Text("Submit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A3A26),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
