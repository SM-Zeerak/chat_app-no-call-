import 'package:firebase_database/firebase_database.dart';

class ChatService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Generate a chat ID based on user IDs
  String _generateChatId(String userId1, String userId2) {
    // Ensure the IDs are in a consistent order to avoid duplication
    return userId1.compareTo(userId2) < 0
        ? '$userId1 _ $userId2'
        : '$userId2 _ $userId1';
  }

  // Get or create a chat ID for the given user IDs
    Future<String> getOrCreateChatId(String userId1, String userId2) async {
      final chatId = _generateChatId(userId1, userId2);

      final chatRef = _database.child('Chats').child(chatId);

      // Check if chat already exists
      final snapshot = await chatRef.get();
      if (snapshot.exists) {
        return chatId;
      }

      // If chat does not exist, create it
      await chatRef.set({
        'users': {
          userId1: true,
          userId2: true,
        },
      });

      return chatId;
    }
  }
