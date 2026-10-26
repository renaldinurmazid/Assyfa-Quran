import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_widgets.dart';

/// Skips the network: questions are injected from a real API response.
class _OfflineQuizController extends ArabicQuizController {
  _OfflineQuizController() : super(lessonId: 1, mode: ArabicQuizMode.main);

  @override
  Future<void> load() async {}
}

void main() {
  late _OfflineQuizController c;
  late Map<String, ArabicQuiz> byType;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;

    final json = jsonDecode(
      File('test/fixtures/arabic/quizzes.json').readAsStringSync(),
    );
    byType = {
      for (final q in json['quizzes']) q['type']: ArabicQuiz.fromJson(q),
    };
    c = Get.put(_OfflineQuizController());
    c.quizzes.value = byType.values.toList();
    c.isLoading.value = false;
  });

  tearDown(Get.reset);

  Future<void> show(WidgetTester tester, ArabicQuiz quiz) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ArabicQuestionView(
              controller: c,
              quiz: quiz,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }

  // Google Fonts without the bundled font file reports an error but still renders.
  void ignoreFontErrors(WidgetTester tester) => tester.takeException();

  testWidgets('multiple choice stores the chosen option id', (tester) async {
    final quiz = byType[ArabicQuizType.multipleChoice]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    expect(c.hasAnswer(quiz), false);
    await tester.tap(find.text('Pena'));
    await tester.pump();

    expect(c.answers[quiz.id], 'b');
    expect(c.hasAnswer(quiz), true);
  });

  testWidgets('multiple select toggles ids in a list', (tester) async {
    final quiz = byType[ArabicQuizType.multipleSelect]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text('C'));
    await tester.pump();
    expect(c.answers[quiz.id], unorderedEquals(['1', '3']));

    await tester.tap(find.text('A'));
    await tester.pump();
    expect(c.answers[quiz.id], ['3']);
  });

  testWidgets('true/false stores a bool', (tester) async {
    final quiz = byType[ArabicQuizType.trueFalse]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    await tester.tap(find.text('Salah'));
    await tester.pump();
    expect(c.answers[quiz.id], false);
  });

  testWidgets('short answer stores the typed text', (tester) async {
    final quiz = byType[ArabicQuizType.shortAnswer]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    await tester.enterText(find.byType(TextField), 'buku');
    expect(c.answers[quiz.id], 'buku');
    expect(c.hasAnswer(quiz), true);
  });

  testWidgets('matching pairs a left item with a right item', (tester) async {
    final quiz = byType[ArabicQuizType.matching]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    await tester.tap(find.text('كتاب'));
    await tester.pump();
    await tester.tap(find.text('buku'));
    await tester.pump();
    expect(c.answers[quiz.id], {'1': '1'});
    expect(c.hasAnswer(quiz), false); // one pair still open

    await tester.tap(find.text('قلم'));
    await tester.pump();
    await tester.tap(find.text('pena'));
    await tester.pump();
    expect(c.answers[quiz.id], {'1': '1', '2': '2'});
    expect(c.hasAnswer(quiz), true);

    // Tapping a paired right item with nothing selected unpairs it.
    await tester.tap(find.text('buku'));
    await tester.pump();
    expect(c.answers[quiz.id], {'2': '2'});
  });

  testWidgets('ordering lists every item and starts from the shuffled order', (
    tester,
  ) async {
    final quiz = byType[ArabicQuizType.ordering]!;
    c.answers[quiz.id] = quiz.options.map((o) => o.id).toList();
    await show(tester, quiz);
    ignoreFontErrors(tester);

    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Dua'), findsOneWidget);
    expect(find.text('Tiga'), findsOneWidget);
    expect(c.hasAnswer(quiz), true);
  });

  testWidgets('fill in the blank shows the Arabic sentence and options', (
    tester,
  ) async {
    final quiz = byType[ArabicQuizType.fillBlank]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    expect(find.text('هذا ___'), findsOneWidget);
    await tester.tap(find.text('كتاب'));
    await tester.pump();
    expect(c.answers[quiz.id], 'a');
  });

  testWidgets('answers are locked once the question was checked', (
    tester,
  ) async {
    final quiz = byType[ArabicQuizType.multipleChoice]!;
    await show(tester, quiz);
    ignoreFontErrors(tester);

    await tester.tap(find.text('Buku'));
    await tester.pump();
    c.results[quiz.id] = ArabicAnswerResult(
      quizId: quiz.id,
      isCorrect: true,
      correctAnswer: 'a',
    );
    await tester.tap(find.text('Pena'));
    await tester.pump();

    expect(c.answers[quiz.id], 'a');
  });
}
