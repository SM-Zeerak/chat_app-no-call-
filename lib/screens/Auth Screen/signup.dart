import 'package:chat_app_1/Components/textfield.dart';
import 'package:chat_app_1/Services/Authentication/signup_auth.dart';
import 'package:chat_app_1/Services/message_utlis.dart';
import 'package:chat_app_1/Services/user_utils.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Ensure this import is correct for your project

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  final _userIdController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRepasswordVisible = false;

  Future<void> _handleSubmit() async {
    await submitSignupForm(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      repassword: _repasswordController.text.trim(),
      userId: _userIdController.text.trim(),
      context: context,
      showMessage: (message) => showMessage(context: context, message: message),
      showUserIdSuggestionsDialog: (suggestions) =>
          _showUserIdSuggestionsDialog(suggestions),
      generateUserIdSuggestions: (userId) => generateUserIdSuggestions(userId),
    );
  }

  void _showUserIdSuggestionsDialog(List<String> suggestions) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User ID Taken'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'The User ID you entered is already taken. Here are some suggestions:'),
              SizedBox(height: 10),
              ...suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _userIdController.text = suggestion;
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void clearField(){
    _nameController.clear();
  _emailController.clear();
  _passwordController.clear();
  _repasswordController.clear();
  _userIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Name', width: 300,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email', width: 300,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: !_isPasswordVisible,
              isPasswordVisible: _isPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }, width: 300,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _repasswordController,
              labelText: 'Re-enter Password',
              obscureText: !_isRepasswordVisible,
              isRepasswordVisible: _isRepasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isRepasswordVisible = !_isRepasswordVisible;
                });
              }, width: 300,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _userIdController,
              labelText: 'User ID', width: 300,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      clearField();
                      await _handleSubmit();
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                    },
              child: _isLoading ? CircularProgressIndicator() : Text('Signup'),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Text('Already have an account? Click '),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
