import 'package:flutter/material.dart';
import 'maps/maps.dart';

class LocalInsights extends StatelessWidget {
  final List<Map<String, dynamic>> hikingSpots = [
    {
      'title': 'Edge of the World',
      'description': 'Jaw-dropping cliffs near Riyadh.',
      'icon': Icons.landscape,
      'trailId': '2Yw6opv4xnsZF0qGeq5C',
    },
    {
      'title': 'Jebel Fihrayn',
      'description': 'A desert trek for adventurous hikers.',
      'icon': Icons.terrain,
      'trailId': '1Db2to6Na0EvQf6RlBEc',
    },
    {
      'title': 'Al-Soudah',
      'description': 'Green mountains and cool temperatures.',
      'icon': Icons.forest,
      'trailId': 'Qx6ofHuhkip4c9Zc1znV',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Local Insights",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
     
      body: Container(
        color: Color(0xFFEAE7D8),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderSection(context),
            _buildCardWithSteps(
              title: 'Best Hiking Seasons',
              steps: [
                {
                  'icon': Icons.calendar_today,
                  'text': 'Winter (November to February): Perfect weather, cool and clear.',
                },
                {
                  'icon': Icons.wb_sunny,
                  'text': 'Spring & Fall: Great for mountain hikes, avoid deserts.',
                },
                {
                  'icon': Icons.warning,
                  'text': 'Summer: Too hot for most hikes, stay safe indoors.',
                },
              ],
            ),
            _buildHikingSpotsCard(context),
            _buildCardWithSteps(
              title: 'Wildlife to Watch For',
              steps: [
                {
                  'icon': Icons.pets,
                  'text': 'Deserts: Camels, Arabian oryx, and foxes.',
                },
                {
                  'icon': Icons.mood,
                  'text': 'Mountains: Baboons and ibex.',
                },
                {
                  'icon': Icons.flight,
                  'text': 'Wetlands: Migratory birds in winter.',
                },
              ],
            ),
            _buildCardWithSteps(
              title: 'Cultural Tips',
              steps: [
                {
                  'icon': Icons.checkroom,
                  'text': 'Dress modestly, especially in rural areas.',
                },
                {
                  'icon': Icons.handshake,
                  'text': 'Respect local traditions and customs.',
                },
                {
                  'icon': Icons.directions_walk,
                  'text': 'Hire a guide for remote hikes.',
                },
              ],
            ),
            _buildQuickTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Image.asset(
          'assets/images/1.jpg',
          width: screenWidth * 0.9,
          height: screenWidth * 0.5,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 10),
        Text(
          'Discover Saudi Arabia’s Hiking!',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Explore breathtaking landscapes, diverse wildlife, and the cultural richness of hiking in Saudi Arabia. Dive into the details below to plan your next adventure!',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCardWithSteps({required String title, required List<Map<String, dynamic>> steps}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
            ),
            SizedBox(height: 12),
            Column(
              children: steps
                  .map(
                    (step) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(step['icon'], color: Color(0xFF2A3A26)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step['text'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHikingSpotsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Hiking Spots',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
            ),
            SizedBox(height: 12),
            Column(
              children: hikingSpots.map((spot) {
                return ListTile(
                  leading: Icon(spot['icon'], color: Color(0xFF2A3A26)),
                  title: Text(
                    spot['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(spot['description']),
                  trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF2A3A26)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(trailId: spot['trailId']),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTip() {
    return Card(
      color: Color(0xFFD9F7BE),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Color(0xFF2A3A26), size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Quick Tip: Always carry extra water and sunscreen when hiking in Saudi Arabia’s diverse terrain!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
