
import 'package:awj/src/features/AddTripForm.dart';
import 'package:awj/src/features/JoinTripForm.dart';
import 'package:awj/src/features/ParticipantProfilePage.dart';
import 'package:awj/src/features/UnJoinTrip.dart';
import 'package:awj/src/features/authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupTripsPage extends StatefulWidget {
  @override
  _GroupTripsPageState createState() => _GroupTripsPageState();
}

class _GroupTripsPageState extends State<GroupTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedLocation;
  String? _selectedOrganizer;
  List<String> _userIds = [];
  @override
  void initState() {
    super.initState();
   int tabCount = FirebaseAuth.instance.currentUser == null ? 1 : 2; // Adjust tab count dynamically

_tabController = TabController(length: tabCount, vsync: this);

     _tabController.addListener(() {
      setState(() {}); // Ensure UI updates when the tab changes
    });
  }

  void _openAddTripForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(), // Replace with AddTripForm()
    );
  }

// Fetch users who organized trips
Future<void> _fetchOrganizers() async {
  try {
    // Fetch all trips and extract unique organizer IDs
    final tripQuerySnapshot = await FirebaseFirestore.instance.collection('GroupTrips').get();
    final organizerIds = <String>{};

    for (var tripDoc in tripQuerySnapshot.docs) {
      final tripData = tripDoc.data() as Map<String, dynamic>;
      final organizerId = tripData['organizerId'] as String?;
      if (organizerId != null) {
        organizerIds.add(organizerId);
      }
    }

    // Fetch user documents for the organizers
    final validOrganizers = <String>[];
    for (var organizerId in organizerIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(organizerId).get();
      if (userDoc.exists) {
        validOrganizers.add(organizerId);
      }
    }

    setState(() {
      _userIds = validOrganizers; // Store valid organizer user IDs
    });

    print("Fetched Organizer IDs: $_userIds");
  } catch (e) {
    print("Error fetching organizers: $e");
  }
}

  @override
  Widget build(BuildContext context) {
   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
            onPressed: _openFilterDialog, // Call the method here
          ),
        ],
        bottom:TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Keep text color white
          unselectedLabelColor: Colors.white, // Keep unselected text white
          indicatorColor: Colors.white, // White underline for selected tab
          indicatorWeight: 3, // Standard underline thickness
          tabs: [
            Tab(
              child: Text(
                "Posted Trips",
                style: TextStyle(
                  fontSize: _tabController.index == 0 ? 22 : 18, // Increase when selected
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
              if (currentUserId != null)
            Tab(
              child: Text(
                "My Trips",
                style: TextStyle(
                  fontSize: _tabController.index == 1 ? 22 : 18, // Increase when selected
                  fontWeight: FontWeight.bold,
                ),
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
          ),
          MyTripsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddTripForm(),
          );
        },
        backgroundColor: const Color(0xFF2A3A26),
        child: const Icon(Icons.add, color: Color(0xFFF7A22C)),
      ),
    );
  }

  void _openFilterDialog() async {
  await _fetchOrganizers(); // Fetch organizers before showing the dialog

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String? tempLocation = _selectedLocation;
      String? tempOrganizer = _selectedOrganizer;

      return AlertDialog(
        title: const Text("Filter Trips"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Location"),
              onChanged: (value) => tempLocation = value,
            ),
            DropdownButtonFormField<String>(
              value: tempOrganizer,
              hint: const Text("Select Organizer"),
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
                              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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
                tempOrganizer = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLocation = tempLocation;
                _selectedOrganizer = tempOrganizer;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Apply"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLocation = null;
                _selectedOrganizer = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Clear"),
          ),
        ],
      );
    },
  );
}
}

// Posted Trips Tab (All Available Trips)
class PostedTripsTab extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedOrganizer;

  PostedTripsTab({this.selectedLocation, this.selectedOrganizer});

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

        // Apply date-based filtering (Upcoming or Previous trips)
        var trips = snapshot.data!.docs.where((trip) {
          final data = trip.data() as Map<String, dynamic>;
          final tripDate = (data['timestamp'] as Timestamp).toDate();

          // Apply filters based on location and organizer
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

        return ListView(
          padding: const EdgeInsets.all(10.0),
          children: trips.map((trip) => TripCard(trip: trip)).toList(),
        );
      },
    );
  }
}

