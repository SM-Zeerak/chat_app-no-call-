import 'package:chat_app_1/Services/Authentication/login_auth.dart';
import 'package:chat_app_1/Services/message_utlis.dart';
import 'package:chat_app_1/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_1/Components/button.dart';
import 'package:chat_app_1/Components/textfield.dart';
import 'package:chat_app_1/screens/Auth%20Screen/signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage(context: context, message: 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final errorMessage = await handleLogin(email: email, password: password);

    if (errorMessage == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen())); // Adjust the route as needed
    } else {
      showMessage(context: context, message: errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                obscureText: false, width: 300, // Email fields don't need to be obscure
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: !_isPasswordVisible,
                isPasswordVisible: true,
                onVisibilityToggle: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }, width: 300,
              ),
              SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: _handleLogin,
                buttonText: 'Login',
                isLoading: _isLoading,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text('Don\'t have an account? Click '),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
