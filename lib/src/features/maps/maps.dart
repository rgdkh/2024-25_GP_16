import 'dart:io';
import 'dart:math';
import 'package:awj/src/features/EditTrailPage.dart';
import 'package:awj/src/features/ReviewDetailsPage.dart';
import 'package:awj/src/features/authentication/login/login.dart';
import 'package:awj/src/features/point_system.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'picsComment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  final String trailId;

  const MapPage({super.key, required this.trailId});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool get isGuest => FirebaseAuth.instance.currentUser == null;
  Map<String, dynamic>? _selectedTrail;
  List<String> _images = [];
  LatLng? _initialPosition;
  LatLng? _endPosition;
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  int _currentPage = 0; 
  late PageController _pageController;

  // Rating variables
  double overallAverageRating = 0.0;
  int numberOfRatings = 0;
  double userDifficultyRating = 0.0;
  double userConditionRating = 0.0;
  double userAmenitiesRating = 0.0;
  List<double> difficultyRatings = [];
  List<double> conditionRatings = [];
  List<double> amenitiesRatings = [];
bool isFavorited = false;
 List<XFile> selectedImages = [];
 String selectedCondition = '';

  final TextEditingController reviewController = TextEditingController();
  String? uploadedPhotoPath;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTrail();
    fetchInitialRatings();
     checkIfFavorited();
  }

  Future<void> _loadTrail() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _selectedTrail = data;
            _images = List<String>.from(data['images'] ?? []);

            if (data['location'] != null) {
              GeoPoint startGeoPoint = data['location'];
              _initialPosition = LatLng(startGeoPoint.latitude, startGeoPoint.longitude);
              _addMarker(_initialPosition!, 'Start of Trail', 'Tap to open in Google Maps');
            }

            if (data['End Location'] != null) {
              GeoPoint endGeoPoint = data['End Location'];
              _endPosition = LatLng(endGeoPoint.latitude, endGeoPoint.longitude);
              _addMarker(_endPosition!, 'End of Trail', 'Tap to open in Google Maps');
            }

            if (_initialPosition != null && _endPosition != null) {
              List<LatLng> polylinePoints = _generateTrailPoints(_initialPosition!, _endPosition!, 10);
              _addPolyline(polylinePoints);
            }

            if (data['locations'] != null && data['locations'] is List) {
              List locations = data['locations'];
              for (int i = 0; i < locations.length; i++) {
                if (locations[i] is GeoPoint) {
                  LatLng position = LatLng(locations[i].latitude, locations[i].longitude);
                  _addMarker(position, 'Location ${i + 1}', 'Tap to open in Google Maps');
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print("Error loading trail: $e");
    }
  }

  Future<void> fetchInitialRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          difficultyRatings = List<double>.from(data['ratings'] ?? []);
          conditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
          amenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);
          overallAverageRating = calculateOverallAverage();
          numberOfRatings = data['numberOfRatings'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching initial ratings: $e");
    }
  }
