import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'GroupTripDetailsPage.dart';

class TripCard extends StatelessWidget {
  final QueryDocumentSnapshot trip;
  final bool isHighlighted;

  const TripCard({
    super.key, 
    required this.trip,
    this.isHighlighted = false,
  });

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date); // e.g., May 23, 2025
  }

  Future<List<String>> _fetchTrailImages(String trailName) async {
    final trailSnapshot = await FirebaseFirestore.instance
        .collection('trails')
        .where('Name', isEqualTo: trailName)
        .get();

    if (trailSnapshot.docs.isNotEmpty) {
      final trailData = trailSnapshot.docs.first.data();
      final images = trailData['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        return List<String>.from(images);
      }
    }
    return ['https://via.placeholder.com/400x200?text=No+Image'];
  }

  @override
  Widget build(BuildContext context) {
    final data = trip.data() as Map<String, dynamic>;
    final tripDate = (data['timestamp'] as Timestamp).toDate();
    final trailName = data['trailName'] ?? "Unnamed Trail";

    return FutureBuilder<List<String>>(
      future: _fetchTrailImages(trailName),
      builder: (context, imageSnapshot) {
        if (!imageSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final images = imageSnapshot.data!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlighted
                ? const BorderSide(color: Colors.orange, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupTripDetailsPage(tripId: trip.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    images[0],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trailName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3A26),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Color(0xFF2A3A26)),
                          const SizedBox(width: 4),
                          Text(data['city'] ?? 'Unknown'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2A3A26)),
                          const SizedBox(width: 4),
                          Text(_formatDate(tripDate)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "See Trip Details",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}