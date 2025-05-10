import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart'; 
import '../login/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _gender = '';
  DateTime? _dob;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showGenderError = false;
bool _acceptedTerms = false;
bool _showTermsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _dobController.dispose(); 
    super.dispose();
  }

 void _signUp() async {
  setState(() {
    _showGenderError = _gender.isEmpty;
    _showTermsError = !_acceptedTerms;
  });

  if (_formKey.currentState!.validate() && !_showGenderError  && _acceptedTerms) {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String gender = _gender;
    String dob = _dob != null ? _dob!.toIso8601String() : '';

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }

        await _showEmailVerificationDialog();

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'gender': gender,
          'dateOfBirth': dob,
          'createdAt': Timestamp.now(),
          'isEmailVerified': false,
          'isBlocked': false,
            'points': 0, 
            'level' : 1,
            'levelTitle' : 'Beginner Hiker 🌱'
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This email is already in use. Please login.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
}


  Future<void> _showEmailVerificationDialog() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFEAE7D8), // Same background color
        title: Text(
          'Verify Your Email',
          style: TextStyle(color: Color(0xFF2A3A26)), // Text color
        ),
        content: Text(
          'A verification email has been sent to ${_emailController.text}. Please verify your account.',
          style: TextStyle(color: Color(0xFF2A3A26)), // Content text color
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2A3A26), // Button text color
            ),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  // Function to validate email using EmailValidator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!EmailValidator.validate(value)) {
      return 'Enter a valid email'; // Show error message under email field
    }
    return null;
  }

  // Function to validate password
  String? validatePassword(String? value) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Enter a valid password';
    }
    return null;
  }

  // Function to validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Function to validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }


  // Function to validate date of birth
  String? validateDob(String? value) {
    if (_dob == null) {
      return 'Date of birth is required';
    }
    return null;
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEAE7D8),
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2A3A26)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Sign Up',
        style: TextStyle(
          color: Color(0xFF2A3A26),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFEAE7D8),
    ),
    body: SafeArea(
      
      child: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFEAE7D8),
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2A3A26)),
                    ),
                  ),
                  validator: validateName,
                ),
                const SizedBox(height: 20),
             Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const Text(
          'Gender:',
          style: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF2A3A26), // Text color
          ),
        ),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Male',
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value!;
              _showGenderError = false; // Clear error when gender is selected
            });
          },
          activeColor: Color(0xFF2A3A26),
        ),
        const Text(
          'Male',
          style: TextStyle(fontSize: 16.0, color: Color(0xFF2A3A26)),
        ),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Female',
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value!;
              _showGenderError = false; // Clear error when gender is selected
            });
          },
          activeColor: Color(0xFF2A3A26),
        ),
        const Text(
          'Female',
          style: TextStyle(fontSize: 16.0, color: Color(0xFF2A3A26)),
        ),
      ],
    ),
    if (_showGenderError) // Show error only when _showGenderError is true
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Gender is required',
          style: TextStyle(
            color: const Color.fromARGB(255, 184, 35, 25),
            fontSize: 12,
          ),
        ),
      ),
  ],
),


                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime maxDate =
                        DateTime.now().subtract(const Duration(days: 365 * 15));
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: maxDate,
                      firstDate: DateTime(1900),
                      lastDate: maxDate,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dob = pickedDate;
                        _dobController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  validator: validateDob,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF2A3A26)),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF2A3A26),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF2A3A26),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: validateConfirmPassword,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must contain at least 8 characters, 1 letter, and 1 number.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ),
                
                const SizedBox(height: 20),
                Padding(
  padding: const EdgeInsets.only(top: 20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
                _showTermsError = false;
              });
            },
            activeColor: Color(0xFF2A3A26),
          ),
          Expanded(
           
            
            child: const Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: '* ', // Red star
        style: TextStyle(color: Colors.red, fontSize: 14),
      ),
      TextSpan(
        text: 'I accept full responsibility for my actions and participation in posts or group trips, and I understand that AWJ is not liable for any content or conduct that may occur. ',
        style: TextStyle(color: Color(0xFF2A3A26), fontSize: 10),
      ),
    ],
  ),
),

          
          ),
        ],
      ),
      if (_showTermsError)
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            'To proceed with registration, you need to agree to the terms.',
            style: TextStyle(
              color: const Color.fromARGB(255, 184, 35, 25),
              fontSize: 12,
            ),
          ),
        ),
    ],
  ),
),

                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A3A26),
                        foregroundColor: const Color(0xFFEAE7D8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                       child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}
