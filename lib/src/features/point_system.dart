import 'package:cloud_firestore/cloud_firestore.dart';
Future<void> updateUserPoints(String userId, int pointsToAdd, String actionType) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final snapshot = await userRef.get();
  if (!snapshot.exists) return;

  int currentPoints = snapshot['points'] ?? 0;
  int newPoints = currentPoints + pointsToAdd;

  // Get new level and title
  int level = _calculateLevel(newPoints);
  String levelTitle = _getLevelTitle(level);

  // Update user info
  await userRef.update({
    'points': newPoints,
    'level': level,
    'levelTitle': levelTitle,
    'contributions.$actionType': FieldValue.increment(1),
  });

  // Log the points change in history
  await userRef.collection('pointsHistory').add({
    'action': _getActionLabel(actionType),
    'points': pointsToAdd,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// Friendly labels for action types
String _getActionLabel(String actionType) {
  switch (actionType) {
    case 'review_trail': return 'Trail Review';
    case 'review_trip': return 'Trip Review';
    case 'organized_trip': return 'Organized Trip';
    case 'suggested_trail': return 'Trail Suggestion';
    case 'joined_trip': return 'Joined Trip';
    default: return 'Unknown Action';
  }
}


int _calculateLevel(int points) {
  if (points >= 200) return 5;
  if (points >= 100) return 4;
  if (points >= 50) return 3;
  if (points >= 20) return 2;
  return 1;
}

String _getLevelTitle(int level) {
  switch (level) {
    case 5: return "AWJ Guide 🌟";
    case 4: return "Trail Master 🧭";
    case 3: return "Mountain Climber 🏞️";
    case 2: return "Trail Explorer 🥾";
    default: return "Beginner Hiker 🌱";
  }
}
