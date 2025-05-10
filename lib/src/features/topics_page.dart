import 'package:flutter/material.dart';
import 'subtopics_page.dart';

class TopicsPage extends StatelessWidget {
  TopicsPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> topics = [
    {
      'title': 'Trail Selection',
      'icon': Icons.map,
      'subtopics': [
        'Choosing the right trail',
        'Reading trail maps',
        'Estimating trail difficulty',
        'Seasonal trail changes',
        'Finding the trailhead'
      ],
    },
    {
      'title': 'Hiking Techniques',
      'icon': Icons.directions_walk,
      'subtopics': [
        'Uphill hiking techniques',
        'Controlling descents',
        'River crossing safety',
        'Night hiking basics',
        'Steep terrain hiking'
      ],
    },
    {
      'title': 'Survival Skills',
      'icon': Icons.security,
      'subtopics': [
        'Building emergency shelter',
        'Finding water sources',
        'Fire starting basics',
        'Signaling for rescue',
        'Survival priorities outdoors'
      ],
    },
    {
      'title': 'Weather Awareness',
      'icon': Icons.cloud,
      'subtopics': [
        'Reading weather patterns',
        'Gear for rainy hikes',
        'Handling sudden storms',
        'Hiking safely in heat',
        'Cold weather hiking'
      ],
    },
    {
      'title': 'Navigation Skills',
      'icon': Icons.explore,
      'subtopics': [
        'Using a compass',
        'Reading topographic maps',
        'Off-trail navigation',
        'Following trail markers',
        'GPS failure recovery'
      ],
    },
    {
      'title': 'Eco-Safe Hiking',
      'icon': Icons.eco,
      'subtopics': [
        'Staying on the trail',
        'Wildlife safety rules',
        'Leave No Trace principles',
        'Reducing trail erosion',
        'Respecting nature sites'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8), 
      appBar: AppBar(
        title: const Text(
          'Hiking Topics',
          style: TextStyle(color: Color(0xFFEAE7D8), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A3A26),
        centerTitle: true,
        iconTheme: const IconThemeData(color:Color(0xFFEAE7D8)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: topics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 4 / 3,
        ),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubTopicsPage(
                    title: topic['title'],
                    subtopics: topic['subtopics'],
                  ),
                ),
              );
            },
            child: Container(
              
              decoration: BoxDecoration(
                    color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(topic['icon'], size: 50, color: Color(0xFF2A3A26)),
                  const SizedBox(height: 10),
                  Text(
                    topic['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A3A26),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
