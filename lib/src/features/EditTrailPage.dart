import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditTrailPage extends StatefulWidget {
  final String trailId;
  final Map<String, dynamic> existingData;

  const EditTrailPage({super.key, required this.trailId, required this.existingData});

  @override
  _EditTrailPageState createState() => _EditTrailPageState();
}

class _EditTrailPageState extends State<EditTrailPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _durationController = TextEditingController();
  final _highestElevationController = TextEditingController();
  final _lowestElevationController = TextEditingController();
  final _latitudeController = TextEditingController(); // For Latitude
  final _longitudeController = TextEditingController(); // For Longitude

  List<XFile> selectedImages = [];
  List<String> existingImageUrls = [];

  final ImagePicker _picker = ImagePicker();

  String? _selectedRegion;
  String? _selectedDifficulty;
  String? _selectedDistanceRange;

  final List<String> _regions = [
    'Riyadh', 'Makkah', 'Madinah', 'Eastern Province', 'Asir',
    'Jizan', 'Najran', 'Qassim', 'Hail', 'Tabuk', 'Northern Borders', 'Al-Jouf', 'Baha'
  ];

  final List<String> _difficultyLevels = [
    'Easy', 'Medium', 'Difficult', 'Very Difficult'
  ];

  final List<String> _distanceRanges = [
    '0-5 km', '5-10 km', '10-15 km', '15-20 km'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final data = widget.existingData;

    _nameController.text = data['Name'] ?? '';
    _cityController.text = data['City'] ?? '';
    _descriptionController.text = data['Description'] ?? '';
    _locationLinkController.text = data['LocationLink'] ?? '';

    _selectedRegion = _regions.contains(data['Region']) ? data['Region'] : null;
    _selectedDifficulty = _difficultyLevels.contains(data['Difficulty Level']) ? data['Difficulty Level'] : null;
    _selectedDistanceRange = _distanceRanges.contains(data['Distance']) ? data['Distance'] : null;

    _durationController.text = data['Duration'] ?? '';
    _highestElevationController.text = data['Highest elevation above sea level'] ?? '';
    _lowestElevationController.text = data['Lowest elevation above sea level'] ?? '';

    // Extract location GeoPoint
    GeoPoint? locationGeoPoint = data['location'];
    if (locationGeoPoint != null) {
      _latitudeController.text = locationGeoPoint.latitude.toString();
      _longitudeController.text = locationGeoPoint.longitude.toString();
    }

    existingImageUrls = List<String>.from(data['images'] ?? []);
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedImages);
      });
    }
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> uploadedUrls = [];
    for (var image in selectedImages) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('trail_photos/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    }
    return uploadedUrls;
  }

  Future<void> _updateTrail() async {
    if (_nameController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _selectedRegion == null ||
        _selectedDifficulty == null ||
        _selectedDistanceRange == null ||
        _descriptionController.text.isEmpty ||
        (_locationLinkController.text.isEmpty && (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty)) ||
        _durationController.text.trim().isEmpty ||
        _highestElevationController.text.trim().isEmpty ||
        _lowestElevationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    GeoPoint? locationGeoPoint;

    // If latitude and longitude are provided, convert to GeoPoint
    if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty) {
      locationGeoPoint = GeoPoint(
        double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      );
    }

    try {
      List<String> newImageUrls = await _uploadNewImages();
      List<String> finalImages = [...existingImageUrls, ...newImageUrls];

      await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).update({
        'Name': _nameController.text.trim(),
        'City': _cityController.text.trim(),
        'Region': _selectedRegion!,
        'Difficulty Level': _selectedDifficulty!,
        'Distance': _selectedDistanceRange!,
        'Description': _descriptionController.text.trim(),
        'LocationLink': _locationLinkController.text.trim().isNotEmpty ? _locationLinkController.text.trim() : null,
        'Duration': _durationController.text.trim(),
        'Highest elevation above sea level': _highestElevationController.text.trim(),
        'Lowest elevation above sea level': _lowestElevationController.text.trim(),
        'location': locationGeoPoint ?? null, // Saving GeoPoint under 'location'
        'images': finalImages,
      });

      _showSuccessDialog();
    } catch (e) {
      print("Error updating trail: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update trail'), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success", style: TextStyle(color: Color(0xFF2A3A26))),
        content: const Text("Trail updated successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Go back
            },
            child: const Text("OK", style: TextStyle(color: Color(0xFF2A3A26))),
          ),
        ],
      ),
    );
  }

  Widget buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF2A3A26), fontSize: 16),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text('Edit Trail', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField('Trail Name', _nameController),
          const SizedBox(height: 16),
          _buildTextField('City', _cityController),
          const SizedBox(height: 16),
          _buildDropdown('Region', _selectedRegion, _regions, (val) => setState(() => _selectedRegion = val)),
          const SizedBox(height: 16),
          _buildTextField('Description', _descriptionController, maxLines: 2),
          const SizedBox(height: 16),
          _buildDropdown('Distance', _selectedDistanceRange, _distanceRanges, (val) => setState(() => _selectedDistanceRange = val)),
          const SizedBox(height: 16),
          _buildDropdown('Difficulty', _selectedDifficulty, _difficultyLevels, (val) => setState(() => _selectedDifficulty = val)),
          const SizedBox(height: 16),
          _buildTextField('Duration', _durationController),
          const SizedBox(height: 16),
          _buildTextField('Highest Elevation', _highestElevationController),
          const SizedBox(height: 16),
          _buildTextField('Lowest Elevation', _lowestElevationController),
          const SizedBox(height: 16),
          _buildTextField('Location Link', _locationLinkController),
          const SizedBox(height: 16),
          Row(
            children: [
            
              Expanded(child: _buildTextField('Latitude', _latitudeController)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
            
              Expanded(child: _buildTextField('Longitude', _longitudeController)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text('Pick Images'),
             style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2A3A26),
    foregroundColor: Colors.white, // <-- White text
  ),
          ),
         const SizedBox(height: 16),
Text("Existing Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: existingImageUrls.asMap().entries.map((entry) {
    int index = entry.key;
    String imageUrl = entry.value;
    return Stack(
      children: [
        Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                existingImageUrls.removeAt(index);
              });
            },
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }).toList(),
),
const SizedBox(height: 16),
Text("New Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: selectedImages.asMap().entries.map((entry) {
    int index = entry.key;
    XFile image = entry.value;
    return Stack(
      children: [
        Image.file(
          File(image.path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedImages.removeAt(index);
              });
            },
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }).toList(),
),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _updateTrail,
            child: const Text('Update Trail'),
           style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2A3A26),
    foregroundColor: Colors.white, // <-- White text
  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