void _showGuestMessageRate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to rate a trail."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }
  void _addMarker(LatLng position, String title, String snippet) {
    _markers.add(Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
        onTap: () => _openGoogleMaps(position.latitude, position.longitude),
      ),
    ));
  }

  void _addPolyline(List<LatLng> points) {
    _polylines.add(Polyline(
      polylineId: PolylineId('trailLine'),
      points: points,
      color: Colors.red,
      width: 5,
    ));
  }

  List<LatLng> _generateTrailPoints(LatLng start, LatLng end, int numPoints) {
    List<LatLng> points = [];
    double latDiff = (end.latitude - start.latitude) / numPoints;
    double lngDiff = (end.longitude - start.longitude) / numPoints;

    for (int i = 0; i <= numPoints; i++) {
      double lat = start.latitude + latDiff * i;
      double lng = start.longitude + lngDiff * i;

      double latRandomOffset = (Random().nextDouble() - 0.5) * 0.002;
      double lngRandomOffset = (Random().nextDouble() - 0.5) * 0.002;

      lat += latRandomOffset;
      lng += lngRandomOffset;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  double calculateAverage(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.fold(0.0, (previous, current) => previous + current);
    return sum / ratings.length;
  }

  double calculateOverallAverage() {
    double avgDifficulty = calculateAverage(difficultyRatings);
    double avgCondition = calculateAverage(conditionRatings);
    double avgAmenities = calculateAverage(amenitiesRatings);
    return (avgDifficulty + avgCondition + avgAmenities) / 3;
  }
/////////////////////////////
  void _showAspectDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Rating Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A3A26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      overallAverageRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRatingDescription(overallAverageRating),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetailsPage(
                                trailId: widget.trailId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'See $numberOfRatings detailed reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2A3A26),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildAspectRatings(),
              SizedBox(height: 16),
            ],
          ),
        ),
         actions: <Widget>[
  TextButton(
  onPressed: () async {
    if (isGuest) {
      // Handle guests explicitly
      _showGuestMessageRate(); // Show the guest-specific dialog
      return; // Stop further processing
    }

    // For authenticated users
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;

      try {
        // Only query Firestore for authenticated users
        final existingReview = await FirebaseFirestore.instance
            .collection('trails')
            .doc(widget.trailId)
            .collection('reviews')
            .where('userId', isEqualTo: userId)
            .get();

        if (existingReview.docs.isNotEmpty) {
          // If a review already exists for this user
          _showAlreadyRatedDialog();
          return; // Stop further processing
        }

        // Proceed to show the rating input dialog
        _showRatingDialog();
      } catch (e) {
        // Log errors for debugging
        print("Error checking existing reviews: $e");
      }
    } else {
      // This should not happen since isGuest already handles guest users
      print("Error: No authenticated user found.");
    }
  },
  style: TextButton.styleFrom(
    backgroundColor: const Color(0xFF2A3A26),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text('Rate'),
),

  TextButton(
    onPressed: () => Navigator.of(context).pop(),
    style: TextButton.styleFrom(
      backgroundColor: const Color(0xFF2A3A26),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: const Text('Close'),
  ),
],

      );
    },
  );
}

///////////////

String _getRatingDescription(double rating) {
  if (rating == 0) return ''; 
  if (rating >= 4.5) return 'Fabulous';
  if (rating >= 4) return 'Very Good';
  if (rating >= 3) return 'Good';
  if (rating >= 2.5) return 'Fair';
  if (rating >= 2) return 'Poor';
  return 'Very Poor';
}


  Widget _buildAspectRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      _buildHoverableAspect(
  title: "Difficulty ",
  description: "Rate how challenging you found the trail.",
  averageRating: calculateAverage(difficultyRatings),
  icons: [Icons.hiking, Icons.directions_walk, Icons.trending_up], 
),

// Condition with multiple icons
_buildHoverableAspect(
  title: "Condition ",
  description: "Rate the overall condition of the trail (e.g., terrain, upkeep).",
  averageRating: calculateAverage(conditionRatings),
  icons: [Icons.terrain, Icons.stairs, Icons.construction], 
),

// Facilities with multiple icons
_buildHoverableAspect(
  title: "Facilities ",
  description: "Rate the quality and availability of amenities (e.g., benches, water, toilets).",
  averageRating: calculateAverage(amenitiesRatings),
  icons: [Icons.chair, Icons.water_drop, Icons.wc], 
),
      ],
    );
  }

   Widget _buildHoverableAspect({
  required String title,
  required String description,
  required double averageRating,
  required List<IconData> icons, // List of icons for the aspect
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
           Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A26),
            ),
          ),
          // Display multiple icons with spacing
          for (var icon in icons) ...[
            Icon(icon, color: Color(0xFF2A3A26)), // Display the icon
            SizedBox(width: 4), // Add spacing between icons
          ],
          SizedBox(width: 8), // Add spacing between icons and title
         
        ],
      ),
      SizedBox(height: 4),
      Text(
        description,
        style: TextStyle(fontSize: 12),
      ),
      buildProgressBar(title, averageRating),
    ],
  );
}

  Widget buildProgressBar(String title, double averageRating) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: averageRating / 5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
        SizedBox(width: 8),
        Text('${averageRating.toStringAsFixed(1)} / 5'),
      ],
    );
  }
  void _showAlreadyRatedDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text(
          "Feedback Recorded",
          style: TextStyle(color: Color(0xFF2A3A26)),
        ),
        content: Text(
          "You have already rated this trail. Thank you for your feedback",
          style: TextStyle(color: Color(0xFF2A3A26)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2A3A26),
            ),
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

