import 'package:flutter/material.dart';

class PicsComment extends StatelessWidget {
 
  final List<String> _images = [
    'assets/images/jumper6.jpg',
    'assets/images/hike.jpg',
    'assets/images/The trails of Al Madinah.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8),
     appBar: AppBar(
        title: const Text(
          "Hiker's Photos",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _images.map((imagePath) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 400,  
                    height: 250, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: Center(child: Text('Image not available')),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}