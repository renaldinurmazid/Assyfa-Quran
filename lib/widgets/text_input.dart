import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import 'package:quran_app/theme/font.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      cursorColor: context.theme.colorScheme.primary,
      style: pSemiBold14,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: pRegular12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
