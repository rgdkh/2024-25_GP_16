import 'package:flutter/material.dart';

class GroupTripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Group Trips",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFEAE7D8),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          TripCard(
            imageUrl: 'assets/images/sample_trip2.jpg',
            tripTitle: 'New Trip: Al Makhrooq Mountain',
            organizer: 'by AhmadALM',
          ),
          TripCard(
            imageUrl: 'assets/images/sample_trip1.jpg',
            tripTitle: 'Join Me: Khashm al Hisan',
            organizer: 'by Mona',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
        },
        backgroundColor: const Color(0xFF2A3A26), 
        child: const Icon(Icons.add, color: Color(0xFFF7A22C)), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), 
        ),
        elevation: 10, 
        splashColor: Colors.orangeAccent, 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TripCard extends StatelessWidget {
  final String imageUrl;
  final String tripTitle;
  final String organizer;

  TripCard({required this.imageUrl, required this.tripTitle, required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEAE7D8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
            child: Image.asset(
              imageUrl,
              height: 120, 
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), 
            child: ListTile(
              contentPadding: EdgeInsets.zero, 
              title: Text(
                tripTitle,
                style: const TextStyle(
                  color: Color(0xFF2A3A26),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                organizer,
                style: const TextStyle(
                  color: Color(0xFF2A3A26),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), 
            child: Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF7A22C),
                  minimumSize: Size(100, 36), 
                  padding: EdgeInsets.symmetric(horizontal: 10), 
                ),
                child: const Text(
                  'Request Join',
                  style: TextStyle(
                    color: Color(0xFF2A3A26),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