/////////////////
 void _showRatingDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color(0xFFEAE7D8),
            title: Text(
              "Rate and Review",
              style: TextStyle(
                color: Color(0xFF2A3A26),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Inputs (Difficulty, Condition, Facilities)
                  _buildUserRatingInputs(setState),
                  SizedBox(height: 16),

                  // Add Review Section
                  Text(
                    "Add Review (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Add Photo Section
                  Row(
                    children: [
                      Text(
                        "Add Photo (Optional)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add_a_photo, color: Color(0xFF2A3A26)),
                        onPressed: () async {
                          await _pickImages(); // Trigger image selection
                          setState(() {}); // Update state in dialog for selected images
                        },
                      ),
                    ],
                  ),

                  // Display Selected Photos
                  if (selectedImages.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Photos Selected:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3A26),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
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
                                        selectedImages.remove(image); // Remove specific image
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
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Text(
                        "No photo selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),

            // Dialog Actions
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                 
                  _submitRatings(); // Submit ratings, review, and photo
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    },
  );
}

////////////

  Widget _buildUserRatingInputs(Function(void Function()) setDialogState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Difficulty Section
      Row(
        children: [
          Text(
            'Difficulty ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A26),
            ),
          ),
          Icon(Icons.hiking, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.directions_walk, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.trending_up, color: Color(0xFF2A3A26), size: 20),
          Spacer(),
        ],
      ),
      SizedBox(height: 4),
      Text(
        "Rate how challenging you found the trail.",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      buildUserRatingBar(userDifficultyRating, (rating) {
        setDialogState(() {
          userDifficultyRating = rating; // Update difficulty rating
        });
      }),
      SizedBox(height: 16),

      // Condition Section
      Row(
        children: [
          Text(
            'Condition ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A26),
            ),
          ),
          Icon(Icons.terrain, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.stairs, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.construction, color: Color(0xFF2A3A26), size: 20),
          Spacer(),
        ],
      ),
      SizedBox(height: 4),
      Text(
        "Rate the overall condition of the trail.",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      _buildConditionOptions(setDialogState), // Pass dialog's setState to condition options

      SizedBox(height: 16),

      // Facilities Section
      Row(
        children: [
          Text(
            'Facilities ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A26),
            ),
          ),
          Icon(Icons.chair, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.water_drop, color: Color(0xFF2A3A26), size: 20),
          Icon(Icons.wc, color: Color(0xFF2A3A26), size: 20),
          Spacer(),
        ],
      ),
      SizedBox(height: 4),
      Text(
        "Rate the quality and availability of amenities (e.g., benches, signs).",
        style: TextStyle(fontSize: 12, color: Color(0xFF2A3A26)),
      ),
      SizedBox(height: 8),
      buildUserRatingBar(userAmenitiesRating, (rating) {
        setDialogState(() {
          userAmenitiesRating = rating; // Update facilities rating
        });
      }),
    ],
  );
}

Widget _buildConditionOptions(Function(void Function()) setDialogState) {
  List<String> conditionOptions = [
    'Excellent (Well-maintained)', // 5
    'Good (Minor Issues)',                 // 4
    'Fair (Needs Improvement)',            // 3
    'Poor (Difficult to Navigate)',        // 2
    'Very Poor (Inaccessible)',  // 1
  ];

  return Wrap(
    spacing: 8,
    children: conditionOptions.asMap().entries.map((entry) {
      final int index = conditionOptions.length - entry.key; // Reverse index

      return ChoiceChip(
        label: Text(entry.value),
        selected: userConditionRating == index.toDouble(),
        onSelected: (isSelected) {
          setDialogState(() {
            userConditionRating = isSelected ? index.toDouble() : 0.0;
          });
        },
        selectedColor: Color(0xFF2A3A26),
        backgroundColor: Colors.grey[300],
        labelStyle: TextStyle(
          color: userConditionRating == index.toDouble()
              ? Colors.white
              : Color(0xFF2A3A26),
        ),
      );
    }).toList(),
  );
}




 Widget buildUserRatingBar(double userRating, Function(double) onRatingUpdate) {
    return RatingBar.builder(
      initialRating: userRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: onRatingUpdate,
    );
  }

//////////////

final ImagePicker _picker = ImagePicker();

List<String>? uploadedPhotoPaths; // Optional: to track local paths of images


Future<void> _pickImages() async {
  try {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        // Append the newly picked images to the existing list
        selectedImages.addAll(pickedImages);
      });
      print("Images selected: ${pickedImages.map((image) => image.path).join(', ')}"); // Debug log
    } else {
      print("No images selected."); // Debug log
    }
  } catch (e) {
    print("Error picking images: $e");
  }
}



