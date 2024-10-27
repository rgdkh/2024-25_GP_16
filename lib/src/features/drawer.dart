import 'my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSighnOut;
  final void Function()? onAboutusTap;
  final void Function()? onContacsusTap;
  const MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onSighnOut,
      required this.onAboutusTap,
      required this.onContacsusTap});
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Color(0xFF2A3A26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                //header
                DrawerHeader(
                    child: Icon(
                  Icons.settings_suggest_sharp,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 64,
                )),

                //home
                MyListTile(
                  icon: Icons.home,
                  text: 'H O M E',
                  onTap: () => Navigator.pop(context),
                ),
                //profile
                MyListTile(
                    icon: Icons.person,
                    text: 'P R O F I L E',
                    onTap: onProfileTap),
                MyListTile(
                    icon: Icons.lightbulb,
                    text: 'A B O U T  U S',
                    onTap: onAboutusTap),
                MyListTile(
                    icon: Icons.import_contacts,
                    text: 'C O N T A C T  U S',
                    onTap: onContacsusTap),
              ],
            ),
            // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
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