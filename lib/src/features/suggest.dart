import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SuggestTrailPage extends StatefulWidget {
  @override
  _SuggestTrailPageState createState() => _SuggestTrailPageState();
}

class _SuggestTrailPageState extends State<SuggestTrailPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();

  // Selected region
  String? _selectedRegion;

  // List of regions
  final List<String> _regions = [
    'Riyadh',
    'Makkah',
    'Madinah',
    'Eastern Province',
    'Asir',
    'Jizan',
    'Najran',
    'Qassim',
    'Hail',
    'Tabuk',
    'Northern Borders',
    'Al-Jouf',
    'Baha',
  ];

  // List of selected images
  final List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null && pickedImages.isNotEmpty) {
        setState(() {
          selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }
  
Future<List<String>> _uploadImages() async {
  // Create a copy of selectedImages for safe iteration
  final List<XFile> imagesToUpload = List<XFile>.from(selectedImages);
  final List<String> uploadedUrls = [];

  for (var image in imagesToUpload) {
    try {
      // Generate a unique file name for the image
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // Reference to Firebase Storage path
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('trail_photos/$fileName');
      // Upload image file
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      // Get the download URL of the uploaded image
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    } catch (e) {
      // Log the error for debugging
      print("Error uploading image: $e");
    }
  }

  // Clear the original list after all uploads are complete
  selectedImages.clear();

  return uploadedUrls;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Suggest a Trail",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Can't find the trail you're looking for? Suggest it to us!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              "Note: Your suggestion will be reviewed and once we verified it, the trail will appear for everyone.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Trail Details"),
            const SizedBox(height: 16),
            _buildTextField("Trail Name", controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField("City", controller: _cityController),
            const SizedBox(height: 16),
            _buildRegionDropdown(),
            const SizedBox(height: 16),
            _buildTextField("Description (Optional)",
                maxLines: 2, controller: _descriptionController),
            const SizedBox(height: 32),
            _buildSectionHeader("Location"),
            const SizedBox(height: 16),
            _buildTextField("Provide the location link",
                controller: _locationLinkController),
            const SizedBox(height: 32),
            _buildSectionHeader("Photos (Optional)"),
            const SizedBox(height: 16),
            _buildPhotoUploader(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      decoration: InputDecoration(
        labelText: "Region",
        labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: _regions.map((region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRegion = value;
        });
      },
    );
  }

  Widget _buildPhotoUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.cloud_upload, color: Colors.white),
          label: Text(
            "Upload Photos",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A3A26),
          ),
        ),
        const SizedBox(height: 8),
        if (selectedImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedImages.map((image) {
              return Stack(
                children: [
                  Image.file(
                    File(image.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages.remove(image);
                        });
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        else
          Center(
            child: Text(
              "No photos selected",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () async {
        final name = _nameController.text;
        final city = _cityController.text;
        final region = _selectedRegion;
        final description = _descriptionController.text;
        final locationLink = _locationLinkController.text;

        if (name.isEmpty || city.isEmpty || locationLink.isEmpty || region == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in all required fields."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Upload photos and get URLs
        final photoUrls = await _uploadImages();

        // Save trail data to Firestore
        final data = {
          'name': name,
          'city': city,
          'region': region,
          'description': description.isNotEmpty ? description : null,
          'locationLink': locationLink,
          'photoUrls': photoUrls,
          'timestamp': FieldValue.serverTimestamp(),
        };

        try {
          await FirebaseFirestore.instance.collection('suggestedtrails').add(data);

          // Show confirmation dialog
          _showConfirmationDialog();

          _clearForm();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A3A26),
      ),
      child: const Text(
        "Submit",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}
void _showConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEAE7D8),
        title: const Text(
          "Success",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
        ),
        content: const Text(
          "Your trail suggestion has been submitted successfully. Thank you for your contribution!",
          style: TextStyle(color: Color(0xFF2A3A26)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              "OK",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A3A26),
              ),
            ),
          ),
        ],
      );
    },
  );
}


  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: const TextStyle(
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 3,
            width: 80,
            color: const Color(0xFFF7A22C), // Orange line
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    _nameController.clear();
    _cityController.clear();
    _descriptionController.clear();
    _locationLinkController.clear();
    _selectedRegion = null;
    selectedImages.clear();
    setState(() {});
  }
}
