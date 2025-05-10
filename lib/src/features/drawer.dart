import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_list_tile.dart';
import 'authentication/login/login.dart';
import 'authentication/signup/signup.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSighnOut;
  final void Function()? onAboutusTap;
  final void Function()? onContacsusTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSighnOut,
    required this.onAboutusTap,
    required this.onContacsusTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    User? currentUser = FirebaseAuth.instance.currentUser;
    bool isGuest = currentUser == null;

    return Drawer(
      backgroundColor: Color(0xFF2A3A26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Header
              DrawerHeader(
                child: Icon(
                  Icons.settings_suggest_sharp,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 64,
                ),
              ),

              // Home
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              // Profile
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),

              // About Us
              MyListTile(
                icon: Icons.lightbulb,
                text: 'A B O U T  U S',
                onTap: onAboutusTap,
              ),

              // Contact Us
              MyListTile(
                icon: Icons.import_contacts,
                text: 'C O N T A C T  U S',
                onTap: onContacsusTap,
              ),
            ],
          ),

          // Show Sign Up and Login for Guests, Logout for Logged-in Users
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: isGuest
                ? Column(
                    children: [
                      // Sign Up Button
                      MyListTile(
                        icon: Icons.app_registration,
                        text: 'S I G N  U P',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()),
                          );
                        },
                      ),

                      // Login Button
                      MyListTile(
                        icon: Icons.login,
                        text: 'L O G I N',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                    ],
                  )
                : MyListTile(
                    icon: Icons.logout,
                    text: 'L O G  O U T',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color(0xFFEAE7D8),
                            title: Text("Confirm Logout"),
                            content: Text("Are you sure you want to log out?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF2A3A26),
                                ),
                              ),
                              TextButton(
                                child: Text('Logout'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  if (onSighnOut != null) {
                                    onSighnOut!(); // Trigger the sign-out function
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF2A3A26),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
