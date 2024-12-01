import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Navigation",
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
            _buildGraphNode(
              icon: Icons.map,
              title: 'Before the Hike',
              description:
                  'Check the trail map, mark important spots like water sources and resting points',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.gps_fixed,
              title: 'During the Hike',
              description:
                  'Use GPS or hiking apps as backup and always follow the trail signs. share your live location with a trusted contact. Avoid shortcuts to stay safe.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.assistant_direction,
              title: 'If You Get Lost',
              description:
                  'Stay calm and avoid moving too far from where you are. If needed, call Saudi Arabia’s emergency number: 911.',
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
          'assets/images/2.webp', // Replace with your image path
          width: screenWidth * 0.9,
          height: screenWidth * 0.5,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 16),
        Text(
          'Navigation Tips',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Learn how to use GPS, and  have an emergency plans to stay safe during the hike.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGraphNode({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Color(0xFF2A3A26)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Center(
      child: Container(
        height: 40,
        width: 4,
        color: Color(0xFF2A3A26),
      ),
    );
  }

  Widget _buildQuickTip() {
    return Card(
      color: Color(0xFFDFF6DD),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Color(0xFF2A3A26), size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Quick Tip: Share your live location with a friend or family member before you start hiking, and let them know your estimated return time.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
