import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_widgets.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/font.dart';

/// Plays a quiz session.
/// Route arguments: `{'lessonId': int, 'mode': ArabicQuizMode}`.
class ArabicQuizScreen extends StatefulWidget {
  const ArabicQuizScreen({super.key});

  @override
  State<ArabicQuizScreen> createState() => _ArabicQuizScreenState();
}

class _ArabicQuizScreenState extends State<ArabicQuizScreen> {
  // Owned here (not by a route binding) so replacing this route with another
  // quiz never shares or prematurely deletes the controller.
  late final String _tag = UniqueKey().toString();
  late final ArabicQuizController c;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map;
    c = Get.put(
      ArabicQuizController(
        lessonId: args['lessonId'] as int,
        mode: args['mode'] as ArabicQuizMode,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ArabicQuizController>(tag: _tag);
    super.dispose();
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar dari kuis?', style: pSemiBold16),
        content: Text(
          'Jawaban yang belum dikirim tidak akan tersimpan.',
          style: pRegular12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Lanjut Belajar', style: pSemiBold14),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: pSemiBold14.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (leave == true) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Obx(() {
      final inProgress =
          !c.isLoading.value && c.quizzes.isNotEmpty && !c.isFinished;
      final color = arabicColor(c.lessonColor.value);

      return PopScope(
        canPop: !inProgress || c.results.isEmpty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmExit();
        },
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(LucideIcons.x, color: colorScheme.onSurface),
              onPressed: () => inProgress && c.results.isNotEmpty
                  ? _confirmExit()
                  : Get.back(),
            ),
            title: inProgress ? _ProgressBar(c: c, color: color) : null,
            actions: [
              if (inProgress) _ModeBadge(c: c),
              const SizedBox(width: 12),
            ],
          ),
          body: _body(context, color),
        ),
      );
    });
  }

  Widget _body(BuildContext context, Color color) {
    final colorScheme = context.theme.colorScheme;

    if (c.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 3, color: color),
      );
    }

    if (c.submitResult.value != null) {
      return _SubmitResultView(c: c, color: color);
    }
    if (c.practiceFinished.value) {
      return _PracticeResultView(c: c, color: color);
    }

    if (c.quizzes.isEmpty) {
      final review = c.mode.value == ArabicQuizMode.review;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  review ? LucideIcons.partyPopper : LucideIcons.fileQuestion,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                review
                    ? 'Tidak ada soal yang perlu diulang'
                    : 'Belum ada pertanyaan',
                style: pBold16,
              ),
              const SizedBox(height: 4),
              Text(
                review
                    ? 'Semua soal sudah kamu jawab dengan benar.'
                    : 'Soal untuk pelajaran ini sedang disiapkan.',
                style: pMedium12.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final quiz = c.current!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ArabicQuestionView(
              // A new key per question resets per-question state.
              key: ValueKey(quiz.id),
              controller: c,
              quiz: quiz,
              color: color,
            ),
          ),
        ),
        _BottomBar(c: c, quiz: quiz),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final ArabicQuizController c;
  final Color color;
  const _ProgressBar({required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Obx(() {
      final total = c.quizzes.length;
      // Counts answered questions so the bar is full only after the last check.
      final done = total == 0 ? 0.0 : c.results.length / total;
      final position = total == 0 ? 0 : (c.index.value + 1).clamp(1, total);
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: done),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$position/$total',
            style: pBold12.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    });
  }
}

class _ModeBadge extends StatelessWidget {
  final ArabicQuizController c;
  const _ModeBadge({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final limited =
          (c.current?.timeLimit ?? 0) > 0 && c.currentResult == null;
      if (limited) {
        final low = c.secondsLeft.value <= 5;
        return ArabicChip(
          label: '${c.secondsLeft.value}s',
          icon: LucideIcons.timer,
          color: low ? Colors.red : Colors.orange.shade700,
        );
      }
      final (label, icon) = switch (c.mode.value) {
        ArabicQuizMode.practice => ('Latihan', LucideIcons.dumbbell),
        ArabicQuizMode.review => ('Ulangi', LucideIcons.rotateCcw),
        ArabicQuizMode.main => ('Kuis', LucideIcons.listChecks),
      };
      return ArabicChip(
        label: label,
        icon: icon,
        color: context.theme.colorScheme.primary,
      );
    });
  }
}

