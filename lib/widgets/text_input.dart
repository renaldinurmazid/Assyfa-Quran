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
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      onChanged: onChanged,
      controller: controller,
      cursorColor: context.theme.colorScheme.primary,
      style: pSemiBold14.copyWith(color: context.theme.colorScheme.primary),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: pRegular12.copyWith(
          color: context.theme.colorScheme.primary.withOpacity(0.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.theme.colorScheme.primary),
        ),
      ),
    );
  }
}
