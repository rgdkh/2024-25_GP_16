import 'package:awj/src/features/FavoriteTrailsBrowse.dart';
import 'package:awj/src/features/PointsHistoryPage.dart';
import 'package:awj/src/features/maps/maps.dart';

import 'authentication/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ResetPass.dart';
import 'myinfobox.dart';
import 'MyEditableInfoBox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  String? selectedIcon; // Store the selected icon

  @override
  void initState() {
    super.initState();
    loadUserIcon();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkGuestUser();
  }

  // Check if the current user is null and show a login dialog
  void _checkGuestUser() {
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginDialog();
      });
    }
  }

  // Show a dialog for guest users
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
          title: Text("Login Required"),
          content: Text("You need to login or sign up to view your profile."),
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

  // Load the selected icon from Firestore if it exists
  // Load the selected icon from Firestore if it exists, otherwise set a default icon
void loadUserIcon() async {
  if (currentUser == null) return;
  try {
    DocumentSnapshot userDoc =
        await usersCollection.doc(currentUser!.uid).get();
    setState(() {
      selectedIcon = userDoc.exists && userDoc.data() != null
          ? userDoc.get('icon') as String? ?? '60981' // Use default if 'icon' is null
          : '60981'; // Default icon for new users
      
     
    });
  } catch (e) {
    // Handle any errors gracefully
    print('Error loading user icon: $e');
    setState(() {
      selectedIcon = '60981'; // Set the default icon in case of an error
    });
  }
}


  // Function to choose an icon from predefined choices
  Future<void> chooseIcon() async {
    if (currentUser == null) {
      _showLoginDialog();
      return;
    }
    String? chosenIcon = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: Color(0xFFEAE7D8),
        title: const Text("Choose Avatar"),
        content: SizedBox(
          height: 200,
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 3, // 3 icons per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildIconOption(Icons.account_circle_outlined),
              _buildIconOption(Icons.face),
              _buildIconOption(Icons.face_3),
              _buildIconOption(Icons.forest),
              _buildIconOption(Icons.hiking),
              _buildIconOption(Icons.landscape_outlined),
            ],
          ),
        ),
      ),
    );

    if (chosenIcon != null && currentUser != null) {
      String userId = currentUser!.uid;
      await usersCollection.doc(userId).update({'icon': chosenIcon});
      setState(() {
        selectedIcon = chosenIcon;
      });
    }
  }

  // Helper widget to display an icon option
  Widget _buildIconOption(IconData iconData) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(iconData.codePoint.toString());
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: Icon(
          iconData,
          size: 40,
          color: Colors.black,
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
      ],
    );
  }
  // Edit field function for the name
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A26),
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (currentUser == null) {
      print('User not logged in.');
      return;
    }

    if (newValue.trim().isNotEmpty) {
      String userId = currentUser!.uid;

      try {
        await usersCollection.doc(userId).update({field: newValue});
        print('User data updated successfully.');
      } catch (e) {
        print('Failed to update user data: $e');
      }
    }
  }
  Widget _buildSimpleHorizontalSlideshow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth / 2) - 24;

    return SizedBox(
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: itemWidth,
                  height: 150,
                  color: const Color(0xFF2A3A26),
                  child: Center(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
  void _navigateToResetPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPass()),
    );
  }