// Trip Card with Join Button
class TripCard extends StatefulWidget {
  final QueryDocumentSnapshot trip;

  TripCard({required this.trip});

  @override
  _TripCardState createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  String? _userId;
  
   bool get isGuest => FirebaseAuth.instance.currentUser == null; 
  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
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
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
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
  }

  // Show a dialog if the user is already joined
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
            Navigator.pop(context);  // Close the dialog
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
      return _formatFullDateTime(
          dateTime); // Show full date & time after 6 days
    }
  }

  Future<void> _openJoinTripForm(BuildContext context, String tripId) async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    // Check if the user is already a participant
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

    // Fetch trip details
    DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
        .collection('GroupTrips')
        .doc(tripId)
        .get();
    final tripData = tripSnapshot.data() as Map<String, dynamic>;

    String tripType = tripData['tripType'];
    String ageLimit = tripData['ageLimit'];

    // Fetch user details
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userData = userSnapshot.data() as Map<String, dynamic>;

    String userGender = userData['gender'];
    String userDob = userData['dateOfBirth'];
    int userAge = _calculateAge(DateTime.parse(userDob));

    // Check if restrictions apply
    bool genderRestricted = (tripType == 'Only Men' && userGender != 'Male') ||
                            (tripType == 'Only Women' && userGender != 'Female');

    int requiredAge = _getAgeLimitValue(ageLimit);
    bool ageRestricted = requiredAge > 0 && userAge < requiredAge;

    // Determine the restriction message
    String restrictionMessage = "";
    if (genderRestricted && ageRestricted) {
      restrictionMessage = "You do not meet the age and gender restrictions.";
    } else if (genderRestricted) {
      restrictionMessage = "You do not meet the gender restriction.";
    } else if (ageRestricted) {
      restrictionMessage = "You do not meet the age requirement.";
    }

    // If restrictions exist, show the dialog and return
    if (restrictionMessage.isNotEmpty) {
      _showRestrictionDialog(context, restrictionMessage);
      return;
    }

    // If no restrictions, show the join form
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
      backgroundColor: const Color(0xFFEAE7D8), // Set background color
      title: const Text(
        "Restriction Alert",
        style: TextStyle(color: Color(0xFF2A3A26)), // Title text color
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.black), // Ensure content is readable
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF2A3A26), // Button color
            foregroundColor: const Color(0xFFEAE7D8), // Text color
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
        return 0; // No Limit
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


bool _isPastTrip() {
  final data = widget.trip.data() as Map<String, dynamic>;
  DateTime tripDateTime = (data['timestamp'] as Timestamp).toDate();
  return tripDateTime.isBefore(DateTime.now());
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

  String _formatFullDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

 void addToCalendar(
    String eventName, String organizerName, DateTime eventDate, String location) async {
  final eventStart = DateTime(
      eventDate.year, eventDate.month, eventDate.day, eventDate.hour, eventDate.minute);
  final eventEnd = eventStart.add(const Duration(hours: 2)); // Event duration

  // Properly encode the parameters
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

  // Use the url_launcher package to open the URL
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch the calendar.')),
    );
  }
}

