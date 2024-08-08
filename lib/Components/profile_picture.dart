// lib/Components/profile_avatar.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAvatar extends StatefulWidget {
  final String? profileImageUrl;
  final Function(String?) onImagePicked;

  ProfileAvatar({this.profileImageUrl, required this.onImagePicked});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: await _showImageSourceDialog(context),
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await _uploadImage(context, imageFile);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<ImageSource> _showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery), // Default to gallery
            ),
          ],
        );
      },
    ) ?? ImageSource.gallery; // Default to gallery if dialog is dismissed
  }

  Future<void> _uploadImage(BuildContext context, File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');

      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });

      widget.onImagePicked(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: CircleAvatar(
        radius: 100,
        backgroundColor: Colors.grey[200],
        backgroundImage: widget.profileImageUrl != null
            ? NetworkImage(widget.profileImageUrl!)
            : null,
        child: widget.profileImageUrl == null
            ? Icon(Icons.camera_alt, color: Colors.grey[800], size: 50)
            : null,
      ),
    );
  }
}
