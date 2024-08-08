// lib/widgets/custom_elevated_button.dart
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String buttonText;

  CustomElevatedButton({
    required this.onPressed,
    this.isLoading = false,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? CircularProgressIndicator()
          : Text(buttonText),
    );
  }
}
