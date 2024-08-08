// lib/utils/user_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> generateUserIdSuggestions(String existingUserId) async {
  final suggestions = <String>[];
  for (int i = 1; i <= 5; i++) {
    final suggestion = '$existingUserId$i';
    final userIdQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: suggestion)
        .get();
    if (userIdQuery.docs.isEmpty) {
      suggestions.add(suggestion);
    }
  }
  return suggestions;
}
