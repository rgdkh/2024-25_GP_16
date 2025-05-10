import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'join_requests_tab.dart';
import 'joined_trips_tab.dart';

class MyTripsTab extends StatefulWidget {
  const MyTripsTab({super.key});

  @override
  _MyTripsTabState createState() => _MyTripsTabState();
}

class _MyTripsTabState extends State<MyTripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _innerTabController;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var trip = null;
    return Column(
      children: [
        TabBar(
          controller: _innerTabController,
          tabs: const [
            Tab(text: "Join Requests"),
            Tab(text: "Joined Trips"),
          ],
          indicatorColor: Color(0xFF2A3A26),
          labelColor: Color(0xFF2A3A26),
        ),
        Expanded(
          child: TabBarView(
            controller: _innerTabController,
            children: [
              JoinRequestsTab(currentUserId: currentUserId, trip: trip,),
              JoinedTripsTab(currentUserId: currentUserId),
            ],
          ),
        ),
      ],
    );
  }
}
