import 'dart:async';
import 'package:dana2/src/features/authentication/login/login.dart';
import 'package:flutter/material.dart';

import '../constants/images.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8), // Hex color code
      body: Center(
        child: Image(
              image: const AssetImage(LogoImage),
              width: 300,
              height: 300,
            ),
      ),
    );
  }
}
