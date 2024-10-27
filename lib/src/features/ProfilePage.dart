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

  // Load the selected icon from Firestore if it exists
  void loadUserIcon() async {
    if (currentUser == null) return;
    DocumentSnapshot userDoc =
        await usersCollection.doc(currentUser!.uid).get();
    if (userDoc.exists) {
      setState(() {
        selectedIcon = userDoc.get('icon') as String?; // Get the icon field
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

  void _navigateToResetPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPass()),
    );
  }

//slideshow
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

  //edit dob
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
            {'dateOfBirth':"${pickedDate.year.toString().padLeft(4, '0')}-${(pickedDate.month).toString().padLeft(2, '0')}-${(pickedDate.day).toString().padLeft(2, '0')}"});
        print('Date of Birth updated successfully.');
      } catch (e) {
        print('Failed to update Date of Birth: $e');
      }
    }
  }
//edit gender
  Future<void> editGender() async {
    final DocumentSnapshot userDoc =
        await usersCollection.doc(currentUser!.uid).get();
    String currentGender = userDoc.get('gender');

    String? selectedGender = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3A26),
        title: const Text("Edit Gender",
            style: const TextStyle(color: Colors.white)),
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
                            child: selectedIcon != null
                                ? Icon(
                                    IconData(int.parse(selectedIcon!),
                                        fontFamily: 'MaterialIcons'),
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.account_circle,
                                    size: 80,
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
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _navigateToResetPasswordPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A3A26),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reset Password'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Favorites',
                        style: TextStyle(
                            color: Color(0xFF2A3A26),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
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
                    const SizedBox(height: 10),
                    _buildSimpleHorizontalSlideshow(),
                    const SizedBox(height: 50),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Trips',
                        style: TextStyle(
                            color: Color(0xFF2A3A26),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
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
                    const SizedBox(height: 10),
                    _buildSimpleHorizontalSlideshow(),
                  ],
                );
              },
            ),
    );
  }
}