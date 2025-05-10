import 'package:flutter/material.dart';

class TrailEtiquette extends StatelessWidget {
  final List<Map<String, dynamic>> etiquetteSteps = [
    {
      "icon": Icons.trending_up,
      "title": "Let Uphill Hikers Pass",
      "description":
          "When you're going downhill and meet someone climbing uphill, step aside to let them pass."
    },
    {
      "icon": Icons.nature,
      "title": "Stay on the Trail",
      "description":
          "Don’t walk off the trail. It keeps plants and animals safe and protects nature."
    },
    {
      "icon": Icons.delete,
      "title": "Take Your Trash Home",
      "description":
          "Don’t leave trash behind. Bring a small bag to carry your garbage, even things like fruit peels."
    },
    {
      "icon": Icons.volume_down,
      "title": "Keep It Quiet",
      "description":
          "Speak softly and avoid loud music. It helps keep the trail peaceful for everyone."
    },
    {
      "icon": Icons.emoji_people,
      "title": "Be Friendly",
      "description":
          "Say hello to other hikers. Move to the side if you stop so the trail stays clear."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trail Etiquette",
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
            ..._buildEtiquetteNodes(),
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
          'Trail Etiquette',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A26),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Follow these simple rules to make the hike fun for you and others.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildEtiquetteNodes() {
    List<Widget> nodes = [];
    for (int i = 0; i < etiquetteSteps.length; i++) {
      nodes.add(_buildGraphNode(
        icon: etiquetteSteps[i]["icon"],
        title: etiquetteSteps[i]["title"],
        description: etiquetteSteps[i]["description"],
      ));
      if (i != etiquetteSteps.length - 1) {
        nodes.add(_buildConnector());
      }
    }
    return nodes;
  }

  Widget _buildGraphNode({required IconData icon, required String title, required String description}) {
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
                'Quick Tip: Bring a small first aid kit for minor injuries like cuts or blisters.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
