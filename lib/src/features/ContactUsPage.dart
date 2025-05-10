import 'package:flutter/material.dart';

class ContactUspage extends StatefulWidget {
  const ContactUspage({super.key});

  @override
  State<ContactUspage> createState() => _ContactUspageState();
}

class _ContactUspageState extends State<ContactUspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, 
            crossAxisAlignment:
                CrossAxisAlignment.center, 
            children: [
              // Icon Section
              Icon(
                Icons.contact_support_outlined,
                size: 100,
                color: const Color(0xFF2A3A26), 
              ),
              const SizedBox(height: 24), 

              // Text Section
              const Text(
                "You can contact us through:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3A26), 
                ),
              ),
              const SizedBox(height: 16), 

              // Email Section
              const Text(
                "Email:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3A26),
                ),
              ),
              const SizedBox(height: 8), 
              const Text(
                "AwjApp.SA@Gmail.com",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2A3A26), 
                ),
              ),
              const SizedBox(
                  height: 32), 

              // Phone Section
              const Text(
                "Phone:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3A26), 
                ),
              ),
              const SizedBox(
                  height: 8), 
              const Text(
                "+996 55 635 9737",
                style: TextStyle(
                  color: Color(0xFF2A3A26),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}