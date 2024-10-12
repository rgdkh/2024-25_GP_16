import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/images.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false; // Added variable for confirm password visibility

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String name = _nameController.text;

    // Check for empty fields
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return; // Stop the sign-up process if the email is invalid
    }

    // Password length validation
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 8 characters long.')),
      );
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Color(0xFFEAE7D8),
      ),
      body: Container(
        color: Color(0xFFEAE7D8),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 40),
              child: Image(
                image: const AssetImage(LogoImage),
                width: 100,
                height: 100,
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder( borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder:UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder( borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder:UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder( borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder:UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF2A3A26)),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder( borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder:UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF2A3A26)),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26),
                  foregroundColor: Color(0xFFEAE7D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _signUp,
                child: Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
