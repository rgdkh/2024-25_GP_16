import 'afterForgot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  void resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      
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
        title: const Text(
          'Forgot Password',  style: TextStyle(
              color:Color(0xFF2A3A26), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEAE7D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 40),
            const Text(
              'Enter your Email',
              style: TextStyle(fontSize: 24, color: Color(0xFF2A3A26)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              height: 40, 
              child: ElevatedButton(
                onPressed: () => resetPassword(context, emailController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3A26), 
                  foregroundColor: const Color(0xFFEAE7D8), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 18)), 
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFEAE7D8),
    );
  }
}
