import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/controller/popup_controller.dart';
import 'package:quran_app/models/popup_model.dart';
import 'package:quran_app/widgets/popup_widget.dart';

/// Records what the app reports to the server instead of calling it.
class _FakePopupController extends PopupController {
  final events = <String>[];

  @override
  Future<void> recordView(int popupId) async => events.add('view:$popupId');
  @override
  Future<void> recordDismiss(int popupId) async =>
      events.add('dismiss:$popupId');
  @override
  Future<void> recordClick(int popupId) async => events.add('click:$popupId');
}

PopupData popup(
  int id, {
  String title = 'Promo',
  String? description,
  String? actionUrl,
  String? actionText,
  bool dismissible = true,
}) => PopupData.fromJson({
  'id': id,
  'title': title,
  'description': description,
  'action_url': actionUrl,
  'action_text': actionText,
  'type': 'promo',
  'is_dismissible': dismissible,
  'priority': 0,
});

void main() {
  group('PopupData', () {
    test('parses the full API payload', () {
      final p = PopupData.fromJson({
        'id': 7,
        'title': 'Halo',
        'description': 'Isi',
        'image': 'https://x.test/a.png',
        'action_url': '/charity',
        'action_text': 'Buka',
        'type': 'update',
        'is_dismissible': false,
        'frequency': 'every_launch',
        'show_once': false,
        'priority': 3,
      });

      expect(p.description, 'Isi');
      expect(p.frequency, 'every_launch');
      expect(p.isDismissible, false);
    });

    test(
      'an older server payload without description/frequency still parses',
      () {
        final once = PopupData.fromJson({
          'id': 1,
          'title': 'a',
          'show_once': true,
        });
        final repeat = PopupData.fromJson({'id': 2, 'title': 'b'});

        expect(once.description, isNull);
        expect(once.frequency, 'once');
        expect(repeat.frequency, 'daily');
        expect(repeat.isDismissible, true);
      },
    );
  });

  group('PopupWidget', () {
    late _FakePopupController controller;

    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      Get.testMode = true;
      PopupWidget.resetForTest();
      controller =
          Get.put<PopupController>(_FakePopupController())
              as _FakePopupController;
    });
    tearDown(Get.reset);

    Future<void> launch(WidgetTester tester, List<PopupData> popups) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      controller.popups.assignAll(popups);
      await tester.pumpWidget(
        GetMaterialApp(
          home: const Scaffold(body: SizedBox()),
          getPages: [
            GetPage(
              name: '/x',
              page: () => const Scaffold(body: Text('PAGE X')),
            ),
          ],
        ),
      );
      PopupWidget.showPopups();
      await tester.pump(); // builds the dialog route
      await tester.pump(const Duration(milliseconds: 600)); // pop-in done
      tester.takeException(); // Google Fonts cannot load offline.
    }

    /// Lets the close animation and the 500ms delay before the next popup elapse.
    Future<void> settle(WidgetTester tester) async {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      tester.takeException();
    }

    testWidgets(
      'shows title, description, default CTA label and records the view',
      (tester) async {
        await launch(tester, [
          popup(
            1,
            title: 'Promo Ramadan',
            description: 'Diskon besar',
            actionUrl: '/x',
          ),
        ]);

        expect(find.text('Promo Ramadan'), findsOneWidget);
        expect(find.text('Diskon besar'), findsOneWidget);
        expect(find.text('Lihat Selengkapnya'), findsOneWidget);
        expect(find.text('Nanti saja'), findsOneWidget);
        expect(controller.events, ['view:1']);
      },
    );

    testWidgets(
      'a custom CTA label is used, and no CTA means a plain "Tutup"',
      (tester) async {
        await launch(tester, [
          popup(1, actionUrl: '/x', actionText: 'Buka Sekarang'),
        ]);
        expect(find.text('Buka Sekarang'), findsOneWidget);
      },
    );

    testWidgets('without a link there is no CTA button, only "Tutup"', (
      tester,
    ) async {
      await launch(tester, [popup(1, actionText: 'Tidak ada tautan')]);

      expect(find.text('Tidak ada tautan'), findsNothing);
      expect(find.text('Tutup'), findsOneWidget);
    });

    testWidgets('dismissing records it and moves on to the next popup', (
      tester,
    ) async {
      await launch(tester, [popup(1, title: 'Satu'), popup(2, title: 'Dua')]);

      await tester.tap(find.text('Tutup'));
      await settle(tester);

      expect(find.text('Dua'), findsOneWidget);
      expect(controller.events, ['view:1', 'dismiss:1', 'view:2']);
    });

    testWidgets('tapping outside the card counts as a dismissal', (
      tester,
    ) async {
      await launch(tester, [popup(1, title: 'Satu')]);

      await tester.tapAt(const Offset(5, 5));
      await settle(tester);

      expect(find.text('Satu'), findsNothing);
      expect(controller.events, ['view:1', 'dismiss:1']);
    });

    testWidgets(
      'a non-dismissible popup has no close controls and ignores outside taps',
      (tester) async {
        await launch(tester, [
          popup(1, title: 'Wajib', actionUrl: '/x', dismissible: false),
        ]);

        expect(find.text('Nanti saja'), findsNothing);
        expect(find.byIcon(Icons.close_rounded), findsNothing);

        await tester.tapAt(const Offset(5, 5));
        await settle(tester);

        expect(find.text('Wajib'), findsOneWidget);
        expect(controller.events, ['view:1']);
      },
    );

    testWidgets(
      'tapping the CTA records a click, opens the link and stops the chain',
      (tester) async {
        await launch(tester, [
          popup(1, title: 'Satu', actionUrl: '/x'),
          popup(2, title: 'Dua'),
        ]);

        await tester.tap(find.text('Lihat Selengkapnya'));
        await settle(tester);

        expect(find.text('PAGE X'), findsOneWidget);
        expect(find.text('Dua'), findsNothing);
        expect(controller.events, ['view:1', 'click:1']);
      },
    );
  });
}
