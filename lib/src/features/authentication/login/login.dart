import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import '../../forgotpassword.dart';
import '../../homepage.dart';
import '../signup/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;


  void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).size.height - 130,
        ),
      ),
    );
  }

void signUserIn(BuildContext context) async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {

    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: usernameController.text)
        .get();

   
    if (userQuerySnapshot.docs.isEmpty) {
      showCustomSnackBar(context, 'No user found with this email. Please sign up first.', isError: true);
      setState(() {
        _isLoading = false;
      });
      return; 
    }

    
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: usernameController.text,
      password: passwordController.text,
    );

    User? user = userCredential.user;
    if (user != null && user.emailVerified) {
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isEmailVerified': true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homepage()),
      );
    } else {
      await _auth.signOut();
      showCustomSnackBar(context, 'Please verify your email before logging in.', isError: true);
    }
  } on FirebaseAuthException catch (e) {
    
    String message;
    if (e.code == 'wrong-password') {
      message = 'Incorrect password. Please try again.';
    } else if (e.code == 'invalid-email') {
      message = 'The email format is invalid. Please check and try again.';
    } else {
      message = 'Incorrect email or password. Please try again.';
    }
    showCustomSnackBar(context, message, isError: true);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  //  email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  //  password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEAE7D8),
      ),
      body: Container(
        color: const Color(0xFFEAE7D8),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  suffixIcon: usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF2A3A26)),
                          onPressed: () {
                            setState(() {
                              usernameController.clear();
                            });
                          },
                        )
                      : null,
                ),
                validator: validateEmail, 
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3A26)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF2A3A26),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: validatePassword, 
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF2A3A26))),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: 250,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => signUserIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3A26),
                          foregroundColor: const Color(0xFFEAE7D8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAE7D8),
                    foregroundColor: const Color(0xFF2A3A26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const homepage()),
                    );
                  },
                  child: const Text('Continue as a Guest', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up', style: TextStyle(color: Color(0xFF2A3A26))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
