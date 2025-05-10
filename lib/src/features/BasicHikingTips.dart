import 'package:flutter/material.dart';

class BasicHikingTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text(
          "Basic Hiking Tips",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
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
              icon: Icons.directions_walk,
              title: 'Choose the Right Trail',
              description:
                  'Select a trail that matches your fitness level and experience. Start with shorter, easier hikes if you are a beginner.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.checkroom,
              title: 'Dress Smartly',
              description:
                  'Wear moisture-wicking fabrics, dress in layers, and choose comfortable, sturdy hiking shoes.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.local_drink,
              title: 'Pack Essentials',
              description:
                  'Bring enough water, snacks, a first aid kit, and navigation tools such as a map or GPS.',
            ),
            _buildConnector(),
            _buildGraphNode(
              icon: Icons.notifications_active,
              title: 'Inform Someone',
              description:
                  'Let a trusted person know your hiking plans, including your route and estimated return time.',
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
        SizedBox(height: 16),
        Text(
          'Basics of Hiking',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A3A26)),
        ),
        SizedBox(height: 8),
        Text(
          'Prepare well to make your hiking adventure safe and enjoyable. Follow these essential tips for a great experience!',
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
                'Quick Tip: Check the weather forecast before heading out to avoid unexpected conditions!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
