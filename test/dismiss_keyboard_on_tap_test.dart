import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/widgets/dismiss_keyboard_on_tap.dart';

void main() {
  late FocusNode focus;
  late int pressed;

  setUp(() {
    focus = FocusNode();
    pressed = 0;
  });
  tearDown(() => focus.dispose());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => DismissKeyboardOnTap(child: child),
      home: Scaffold(
        body: Column(
          children: [
            TextField(focusNode: focus),
            ElevatedButton(
              onPressed: () => pressed++,
              child: const Text('Kirim'),
            ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    ),
  );

  testWidgets('tapping empty space closes the keyboard', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focus.hasFocus, true);

    await tester.tapAt(const Offset(200, 500));
    await tester.pump();
    expect(focus.hasFocus, false);
  });

  testWidgets('tapping the field keeps the keyboard open', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(focus.hasFocus, true);
  });

  testWidgets('buttons still receive their tap', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.tap(find.text('Kirim'));
    await tester.pump();

    expect(pressed, 1);
  });
}
