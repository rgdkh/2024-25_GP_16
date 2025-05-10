import 'package:awj/src/features/CommunityHikingTips.dart';
import 'package:awj/src/features/GroupTripDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'maps/maps.dart'; // Import MapPage
import 'BrowseTrails.dart'; // Import ExploreTrailsScreen
import 'authentication/login/login.dart';
import 'ProfilePage.dart';
import 'AboutUsPage.dart';
import 'ContactUsPage.dart';
import 'drawer.dart';
import 'Hiking101Page.dart'; // Import Hiking101Page
import 'GroupTripsPage.dart'; // Import GroupTripsPage
import 'ChatbotPage.dart'; // Import ChatbotPage
import 'guest_session.dart';
import 'topics_page.dart';

class TrailData {
  final String id;
  final String name;
  final List<String> images;

  TrailData({
    required this.id,
    required this.name,
    required this.images,
  });
}

class TripData {
  final String id;
  final String name;
  final String images;

  TripData({
    required this.id,
    required this.name,
    required this.images,
  });
}

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homepage> {
  int _selectedIndex = 0;

  // Define the list of pages for navigation
  final List<Widget> _pages = [
    HomeContent(),
    Hiking101Page(),
    CommunityHikingTips(),
    TopicsPage(),
    ChatbotPage(
      topicTitle: "General Chat",
      quickPrompts: [
        "Tell me about hiking!",
        "Best trails for beginners?",
        "How to prepare for a hike?",
        "Safety tips for hiking?",
        "Essential hiking gear?"
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> signOut() async {
    GuestSession.clear();
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void goTpProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ));
  }

  void gotoaboutpage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsPage(),
      ));
  }

  void gotocontactpage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUspage(),
      ));
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFECE9DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A3A26),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the drawer icon color to white
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                'assets/images/logow.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goTpProfilePage,
        onSighnOut: signOut,
        onAboutusTap: gotoaboutpage,
        onContacsusTap: gotocontactpage,
      ),
      body: _pages[_selectedIndex], // Display the selected page here
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF2A3A26),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFE9E6D7),
      currentIndex: _selectedIndex, // Set the selected index
      onTap: _onItemTapped, // Handle the item tap to change page
      selectedIconTheme: IconThemeData(
        size: 35,
        color: const Color(0xFFF7A22C),
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      unselectedIconTheme: const IconThemeData(
        size: 24,
        color: Color(0xFFE9E6D7),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk),
          label: 'Hiking 101',
        ),
        BottomNavigationBarItem(
          
           icon: Icon(Icons.group),
          label: 'Hiking Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          label: 'Chatbot',
        ),
      ],
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String userName = 'Guest';
  bool nameAsked = false;
  List<TrailData> trails = [];
  List<TripData> groupTrips = [];

  void _askGuestNameIfNeeded() {
    final isGuest = FirebaseAuth.instance.currentUser == null;

    if (isGuest && GuestSession.guestName == null && !nameAsked) {
      nameAsked = true;

      final TextEditingController nameController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Welcome, Guest!'),
             backgroundColor: const Color(0xFFEAE7D8),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'What\'s your name?'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    setState(() {
                      GuestSession.guestName = nameController.text.trim();
                    });
                    Navigator.of(context).pop();
                  }
                },
                 style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26)),
                 child: const Text(
        'Continue',
        style: TextStyle(color: Colors.white),
      ),
                
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrails();
      _askGuestNameIfNeeded();
      _loadGroupTrips();
    });
  }

  Future<void> _loadGroupTrips() async {
    QuerySnapshot trailsSnapshot =
        await FirebaseFirestore.instance.collection('GroupTrips').get();
        
    if (trailsSnapshot.docs.isNotEmpty) {
      setState(() {
        groupTrips = trailsSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return TripData(
            id: doc.id,
            name: data['trailName'] ?? 'Unknown Name',
            images: data['tripImageUrl'] ?? '',
          );
        }).toList();
      });
    }
  }

  Future<void> _loadTrails() async {
    QuerySnapshot trailsSnapshot =
        await FirebaseFirestore.instance.collection('trails').get();
    if (trailsSnapshot.docs.isNotEmpty) {
      setState(() {
        trails = trailsSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return TrailData(
            id: doc.id,
            name: data['Name'] ?? 'Unknown Name',
            images: data.containsKey('images')
                ? List<String>.from(data['images'])
                : [],
          );
        }).toList();
      });
    }
  }

  Widget _buildTrailImageByTrailName(String trailName) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('trails')
          .where('Name', isEqualTo: trailName)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Image.asset(
            'assets/images/trail-fork.jpg',
            fit: BoxFit.cover,
          );
        }

        final trailData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final images = trailData['images'] as List<dynamic>?;

        String? imageUrl;
        if (images != null && images.length > 1) {
          imageUrl = images[1]; // second image
        } else if (images != null && images.isNotEmpty) {
          imageUrl = images[0]; // fallback to first image
        }

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return Image.asset(
            imageUrl,
            fit: BoxFit.cover,
          );
        } else {
          return Image.asset(
            'assets/images/trail-fork.jpg',
            fit: BoxFit.cover,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return currentUser != null
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading user data.'));
              }

              if (snapshot.hasData && snapshot.data!.exists) {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                userName = userData['name'] ?? 'Guest';
              }

              return _buildContent();
            },
          )
        : _buildContent();
  }

  Widget _buildContent() {
    final isGuest = FirebaseAuth.instance.currentUser == null;
    final displayName =
        isGuest ? (GuestSession.guestName ?? 'Guest') : userName;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $displayName!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374923),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Explore Trails', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExploreTrailsScreen(
                      isGuest: FirebaseAuth.instance.currentUser == null),
                ),
              );
            }),
            const SizedBox(height: 8),
            _buildHorizontalListView(context, trails),
            const SizedBox(height: 24),
            _buildSectionTitle('Group Trips', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupTripsPage(selectedTripId: '',)),
              );
            }),
            const SizedBox(height: 8),
            _buildGroupTripsFromFirestore(context, groupTrips),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAllPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          color: const Color(0xFFF7A22C),
        ),
      ],
    );
  }

  Widget _buildHorizontalListView(
      BuildContext context, List<TrailData> trails) {
    final screenWidth = MediaQuery.of(context).size.width;
    final trailWidth = (screenWidth / 2) - 24;

    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: trails.map((trail) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(trailId: trail.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: trailWidth,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('trails')
                                    .doc(trail.id)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    return Image.asset(
                                      'assets/images/trail-fork.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  }

                                  final trailData = snapshot.data!.data() as Map<String, dynamic>;
                                  final images = trailData['images'] as List<dynamic>?;

                                  String? imageUrl;
                                  if (images != null && images.length > 1) {
                                    imageUrl = images[1];
                                  } else if (images != null && images.isNotEmpty) {
                                    imageUrl = images[0];
                                  }

                                  if (imageUrl != null && imageUrl.isNotEmpty) {
                                    return Image.asset(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Image.asset(
                                      'assets/images/trail-fork.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  trail.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black26],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
Widget _buildGroupTripsFromFirestore(
  BuildContext context, List<TripData> groupTrips) {
  final screenWidth = MediaQuery.of(context).size.width;
  final trailWidth = (screenWidth / 2) - 24;

  return Stack(
    children: [
      SizedBox(
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: groupTrips.map((trip) {
              return GestureDetector(
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupTripDetailsPage(tripId: trip.id),
    ),
  );
},

                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: trailWidth,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('trails')
                                  .where('Name', isEqualTo: trip.name)
                                  .get(),
                              builder: (context, trailSnapshot) {
                                if (trailSnapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (!trailSnapshot.hasData || trailSnapshot.data!.docs.isEmpty) {
                                  return Image.asset(
                                    'assets/images/trail-fork.jpg',
                                    fit: BoxFit.cover,
                                  );
                                }

                                final trailData = trailSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                final images = trailData['images'] as List<dynamic>?;

                                String? imageUrl;
                                if (images != null && images.length > 1) {
                                  imageUrl = images[1];
                                } else if (images != null && images.isNotEmpty) {
                                  imageUrl = images[0];
                                }

                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return Image.asset(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.asset(
                                    'assets/images/trail-fork.jpg',
                                    fit: BoxFit.cover,
                                  );
                                }
                              },
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                trip.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Container(
            width: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black26],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ],
  );
}
}