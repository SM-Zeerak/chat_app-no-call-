import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app_1/screens/chat_screen.dart';
import 'package:chat_app_1/screens/profile_screen.dart';
import 'package:chat_app_1/screens/widgets/dropdown_search.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late String _currentUserId;
  String _currentUserName = ''; // Store the current user's name
  bool _isDropdownVisible = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _filteredUserIds = [];
  bool _isLoading = false;
  Map<String, String> _lastMessages = {};
  Map<String, String> _userNames = {};
  Map<String, String> _userImages = {}; // Store user images

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _searchController.addListener(_onSearchChanged);
    _loadUserName(); // Load current user name
    _loadUsers(); // Load all users on initialization
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserName = userData['name'] ?? 'User'; // Default to 'User' if name is null
        });
      } else {
        print('User document does not exist.');
        setState(() {
          _currentUserName = 'User'; // Default to 'User' if user document does not exist
        });
      }
    } catch (error) {
      print('Error loading user name: $error');
      setState(() {
        _currentUserName = 'User'; // Default to 'User' if an error occurs
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs;

      final lastMessages = <String, String>{};
      final userNames = <String, String>{};
      final userImages = <String, String>{}; // Add a map for user images
      final filteredUserIds = <String>[];

      for (final userDoc in users) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userDocId = userDoc.id;
        final userName = userData['name'] as String?;
        final userImage = userData['profileImageUrl'] as String?; // Fetch the image URL

        if (userDocId != _currentUserId) {
          final chatId = _currentUserId.compareTo(userDocId) < 0
              ? '$_currentUserId _ $userDocId'
              : '$userDocId _ $_currentUserId';

          final chatDoc = await _firestore.collection('Chats').doc(chatId).get();

          if (chatDoc.exists) {
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final lastMessage = chatData['lastMessage'] as String?;

            if (lastMessage != null) {
              lastMessages[chatId] = lastMessage;
              filteredUserIds.add(userDocId); // Only add to filteredUserIds if lastMessage is not null
            } else {
              lastMessages[chatId] = 'No message';
            }
          } else {
            lastMessages[chatId] = 'No message';
          }

          userNames[userDocId] = userName ?? 'Unknown';
          userImages[userDocId] = userImage ?? ''; // Default to empty string if imageUrl is null
        }
      }

      setState(() {
        _filteredUserIds = filteredUserIds;
        _lastMessages = lastMessages;
        _userNames = userNames;
        _userImages = userImages; // Add this to the state
      });
    } catch (error) {
      print('Error loading users: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() async {
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty) {
      setState(() {
        _isDropdownVisible = false;
        _searchResults = [];
      });
    } else {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userId', isGreaterThanOrEqualTo: searchQuery)
          .where('userId', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .get();

      final users = querySnapshot.docs;

      setState(() {
        _isDropdownVisible = true;
        _searchResults = users.where((doc) {
          final user = doc.data() as Map<String, dynamic>;
          return user['userId'] != _currentUserId;
        }).map((doc) {
          final user = doc.data() as Map<String, dynamic>;
          return {
            'userId': user['userId'],
            'name': user['name'],
            'email': user['email'],
            'docId': doc.id,
            'profileImageUrl': user['profileImageUrl'], // Include image URL
          };
        }).toList();
      });
    }
  }

  void _onUserSelected(Map<String, dynamic> user) async {
    final selectedUserDocId = user['docId'];
    final selectedUserName = user['name']; // Get the selected user's name
    final selectedUserImage = user['profileImageUrl']; // Get the selected user's image URL

    setState(() {
      if (!_filteredUserIds.contains(selectedUserDocId)) {
        _filteredUserIds.add(selectedUserDocId);
        _isDropdownVisible = false;
        _searchController.clear();
      }
    });

    await _loadUsers(); // Reload users to include the selected one

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          selectedUserId: selectedUserName, // Pass the username
          selectedUserDocId: selectedUserDocId,
          selectedUserImage: selectedUserImage, // Pass the user image URL
        ),
      ),
    );
  }

  void _onContainerTapped(String userDocId) {
    final selectedUserName = _userNames[userDocId] ?? 'Unknown';
    final selectedUserImage = _userImages[userDocId] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          selectedUserId: selectedUserName,
          selectedUserDocId: userDocId,
          selectedUserImage: selectedUserImage,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 138, 138, 138),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(181, 152, 151, 151),
        automaticallyImplyLeading: false,
        title: Text(
          _currentUserName.isNotEmpty ? _currentUserName : 'User',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.manage_accounts_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: _logout,
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'Search User By ID',
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
                CustomDropdown(
                  items: _searchResults,
                  onSelect: _onUserSelected,
                  isVisible: _isDropdownVisible,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredUserIds.length,
                  itemBuilder: (context, index) {
                    final userDocId = _filteredUserIds[index];
                    final chatId = _currentUserId.compareTo(userDocId) < 0
                        ? '$_currentUserId _ $userDocId'
                        : '$userDocId _ $_currentUserId';
                    final lastMessage = _lastMessages[chatId] ?? 'No message';
                    final userName = _userNames[userDocId] ?? 'Unknown';
                    final userImage = _userImages[userDocId] ?? ''; // Fetch the image URL

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => _onContainerTapped(userDocId),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(52, 0, 0, 0),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: userImage.isNotEmpty
                                    ? NetworkImage(userImage)
                                    : AssetImage('assets/default_avatar.png') as ImageProvider, // Default image
                                radius: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$userName',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '$lastMessage',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
