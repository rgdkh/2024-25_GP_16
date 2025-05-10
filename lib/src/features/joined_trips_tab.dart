import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unjoin_trip_form.dart'; // Update import path if necessary

class JoinedTripsTab extends StatefulWidget {
  final String currentUserId;

  const JoinedTripsTab({super.key, required this.currentUserId});

  @override
  _JoinedTripsTabState createState() => _JoinedTripsTabState();
}

class _JoinedTripsTabState extends State<JoinedTripsTab> {
  String _selectedFilter = "Upcoming";

  void _openUnjoinTripForm(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnjoinTripForm(
        tripId: tripId,
        userId: widget.currentUserId,
      ),
    );
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEAE7D8),
          title: const Text(
            "Filter Trips",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption("Upcoming"),
              _buildFilterOption("Past"),
              _buildFilterOption("Both"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2A3A26)),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String filterType) {
    return ListTile(
      title: Text(
        filterType,
        style: TextStyle(
          fontWeight: _selectedFilter == filterType ? FontWeight.bold : FontWeight.normal,
          color: _selectedFilter == filterType ? const Color(0xFF2A3A26) : Colors.black,
        ),
      ),
      trailing: _selectedFilter == filterType
          ? const Icon(Icons.check, color: Color(0xFF2A3A26))
          : null,
      onTap: () {
        setState(() {
          _selectedFilter = filterType;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _openFilterDialog,
            icon: const Icon(Icons.filter_list),
            label: Text("Filter: $_selectedFilter"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A26),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('GroupTrips').snapshots(),
            builder: (context, tripSnapshot) {
              if (tripSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!tripSnapshot.hasData || tripSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text("You haven't joined any trips yet."));
              }

              final trips = tripSnapshot.data!.docs.where((trip) {
                final tripData = trip.data() as Map<String, dynamic>;
                final tripDate = (tripData['timestamp'] as Timestamp).toDate();

                if (_selectedFilter == "Upcoming") return tripDate.isAfter(now);
                if (_selectedFilter == "Past") return tripDate.isBefore(now);
                return true;
              }).toList();

              return ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final tripData = trip.data() as Map<String, dynamic>;
                  final tripDate = (tripData['timestamp'] as Timestamp).toDate();

                  return FutureBuilder<DocumentSnapshot>(
                    future: trip.reference
                        .collection('participants')
                        .doc(widget.currentUserId)
                        .get(),
                    builder: (context, participantSnapshot) {
                      if (!participantSnapshot.hasData || !participantSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      final participantData =
                          participantSnapshot.data!.data() as Map<String, dynamic>;
                      final status = participantData['status'] ?? 'Pending';
                      final isPast = tripDate.isBefore(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(tripData['trailName'] ?? 'Unnamed Trail'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("City: ${tripData['city']}"),
                              Text("Date: ${_formatDateTime(tripDate)}"),
                              Text("Status: $status",
                                  style: TextStyle(
                                    color: status == "Accepted"
                                        ? Colors.green
                                        : status == "Rejected"
                                            ? Colors.red
                                            : Colors.orange,
                                  )),
                            ],
                          ),
                          trailing: isPast
                              ? null
                              : ElevatedButton(
                                  onPressed: () => _openUnjoinTripForm(context, trip.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Unjoin"),
                                ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${dt.day}/${dt.month}/${dt.year} at $hour:$minute $ampm";
  }
}