//////////////

Future<String?> _uploadImage(XFile image) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('trail_reviews').child(fileName);
    UploadTask uploadTask = storageRef.putFile(File(image.path));
    
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}

///////
 void _submitRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<double> currentDifficultyRatings = List<double>.from(data['ratings'] ?? []);
        List<double> currentConditionRatings = List<double>.from(data['trailConditionRatings'] ?? []);
        List<double> currentAmenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);
        List<String> uploadedUrls = [];

        currentDifficultyRatings.add(userDifficultyRating);
        currentConditionRatings.add(userConditionRating);
        currentAmenitiesRatings.add(userAmenitiesRating);

        int currentNumberOfRatings = data['numberOfRatings'] ?? 0;
        currentNumberOfRatings += 1;

       await FirebaseFirestore.instance.collection('trails').doc(widget.trailId).update({
          'ratings': currentDifficultyRatings,
          'trailConditionRatings': currentConditionRatings,
          'amenitiesRatings': currentAmenitiesRatings,
          'numberOfRatings': currentNumberOfRatings,
        });
        // Upload each photo to Firebase Storage and get the URL
        for (var image in selectedImages) {
          String? photoUrl = await _uploadImage(image);
          if (photoUrl != null) {
            uploadedUrls.add(photoUrl); // Add the URL to the list
          }
        }

        // Add review data to Firestore
        await FirebaseFirestore.instance
            .collection('trails')
            .doc(widget.trailId)
            .collection('reviews')
            .add({
          'difficultyRating': userDifficultyRating,
          'conditionRating': userConditionRating,
          'amenitiesRating': userAmenitiesRating,
          'reviewText': reviewController.text,
          'photoUrls': uploadedUrls, // Save the list of uploaded URLs directly
          'createdAt': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
// ✅ Give user 10 points for submitting a review
await updateUserPoints(
  FirebaseAuth.instance.currentUser!.uid,
  10,
  'review_trail',
);

        // Clear the selected images after successful upload
        setState(() {
          selectedImages.clear();
        });

        

        setState(() {
          fetchInitialRatings();
        });
         Navigator.of(context).pop(); 
      }
    } catch (e) {
      print("Error submitting ratings: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
bool canEditTrail = _selectedTrail?['AddedBy'] == currentUser?.uid;

    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
 
appBar: AppBar(
  title: const Text(
    "Hiking Trail",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFF2A3A26),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  actions: [
    IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited ? Colors.red : Colors.white,
      ),
      onPressed: toggleFavorite,
    ),

  ],
),


      body: _selectedTrail == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   _images.isNotEmpty
    ? Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                String imageUrl = _images[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: imageUrl.startsWith('http')
      ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/trail-fork.jpg',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            );
          },
        )
      : Image.asset(
          imageUrl.isNotEmpty
              ? imageUrl
              : 'assets/images/trail-fork.jpg',
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
),


                );
              },
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => buildDot(index),
            ),
          ),
        ],
      )
    : Container(),
                    SizedBox(height: 16),
                  Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedTrail?['Name'] ?? 'Name not available',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
         
          const SizedBox(height: 4),
          if (_selectedTrail?['AddedByName'] != null)
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF2A3A26), size: 18),
                const SizedBox(width: 4),
                Text(
                  'Suggested by: ${_selectedTrail?['AddedByName']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2A3A26),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (canEditTrail)
                const SizedBox(width: 4),
  Align(
    alignment: Alignment.centerRight,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A3A26),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTrailPage(
              trailId: widget.trailId,
              existingData: _selectedTrail!,
            ),
          ),
        );
      },
      child: const Text(
        'Edit Trail',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),

              ],
            ),
        ],
      ),
    ),

    // Hikers' Photos button
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PicsComment(trailId: widget.trailId),
          ),
        );
      },
      child: Row(
        children: const [
          Icon(
            Icons.camera_alt,
            color: Color(0xFF2A3A26),
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            "Hikers' Photos",
            style: TextStyle(
              color: Color(0xFF2A3A26),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  ],
),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _selectedTrail?['Description'] ?? 'Description not available',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showAspectDialog,
                      child: Row(
                        children: [
                          Text("Rating: ", style: TextStyle(color: Color(0xFF2A3A26))),
                          RatingBarIndicator(
                            rating: overallAverageRating,
                            itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(width: 8),
                          Text('${overallAverageRating.toStringAsFixed(1)} ($numberOfRatings)', style: TextStyle(color: Color(0xFF2A3A26))),
                          SizedBox(width: 8),
                      TextButton(
  onPressed: () async {
    if (isGuest) {
      _showGuestMessageRate(); // Show a dialog if the user is a guest
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;

      try {
        // Check if the user has already rated this trail
        final existingReview = await FirebaseFirestore.instance
            .collection('trails')
            .doc(widget.trailId)
            .collection('reviews')
            .where('userId', isEqualTo: userId)
            .get();

        if (existingReview.docs.isNotEmpty) {
          _showAlreadyRatedDialog(); // Show the "Already Rated" dialog
          return;
        }

        _showRatingDialog(); // Show the rating input dialog if not already rated
      } catch (e) {
        print("Error checking existing reviews: $e");
        // Optionally show an error dialog
      }
    } else {
      print("Error: No authenticated user found.");
    }
  },
  style: TextButton.styleFrom(
    padding: EdgeInsets.all(12.0),
    backgroundColor: Color(0xFFF7A22C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: Text(
    "Rate",
    style: TextStyle(color: Colors.white),
  ),
),

                     ],
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Details',
                        style: TextStyle(
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
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Region', _selectedTrail?['Region']),
                    _buildInfoRow(Icons.location_city, 'City', _selectedTrail?['City']),
                    _buildInfoRow(Icons.terrain, 'Difficulty Level', _selectedTrail?['Difficulty Level']),
                    Row(
                      children: [
                        SizedBox(width: 6),
                        Image.asset(
                          'assets/images/distanceIcon.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text('Length ${_selectedTrail?['Distance']} ', style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14)),
                      ],
                    ),
                    _buildInfoRow(Icons.access_time, 'Duration', _selectedTrail?['Duration']),
                    _buildInfoRow(Icons.vertical_align_top, 'Highest elevation above sea level', _selectedTrail?['Highest elevation above sea level']),
                    _buildInfoRow(Icons.vertical_align_bottom, 'Lowest elevation above sea level', _selectedTrail?['Lowest elevation above sea level']),
                   const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Location',
                        style: TextStyle(
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
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                   
                    SizedBox(height: 300, child: _buildMap()),
                 
                 
                 
                  ],
                  
                ),
              ),
            ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.black : Colors.grey,
      ),
    );
  }

 Widget _buildMap() {
  if (_initialPosition != null) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialPosition!, zoom: 14.0),
      markers: _markers,
      polylines: _polylines,
    );
  } else if (_selectedTrail?['LocationLink'] != null) {
    final locationLink = _selectedTrail!['LocationLink'];
    return Center(
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse(locationLink);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch map link')),
            );
          }
        },
        child: Text(
          'Open Location on Map',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  } else {
    return Center(child: Text("Location not available"));
  }
}


  ///fav
