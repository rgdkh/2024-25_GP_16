import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsHistoryPage extends StatelessWidget {
  const PointsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Points History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFEAE7D8),
      body: userId == null
          ? const Center(child: Text("Please log in to view your points history."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('pointsHistory')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No points history available."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final String reason = data['action'] ?? 'Activity';
                    final int points = data['points'] ?? 0;
                    final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                    final DateTime dateTime = timestamp.toDate();

                    return ListTile(
                      leading: const Icon(Icons.star, color: Color(0xFFF7A22C)),
                      title: Text(reason, style: const TextStyle(color: Color(0xFF2A3A26))),
                      subtitle: Text(
                        "${dateTime.day}/${dateTime.month}/${dateTime.year} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        "+$points",
                        style: const TextStyle(
                          color: Color(0xFF2A3A26),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
