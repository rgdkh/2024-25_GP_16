import 'package:flutter/material.dart';

class Hiking101Page extends StatelessWidget {
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
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 2, 
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: <Widget>[
            _buildSquareButton('Learn the fundamentals of hiking.', 'assets/images/h1.png', context),
            _buildSquareButton('Essential gear you need on a trip.', 'assets/images/h2.png', context),
          
            _buildSquareButton('Tips on handling emergencies.', 'assets/images/h3.png', context),
            _buildSquareButton('Learn about hiking in Saudi Arabia.', 'assets/images/h4.png', context),
          ],
        ),
      ),
    );
  }

 Widget _buildSquareButton(String title, String imagePath, BuildContext context) {
  return GestureDetector(
    onTap: () {
      
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), 
            blurRadius: 8,
            offset: Offset(4, 4), 
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
}