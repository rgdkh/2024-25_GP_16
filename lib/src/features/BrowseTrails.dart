import 'dart:io';

import 'package:awj/src/features/ReviewDetailsPage.dart';
import 'package:awj/src/features/point_system.dart';
import 'package:awj/src/features/suggest_trail_intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'maps/maps.dart';

class ExploreTrailsScreen extends StatefulWidget {
  final bool isGuest;

  const ExploreTrailsScreen({super.key, required this.isGuest});

  @override
  _ExploreTrailsScreenState createState() => _ExploreTrailsScreenState();
}

class _ExploreTrailsScreenState extends State<ExploreTrailsScreen> {
  String searchQuery = ''; // Search query state
  String selectedDifficulty = 'All'; // Selected difficulty filter
  String selectedCity = 'All'; // Selected city filter
  String selectedDistanceRange = 'All'; // Selected distance range filter
  List<String> cities = ['All']; // Default city options

  @override
  void initState() {
    super.initState();
    fetchCities(); // Fetch unique cities from Firestore
  }

  // Fetch unique cities from Firestore for the city filter
  Future<void> fetchCities() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('trails').get();
      Set<String> uniqueCities = {'All'};

      for (var doc in snapshot.docs) {
        var trailData = doc.data() as Map<String, dynamic>;
      }

      setState(() {
        cities = uniqueCities.toList();
      });
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<List<String>> fetchCitiesFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('trails').get();

      // Extract unique cities
      Set<String> citySet = {};
      for (var doc in snapshot.docs) {
        String? city = doc['City']; // Assuming each trail has a 'city' field
        if (city != null && city.isNotEmpty) {
          citySet.add(city);
        }
      }

