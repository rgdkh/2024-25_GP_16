import 'package:dana2/src/features/authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/images.dart';

class AfterForgot extends StatefulWidget {
  final String email;

  AfterForgot({Key? key, required this.email}) : super(key: key);

  @override
  _AfterForgotState createState() => _AfterForgotState();
}

class _AfterForgotState extends State<AfterForgot> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Still keeping this in case you need it for other reasons

  void resendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email resent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to resend password reset email: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7D8), // Cream background
      body: Center( // This centers the Column within the Scaffold
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure everything is centered horizontally
          children: <Widget>[
             Image(
              image: const AssetImage(LogoImage),
              width: 100,
              height: 100,
            ),
            Text(
              'Password Reset Email Sent',
              style: TextStyle(
                color: Color(0xFF2A3A26), // Green color for text
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "We've sent you a secure link to safely change your password and keep your account protected.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF2A3A26),
                ),
                textAlign: TextAlign.center,
              ),
            ),
         TextButton(
            onPressed:resendPasswordResetEmail, // Implement resend email functionality
            child: Text('Resend Email'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2A3A26), // Green color text
            ),
          ),
            SizedBox(height: 20),
            SizedBox(
            width: 250,
              height: 40,// Increase button height
              child: ElevatedButton(
             onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26), // Green background color for button
                  foregroundColor: Color(0xFFEAE7D8), // Cream text color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rectangular shape with slight rounding
                  ),
                ),
               
                child: Text('Done', style: TextStyle(fontSize: 18)), // Increase text size
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