void checkIfFavorited() async {
  if (isGuest) return; // Skip checking if the user is a guest

  try {
    final user = FirebaseAuth.instance.currentUser; // Get the currently signed-in user
    if (user == null) return;

    // Access the Firestore document for the user's favorites
    final favoritesDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Use the user's UID as the document ID
        .collection('favorites')
        .doc(widget.trailId) // Use the trail ID as the document ID
        .get();

    setState(() {
      isFavorited = favoritesDoc.exists;
    });
  } catch (e) {
    print("Error checking favorite status: $e");
  }
}
void _showGuestMessageFavorite() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
        title: Text("Login Required"),
        content: Text("You need to login or sign up to add this trail to favorites."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            child: Text('Login'),
          ),
        ],
      );
    },
  );
}

void toggleFavorite() async {
  if (isGuest) {
    _showGuestMessageFavorite();
    return;
  }

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    final favoriteDoc = await favoritesCollection.doc(widget.trailId).get();

    if (favoriteDoc.exists) {
      await favoritesCollection.doc(widget.trailId).delete();
      setState(() {
        isFavorited = false;
      });
    } else {
      await favoritesCollection.doc(widget.trailId).set({
        'trailId': widget.trailId,
      });
      setState(() {
        isFavorited = true;
      });
    }
  } catch (e) {
    print("Error toggling favorite: $e");
  }
}

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2A3A26)),
          SizedBox(width: 8),
          Text('$label: ${value ?? 'N/A'}'),
        ],
      ),
    );
  }
}