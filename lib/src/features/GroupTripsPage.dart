import 'dart:io';
import 'package:awj/src/features/AddTripForm.dart';
import 'package:awj/src/features/GroupTripDetailsPage.dart';
import 'package:awj/src/features/JoinTripForm.dart';
import 'package:awj/src/features/ReviewTrip.dart';
import 'package:awj/src/features/UnJoinTrip.dart';
import 'package:awj/src/features/authentication/login/login.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import "join_requests_tab.dart";
import 'JoinRequests.dart';

class GroupTripsPage extends StatefulWidget {
  final String? selectedTripId;

  const GroupTripsPage({super.key, this.selectedTripId});

  @override
  _GroupTripsPageState createState() => _GroupTripsPageState();
}

class _GroupTripsPageState extends State<GroupTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedLocation;
  String? _selectedOrganizer;
  List<String> _userIds = [];
  final ScrollController _scrollController = ScrollController();
  String? _highlightedTripId;

  @override
  void initState() {
    super.initState();
    int tabCount = FirebaseAuth.instance.currentUser == null ? 1 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    _highlightedTripId = widget.selectedTripId;
    
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _scrollToHighlightedTrip() {
    if (_highlightedTripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = GlobalKey();
        final context = key.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isGuest = currentUserId == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Trips",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    height: _tabController.index == 0 ? 45 : 38,
                    width: _tabController.index == 0 ? 140 : 120,
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tabController.index == 0
                            ? Colors.white.withOpacity(0.8)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  Text(
                    "Posted Trips",
                    style: TextStyle(
                      fontSize: _tabController.index == 0 ? 20 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (currentUserId != null)
              Tab(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: _tabController.index == 1 ? 45 : 38,
                      width: _tabController.index == 1 ? 140 : 120,
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _tabController.index == 1
                              ? Colors.white.withOpacity(0.8)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    Text(
                      "My Trips",
                      style: TextStyle(
                        fontSize: _tabController.index == 1 ? 20 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFEAE7D8),
      body: TabBarView(
        controller: _tabController,
        children: [
          PostedTripsTab(
            selectedLocation: _selectedLocation,
            selectedOrganizer: _selectedOrganizer,
            highlightedTripId: _highlightedTripId,
            scrollController: _scrollController,
          ),
          if (currentUserId != null) MyTripsTab(),
        ],
      ),
      floatingActionButton: buildAddTripButton(context, isGuest),
    );
  }

  Future<void> _fetchOrganizers() async {
    try {
      final tripQuerySnapshot = await FirebaseFirestore.instance.collection('GroupTrips').get();
      final organizerIds = <String>{};

      for (var tripDoc in tripQuerySnapshot.docs) {
        final tripData = tripDoc.data();
        final organizerId = tripData['organizerId'] as String?;
        if (organizerId != null) {
          organizerIds.add(organizerId);
        }
      }

      final validOrganizers = <String>[];
      for (var organizerId in organizerIds) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(organizerId).get();
        if (userDoc.exists) {
          validOrganizers.add(organizerId);
        }
      }

      setState(() {
        _userIds = validOrganizers;
      });
    } catch (e) {
      print("Error fetching organizers: $e");
    }
  }

  void _openFilterDialog() async {
    await _fetchOrganizers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? tempLocation = _selectedLocation;
        String? tempOrganizer = _selectedOrganizer;
        String? tempTripType;
        String? tempTrail;
        String? tempAgeLimit;

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
                  offset: const Offset(0, -4),
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
                        "Filter Trips",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => tempLocation = value,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: tempOrganizer,
                        hint: const Text("Select Organizer"),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _userIds.isEmpty
                            ? [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("No organizers available"),
                                ),
                              ]
                            : _userIds
                                .map((userId) => DropdownMenuItem<String>(
                                      value: userId,
                                      child: FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Text("Loading...");
                                          } else if (snapshot.hasError) {
                                            return const Text("Error loading organizer");
                                          } else if (!snapshot.hasData || !snapshot.data!.exists) {
                                            return const Text("Organizer not found");
                                          } else {
                                            final userData = snapshot.data!;
                                            final userName = userData['name'] ?? 'Unknown';
                                            return Text(userName);
                                          }
                                        },
                                      ),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          setModalState(() => tempOrganizer = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocation = tempLocation;
                                _selectedOrganizer = tempOrganizer;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A3A26),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocation = null;
                                _selectedOrganizer = null;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
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
  
  Widget buildAddTripButton(BuildContext context, bool isGuest) {
    return FloatingActionButton(
      onPressed: () {
        if (isGuest) {
          _showGuestMessageRate();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddTripForm(),
          );
        }
      },
      backgroundColor: const Color(0xFF2A3A26),
      child: const Icon(Icons.add, color: Color(0xFFF7A22C)),
    );
  }

  void _showGuestMessageRate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to join a trip."),
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

class PostedTripsTab extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedOrganizer;
  final String? highlightedTripId;
  final ScrollController? scrollController;

  const PostedTripsTab({
    super.key, 
    this.selectedLocation, 
    this.selectedOrganizer,
    this.highlightedTripId,
    this.scrollController,
  });

  @override
  _PostedTripsTabState createState() => _PostedTripsTabState();
}

class _PostedTripsTabState extends State<PostedTripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Previous"),
          ],
          indicatorColor: Color(0xFF2A3A26),
          labelColor: Color(0xFF2A3A26),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTripList(isUpcoming: true),
              _buildTripList(isUpcoming: false),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildTripList({required bool isUpcoming}) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('GroupTrips')
        .orderBy('timestamp', descending: false)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading trips.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No trips available.'));
        }

        final now = DateTime.now();

        var trips = snapshot.data!.docs.where((trip) {
          final data = trip.data() as Map<String, dynamic>;
          final tripDate = (data['timestamp'] as Timestamp).toDate();

          bool matchesLocation = widget.selectedLocation == null ||
              data['city'].toString().toLowerCase() ==
                  widget.selectedLocation!.toLowerCase();
          bool matchesOrganizer = widget.selectedOrganizer == null ||
              data['organizerId'] == widget.selectedOrganizer;

          bool matchesDate =
              isUpcoming ? tripDate.isAfter(now) : tripDate.isBefore(now);

          return matchesLocation && matchesOrganizer && matchesDate;
        }).toList();

        if (trips.isEmpty) {
          return Center(
            child: Text(
              isUpcoming ? "No upcoming trips." : "No previous trips.",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(10.0),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return TripCard(
            trip: trip,
            isHighlighted: trip.id == widget.highlightedTripId,
          );
        },
      );
    },
  );
}
  }


