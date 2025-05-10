import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequestsPage extends StatelessWidget {
  final String tripId;

  JoinRequestsPage({required this.tripId});

  Future<void> _updateParticipantStatus({
    required String participantId,
    required String newStatus,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(tripId)
          .collection('participants')
          .doc(participantId)
          .update({'status': newStatus});
    } catch (e) {
      print("Error updating participant status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    "Join Requests",
    style: TextStyle(
      color: Color(0xFFEAE7D8), // Text color changed to #EAE7D8
      fontWeight: FontWeight.bold, // Optional: Makes it stand out
    ),
  ),
  centerTitle: true, // Centers the text
  backgroundColor: const Color(0xFF2A3A26), // Keeps background color
  iconTheme: const IconThemeData(color: Colors.white), // Keeps icon color white
),

      backgroundColor: const Color(0xFFEAE7D8),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('GroupTrips')
            .doc(tripId)
            .collection('participants')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading participants."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No join requests yet."));
          }

          return ListView(
            padding: const EdgeInsets.all(10.0),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String participantId = doc.id;
              String firstName = data['firstName'] ?? "Unknown";
              String lastName = data['lastName'] ?? "User";
              String contactNumber = data['contactNumber'] ?? "No contact";
              String skillLevel = data['skillLevel'] ?? "Not specified";
              String tripExperience = data['tripExperience'] ?? "Unknown";
              String previousTrip = data['previousTrip'] ?? "Unknown";
              List<dynamic> languages = data['languages'] ?? [];
              String idProofUrl = data['idProofUrl'] ?? '';
              String status = data['status'] ?? "Pending";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$firstName $lastName",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      Text("📞 Contact: $contactNumber"),
                      Text("🎯 Skill Level: $skillLevel"),
                      Text("🏕 Experience: $tripExperience"),
                      Text("⏳ Previous Trip: $previousTrip"),
                      Text("🗣 Languages: ${languages.join(', ')}"),

                      const SizedBox(height: 10),
                      if (idProofUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () => _viewImage(context, idProofUrl),
                          child: Text(
                            "📄 View ID Proof",
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                      Text(
                        "📝 Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Accepted"
                              ? Colors.green
                              : status == "Rejected"
                                  ? Colors.red
                                  : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 10),
                      if (status == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _updateParticipantStatus(participantId: participantId, newStatus: "Accepted"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A3A26),
                                foregroundColor: const Color(0xFFEAE7D8),
                              ),
                              child: const Text("Accept"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _updateParticipantStatus(participantId: participantId, newStatus: "Rejected"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Reject"),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _viewImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(imageUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
