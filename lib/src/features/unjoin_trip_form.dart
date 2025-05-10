import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnjoinTripForm extends StatelessWidget {
  final String tripId;
  final String userId;

  const UnjoinTripForm({
    super.key,
    required this.tripId,
    required this.userId,
  });

  Future<void> _unjoinTrip(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(tripId)
          .collection('participants')
          .doc(userId)
          .delete();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have unjoined the trip.')),
      );
    } catch (e) {
      print('Error unjoining trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unjoin. Try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFEAE7D8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unjoin Trip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text("Are you sure you want to unjoin this trip?"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                onPressed: () => _unjoinTrip(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Unjoin"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
