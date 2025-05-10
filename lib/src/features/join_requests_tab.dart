import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JoinRequests.dart'; // Update path if needed

class JoinRequestsTab extends StatelessWidget {
  final String currentUserId;

  const JoinRequestsTab({super.key, required this.currentUserId, required QueryDocumentSnapshot<Object?> trip});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('GroupTrips')
          .where('organizerId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No trips you're organizing."));
        }

        return ListView(
          children: snapshot.data!.docs.map((trip) {
            final data = trip.data() as Map<String, dynamic>;
            return Card(
              elevation: 5,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  data['trailName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2A3A26),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text("Trip Type: ${data['tripType']}"),
                    Text("Age Limit: ${data['ageLimit']}"),
                    if (data['description'] != null)
                      Text("Description: ${data['description']}"),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JoinRequestsPage(tripId: trip.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3A26),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("View Join Requests"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
