// lib/widgets/custom_textfield.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final bool isPasswordVisible;
  final bool isRepasswordVisible;
  final double width;

  CustomTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.isPasswordVisible = false,
    this.isRepasswordVisible = false, required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 55,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          // border:  OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey
          //   ),
          //   borderRadius: BorderRadius.circular(20)
          // ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          labelText: labelText,
          suffixIcon: onVisibilityToggle != null
              ? IconButton(
                  icon: Icon(
                    !obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        ),
      ),
    );
  }
}
