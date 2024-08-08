import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:chat_app_1/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (error) {
      print('Error signing out: $error'); // Handle error (e.g., show a Snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('senderId', isEqualTo: _currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats found.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final receiverId = chat['receiverId'];
              final lastMessage = chat['text'];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(receiverId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final user = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final userName = user?['name'] ?? 'Unknown';

                  return ListTile(
                    title: Text(userName),
                    subtitle: Text(lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            selectedUserId: receiverId,
                            selectedUserDocId: receiverId, selectedUserImage:'', // Pass the receiver's document ID
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
