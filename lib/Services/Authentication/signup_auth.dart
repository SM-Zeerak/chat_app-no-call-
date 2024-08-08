// lib/utils/auth_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> submitSignupForm({
  required String name,
  required String email,
  required String password,
  required String repassword,
  required String userId,
  required BuildContext context,
  required Function(String) showMessage,
  required Function(List<String>) showUserIdSuggestionsDialog,
  required Function(String) generateUserIdSuggestions,
}) async {
  if (name.isEmpty || email.isEmpty || password.isEmpty || repassword.isEmpty || userId.isEmpty) {
    showMessage('Please fill in all fields.');
    return;
  }

  if (password != repassword) {
    showMessage('Passwords do not match.');
    return;
  }

  if (!RegExp(r'^(?=.*?[A-Z]).{8,}$').hasMatch(password)) {
    showMessage('Password must be at least 8 characters long and include 1 uppercase letter.');
    return;
  }

  try {
    // Check if userId already exists
    final userIdQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .get();

    if (userIdQuery.docs.isNotEmpty) {
      // Show dialog with recommendations if userId is already taken
      final suggestions = await generateUserIdSuggestions(userId);
      if (suggestions.isNotEmpty) {
        showUserIdSuggestionsDialog(suggestions);
      } else {
        showMessage('User ID is already taken. Please choose another.');
      }
      return;
    }

    // Create user with Firebase Authentication
    final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user data in Firestore
    await FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
      'name': name,
      'email': email,
      'userId': userId,
    });

    // Show success message and navigate to login page
    showMessage('Account successfully created!');
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pushReplacementNamed('/login'); // Adjust as needed
  } catch (e) {
    // Handle authentication errors
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operation not allowed. Please contact support.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
          break;
      }
    } else {
      errorMessage = 'An unknown error occurred. Please try again.';
    }
    showMessage(errorMessage);
  }
}
