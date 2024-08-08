// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

Future<String?> handleLogin({
  required String email,
  required String password,
}) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null; // No error
  } on FirebaseAuthException catch (e) {
    // Log the error code for debugging purposes
    print('Firebase Auth Error Code: ${e.code}');
    print('Firebase Auth Error Message: ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'invalid-credential':
        return 'The credentials provided are invalid. Please check your email and password.';
      default:
        return 'An error occurred: ${e.message}';
    }
  } catch (e) {
    return 'An unknown error occurred. Please try again.';
  }
}
