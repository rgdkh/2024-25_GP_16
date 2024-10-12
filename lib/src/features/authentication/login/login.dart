import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/images.dart';
import '../../forgotpassword.dart';
import '../../otherPage.dart';
import '../signup/signup.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Login method
void signUserIn(BuildContext context) async {
    // Check if either the email or password fields are empty
  if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all fields.')),
    );
    return; // Stop the sign-in process if any field is empty
  }
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: usernameController.text,
      password: passwordController.text,
    );
    // If login is successful, navigate to OtherPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Otherpage()),
    );
  } on FirebaseAuthException catch (e) {
    String message = 'Invalid email or password';
    // Show the error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    // Handle any other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred. Please try again.')),
    );
  }
}

   


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                enabledBorder:UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)),
                ),
                suffixIcon: usernameController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Color(0xFF2A3A26)),
                        onPressed: () {
                          setState(() {
                            usernameController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF2A3A26),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
  );
},

                child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF2A3A26))),
              ),
            ),
            SizedBox(
            width: 250,
              height: 40,// Increase button height
              child: ElevatedButton(
                onPressed: () => signUserIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A3A26), // Green background color for button
                  foregroundColor: Color(0xFFEAE7D8), // Cream text color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rectangular shape with slight rounding
                  ),
                ),
               
                child: Text('Login', style: TextStyle(fontSize: 18)), // Increase text size
              ),
            ),
             SizedBox(
              width: 250,
              height: 40, // Increase button height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEAE7D8), // Green background color for button
                  foregroundColor: Color(0xFF2A3A26), // Cream text color for button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rectangular shape with slight rounding
                  ),
                ),
                onPressed: () {
                  // Handle Continue as a Guest button press
                },
                child: Text('Continue as a Guest', style: TextStyle(fontSize: 18)), // Increase text size
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Don\'t have an account? Sign up', style: TextStyle(color: Color(0xFF2A3A26))),
            ),
          ],
        ),
      ),
    );
  }
}
