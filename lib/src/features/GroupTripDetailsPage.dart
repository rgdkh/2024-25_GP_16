import 'dart:io';

import 'package:awj/src/features/ReviewTrip.dart';
import 'AddTripForm.dart';
import 'JoinTripForm.dart';
import 'authentication/login/login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class GroupTripDetailsPage extends StatefulWidget {
  final String tripId;

  const GroupTripDetailsPage({super.key, required this.tripId});

  @override
  State<GroupTripDetailsPage> createState() => _GroupTripDetailsPageState();
}

class _GroupTripDetailsPageState extends State<GroupTripDetailsPage> {
  double overallAverageRating = 0.0;
  int numberOfRatings = 0;
  double userRating = 0.0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTripRatings();
  }

  Future<List<String>> _fetchTrailImages(String trailName) async {
    final trailSnapshot = await FirebaseFirestore.instance
        .collection('trails')
        .where('Name', isEqualTo: trailName)
        .get();

    if (trailSnapshot.docs.isNotEmpty) {
      final trailData = trailSnapshot.docs.first.data();
      final images = trailData['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        return List<String>.from(images);
      }
    }

    return ['https://via.placeholder.com/400x200?text=No+Image'];
  }

  void _showRatingInputDialog(BuildContext context) {
    File? selectedImage;
    String? imageUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                setState(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            }

            Future<void> uploadImage() async {
              if (selectedImage == null) return;

              final storageRef = FirebaseStorage.instance.ref().child('review_images/${DateTime.now().toString()}');
              await storageRef.putFile(selectedImage!);
              imageUrl = await storageRef.getDownloadURL();
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFEAE7D8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate this Trip",
                    style: TextStyle(
                      color: const Color(0xFF2A3A26),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripReviewPage(tripId: widget.tripId),
                        ),
                      );
                    },
                    child: Text(
                      'See $numberOfRatings detailed reviews',
                      style: TextStyle(
                        color: Color(0xFF2A3A26),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      userRating = rating;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add a Photo (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF2A3A26)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text("Choose Photo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3A26),
                          foregroundColor: const Color(0xFFEAE7D8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (selectedImage != null)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await uploadImage();
                    Navigator.of(context).pop();
                    _submitTripRating(imageUrl);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3A26),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitTripRating(String? imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.tripId)
          .collection('reviews')
          .add({
        'rating': userRating,
        'reviewText': reviewController.text,
        'userId': user.uid,
        'userEmail': user.email,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      reviewController.clear();
      fetchTripRatings();
    } catch (e) {
      print("Error submitting trip rating: $e");
    }
  }

  void _openEditTripForm(
      BuildContext context, String tripId, Map<String, dynamic> tripData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTripForm(tripId: tripId, tripData: tripData),
    );
  }

  void _deleteTrip(BuildContext context) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete Trip"),
            content: Text("Are you sure you want to delete this trip?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.tripId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Trip deleted successfully"),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to delete trip: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchTripRatings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.tripId)
          .collection('reviews')
          .get();

      List<double> ratings = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['rating'] != null) {
          ratings.add((data['rating'] as num).toDouble());
        }
      }

      setState(() {
        numberOfRatings = ratings.length;
        overallAverageRating = ratings.isEmpty ? 0.0 : 
          ratings.reduce((a, b) => a + b) / ratings.length;
      });
    } catch (e) {
      print("Error fetching trip ratings: $e");
    }
  }

  void _showGuestMessageRate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text("Login Required"),
          content: const Text("You need to login or sign up to rate this trip."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

 Future<void> _addToCalendar(DateTime tripDate, String trailName, String city) async {
  // 1) Build your ISO strings
  final start = tripDate.toUtc();
  final end = tripDate.add(const Duration(hours: 2)).toUtc();
  final startStr = start
      .toIso8601String()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .split('.')
      .first + 'Z';
  final endStr = end
      .toIso8601String()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .split('.')
      .first + 'Z';

  // 2) Build a proper Uri
  final uri = Uri(
    scheme: 'https',
    host: 'calendar.google.com',
    path: '/calendar/render',
    queryParameters: {
      'action': 'TEMPLATE',
      'text': 'Trip to $trailName',
      'dates': '$startStr/$endStr',
      'details': 'Join us for a group trip to $trailName in $city',
      'location': city,
    },
  );

  // 3) Try to launch it externally
  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    // If that fails, let the user know
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open calendar')),
    );
  }
}


  Future<String> _fetchOrganizerName(String organizerId) async {
    if (organizerId.isEmpty) return 'Unknown';
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(organizerId)
        .get();
    if (!userDoc.exists) return 'Unknown';
    final data = userDoc.data() as Map<String, dynamic>;
    return data['name'] as String? ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A3A26),
        title: const Text(
          "Group Trip Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('GroupTrips')
            .doc(widget.tripId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Trip not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final tripDate = (data['timestamp'] as Timestamp).toDate();
          final trailName = data['trailName'] ?? "Unnamed Trail";
          final city = data['city'] ?? '';
          final organizerId = data['organizerId'] ?? '';
          final now = DateTime.now();

          return FutureBuilder<List<String>>(
            future: _fetchTrailImages(trailName),
            builder: (context, imageSnapshot) {
              if (!imageSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final images = imageSnapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1) Image carousel
                   SizedBox(
  height: 250,
  width: double.infinity,
  child: PageView.builder(
    itemCount: images.length,
    itemBuilder: (context, index) {
      final imageUrl = images[index];

      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              )
            : Image.asset(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
      );
    },
  ),
),

                    const SizedBox(height: 16),

                    // 2) Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        trailName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3A26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3) Description (moved under the title)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        data['description'] as String? ?? "No description provided.",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 9),

                    // Organizer and report button
                    FutureBuilder<String>(
                      future: _fetchOrganizerName(organizerId),
                      builder: (context, snap) {
                        final organizerName = snap.data ?? 'Loading…';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Organizer Name on the left
                              Expanded(
                                child: Text(
                                  'Organized by $organizerName',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              // Edit and Delete stacked vertically above the Report button
                              if (user?.uid == organizerId)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                          tooltip: 'Edit Trip',
                                          onPressed: () => _openEditTripForm(context, widget.tripId, data),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          tooltip: 'Delete Trip',
                                          onPressed: () => _deleteTrip(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else
                                // Report button for non-organizers
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.flag, size: 20, color: Colors.redAccent),
                                      tooltip: 'Report Trip',
                                      onPressed: () {
                                        if (user == null) {
                                          _showLoginDialog(context);
                                        } else {
                                          _showReportDialog(context, widget.tripId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Rating row - moved here and consolidated
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TripReviewPage(tripId: widget.tripId),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                RatingBarIndicator(
                                  rating: overallAverageRating,
                                  itemCount: 5,
                                  itemSize: 24,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '($numberOfRatings)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2A3A26),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (tripDate.isBefore(DateTime.now()))
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('GroupTrips')
                                  .doc(widget.tripId)
                                  .collection('participants')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox();
                                }

                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return const SizedBox();
                                }

                                return ElevatedButton(
                                  onPressed: () {
                                    if (user == null) {
                                      _showGuestMessageRate(context);
                                    } else {
                                      _showRatingInputDialog(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A3A26),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text(
                                    "Rate",
                                    style: TextStyle(color: Color(0xFFEAE7D8)),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Details header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A3A26),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 3,
                            color: const Color(0xFFF7A22C),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Info rows
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: 'City',
                            value: city,
                          ),
                          _buildInfoRow(
                            icon: Icons.map,
                            label: 'Region',
                            value: data['region'] ?? '',
                          ),
                          _buildInfoRow(
                            icon: Icons.group,
                            label: 'Trip Type',
                            value: data['tripType'] ?? '',
                          ),
                          _buildInfoRow(
                            icon: Icons.cake,
                            label: 'Age Limit',
                            value: data['ageLimit'] ?? '',
                          ),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Trip Date',
                            value: _formatDate(tripDate),
                          ),
                        ],
                      ),
                    ),
                    
                    // Join and Calendar buttons
                    if (tripDate.isAfter(now) && FirebaseAuth.instance.currentUser?.uid != data['organizerId'])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid == null) {
                                    _showLoginDialog(context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => JoinTripForm(tripId: widget.tripId)),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2A3A26),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Join Trip',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _addToCalendar(tripDate, trailName, city),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2A3A26),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Add to Calendar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2A3A26)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A3A26),
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${dt.day}/${dt.month}/${dt.year} at $hour:$minute $amPm";
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("You need to log in to report a trip."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context, String tripId) async {
    String? selectedReason;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFEAE7D8),
              title: const Text("Report Trip"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Reason"),
                    items: [
                      "Inappropriate Content",
                      "Spam or Fake",
                      "Unsafe Activity",
                      "Other"
                    ]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedReason = v),
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: (selectedReason == null || isSubmitting)
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection('GroupTrips')
                                .doc(tripId)
                                .collection('reports')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .set({
                              'reason': selectedReason,
                              'reportedAt': FieldValue.serverTimestamp(),
                              'adminSeen': false,
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Trip reported. Thank you.")),
                            );
                          } catch (e) {
                            print("Error reporting trip: $e");
                            setState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to report: $e")),
                            );
                          }
                        },
                  child: const Text("Submit"),
                ),
              ],
            ); 
          },
        );
      },
    );
  }
}