import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  final _formKey = GlobalKey<FormState>();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final auth = FirebaseAuth.instance;

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  // Function to show styled error messages
  void showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
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
          bottom: MediaQuery.of(context).size.height - 300,
        ),
      ),
    );
  }

  // Function to validate the new password
  String? validatePassword(String? value) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Enter valid Password';
    }
    return null;
  }

  Future<void> changePassword(String newPassword) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        // Re-authenticate the user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Change the password
        await user.updatePassword(newPassword);

        // Clear text fields after successful change
        oldPassController.clear();
        newPassController.clear();

        showCustomSnackBar(context, "Password changed successfully!",
            isError: false);
      } catch (e) {
        print("Error: $e"); // Log error for debugging
        showCustomSnackBar(context, "Error changing password, please try again",
            isError: true);
      }
    } else {
      showCustomSnackBar(context, "No user is signed in.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7D8),
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A26),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: oldPassController,
                  obscureText: !_isOldPasswordVisible,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    hintText: "********",
                    labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isOldPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF2A3A26),
                      ),
                      onPressed: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: newPassController,
                  obscureText: !_isNewPasswordVisible,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "********",
                    labelStyle: const TextStyle(color: Color(0xFF2A3A26)),
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF2A3A26),
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must be at least 8 characters long and contain at least one letter and one number.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      changePassword(newPassController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3A26),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
