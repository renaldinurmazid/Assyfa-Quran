import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/widgets/keyboard_avoiding_bar.dart';

void main() {
  Widget app({required bool avoiding}) {
    const bar = SizedBox(height: 60, child: Center(child: Text('BAR')));
    return MaterialApp(
      home: Scaffold(
        body: const SingleChildScrollView(child: TextField()),
        bottomNavigationBar: avoiding
            ? const KeyboardAvoidingBar(child: bar)
            : bar,
      ),
    );
  }

  Future<double> barBottomWithKeyboard(
    WidgetTester tester, {
    required bool avoiding,
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(avoiding: avoiding));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    return tester.getRect(find.text('BAR')).bottom;
  }

  testWidgets('a plain bottom bar is covered by the keyboard', (tester) async {
    final bottom = await barBottomWithKeyboard(tester, avoiding: false);
    expect(bottom, greaterThan(800 - 300)); // inside the keyboard area
  });

  testWidgets('KeyboardAvoidingBar stays above the keyboard', (tester) async {
    final bottom = await barBottomWithKeyboard(tester, avoiding: true);
    expect(bottom, lessThanOrEqualTo(800 - 300));
  });

  testWidgets('without a keyboard the bar sits at the bottom edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(avoiding: true));

    expect(tester.getRect(find.text('BAR')).bottom, lessThanOrEqualTo(800));
    expect(tester.getRect(find.text('BAR')).bottom, greaterThan(800 - 100));
  });
}
