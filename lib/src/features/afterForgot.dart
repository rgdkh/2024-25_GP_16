import 'authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AfterForgot extends StatefulWidget {
  final String email;

  const AfterForgot({super.key, required this.email});

  @override
  _AfterForgotState createState() => _AfterForgotState();
}

class _AfterForgotState extends State<AfterForgot> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  
  void resendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      backgroundColor: const Color(0xFFEAE7D8), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'assets/images/logo.png', 
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Password Reset Email Sent',
              style: TextStyle(
                color: Color(0xFF2A3A26),
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
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
              onPressed: resendPasswordResetEmail,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A3A26), 
              ),
              child: const Text('Resend Email'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 40, 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26), 
                  foregroundColor: const Color(0xFFEAE7D8), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 18)), 
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
