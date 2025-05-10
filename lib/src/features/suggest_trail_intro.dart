
import 'suggest.dart';
import 'package:flutter/material.dart';

class SuggestTrailIntroPage extends StatelessWidget {
  const SuggestTrailIntroPage({super.key});

  final List<Map<String, dynamic>> criteriaList = const [
  {
    "icon": Icons.hiking,
    "title": "Hikable",
    "description":
        "Only suggest trails that are clearly walkable and safe for hiking. Avoid paths that are primarily for off-roading, climbing, or require special gear beyond standard hiking equipment."
  },
  {
    "icon": Icons.straighten,
    "title": "Trail Length",
    "description":
        "Select trails with a length appropriate for hiking — not too short to be insignificant, and not excessively long without checkpoints or rest areas."
  },
  {
    "icon": Icons.landscape,
    "title": "Cultural Appeal",
    "description":
        "Suggest trails that pass through beautiful natural scenery or culturally significant locations to enhance the hiking experience."
  },
  {
    "icon": Icons.access_time,
    "title": "Estimated Duration",
    "description":
        "Provide an accurate estimate of how long the trail typically takes to hike, considering rest stops and terrain difficulty."
  },
  {
    "icon": Icons.local_hospital,
    "title": "Safety and Emergency",
    "description":
        "Ensure the trail is relatively safe, has mobile signal in parts (if possible), and can be accessed by rescue services in emergencies."
  },
  {
    "icon": Icons.location_on,
    "title": "Accessibility",
    "description":
        "Make sure the trail is located in Saudi Arabia and reachable by common transport methods (car, walking, etc.)."
  },
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Suggest a Trail",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            "Help the community by suggesting hiking trails that are not yet in AWJ. Make sure to provide accurate and helpful information.",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF2A3A26),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "Trail Selection Criteria",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A26),
            ),
          ),
          
          const SizedBox(height: 24),
          ..._buildCriteriaNodes(),
          const SizedBox(height: 8),
          const Text(
            "Choose the right trail by considering important factors that ensure a safe and enjoyable experience.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  List<Widget> _buildCriteriaNodes() {
    List<Widget> nodes = [];
    for (int i = 0; i < criteriaList.length; i++) {
      nodes.add(_buildGraphNode(
        icon: criteriaList[i]["icon"],
        title: criteriaList[i]["title"],
        description: criteriaList[i]["description"],
      ));
      if (i != criteriaList.length - 1) {
        nodes.add(_buildConnector());
      }
    }
    return nodes;
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
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
        height: 32,
        width: 4,
        color: const Color(0xFF2A3A26),
      ),
    );
  }


  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuggestTrailPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A3A26),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      child: Row(
  mainAxisSize: MainAxisSize.min,
  children: const [
    Text(
      "Continue to Suggest Trail",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    SizedBox(width: 8),
    Icon(
      Icons.arrow_forward_ios,
      color: Colors.white,
      size: 16,
    ),
  ],
),

      ),
    );
  }
}
