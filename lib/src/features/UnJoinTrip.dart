import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnjoinTripForm extends StatefulWidget {
  final String tripId;
  final String userId;

  UnjoinTripForm({required this.tripId, required this.userId});

  @override
  _UnjoinTripFormState createState() => _UnjoinTripFormState();
}

class _UnjoinTripFormState extends State<UnjoinTripForm> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';

  Future<void> _unjoinTrip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final participantRef = FirebaseFirestore.instance
          .collection('GroupTrips')
          .doc(widget.tripId)
          .collection('participants')
          .doc(widget.userId);

      try {
        // Store the reason before deleting the document
        await participantRef.update({'leaveReason': _reason});
        await Future.delayed(Duration(seconds: 1)); // Give time for Firestore update

        // Now delete the document
        await participantRef.delete();

        // Close the dialog
        Navigator.pop(context);
      } catch (e) {
        print("Error unjoining trip: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error unjoining trip: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFEAE7D8), // Set background color
      title: Text(
        "Unjoin Trip",
        style: TextStyle(color: Color(0xFF2A3A26)), // Title color
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Reason for unjoining (optional)",
                labelStyle: TextStyle(color: Color(0xFF2A3A26)), // Label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26)), // Border color
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2A3A26), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(color: Color(0xFF2A3A26)), // Input text color
              cursorColor: Color(0xFF2A3A26), // Cursor color
              onSaved: (value) => _reason = value ?? '',
            ),
            SizedBox(height: 20),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog without submitting
                  },
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Color(0xFF2A3A26), // Button color
                    foregroundColor: Color(0xFFEAE7D8), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Close"),
                ),
                ElevatedButton(
                  onPressed: _unjoinTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A3A26), // Button color
                    foregroundColor: Color(0xFFEAE7D8), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