// Helper method to format DateTime for Google Calendar (ISO 8601 without separators)
String _formatDateTime(DateTime dateTime) {
  return dateTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
}

  @override
  Widget build(BuildContext context) {
    final data = widget.trip.data() as Map<String, dynamic>;
     final String tripImageUrl = data['tripImageUrl'] ?? '';
    DateTime tripDateTime = (data['timestamp'] as Timestamp).toDate();
    String formattedDate =
        "${_dayOfWeek(tripDateTime)} - ${_month(tripDateTime)} ${tripDateTime.day}, ${tripDateTime.year}";
    String formattedTime = "${_formatTime(tripDateTime)}";
    // Get the "lastUpdated" timestamp or default to "timestamp"
    String lastUpdatedText;
    if (data['lastUpdated'] != null) {
      lastUpdatedText =
          _formatLastUpdated((data['lastUpdated'] as Timestamp).toDate());
    } else {
      lastUpdatedText = "Undefined";
    }

     final String? currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    final bool isOrganizer = currentUserId == data['organizerId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(data['organizerId'])
          .get(),
      builder: (context, snapshot) {
        String organizerName = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!['name']
            : "Unknown Organizer";

        return Card(
  color: Colors.white,
  elevation: 5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Trip Image Section
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: data['tripImageUrl'] != null && data['tripImageUrl'].isNotEmpty
            ? Image.network(
                data['tripImageUrl'],
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )
            : Container(
               
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Organizer Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['trailName'],
                    style: const TextStyle(
                        color: Color(0xFF2A3A26),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text("by $organizerName",
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic)),
              ],
            ),

            const SizedBox(height: 5),

            // City & Region + Edit/Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${data['city']}, ${data['region']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                if (isOrganizer)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openEditTripForm(
                            context, widget.trip.id, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTrip(context),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 5),

            _buildInfoRow(Icons.calendar_today, "Trip Date:", formattedDate),
            _buildInfoRow(Icons.av_timer_rounded, "Trip Time:", formattedTime),
            _buildInfoRow(Icons.people, "Trip Type:", data['tripType']),
            _buildInfoRow(Icons.person, "Age Limit:", "${data['ageLimit']}"),

            if (data['description'] != null && data['description'].isNotEmpty)
              _buildInfoRow(
                  Icons.description, "Description:", data['description']),

            const SizedBox(height: 10),

            // Join Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isOrganizer && !_isPastTrip())
                  ElevatedButton(
                    onPressed: () {
                      if (isGuest) {
                        _showGuestMessageRate();
                      } else {
                        _openJoinTripForm(context, widget.trip.id);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A3A26),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      "Join",
                      style: TextStyle(color: Color(0xFFEAE7D8)),
                    ),
                  ),
              ],
            ),

            // Add to Calendar Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  addToCalendar(data['trailName'], organizerName, tripDateTime,
                      "${data['city']}, ${data['region']}");
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2A3A26),
                ),
              ),
            ),

            // Last Updated Section
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Last Updated: $lastUpdatedText",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF2A3A26)),
            ),
          ],
        );
      },
    );
  }  
}

// Organizer's Trip Card to Manage Participants

class MyTripsTab extends StatefulWidget {
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
            Tab(text: "Join Requests"),
            Tab(text: "Joined Trips"),
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('GroupTrips')
          .where('organizerId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No trips you're organizing"));
        }

        return ListView(
          children: snapshot.data!.docs.map((trip) {
            return JoinRequestsTab(trip: trip);
          }).toList(),
        );
      },
    );
  }
}

class JoinRequestsTab extends StatelessWidget {
  final QueryDocumentSnapshot trip;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  JoinRequestsTab({required this.trip});

