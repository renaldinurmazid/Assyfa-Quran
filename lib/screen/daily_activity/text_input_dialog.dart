import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/theme/font.dart';

/// A one-field dialog. [onSubmit] returns true when the value was accepted, which closes the dialog;
/// on false it stays open (the caller has already shown the error).
///
/// The text controller lives in the dialog's State and is disposed only when the widget is really
/// gone. Disposing it from `Get.dialog(...).whenComplete` is wrong: that future completes as the
/// dialog starts closing, while the exit animation still renders the TextField.
Future<void> showTextInputDialog({
  required String title,
  required String confirmLabel,
  required Future<bool> Function(String value) onSubmit,
  String? hint,
  String? initialValue,
  TextCapitalization capitalization = TextCapitalization.sentences,
  int maxLength = 100,
}) {
  return Get.dialog(
    _TextInputDialog(
      title: title,
      confirmLabel: confirmLabel,
      onSubmit: onSubmit,
      hint: hint,
      initialValue: initialValue,
      capitalization: capitalization,
      maxLength: maxLength,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final Future<bool> Function(String value) onSubmit;
  final String? hint;
  final String? initialValue;
  final TextCapitalization capitalization;
  final int maxLength;

  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.onSubmit,
    required this.hint,
    required this.initialValue,
    required this.capitalization,
    required this.maxLength,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialValue,
  );
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _text.text.trim();
    if (value.isEmpty || _busy) return;
    setState(() => _busy = true);
    final accepted = await widget.onSubmit(value);
    if (!mounted) return;
    if (accepted) {
      Get.back();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: pBold18),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: widget.capitalization,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(hintText: widget.hint, counterText: ''),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Get.back(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _busy ? null : _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