      return citySet.toList()
        ..sort(); // Convert Set to List and sort alphabetically
    } catch (e) {
      print("Error fetching cities: $e");
      return [];
    }
  }

  // Open the filter modal
  void openFilterDialog() async {
    // Fetch unique cities from Firestore
    List<String> cities = await fetchCitiesFromFirestore();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAE7D8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Difficulty Filter
                      buildFilterOption(
                        'Difficulty',
                        selectedDifficulty,
                        [
                          'All',
                          'Easy',
                          'Medium',
                          'Difficult',
                          'Very Difficult'
                        ],
                        (value) {
                          setModalState(() => selectedDifficulty = value);
                        },
                      ),

                      // City Filter (Loaded from Firestore)
                      buildFilterOption(
                        'City',
                        selectedCity,
                        cities.isNotEmpty ? ['All', ...cities] : ['All'],
                        (value) {
                          setModalState(() => selectedCity = value);
                        },
                      ),

                      // Distance Filter
                      buildFilterOption(
                        'Length',
                        selectedDistanceRange,
                        ['All', '0-5 km', '5-10 km', '10-15 km', '15-20 km'],
                        (value) {
                          setModalState(() => selectedDistanceRange = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Apply Filters Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {}); // Apply filters
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3A26),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(color: Color(0xFFEAE7D8)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Build a single filter option as a row with a dropdown
  Widget buildFilterOption(String title, String currentValue,
      List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButton<String>(
              value: currentValue,
              onChanged: (String? newValue) {
                if (newValue != null) onChanged(newValue);
              },
              isExpanded: true, // Ensures dropdown takes up full width
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
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
        backgroundColor: const Color(0xFF2A3A26),
        elevation: 0,
        centerTitle: true, // Center the title text
        toolbarHeight: 120, // Increase AppBar height
        title: Column(
          mainAxisSize: MainAxisSize.min, // Prevents stretching
          children: [
            // "Explore Trails" Title
            Text(
              'Explore Trails',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8), // Add space between title and search bar
            // Search Bar and Filter
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3A26),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search trails by Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A3A26),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                    width: 8), // Add space between search bar and filter icon
                // Filter Icon
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: openFilterDialog,
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trails').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Filter and Search Logic
          List<DocumentSnapshot> filteredDocuments =
              snapshot.data!.docs.where((doc) {
            var trailData = doc.data() as Map<String, dynamic>;
            String trailName = trailData['Name'].toString().toLowerCase();
            String trailCity = trailData['City'].toString().toLowerCase();
            String difficulty = trailData['Difficulty Level'] ?? '';

            // Parse distance as a double
            double? distance;
            if (trailData['Distance'] is int ||
                trailData['Distance'] is double) {
              distance = (trailData['Distance'] as num).toDouble();
            } else if (trailData['Distance'] is String) {
              distance =
                  double.tryParse(trailData['Distance'].replaceAll(' km', ''));
            } else {
              distance = 0.0;
            }

            // Apply distance range filtering
            bool matchesDistanceRange;
            switch (selectedDistanceRange) {
              case '0-5 km':
                matchesDistanceRange =
                    (distance != null && distance >= 0 && distance <= 5);
                break;
              case '5-10 km':
                matchesDistanceRange =
                    (distance != null && distance > 5 && distance <= 10);
                break;
              case '10-15 km':
                matchesDistanceRange =
                    (distance != null && distance > 10 && distance <= 15);
                break;
              case '15-20 km':
                matchesDistanceRange =
                    (distance != null && distance > 15 && distance <= 20);
                break;
              default:
                matchesDistanceRange = true;
            }

            // Filter conditions
            return (trailName.contains(searchQuery) ||
                    trailCity.contains(searchQuery)) &&
                (selectedDifficulty == 'All' ||
                    selectedDifficulty == difficulty) &&
                (selectedCity == 'All' ||
                    selectedCity.toLowerCase() == trailCity) &&
                matchesDistanceRange;
          }).toList();

          if (filteredDocuments.isEmpty) {
            return const Center(
              child: Text(
                'No trails found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Display the filtered list of trails
          return ListView.builder(
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              String documentId = filteredDocuments[index].id;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TrailWidget(
                  documentId: documentId,
                  trailData:
                      filteredDocuments[index].data() as Map<String, dynamic>,
                  isGuest: widget.isGuest,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Tooltip(
        message: 'Add a Trail', // Text to display when hovering
        child: FloatingActionButton(
          backgroundColor: Color(0xFF2A3A26),
          onPressed: () {
            if (widget.isGuest) {
              _showGuestMessageadd(); // Show a message if the user is a guest
            } else {
             Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SuggestTrailIntroPage()),
);
// Navigate to SuggestTrailPage
            }
          },
          child:
              Icon(Icons.add, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }

  void _showGuestMessageadd() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to Suggest a trail."),
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
}

class TrailWidget extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> trailData;
  final bool isGuest;

  const TrailWidget(
      {super.key,
      required this.documentId,
      required this.trailData,
      required this.isGuest});

  @override
  _TrailWidgetState createState() => _TrailWidgetState();
}

class _TrailWidgetState extends State<TrailWidget> {
  List<double> difficultyRatings = [];
  List<double> conditionRatings = [];
  List<double> amenitiesRatings = [];
  List<XFile> selectedImages = [];

  ///
  late final String trailId;
  bool get isGuest => FirebaseAuth.instance.currentUser == null;

  ///
  double userDifficultyRating = 0.0;
  double userConditionRating = 0.0;
  double userAmenitiesRating = 0.0;
  double overallAverageRating = 0.0;
  int numberOfRatings = 0; // Track the number of ratings
  bool isFavorited = false;
  final TextEditingController reviewController = TextEditingController();
  String? uploadedPhotoPath;

  Future<bool> _hasUserReportedTrail(String trailId, String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('trails')
        .doc(trailId)
        .collection('reported_trails')
        .where('reportedBy', isEqualTo: userId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  void _showTrailReportReasonDialog(BuildContext context, String trailId) {
    String? selectedReason;
    TextEditingController otherController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Report Trail"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text("Select Reason"),
                    value: selectedReason,
                    items: [
                      DropdownMenuItem(
                          value: "Inappropriate Content",
                          child: Text("Inappropriate Content")),
                      DropdownMenuItem(
                          value: "Fake Information",
                          child: Text("Fake Information")),
                      DropdownMenuItem(value: "Spam", child: Text("Spam")),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],
                    onChanged: (val) => setState(() => selectedReason = val),
                  ),
                  if (selectedReason == "Other")
                    TextField(
                      controller: otherController,
                      decoration:
                          InputDecoration(hintText: "Enter your reason"),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                String reason = selectedReason == "Other"
                    ? otherController.text
                    : selectedReason ?? "No reason";
                _submitTrailReport(trailId, reason);
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _showThankYouDialog(BuildContext context) {
    print("Thank You Dialog triggered"); // Add this to debug
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text(
            "Thank You!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Our team will review this content soon.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A3A26)),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _submitTrailReport(String trailId, String reason) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('trails')
        .doc(trailId)
        .collection('reported_trails')
        .add({
      'reportedBy': user.uid,
      'reason': reason,
      'trailId': trailId,
      'timestamp': FieldValue.serverTimestamp(),
       'adminSeen': false,
    });

    await FirebaseFirestore.instance.collection('trails').doc(trailId).update({
      'reportCount': FieldValue.increment(1),
    });

    _showThankYouDialog(context); // Already implemented in your code
  }

  void _showAlreadyReportedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text(
            "Feedback Recorded",
          ),
          content: const Text(
            "You have already reported this review. Thank you for your feedback.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A3A26)),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showGuestMessageReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text("Login Required"),
          content:
              const Text("You need to login or sign up to report this trail."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A3A26)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A3A26)),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _handleTrailReport(String trailId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Check if already reported
    bool alreadyReported =
        await _hasUserReportedTrail(trailId, currentUser.uid);

    if (alreadyReported) {
      _showAlreadyReportedDialog(context);
    } else {
      _showTrailReportReasonDialog(context, trailId); // Open reason dialog
    }
  }

  void checkIfFavorited() async {
    if (widget.isGuest) return; // Skip checking if the user is a guest

    try {
      final user =
          FirebaseAuth.instance.currentUser; // Get the currently signed-in user
      if (user == null) return;

      // Access the Firestore document for the user's favorites
      final favoritesDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the user's UID as the document ID
          .collection('favorites')
          .doc(widget.documentId) // Use the trail ID as the document ID
          .get();

      // Update the favorite state based on whether the trail exists in favorites
      setState(() {
        isFavorited = favoritesDoc.exists;
      });
    } catch (e) {
      print("Error checking favorite status: $e"); // Print any errors
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInitialRatings();
    checkIfFavorited();
  }

  void toggleFavorite() async {
    if (widget.isGuest) {
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

      final favoriteDoc =
          await favoritesCollection.doc(widget.documentId).get();

      if (favoriteDoc.exists) {
        await favoritesCollection.doc(widget.documentId).delete();
        setState(() {
          isFavorited = false;
        });
      } else {
        await favoritesCollection.doc(widget.documentId).set({
          'trailId': widget.documentId, // Only store the trail ID
        });
        setState(() {
          isFavorited = true;
        });
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  bool isHovering = false;

  Widget _buildHoverableAspect({
    required String title,
    required String description,
    required double averageRating,
    required List<IconData> icons,
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
              Icon(icon, color: Color(0xFF2A3A26)),
              SizedBox(width: 4),
            ],
            SizedBox(width: 8),
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

  void fetchInitialRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('trails')
          .doc(widget.documentId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          difficultyRatings = List<double>.from(data['ratings'] ?? []);
          conditionRatings =
              List<double>.from(data['trailConditionRatings'] ?? []);
          amenitiesRatings = List<double>.from(data['amenitiesRatings'] ?? []);
          overallAverageRating = calculateOverallAverage();
          numberOfRatings =
              data['numberOfRatings'] ?? 0; // Set number of ratings
        });
      }
    } catch (e) {
      print("Error fetching initial ratings: $e");
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

  ///////////////////////
  void _submitRatings() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('trails')
          .doc(widget.documentId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<double> currentDifficultyRatings =
            List<double>.from(data['ratings'] ?? []);
        List<double> currentConditionRatings =
            List<double>.from(data['trailConditionRatings'] ?? []);
        List<double> currentAmenitiesRatings =
            List<double>.from(data['amenitiesRatings'] ?? []);
        List<String> uploadedUrls = [];

        currentDifficultyRatings.add(userDifficultyRating);
        currentConditionRatings.add(userConditionRating);
        currentAmenitiesRatings.add(userAmenitiesRating);

        int currentNumberOfRatings = data['numberOfRatings'] ?? 0;
        currentNumberOfRatings += 1;

        await FirebaseFirestore.instance
            .collection('trails')
            .doc(widget.documentId)
            .update({
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
            .doc(widget.documentId)
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

  ///
  ///
  ///

////////////////////////////
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
                          onTap: () async {
                            Navigator.of(context).pop(); // Close the dialog

                            // Navigate to ReviewDetailsPage and await the result
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewDetailsPage(
                                  trailId: widget
                                      .documentId, // Pass required parameters
                                ),
                              ),
                            );

                            if (result == true) {
                              // Trigger refresh logic
                              setState(() {
                                fetchInitialRatings(); // Replace with your actual refresh method
                              });
                            }
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
                        .doc(widget.documentId)
                        .collection('reviews')
                        .where('userId', isEqualTo: userId)
                        .get();

                    if (existingReview.docs.isNotEmpty) {
                      // If a review already exists for this user
                      _showAlreadyRatedDialog();
                      return; // Stop further processing
                    }

                    // Proceed to show the rating input dialog
                    _showRatingInputDialog();
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
//////////////

  String _getRatingDescription(double rating) {
    if (rating == 0) return '';
    if (rating >= 4.5) return 'Fabulous';
    if (rating >= 4) return 'Very Good';
    if (rating >= 3) return 'Good';
    if (rating >= 2.5) return 'Fair';
    if (rating >= 2) return 'Poor';
    return 'Very Poor';
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

//////////////////////
  void _showRatingInputDialog() {
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3A26)),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3A26)),
                        ),
                        Spacer(),
                        IconButton(
                          icon:
                              Icon(Icons.add_a_photo, color: Color(0xFF2A3A26)),
                          onPressed: () async {
                            await _pickImages(); // Trigger image selection
                            setState(
                                () {}); // Update state in dialog for selected images
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
                                          selectedImages.remove(
                                              image); // Remove specific image
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
                    Navigator.of(context).pop();
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

  void _showGuestMessageFavorite() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content:
              Text("You need to login or sign up to add trail to favorites."),
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
        _buildHoverableAspect(
          title: "Condition ",
          description:
              "Rate the overall condition of the trail (e.g., terrain, upkeep).",
          averageRating: calculateAverage(conditionRatings),
          icons: [Icons.terrain, Icons.stairs, Icons.construction],
        ),
        _buildHoverableAspect(
          title: "Facilities ",
          description:
              "Rate the quality and availability of amenities (e.g., benches, water, toilets).",
          averageRating: calculateAverage(amenitiesRatings),
          icons: [Icons.chair, Icons.water_drop, Icons.wc],
        ),
      ],
    );
  }

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
        _buildConditionOptions(
            setDialogState), // Pass dialog's setState to condition options

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
    final List<String> conditionOptions = [
      'Very Poor (Inaccessible)', // 1
      'Poor (Difficult to Navigate)', // 2
      'Fair (Needs Improvement)', // 3
      'Good (Minor Issues)', // 4
      'Excellent (Well-maintained)', // 5
    ];

    return Wrap(
      spacing: 8,
      children: conditionOptions.asMap().entries.map((entry) {
        final int index = entry.key + 1; // Ensure numerical value starts from 1

        return ChoiceChip(
          label: Text(entry.value),
          selected: userConditionRating == index.toDouble(),
          onSelected: (isSelected) {
            setDialogState(() {
              userConditionRating = isSelected ? index.toDouble() : 0.0;
              print("Selected Condition: $userConditionRating"); // Debugging
            });
          },
          selectedColor: const Color(0xFF2A3A26),
          backgroundColor: Colors.grey[300],
          labelStyle: TextStyle(
            color: userConditionRating == index.toDouble()
                ? Colors.white
                : const Color(0xFF2A3A26),
          ),
        );
      }).toList(),
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

  Widget buildUserRatingBar(
      double userRating, Function(double) onRatingUpdate) {
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
        print(
            "Images selected: ${pickedImages.map((image) => image.path).join(', ')}"); // Debug log
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
      Reference storageRef =
          FirebaseStorage.instance.ref().child('trail_reviews').child(fileName);
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MapPage(trailId: widget.documentId))),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Column(
          children: [
         Stack(
  children: [
    // ✅ Safely display image or a placeholder
   widget.trailData['images'] != null &&
        widget.trailData['images'] is List &&
        widget.trailData['images'].isNotEmpty
    ? Builder(
        builder: (context) {
          String imageUrl = widget.trailData['images'][0];

          if (imageUrl.startsWith('http')) {
            return Image.network(
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
            );
          } else {
            return Image.asset(
              imageUrl.isNotEmpty
                  ? imageUrl
                  : 'assets/images/trail-fork.jpg',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            );
          } 
        },
      )
    : Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 50,
        ),
      ),

    // Favorite and Report icons
    Positioned(
      top: 10,
      right: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite icon
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.grey,
              size: 30,
            ),
            onPressed: () {
              if (widget.isGuest) {
                _showGuestMessageFavorite();
              } else {
                toggleFavorite();
              }
            },
          ),

          // Flag icon
          IconButton(
            icon: Icon(Icons.flag, color: Colors.grey, size: 28),
            onPressed: () async {
              if (widget.isGuest) {
                _showGuestMessageReport();
              } else {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  bool alreadyReported = await _hasUserReportedTrail(
                      widget.documentId, currentUser.uid);
                  if (alreadyReported) {
                    _showAlreadyReportedDialog(context);
                  } else {
                    _showTrailReportReasonDialog(context, widget.documentId);
                  }
                }
              }
            },
          ),
        ],
      ),
    ),
  ],
),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      widget.trailData['Name'] ?? 'Unknown Trail',
      style: TextStyle(
        color: Color(0xFF2A3A26),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    SizedBox(height: 4),
    Row(
      children: [
        Icon(Icons.location_on, color: Color(0xFF2A3A26), size: 16),
        SizedBox(width: 4),
        Text(
          'City: ${widget.trailData['City'] ?? 'Unknown'}',
          style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14),
        ),
      ],
    ),
    SizedBox(height: 4),
    Row(
      children: [
        Image.asset('assets/images/distanceIcon.png', width: 16, height: 16),
        SizedBox(width: 4),
        Text(
          'Length: ${widget.trailData['Distance'] ?? 'N/A'}',
          style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14),
        ),
      ],
    ),
    SizedBox(height: 4),
    Row(
      children: [
        Icon(Icons.landscape, color: Color(0xFF2A3A26), size: 16),
        SizedBox(width: 4),
        Text(
          'Difficulty: ${widget.trailData['Difficulty Level'] ?? 'Not Set'}',
          style: TextStyle(color: Color(0xFF2A3A26), fontSize: 14),
        ),
      ],
    ),
  ],
),

                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _showAspectDialog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Rating: ',
                                    style: TextStyle(
                                        color: Color(0xFF2A3A26),
                                        fontSize: 14)),
                                RatingBarIndicator(
                                  rating: overallAverageRating,
                                  itemBuilder: (context, index) =>
                                      Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 16.0,
                                  direction: Axis.horizontal,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  overallAverageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                      color: Color(0xFF2A3A26), fontSize: 14),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '($numberOfRatings)', // Display number of ratings
                                  style: TextStyle(
                                      color: Color(0xFF2A3A26), fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // More Info Button

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 38.0),
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MapPage(trailId: widget.documentId)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'See Trail Details',
                                      style: TextStyle(
                                        color: Color(0xFF2A3A26),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF2A3A26),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
