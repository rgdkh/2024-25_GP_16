import 'package:flutter/material.dart';
import 'BasicHikingTips.dart';
import 'EquipmentGuide.dart';
import 'Navigation.dart';
import 'TrailEtiquette.dart';
import 'LocalInsights.dart';
import 'EmergencyPreparedness.dart';
import 'WhereToBuyEquipment.dart';

class Hiking101Page extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {
      'image': 'assets/images/1.png',
      'page': BasicHikingTips(),
    },
    {
      'image': 'assets/images/2.png',
      'page': EquipmentGuide(),
    },
    {
      'image': 'assets/images/6.png',
      'page': Navigation(),
    },
    {
      'image': 'assets/images/5.png',
      'page': TrailEtiquette(),
    },
    {
      'image': 'assets/images/4.png',
      'page': LocalInsights(),
    },
    {
      'image': 'assets/images/3.png',
      'page': EmergencyPreparedness(),
    },
    {
      'image': 'assets/images/7.png',
      'page': WhereToBuyEquipment(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text(
          "Hiking 101",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Color(0xFFEAE7D8),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two pictures per row
            crossAxisSpacing: 8, // Spacing between columns
            mainAxisSpacing: 8, // Spacing between rows
            childAspectRatio: 1.1, // Adjust to make images larger
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            return _buildGridItem(context, sections[index]);
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> section) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => section['page']),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            section['image'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
