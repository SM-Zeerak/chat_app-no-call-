import 'package:chat_app_1/screens/Auth%20Screen/login_screen.dart';
import 'package:chat_app_1/screens/mainpage.dart';
import 'package:chat_app_1/screens/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is properly initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.amber,
        fontFamily: 'Arial',
      ),
      home: LoginScreen(), // Set the initial screen to LoginScreen
      routes: {
        '/main': (ctx) => MainPage(), // Route to MainPage
        // '/chat': (ctx) => ChatScreen(selectedUserId: '', selectedUserDocId: ''), // Route to ChatScreen
        '/search': (ctx) => SearchScreen(), // Route to SearchScreen
      },
    );
  }
}
