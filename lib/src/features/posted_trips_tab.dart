import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_card.dart';

class PostedTripsTab extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedOrganizer;
  final String? highlightedTripId;
  final ScrollController? scrollController;

  const PostedTripsTab({
    super.key,
    this.selectedLocation,
    this.selectedOrganizer,
    this.highlightedTripId,
    this.scrollController,
  });

  @override
  _PostedTripsTabState createState() => _PostedTripsTabState();
}

class _PostedTripsTabState extends State<PostedTripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Previous"),
          ],
          indicatorColor: Color(0xFF2A3A26),
          labelColor: Color(0xFF2A3A26),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTripList(isUpcoming: true),
              _buildTripList(isUpcoming: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripList({required bool isUpcoming}) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('GroupTrips')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading trips.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No trips available.'));
        }

        final now = DateTime.now();

        var trips = snapshot.data!.docs.where((trip) {
          final data = trip.data() as Map<String, dynamic>;
          final tripDate = (data['timestamp'] as Timestamp).toDate();

          bool matchesLocation = widget.selectedLocation == null ||
              data['city'].toString().toLowerCase() ==
                  widget.selectedLocation!.toLowerCase();
          bool matchesOrganizer = widget.selectedOrganizer == null ||
              data['organizerId'] == widget.selectedOrganizer;

          bool matchesDate =
              isUpcoming ? tripDate.isAfter(now) : tripDate.isBefore(now);

          return matchesLocation && matchesOrganizer && matchesDate;
        }).toList();

        if (trips.isEmpty) {
          return Center(
            child: Text(
              isUpcoming ? "No upcoming trips." : "No previous trips.",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(10.0),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return TripCard(
              trip: trip,
              isHighlighted: trip.id == widget.highlightedTripId,
            );
          },
        );
      },
    );
  }
}
