import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ParticipantProfilePage extends StatefulWidget {
  final String participantId;

  const ParticipantProfilePage({Key? key, required this.participantId}) : super(key: key);

  @override
  _ParticipantProfilePageState createState() => _ParticipantProfilePageState();
}

class _ParticipantProfilePageState extends State<ParticipantProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  IconData? participantIcon;

  @override
  void initState() {
    super.initState();
    _loadParticipantIcon();
  }

  Future<void> _loadParticipantIcon() async {
    DocumentSnapshot userDoc = await usersCollection.doc(widget.participantId).get();
    if (userDoc.exists) {
      String? iconCode = userDoc['icon'];
      if (iconCode != null && int.tryParse(iconCode) != null) {
        setState(() {
          participantIcon = IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
        });
      } else {
        setState(() {
          participantIcon = Icons.account_circle; // Default icon
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Participant Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: usersCollection.doc(widget.participantId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Participant not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'Unknown';
          String email = userData['email'] ?? 'Not available';
          String gender = userData['gender'] ?? 'Not specified';
          String dob = userData['dateOfBirth'] ?? '';
          int? age;

          try {
            if (dob.isNotEmpty) {
              age = _calculateAge(DateTime.parse(dob));
            }
          } catch (e) {
            age = null; // In case of parsing error
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF2A3A26),
                      child: participantIcon != null
                          ? Icon(participantIcon, size: 60, color: Colors.white)
                          : const Icon(Icons.account_circle, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Participant Details',
                style: TextStyle(
                  color: Color(0xFF2A3A26),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 80,
                color: const Color(0xFFF7A22C),
              ),
              const SizedBox(height: 20),
              _buildInfoBox(Icons.person, 'Name', name),
              _buildInfoBox(Icons.email, 'Email', email),
              _buildInfoBox(Icons.wc, 'Gender', gender),
              _buildInfoBox(Icons.cake, 'Age', age != null ? '$age years' : 'Not available'),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // White background for the box
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Light shadow
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2A3A26)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
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
}
