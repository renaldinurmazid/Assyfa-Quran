import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/daily_activity/text_input_dialog.dart';

Future<void> _open(
  WidgetTester tester,
  Future<bool> Function(String) onSubmit, {
  String? initialValue,
}) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showTextInputDialog(
              title: 'Judul',
              confirmLabel: 'Simpan',
              initialValue: initialValue,
              onSubmit: onSubmit,
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'closes after an accepted submit without using a disposed controller',
    (tester) async {
      String? received;
      await _open(tester, (v) async {
        received = v;
        return true;
      });

      await tester.enterText(find.byType(TextField), '  Sholat dhuha  ');
      await tester.tap(find.text('Simpan'));
      // Let the exit animation play out: this is where the old code threw.
      await tester.pumpAndSettle();

      expect(received, 'Sholat dhuha');
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'stays open and re-enables the buttons when the value is rejected',
    (tester) async {
      await _open(tester, (v) async => false);

      await tester.enterText(find.byType(TextField), 'x');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Simpan'))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'ignores an empty value, starts from the initial value, and cancels cleanly',
    (tester) async {
      var calls = 0;
      await _open(tester, (v) async {
        calls++;
        return true;
      }, initialValue: 'Tilawah');

      expect(find.text('Tilawah'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(calls, 0);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
