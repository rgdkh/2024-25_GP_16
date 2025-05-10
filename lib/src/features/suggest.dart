import 'dart:io';
import 'package:awj/src/features/maps/maps.dart';
import 'package:awj/src/features/point_system.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
 import 'package:firebase_auth/firebase_auth.dart'; // Make sure it's at the top

class SuggestTrailPage extends StatefulWidget {
  const SuggestTrailPage({super.key});

  @override
  _SuggestTrailPageState createState() => _SuggestTrailPageState();
}

class _SuggestTrailPageState extends State<SuggestTrailPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
final TextEditingController _difficultyController = TextEditingController();
final TextEditingController _durationController = TextEditingController();
final TextEditingController _highestElevationController = TextEditingController();
final TextEditingController _lowestElevationController = TextEditingController();
final TextEditingController _latitudeController = TextEditingController();
final TextEditingController _longitudeController = TextEditingController();
  bool agreed = false;


  // Selected region
  String? _selectedRegion;
  String? _selectedDifficulty;
  String? _selectedDistanceRange;

  final List<String> _difficultyLevels = [
    'Easy', 'Medium', 'Difficult', 'Very Difficult'
  ];

  final List<String> _distanceRanges = [
    '0-5 km', '5-10 km', '10-15 km', '15-20 km'
  ];
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
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
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
              "Can't find the trail you're looking for? Post it!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            
            const SizedBox(height: 24),
            _buildSectionHeader("Trail Details"),
            const SizedBox(height: 16),
            _buildTextField("Trail Name", controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField("City", controller: _cityController),
            const SizedBox(height: 16),
            _buildRegionDropdown(),
            const SizedBox(height: 16),
            _buildTextField("Description",
                maxLines: 2, controller: _descriptionController),
            const SizedBox(height: 32),
             
            _buildDropdown("Distance", _selectedDistanceRange, _distanceRanges, (val) => setState(() => _selectedDistanceRange = val)),
const SizedBox(height: 16),
 _buildDropdown("Difficulty", _selectedDifficulty, _difficultyLevels, (val) => setState(() => _selectedDifficulty = val)),
const SizedBox(height: 16),
_buildTextField("Duration", controller: _durationController),
const SizedBox(height: 16),
_buildTextField("Highest Elevation", controller: _highestElevationController),
const SizedBox(height: 16),
_buildTextField("Lowest Elevation", controller: _lowestElevationController),
const SizedBox(height: 32),

            _buildSectionHeader("Location"),
          
  const SizedBox(height: 16),
            _buildTextFieldWithoutRequired("Provide the location link",
                controller: _locationLinkController),
const SizedBox(height: 16),
_buildTextFieldWithoutRequired("Latitude", controller: _latitudeController),
const SizedBox(height: 16),
_buildTextFieldWithoutRequired("Longitude", controller: _longitudeController),
  const SizedBox(height: 16),
Text(
  "* Provide either coordinates (latitude and longitude) OR a location link",
   style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
  textAlign: TextAlign.center,
),
            const SizedBox(height: 32),
      
            _buildSectionHeader("Photos"),
            const SizedBox(height: 16),
            _buildPhotoUploader(),
              const SizedBox(height: 16),
            Text(
  "* At least one photo is required",
  style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
),

            const SizedBox(height: 32),
               Row(
                      children: [
                        Checkbox(
                          value: agreed,
                          onChanged: (value) {
                            setState(() {
                              agreed = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            " I agree that the trail data I am submitting is accurate and complete to the best of my knowledge.",
                            style: TextStyle(fontSize: 12), 
                          ),
                        ),
                      ],
                    ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
Widget _buildTextFieldWithoutRequired(String label, {int maxLines = 1, required TextEditingController controller}) {
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),
  );
}

  Widget _buildTextField(String label,
      {int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        label: buildRequiredLabel(label),
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
  Widget _buildDropdown(String label, String? value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          label: buildRequiredLabel(label),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      decoration: InputDecoration(
        label: buildRequiredLabel("Region"),
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

bool _isValidUrl(String url) {
  final regex = RegExp(
    r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}([\/\w \.-]*)*\/?$',
  );
  return regex.hasMatch(url);
}

Widget _buildSubmitButton() {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () async {
        final name = _nameController.text.trim();
        final city = _cityController.text.trim();
        final region = _selectedRegion;
        final description = _descriptionController.text.trim();
        final locationLink = _locationLinkController.text.trim();
          final latitude = _latitudeController.text.trim();
        final longitude = _longitudeController.text.trim();

        // Check if the location link is empty and latitude/longitude are provided
GeoPoint? locationGeoPoint;
if (latitude.isNotEmpty && longitude.isNotEmpty) {
  // Convert latitude and longitude to GeoPoint
  locationGeoPoint = GeoPoint(double.tryParse(latitude) ?? 0.0, double.tryParse(longitude) ?? 0.0);
}


        if (name.isEmpty ||
            city.isEmpty ||
            _selectedRegion == null ||
            _selectedDifficulty == null ||
            _selectedDistanceRange == null ||
            description.isEmpty ||
            _durationController.text.trim().isEmpty ||
            _highestElevationController.text.trim().isEmpty ||
            _lowestElevationController.text.trim().isEmpty || selectedImages == null || agreed == false ) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in all required fields."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
       // Validate the location link if provided
if (locationLink.isNotEmpty) {
  if (!_isValidUrl(locationLink)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please provide a valid location link.")),
    );
    return;
  }
} else if (latitude.isEmpty || longitude.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Please provide either coordinates (latitude and longitude) OR a location link")),
  );
  return;
}

        final photoUrls = await _uploadImages();
        final user = FirebaseAuth.instance.currentUser;

        String addedByName = 'Anonymous';

        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data()?['name'] != null) {
            addedByName = userDoc.data()!['name'];
          }
        }

        final data = {
          'Name': name,
          'City': city,
          'Region': region,
          'Description': description.isNotEmpty ? description : "Not available",
          'LocationLink': locationLink,
          'location': locationGeoPoint ?? null, 
          'Distance': _selectedDistanceRange ?? "Unknown",
          'Difficulty Level': _selectedDifficulty ?? "Unknown",
          'Duration': _durationController.text.isNotEmpty ? _durationController.text : "N/A",
          'Highest elevation above sea level': _highestElevationController.text.isNotEmpty ? _highestElevationController.text : "N/A",
          'Lowest elevation above sea level': _lowestElevationController.text.isNotEmpty ? _lowestElevationController.text : "N/A",
          'images': photoUrls,
          'AddedBy': user?.uid ?? 'Unknown',
          'AddedByName': addedByName,
          'timestamp': FieldValue.serverTimestamp(),
        };

        try {
            final docRef = await FirebaseFirestore.instance.collection('trails').add(data);
            final trailId = docRef.id; // Get the new trail ID
            showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Success"),
      content: const Text("Your trail suggestion has been submitted successfully."),
      actions: [
        TextButton(
          onPressed: () {
             Navigator.of(context).pop(); // Close the SuggestTrailPage
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MapPage(trailId: trailId),  // Pass the trailId to the MapPage
  ),
);
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
         
          if (user != null) {
            await updateUserPoints(user.uid, 20, 'suggested_trail'); // Awarding 20 points for suggesting a trail
          }

          _clearForm(); // Clear the form
            // Navigate to the Maps page with the specific trail ID
   

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



 Widget _buildSectionHeader(String title, {bool isRequired = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
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
    _durationController.clear();
    _highestElevationController.clear();
    _lowestElevationController.clear();
    _selectedRegion = null;
    _selectedDifficulty = null;
    _selectedDistanceRange = null;
    selectedImages.clear();
    setState(() {});
  }

}
