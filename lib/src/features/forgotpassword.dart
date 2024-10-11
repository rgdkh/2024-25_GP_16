import 'package:dana2/src/features/afterForgot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/images.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  void resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Directly navigate to AfterForgot screen upon success
    Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => AfterForgot(email: emailController.text),
  ),
);

    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send password reset email: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: Color(0xFF2A3A26))),
        centerTitle: true,
        backgroundColor: Color(0xFFEAE7D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage(LogoImage),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 40),
            Text(
              'Enter your Email',
              style: TextStyle(fontSize: 24, color: Color(0xFF2A3A26)),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
              ),
            ),
            SizedBox(height: 40),
              SizedBox(
            width: 250,
              height: 40,// Increase button height
              child: ElevatedButton(
              onPressed: () => resetPassword(context, emailController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26), // Green background color for button
                  foregroundColor: Color(0xFFEAE7D8), // Cream text color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rectangular shape with slight rounding
                  ),
                ),
               
                child: Text('Next', style: TextStyle(fontSize: 18)), // Increase text size
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEAE7D8),
    );
  }
}