class TripCard extends StatefulWidget {
  final QueryDocumentSnapshot trip;
  final bool isHighlighted;

  const TripCard({
    super.key, 
    required this.trip,
    this.isHighlighted = false,
  });

  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool hasReported = false;
  String? _userId;
  double overallAverageRating = 0.0;
  int numberOfRatings = 0;
  double userRating = 0.0;
  final TextEditingController reviewController = TextEditingController();

  bool get isGuest => FirebaseAuth.instance.currentUser == null;
  
  Null get isHighlighted => null;
  
  get trip => null; 
Future<List<String>> _fetchTrailImages(String trailName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('trails')
        .where('Name', isEqualTo: trailName)
        .get();

    if (querySnapshot.docs.isEmpty) return ['assets/images/trail-fork.jpg'];

    final trailData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    final images = trailData['images'] as List<dynamic>?;

    if (images == null || images.isEmpty) return ['assets/images/trail-fork.jpg'];

    return images.whereType<String>().toList();
  } catch (e) {
    print("Error fetching trail images: $e");
    return ['assets/images/trail-fork.jpg'];
  }
}
  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    fetchTripRatings();
    checkIfReported();
  }

  void checkIfReported() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final reportDoc = await FirebaseFirestore.instance
        .collection('GroupTrips')
        .doc(widget.trip.id)
        .collection('reports')
        .doc(userId)
        .get();

    if (reportDoc.exists) {
      setState(() {
        hasReported = true;
      });
    }
  }

  void fetchTripRatings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.trip.id)
          .collection('reviews')
          .get();

      List<double> ratings = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as double)
          .toList();

      setState(() {
        numberOfRatings = ratings.length;
        overallAverageRating = calculateAverage(ratings);
      });
    } catch (e) {
      print("Error fetching trip ratings: $e");
    }
  }

  double calculateAverage(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.fold(0.0, (previous, current) => previous + current);
    return sum / ratings.length;
  }

 @override