class _BottomBar extends StatelessWidget {
  final ArabicQuizController c;
  final ArabicQuiz quiz;

  const _BottomBar({required this.c, required this.quiz});

  @override
  Widget build(BuildContext context) => Obx(() => _bar(context));

  Widget _bar(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final result = c.results[quiz.id];
    final checked = result != null;
    final busy = c.isChecking.value || c.isSubmitting.value;
    final enabled = !busy && (checked || c.hasAnswer(quiz));
    final base = arabicColor(c.lessonColor.value);
    final tone = !checked
        ? base
        : result.isCorrect
        ? const Color(0xFF2E9E5B)
        : const Color(0xFFD64545);

    final label = !checked
        ? 'Periksa'
        : c.isLast
        ? (c.mode.value == ArabicQuizMode.practice
              ? 'Selesai'
              : 'Kirim Jawaban')
        : 'Lanjut';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (checked) ...[
                ArabicFeedback(quiz: quiz, result: result),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: enabled ? (checked ? c.next : c.check) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: tone,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          label,
                          style: pBold14.copyWith(
                            color: enabled
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Result views ──────────────────────────────────────────────────────────

/// Gradient hero (icon, title, [headline]) followed by [body] and pinned [actions].
class _ResultScaffold extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget headline;
  final List<Widget> body;
  final List<Widget> actions;

  const _ResultScaffold({
    required this.icon,
    required this.color,
    required this.title,
    required this.headline,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ArabicReveal(
                      child: ArabicGradientCard(
                        color: color,
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(icon, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: pBold20.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            headline,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < body.length; i++)
                      ArabicReveal(delay: i + 1, child: body[i]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: arabicCardDecoration(context, accent: color, radius: 18),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: pBold18.copyWith(color: color)),
            Text(
              label,
              style: pMedium10.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Big score number that counts up from 0.
class _ScoreText extends StatelessWidget {
  final int score;
  const _ScoreText(this.score);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(
        '$v',
        style: pBold24.copyWith(color: Colors.white, fontSize: 48, height: 1.1),
      ),
    );
  }
}

Widget _primaryButton(
  String label,
  VoidCallback onTap, {
  Color? color,
  IconData? icon,
}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(label, style: pBold14.copyWith(color: Colors.white)),
        ],
      ),
    ),
  );
}

Widget _secondaryButton(String label, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: pSemiBold14),
    ),
  );
}

