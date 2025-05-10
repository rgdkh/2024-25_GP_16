import 'package:flutter/material.dart';

class MyDraawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSignOut;
  final VoidCallback onAboutUsTap;
  final VoidCallback onContactUsTap;

  const MyDraawer({
    Key? key,
    required this.onProfileTap,
    required this.onSignOut,
    required this.onAboutUsTap,
    required this.onContactUsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFECE9DD),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2A3A26),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/images/logow.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hiking Companion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF2A3A26)),
            title: const Text(
              'Profile',
              style: TextStyle(color: Color(0xFF2A3A26)),
            ),
            onTap: onProfileTap,
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF2A3A26)),
            title: const Text(
              'About Us',
              style: TextStyle(color: Color(0xFF2A3A26)),
            ),
            onTap: onAboutUsTap,
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Color(0xFF2A3A26)),
            title: const Text(
              'Contact Us',
              style: TextStyle(color: Color(0xFF2A3A26)),
            ),
            onTap: onContactUsTap,
          ),
          const Divider(color: Color(0xFF2A3A26)),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Color(0xFF2A3A26)),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Color(0xFF2A3A26)),
            ),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