Widget build(BuildContext context) {
  final data = widget.trip.data() as Map<String, dynamic>;
  final tripDate = (data['timestamp'] as Timestamp).toDate();
  final trailName = data['trailName'] ?? "Unnamed Trail";

  return FutureBuilder<List<String>>(
    future: _fetchTrailImages(trailName),
    builder: (context, imageSnapshot) {
      // Handle loading state
      if (imageSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Handle error or no data state
      if (imageSnapshot.hasError || !imageSnapshot.hasData) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.error_outline)),
        );
      }

      // Get the first image or fallback to default
      final images = imageSnapshot.data!;
      final imageUrl = images.isNotEmpty ? images[0] : 'assets/images/trail-fork.jpg';

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: widget.isHighlighted
              ? const BorderSide(color: Colors.orange, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupTripDetailsPage(tripId: widget.trip.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported)),
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
  Text(
    trailName,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2A3A26),
    ),
  ),
  const SizedBox(height: 8),
  Row(
    children: [
      const Icon(Icons.location_on, size: 18, color: Color(0xFF2A3A26)),
      const SizedBox(width: 4),
      Text(data['city'] ?? 'Unknown'),
    ],
  ),
  const SizedBox(height: 6),
  Row(
    children: [
      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2A3A26)),
      const SizedBox(width: 4),
      Text(
        "${_dayOfWeek(tripDate)}, ${tripDate.day} ${_month(tripDate)} ${tripDate.year} at ${_formatTime(tripDate)}",
      ),
    ],
  ),
  const SizedBox(height: 12),
 // Rating and Actions on the right
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    // Rating Display
    Row(
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripReviewPage(tripId: widget.trip.id),
          ),
        );
      },
      child: RatingBarIndicator(
        rating: overallAverageRating,
        itemCount: 5,
        itemSize: 24,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Text(
      '($numberOfRatings)',
      style: const TextStyle(
        color: Color(0xFF2A3A26),
        fontSize: 16,
      ),
    ),
  ],
),

  if (data['organizerId'] == FirebaseAuth.instance.currentUser?.uid)
    // Edit and Delete Icons
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF2A3A26)),
          onPressed: () {
            _openEditTripForm(
              context,
              widget.trip.id,
              data,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteTrip(context);
          },
        ),
      ],
    ),
  ],
),

  Align(
    alignment: Alignment.bottomRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "See Trip Details",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward,
          color: Theme.of(context).primaryColor,
          size: 18,
        ),
      ],
    ),
  ),
],
              ),
              ),
            ],
        ),
      )
      );
    },
  );
}

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF2A3A26), size: 18),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(width: 4),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  bool _isPastTrip() {
    final data = widget.trip.data() as Map<String, dynamic>;
    DateTime tripDateTime = (data['timestamp'] as Timestamp).toDate();
    return tripDateTime.isBefore(DateTime.now());
  }

  String _dayOfWeek(DateTime date) {
    return [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][date.weekday % 7];
  }

  String _month(DateTime date) {
    return [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ][date.month - 1];
  }

  String _formatTime(DateTime date) {
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    String amPm = date.hour >= 12 ? "PM" : "AM";
    return "$hour:${date.minute.toString().padLeft(2, '0')} $amPm";
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    } else if (difference.inDays < 6) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else {
      return _formatFullDateTime(dateTime);
    }
  }

  String _formatFullDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
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
          .doc(widget.trip.id)
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

  Future<void> _openJoinTripForm(BuildContext context, String tripId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      DocumentSnapshot participantSnapshot = await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(tripId)
          .collection('participants')
          .doc(userId)
          .get();

      if (participantSnapshot.exists) {
        _showAlreadyJoinedDialog(context);
        return;
      }

      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(tripId)
          .get();
      final tripData = tripSnapshot.data() as Map<String, dynamic>;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userData = userSnapshot.data() as Map<String, dynamic>;

      String userGender = userData['gender'];
      String userDob = userData['dateOfBirth'];
      int userAge = _calculateAge(DateTime.parse(userDob));

      bool genderRestricted = (tripData['tripType'] == 'Only Men' && userGender != 'Male') ||
                              (tripData['tripType'] == 'Only Women' && userGender != 'Female');

      int requiredAge = _getAgeLimitValue(tripData['ageLimit']);
      bool ageRestricted = requiredAge > 0 && userAge < requiredAge;

      String restrictionMessage = "";
      if (genderRestricted && ageRestricted) {
        restrictionMessage = "You do not meet the age and gender restrictions.";
      } else if (genderRestricted) {
        restrictionMessage = "You do not meet the gender restriction.";
      } else if (ageRestricted) {
        restrictionMessage = "You do not meet the age requirement.";
      }

      if (restrictionMessage.isNotEmpty) {
        _showRestrictionDialog(context, restrictionMessage);
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => JoinTripForm(
          tripId: tripId,
        ),
      );
    } catch (e) {
      print("Error checking restrictions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking trip eligibility.")),
      );
    }
  }

  void _showRestrictionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEAE7D8),
        title: const Text(
          "Restriction Alert",
          style: TextStyle(color: Color(0xFF2A3A26)),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A26),
              foregroundColor: const Color(0xFFEAE7D8),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  int _getAgeLimitValue(String ageLimit) {
    switch (ageLimit) {
      case "18+":
        return 18;
      case "21+":
        return 21;
      case "25+":
        return 25;
      case "30+":
        return 30;
      case "40+":
        return 40;
      default:
        return 0;
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showAlreadyJoinedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Already Joined"),
        content: const Text("You have already joined this trip.\nWould you like to unjoin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openUnjoinTripForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Unjoin"),
          ),
        ],
      ),
    );
  }

  void _openUnjoinTripForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnjoinTripForm(
        tripId: widget.trip.id,
        userId: _userId!,
      ),
    );
  }

  void addToCalendar(
      String eventName, String organizerName, DateTime eventDate, String location) async {
    final eventStart = DateTime(
        eventDate.year, eventDate.month, eventDate.day, eventDate.hour, eventDate.minute);
    final eventEnd = eventStart.add(const Duration(hours: 2));

    final url = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/calendar/render',
      queryParameters: {
        'action': 'TEMPLATE',
        'text': eventName,
        'dates': '${_formatDateTime(eventStart)}/${_formatDateTime(eventEnd)}',
        'details': 'Organized by $organizerName',
        'location': location,
      },
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the calendar.')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';
  }

  void _showReportTripDialog(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Report Trip"),
          content: Text("Are you sure you want to report this trip?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showTripReasonSelectionDialog(context, tripId);
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Proceed to Report"),
            ),
          ],
        );
      },
    );
  }

  void _showTripReasonSelectionDialog(BuildContext context, String tripId) {
    String? selectedReason;
    TextEditingController otherReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Select a Reason for Reporting"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text("Select Reason"),
                    value: selectedReason,
                    items: [
                      DropdownMenuItem(
                        value: "Inappropriate Content",
                        child: Text("Inappropriate Content"),
                      ),
                      DropdownMenuItem(
                        value: "Fake or Spam Trip",
                        child: Text("Fake or Spam Trip"),
                      ),
                      DropdownMenuItem(
                        value: "Offensive or Unsafe Activity",
                        child: Text("Offensive or Unsafe Activity"),
                      ),
                      DropdownMenuItem(
                        value: "Other",
                        child: Text("Other"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  if (selectedReason == "Other")
                    TextField(
                      controller: otherReasonController,
                      decoration: InputDecoration(hintText: "Enter your reason"),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                String reportReason = selectedReason == "Other"
                    ? otherReasonController.text
                    : selectedReason ?? "No Reason Provided";
                _submitTripReport(context, tripId, reportReason);
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _submitTripReport(BuildContext context, String tripId, String reason) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('GroupTrips')
        .doc(tripId)
        .collection('reports')
        .doc(userId)
        .set({
      'reason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
       'adminSeen': false,
    }).then((_) {
      setState(() {
        hasReported = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Thank you for your report. We'll review this trip shortly.")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting report: $error")),
      );
    });
  }

  void _showRatingInputDialog() {
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

              String downloadUrl = await storageRef.getDownloadURL();
              setState(() {
                imageUrl = downloadUrl;
              });
            }

            return AlertDialog(
              backgroundColor: Color(0xFFEAE7D8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate this Trip",
                    style: TextStyle(
                      color: Color(0xFF2A3A26),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Trip Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                  ),
                  SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 16),
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
                  Text(
                    'Add a Photo (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: Icon(Icons.photo),
                        label: Text("Choose Photo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A3A26),
                          foregroundColor: Color(0xFFEAE7D8),
                        ),
                      ),
                      SizedBox(width: 10),
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
                    await uploadImage();
                    Navigator.of(context).pop();
                    _submitTripRating();
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

  void _submitTripRating() async {
    try {
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.trip.id)
          .collection('reviews')
          .add({
        'rating': userRating,
        'reviewText': reviewController.text,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        fetchTripRatings();
      });
    } catch (e) {
      print("Error submitting trip rating: $e");
    }
  }

  void _showGuestMessageRate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to join a trip."),
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

class _formatDate {
  _formatDate(DateTime tripDate);
}

class _fetchTrailImages {
  _fetchTrailImages(trailName);
}

class MyTripsTab extends StatefulWidget {
  const MyTripsTab({super.key});

  @override
  _MyTripsTabState createState() => _MyTripsTabState();
}

class _MyTripsTabState extends State<MyTripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _innerTabController;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _innerTabController,
          tabs: const [
            Tab(text: "Organized By Me"),
            Tab(text: "I Joined"),
          ],
          indicatorColor: Color(0xFF2A3A26),
          labelColor: Color(0xFF2A3A26),
        ),
        Expanded(
          child: TabBarView(
            controller: _innerTabController,
            children: [
              _buildJoinRequestsTab(),
              JoinedTripsTab(currentUserId: currentUserId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('GroupTrips')
          .where('organizerId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, tripsSnapshot) {
        if (tripsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!tripsSnapshot.hasData || tripsSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("You haven't organized any trips yet."));
        }

        return ListView.builder(
          itemCount: tripsSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final trip = tripsSnapshot.data!.docs[index];
            final tripData = trip.data() as Map<String, dynamic>;

            return FutureBuilder<List<String>>(
              future: _fetchTrailImages(tripData['trailName']),
              builder: (context, imageSnapshot) {
                final imageUrl = (imageSnapshot.data?.isNotEmpty ?? false)
                    ? imageSnapshot.data!.first
                    : 'assets/images/trail-fork.jpg';

                return Card(
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                        child: imageUrl.startsWith('http')
                            ? Image.network(imageUrl,
                                width: double.infinity, height: 180, fit: BoxFit.cover)
                            : Image.asset(imageUrl,
                                width: double.infinity, height: 180, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tripData['trailName'] ?? 'Unnamed',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A3A26),
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(Icons.people, "Trip Type:", tripData['tripType']),
                            _buildInfoRow(Icons.person, "Age Limit:", tripData['ageLimit']),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                   MaterialPageRoute(
  builder: (_) => JoinRequestsPage(tripId: trip.id),
),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2A3A26),
                                ),
                                child: const Text("View Join Requests"),
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
        );
      },
    );
  }

  Future<List<String>> _fetchTrailImages(String trailName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trails')
          .where('Name', isEqualTo: trailName)
          .get();

      if (querySnapshot.docs.isEmpty) return ['assets/images/trail-fork.jpg'];

      final trailData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final images = trailData['images'] as List<dynamic>?;

      if (images == null || images.isEmpty) return ['assets/images/trail-fork.jpg'];

      return images.whereType<String>().toList();
    } catch (e) {
      print("Error fetching trail images: $e");
      return ['assets/images/trail-fork.jpg'];
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label ",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JoinedTripsTab extends StatefulWidget {
  final String currentUserId;

  const JoinedTripsTab({super.key, required this.currentUserId});

  @override
  _JoinedTripsTabState createState() => _JoinedTripsTabState();
}

class _JoinedTripsTabState extends State<JoinedTripsTab> {
  String _selectedFilter = "Upcoming";

  void _openUnjoinTripForm(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnjoinTripForm(
        tripId: tripId,
        userId: widget.currentUserId,
      ),
    );
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text(
            "Filter Trips",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption("Upcoming"),
              _buildFilterOption("Past"),
              _buildFilterOption("Both"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String filterType) {
    return ListTile(
      title: Text(
        filterType,
        style: TextStyle(
          fontWeight: _selectedFilter == filterType ? FontWeight.bold : FontWeight.normal,
          color: _selectedFilter == filterType ? const Color(0xFF2A3A26) : Colors.black,
        ),
      ),
      trailing: _selectedFilter == filterType ? const Icon(Icons.check, color: Color(0xFF2A3A26)) : null,
      onTap: () {
        setState(() {
          _selectedFilter = filterType;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _openFilterDialog,
            icon: const Icon(Icons.filter_list),
            label: Text("Filter: $_selectedFilter"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A26),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('GroupTrips').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading trips."));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("You haven't joined any trips yet."));
              }

              final now = DateTime.now();
              final trips = snapshot.data!.docs.where((trip) {
                final data = trip.data() as Map<String, dynamic>;
                final tripDate = (data['timestamp'] as Timestamp).toDate();

                if (_selectedFilter == "Upcoming") {
                  return tripDate.isAfter(now);
                } else if (_selectedFilter == "Past") {
                  return tripDate.isBefore(now);
                }
                return true;
              }).toList();

              if (trips.isEmpty) {
                return Center(
                  child: Text(
                    _selectedFilter == "Upcoming"
                        ? "No upcoming trips."
                        : _selectedFilter == "Past"
                            ? "No past trips."
                            : "No trips found.",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(10.0),
                children: trips.map((trip) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: trip.reference.collection('participants').doc(widget.currentUserId).get(),
                    builder: (context, participantSnapshot) {
                      if (participantSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (!participantSnapshot.hasData || !participantSnapshot.data!.exists) {
                        return const SizedBox();
                      }

                      var participantData = participantSnapshot.data!.data() as Map<String, dynamic>;
                      String status = participantData['status'] ?? 'Pending';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(trip['organizerId']).get(),
                        builder: (context, organizerSnapshot) {
                          if (organizerSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!organizerSnapshot.hasData || !organizerSnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          var organizerData = organizerSnapshot.data!.data() as Map<String, dynamic>;
                          String organizerName = organizerData['name'] ?? 'Unknown Organizer';

                          DateTime tripDate = (trip['timestamp'] as Timestamp).toDate();
                          String formattedDate =
                              "${tripDate.year}-${tripDate.month}-${tripDate.day} at ${tripDate.hour}:${tripDate.minute.toString().padLeft(2, '0')}";

                          bool isPastTrip = tripDate.isBefore(DateTime.now());

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(trip['trailName']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location: ${trip['city']}, ${trip['region']}"),
                                  Text("Organized by: $organizerName"),
                                  Text("Date: $formattedDate"),
                                  Text(
                                    "Status: $status",
                                    style: TextStyle(
                                      color: status == "Accepted"
                                          ? Colors.green
                                          : status == "Rejected"
                                              ? Colors.red
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isPastTrip
                                  ? null
                                  : ElevatedButton(
                                      onPressed: () => _openUnjoinTripForm(context, trip.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Unjoin"),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}