/// End of a practice run: local tally only, nothing was saved.
class _PracticeResultView extends StatelessWidget {
  final ArabicQuizController c;
  final Color color;
  const _PracticeResultView({required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    final total = c.quizzes.length;
    final correct = c.correctCount;
    final pct = total == 0 ? 0 : (correct * 100 / total).round();

    return _ResultScaffold(
      icon: LucideIcons.dumbbell,
      color: color,
      title: 'Latihan Selesai!',
      headline: Column(
        children: [
          _ScoreText(pct),
          Text(
            '$correct dari $total soal benar',
            style: pMedium12.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      body: [
        Row(
          children: [
            _Stat(
              icon: LucideIcons.circleCheck,
              label: 'Benar',
              value: '$correct',
              color: const Color(0xFF2E9E5B),
            ),
            const SizedBox(width: 12),
            _Stat(
              icon: LucideIcons.circleX,
              label: 'Salah',
              value: '${total - correct}',
              color: const Color(0xFFD64545),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Latihan tidak mempengaruhi nilai dan XP. Siap mengerjakan kuis utama?',
            style: pMedium12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
      actions: [
        _primaryButton(
          'Mulai Kuis Utama',
          () => c.start(ArabicQuizMode.main),
          color: color,
          icon: LucideIcons.play,
        ),
        _secondaryButton(
          'Ulangi Latihan',
          () => c.start(ArabicQuizMode.practice),
        ),
        _secondaryButton('Kembali ke Pelajaran', Get.back),
      ],
    );
  }
}

/// End of a main/review run: the server's verdict.
class _SubmitResultView extends StatelessWidget {
  final ArabicQuizController c;
  final Color color;
  const _SubmitResultView({required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    final r = c.submitResult.value!;
    final scheme = context.theme.colorScheme;

    final String title;
    final IconData icon;
    final Color tone;
    if (r.justCompleted) {
      title = 'Pelajaran Selesai!';
      icon = LucideIcons.trophy;
      tone = const Color(0xFFD99A06);
    } else if (r.reviewRequired) {
      title = 'Ayo perbaiki yang salah';
      icon = LucideIcons.rotateCcw;
      tone = Colors.orange.shade800;
    } else if (r.completed) {
      title = 'Bagus, tetap berlatih!';
      icon = LucideIcons.badgeCheck;
      tone = const Color(0xFF2E9E5B);
    } else {
      title = 'Belum lulus';
      icon = LucideIcons.flag;
      tone = Colors.orange.shade800;
    }

    final actions = <Widget>[
      if (r.reviewRequired)
        _primaryButton(
          'Ulangi Soal yang Salah',
          () => c.start(ArabicQuizMode.review),
          color: Colors.orange.shade700,
          icon: LucideIcons.rotateCcw,
        )
      else if (r.justCompleted && r.nextLessonId != null)
        _primaryButton(
          'Pelajaran Berikutnya',
          () {
            Get.back();
            Get.offNamed(Routes.arabicLessonDetail, arguments: r.nextLessonId);
          },
          color: color,
          icon: LucideIcons.arrowRight,
        )
      else if (!r.passed)
        _primaryButton(
          'Kerjakan Kuis Lagi',
          () => c.start(ArabicQuizMode.main),
          color: color,
          icon: LucideIcons.play,
        ),
      _secondaryButton('Kembali ke Pelajaran', Get.back),
    ];

    return _ResultScaffold(
      icon: icon,
      color: tone,
      title: title,
      headline: Column(
        children: [
          _ScoreText(r.mode == 'review' ? r.bestScore : r.score),
          Text(
            r.mode == 'review'
                ? 'nilai terbaik • lulus di ${r.passScore}'
                : r.passed
                ? 'skor • memenuhi nilai lulus (${r.passScore})'
                : 'skor • nilai lulus ${r.passScore}',
            style: pMedium12.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      body: [
        Row(
          children: [
            _Stat(
              icon: LucideIcons.circleCheck,
              label: 'Benar',
              value: '${r.correctCount}',
              color: const Color(0xFF2E9E5B),
            ),
            const SizedBox(width: 12),
            _Stat(
              icon: LucideIcons.circleX,
              label: 'Salah',
              value: '${r.wrongCount}',
              color: const Color(0xFFD64545),
            ),
            const SizedBox(width: 12),
            _Stat(
              icon: LucideIcons.zap,
              label: 'XP didapat',
              value: '+${r.xpAwarded}',
              color: Colors.amber.shade800,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Total XP kamu: ${r.totalXp}',
            style: pSemiBold12.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
        if (r.reviewRequired)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'Jawab benar semua soal yang salah untuk menyelesaikan pelajaran ini.',
              style: pMedium12.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        if (r.justCompleted &&
            r.motivationMessage != null &&
            r.motivationMessage!.trim().isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.motivationMessage!,
                    style: pMedium12.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        if (r.levelCompleted)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Center(
              child: ArabicChip(
                label: 'Level selesai!',
                icon: LucideIcons.medal,
                color: const Color(0xFF2E9E5B),
              ),
            ),
          ),
      ],
      actions: actions,
    );
  }
}
