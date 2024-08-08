import 'package:chat_app_1/Components/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app_1/Components/button.dart';
import 'package:chat_app_1/Components/textfield.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _userIdController = TextEditingController();

  String? _profileImageUrl;

  Future<void> updateUserData(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'userId': _userIdController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print("Error updating user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user is logged in')),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data available'));
          } else {
            var userData = snapshot.data!;
            _nameController.text = userData['name'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _userIdController.text = userData['userId'] ?? '';
            _profileImageUrl = userData['profileImageUrl'];

            return Container(
              width: double.infinity,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    ProfileAvatar(
                      profileImageUrl: _profileImageUrl,
                      onImagePicked: (url) {
                        setState(() {
                          _profileImageUrl = url;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Name',
                      width: 300,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      width: 300,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _userIdController,
                      labelText: 'UserId',
                      width: 300,
                    ),
                    SizedBox(height: 20),
                    CustomElevatedButton(
                      onPressed: () => updateUserData(context, userId),
                      buttonText: 'Update',
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