  Future<void> _updateParticipantStatus({
    required String tripId,
    required String participantId,
    required String newStatus,
  }) async {
    try {
      // Update participant status in Firestore
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(tripId)
          .collection('participants')
          .doc(participantId)
          .update({'status': newStatus});

      print("Participant status updated successfully.");
    } catch (e) {
      print("Error updating participant status: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  final data = trip.data() as Map<String, dynamic>;
  final String tripImageUrl = data['tripImageUrl'] ?? '';
  DateTime tripDateTime = (data['timestamp'] as Timestamp).toDate();
  

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "guest";
  final bool isOrganizer = currentUserId == data['organizerId'];

  return Card(
    elevation: 5,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Image Section
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: tripImageUrl.isNotEmpty
              ? Image.network(
                  tripImageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                )
              : Container(),
        ),

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Title and Update/Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data['trailName'],
                      style: const TextStyle(
                          color: Color(0xFF2A3A26),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  if (isOrganizer)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openEditTripForm(context, trip.id, data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTrip(context),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 5),

              _buildInfoRow(Icons.people, "Trip Type:", data['tripType']),
              _buildInfoRow(Icons.person, "Age Limit:", "${data['ageLimit']}"),
              if (data['description'] != null && data['description'].isNotEmpty)
                _buildInfoRow(Icons.description, "Description:", data['description']),

              const SizedBox(height: 10),

              // Embedded Join Requests Section
              const Text(
                "Join Requests :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('GroupTrips')
                    .doc(trip.id)
                    .collection('participants')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print("Error loading participants: ${snapshot.error}");
                    return const Center(child: Text("Error loading participants."));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("No join requests yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  final participants = snapshot.data!.docs;

                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: participants.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      String participantId = doc.id;
                      String firstName = data['firstName'] ?? "Unknown";
                      String lastName = data['lastName'] ?? "User";
                      String contactNumber = data['contactNumber'] ?? "No contact";
                      String status = data['status'] ?? "Pending";
                      String idProofUrl = data['idProofUrl'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$firstName $lastName",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Contact: $contactNumber"),
                              if (idProofUrl.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _viewImage(context, idProofUrl),
                                  child: Text(
                                    "View ID Proof",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              Text(
                                "Status: $status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: status == "Accepted"
                                      ? Colors.green
                                      : status == "Rejected"
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
                              if (status == 'Pending')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _updateParticipantStatus(
                                        tripId: trip.id,
                                        participantId: participantId,
                                        newStatus: "Accepted",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2A3A26),
                                        foregroundColor: const Color(0xFFEAE7D8),
                                      ),
                                      child: const Text("Accept"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _updateParticipantStatus(
                                        tripId: trip.id,
                                        participantId: participantId,
                                        newStatus: "Rejected",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Reject"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper method for displaying row information with an icon and label
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


// Placeholder for delete functionality
void _deleteTrip(BuildContext context) {
  // Show a confirmation dialog before deleting the trip
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete this trip?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('GroupTrips')
                .doc(trip.id)
                .delete()
                .then((_) {
              Navigator.pop(context);
              print("Trip deleted successfully.");
            }).catchError((error) {
              print("Error deleting trip: $error");
            });
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
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



// Function to view uploaded ID proof image
  void _viewImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(imageUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class JoinedTripsTab extends StatelessWidget {
  final String currentUserId;

  JoinedTripsTab({required this.currentUserId});

  void _openUnjoinTripForm(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnjoinTripForm(
        tripId: tripId,
        userId: currentUserId, // Pass the user's ID here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        final joinedTrips = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(10.0),
          children: joinedTrips.map((trip) {
            return FutureBuilder<DocumentSnapshot>(
              future: trip.reference
                  .collection('participants')
                  .doc(currentUserId)
                  .get(),
              builder: (context, participantSnapshot) {
                if (participantSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!participantSnapshot.hasData ||
                    !participantSnapshot.data!.exists) {
                  return const SizedBox();
                }

                var participantData =
                    participantSnapshot.data!.data() as Map<String, dynamic>;
                String status = participantData['status'] ?? 'Pending';

                // Fetch the organizer's name
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(trip['organizerId'])
                      .get(),
                  builder: (context, organizerSnapshot) {
                    if (organizerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!organizerSnapshot.hasData ||
                        !organizerSnapshot.data!.exists) {
                      return const SizedBox();
                    }

                    var organizerData =
                        organizerSnapshot.data!.data() as Map<String, dynamic>;
                    String organizerName =
                        organizerData['name'] ?? 'Unknown Organizer';

                    // Convert Firestore timestamp to DateTime and format manually
                    DateTime tripDate =
                        (trip['timestamp'] as Timestamp).toDate();
                    String formattedDate =
                        "${tripDate.year}-${tripDate.month}-${tripDate.day} at ${tripDate.hour}:${tripDate.minute}";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(trip['trailName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Location: ${trip['city']}, ${trip['region']}"),
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
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _openUnjoinTripForm(context, trip.id),
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
    );
  }
}
