import 'package:flutter/material.dart';

/// For `Scaffold.bottomNavigationBar` bars that hold a primary action.
///
/// The Scaffold lifts only its body above the on-screen keyboard, so a plain
/// bottom bar ends up hidden behind it. Padding the bar by the keyboard height
/// makes it (and the body above it) sit on top of the keyboard instead.
class KeyboardAvoidingBar extends StatelessWidget {
  final Widget child;
  const KeyboardAvoidingBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}
