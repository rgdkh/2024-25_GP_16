import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'maps/maps.dart'; 
import 'BrowseTrails.dart'; 
import 'authentication/login/login.dart';
import 'ProfilePage.dart';
import 'AboutUsPage.dart';
import 'ContactUsPage.dart';
import 'drawer.dart';
import 'Hiking101Page.dart'; 
import 'GroupTripsPage.dart';  
import 'Chatbotpage.dart';     

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

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homepage> {
  int _selectedIndex = 0;

  
  final List<Widget> _pages = [
    HomeContent(), 
    GroupTripsPage(),
    Hiking101Page(),
    Chatbotpage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> signOut() async {
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
          color: Colors.white, 
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
      body: _pages[_selectedIndex], 
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF2A3A26),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFE9E6D7),
      currentIndex: _selectedIndex, 
      onTap: _onItemTapped, 
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
          icon: Icon(Icons.group),
          label: 'Group Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk),
          label: 'Hiking 101',
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
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool isLoading = true;
  String userName = 'Guest';
  List<TrailData> trails = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
   
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['name'] ?? 'Guest';
      }
    }

   
    QuerySnapshot trailsSnapshot =
        await FirebaseFirestore.instance.collection('trails').get();
    if (trailsSnapshot.docs.isNotEmpty) {
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
    }

    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $userName!',
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
                  _buildSectionTitle('Group Trips', () {}),
                  const SizedBox(height: 8),
                  _buildGroupTripsFromFirestore(context),
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

  Widget _buildHorizontalListView(BuildContext context, List<TrailData> trails) {
    final screenWidth = MediaQuery.of(context).size.width;
    final trailWidth = (screenWidth / 2) - 24;

    return SizedBox(
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
                          child: Image.asset(
                            trail.images.isNotEmpty
                                ? trail.images[0]
                                : 'assets/placeholder.png',
                            fit: BoxFit.cover,
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
    );
  }

  Widget _buildGroupTripsFromFirestore(BuildContext context) {
    var groupTrips = [
      {
        'title': 'New Trip - Al Makhrooq Mountain',
        'organizer': 'AhmadALM',
        'images': ['assets/images/sample_trip2.jpg']
      },
      {
        'title': 'Join Me! - Khashm al Hisan',
        'organizer': 'Mona',
        'images': ['assets/images/sample_trip1.jpg']
      }
    ];

    return _buildHorizontalListViewForGroupTrips(context, groupTrips);
  }

  Widget _buildHorizontalListViewForGroupTrips(
      BuildContext context, List<Map<String, dynamic>> groupTrips) {
    final screenWidth = MediaQuery.of(context).size.width;
    final groupTripWidth = (screenWidth / 2) - 24;

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: groupTrips.map((trip) {
            return GestureDetector(
              onTap: () {
               
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: groupTripWidth,
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
                          child: Image.asset(
                            trip['images'][0],
                            fit: BoxFit.cover,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'by ${trip['organizer']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
    );
  }
}
