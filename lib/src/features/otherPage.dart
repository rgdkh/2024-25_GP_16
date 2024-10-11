import 'package:flutter/material.dart';

class Otherpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blank Page'),
        centerTitle: true,
        backgroundColor: Color(0xFFEAE7D8), // Optional: Customize the AppBar color
      ),
      body: Container(
        color: Colors.white, // Optional: Customize the background color
      ),
    );
  }
}
