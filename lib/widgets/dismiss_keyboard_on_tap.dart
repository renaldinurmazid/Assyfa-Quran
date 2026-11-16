import 'package:flutter/material.dart';

/// Closes the keyboard when empty space is tapped.
///
/// iOS number/phone keyboards have no "Done" key, so without this a user can get
/// stuck with the keyboard open. Fields and buttons claim their own taps first,
/// so they are unaffected.
class DismissKeyboardOnTap extends StatelessWidget {
  final Widget? child;
  const DismissKeyboardOnTap({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