Widget _buildFavoriteTrailsSlideshow() {
  final screenWidth = MediaQuery.of(context).size.width;
  final trailWidth = (screenWidth / 2) - 24;

  return StreamBuilder<QuerySnapshot>(
    stream: usersCollection
        .doc(currentUser?.uid)
        .collection('favorites')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No favorite trails found.'));
      }

      final favoriteTrails = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'trailId': data['trailId'] ?? '',
          'trailName': data['trailName'] ?? 'Unknown Name',
          'trailCity': data['trailCity'] ?? 'Unknown City',
        };
      }).toList();

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('trails')
            .where(FieldPath.documentId,
                whereIn: favoriteTrails.map((e) => e['trailId']).toList())
            .get(),
        builder: (context, trailsSnapshot) {
          if (trailsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (trailsSnapshot.hasError || !trailsSnapshot.hasData) {
            return const Center(child: Text('Failed to load favorite trails.'));
          }

          final trails = trailsSnapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['Name'] ?? 'Unknown Name',
              'images': List<String>.from(data['images'] ?? []),
            };
          }).toList();

          return Stack(
            children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trails.length,
                  itemBuilder: (context, index) {
                    final trail = trails[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(trailId: trail['id']),
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
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: trail['images'].isNotEmpty
                                      ? Image.asset(
                                          trail['images'][0],
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/placeholder.png',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trail['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                  },
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
        },
      );
    },
  );
}

  Future<void> editDateOfBirth() async {
    DateTime maxDate = DateTime.now().subtract(Duration(days: 365 * 15));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
    );

    if (pickedDate != null && currentUser != null) {
      String userId = currentUser!.uid;

      try {
        await usersCollection.doc(userId).update(
            {'dateOfBirth': pickedDate.toLocal().toString().split(' ')[0]});
        print('Date of Birth updated successfully.');
      } catch (e) {
        print('Failed to update Date of Birth: $e');
      }
    }
  }
  // Edit gender
  Future<void> editGender() async {
    final DocumentSnapshot userDoc =
        await usersCollection.doc(currentUser!.uid).get();
    String currentGender = userDoc.get('gender');

    String? selectedGender = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A26),
        title: const Text("Edit Gender",
            style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<String>(
                  title:
                      const Text('Male', style: TextStyle(color: Colors.white)),
                  value: 'Male',
                  groupValue: currentGender,
                  onChanged: (value) {
                    setState(() {
                      currentGender = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Female',
                      style: TextStyle(color: Colors.white)),
                  value: 'Female',
                  groupValue: currentGender,
                  onChanged: (value) {
                    setState(() {
                      currentGender = value!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(currentGender);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (selectedGender != null && currentUser != null) {
      String userId = currentUser!.uid;

      try {
        await usersCollection.doc(userId).update({'gender': selectedGender});
        print('Gender updated successfully.');
      } catch (e) {
        print('Failed to update Gender: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Please log in to view your profile'),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: usersCollection.doc(currentUser?.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No data available'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return ListView(
                  children: [
                    const SizedBox(height: 50),
                    GestureDetector(
                      onTap: chooseIcon,
                      child: Column(
                        children: [
                         CircleAvatar(
  radius: 50,
  backgroundColor: const Color(0xFF2A3A26),
  child: Icon(
    getIconData(selectedIcon, fallbackIcon: Icons.account_circle),
    size: selectedIcon != null ? 60 : 80, 
    color: Colors.white,
  ),
),

                          const SizedBox(height: 10),
                          const Text(
                            "Tap to change the Avatar",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
       GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PointsHistoryPage()),
    );
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
      children: [
        Text(
          "🎖 Level ${userData['level'] ?? 1} - ${userData['levelTitle'] ?? 'Beginner Hiker 🌱'}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
          textAlign: TextAlign.center, // Center text within the column
        ),
        SizedBox(height: 6),
        if ((userData['level'] ?? 1) < 5) ...[
          LinearProgressIndicator(
            value: (userData['points'] ?? 0) % 50 / 50,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF7A22C)),
          ),
          SizedBox(height: 4),
          Text(
            "Points: ${userData['points'] ?? 0} / 50 to next level",
            style: TextStyle(color: Color(0xFF2A3A26)),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          SizedBox(height: 4),
          Text(
            "🎉 Max level reached!",
            style: TextStyle(
              color: Color(0xFF2A3A26),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  ),
),



                    const SizedBox(height: 50),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Details',
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
                    const SizedBox(height: 10),
                    MyInfoBox(
                      icon: Icons.email,
                      text: userData['email'] ?? 'No email provided',
                      sectionName: 'Email',
                    ),
                    MyEditableInfoBox(
                      icon: Icons.person,
                      text: userData['name'] ?? 'No name provided',
                      sectionName: 'Name',
                      onPressed: () => editField('name'),
                    ),
                    MyEditableInfoBox(
                      icon: Icons.wc,
                      text: userData['gender'] ?? 'No Gender provided',
                      sectionName: 'Gender',
                      onPressed: editGender,
                    ),
                    MyEditableInfoBox(
                      icon: Icons.cake,
                      text: userData['dateOfBirth'] ??
                          'No Date of Birth provided',
                      sectionName: 'Date of Birth',
                      onPressed: editDateOfBirth, 
                    ),                  
                    const SizedBox(height: 40),
                    _buildSectionTitle('My Favorite', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteTrailsBrowse(),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        width: 80,
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFavoriteTrailsSlideshow(), 
                   
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      
                    ),
                     const SizedBox(height: 10),
                     Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        width: 80,
                        color: const Color(0xFFF7A22C),
                      ),
                    ),
                      SizedBox(height: 15),
                   Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Settings',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _navigateToResetPasswordPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A3A26),
            foregroundColor: Colors.white,
          ),
          child: const Text('Reset Password'),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    onPressed: _showDeleteConfirmationDialog,
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.delete, color: Colors.red),
        SizedBox(width: 8),
        Text('Delete Account'),
      ],
    ),
  ),
)

    ],
  ),
)

                    

                  ],
                );
              },
            ),
    );
  }
  IconData getIconData(String? iconCode, {IconData fallbackIcon = Icons.home}) {
  try {
    return IconData(
      int.parse(iconCode!),
      fontFamily: 'MaterialIcons',
    );
  } catch (e) {
    // Fallback to a default icon in case of an error
    return fallbackIcon;
  }
  
}

void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFEAE7D8),
      title: const Text('Confirm Deletion'),
      content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close the dialog
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog first
            _deleteAccount(); // Then delete account
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

 Future<void> _deleteAccount() async {
  if (currentUser == null) return;

  String userId = currentUser!.uid;

  try {
    // Delete user reviews
    QuerySnapshot reviews = await FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in reviews.docs) {
      await doc.reference.delete();
    }

    // Delete user tips
    QuerySnapshot tips = await FirebaseFirestore.instance
        .collection('tips')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in tips.docs) {
      await doc.reference.delete();
    }

    // Delete user's organized trips
    QuerySnapshot trips = await FirebaseFirestore.instance
        .collection('trips')
        .where('organizerId', isEqualTo: userId)
        .get();
    for (var doc in trips.docs) {
      await doc.reference.delete();
    }

    // Delete user document from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete();

    // Delete user from Firebase Authentication
    await currentUser!.delete();

    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/login');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted successfully')),
    );
  } catch (e) {
    print('Error deleting account: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete account. Please re-authenticate and try again.')),
    );
  }
}



}
