import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_quiz_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/font.dart';

bool _containsArabic(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);

/// Ids selected by a user answer or named by a correct answer (choice types).
Set<String> _ids(dynamic value) {
  if (value == null) return {};
  if (value is List) return value.map((e) => e.toString()).toSet();
  return {value.toString()};
}

const _good = Color(0xFF2E9E5B);
const _bad = Color(0xFFD64545);

/// One question: prompt, media and the answer area for its type.
class ArabicQuestionView extends StatelessWidget {
  final ArabicQuizController controller;
  final ArabicQuiz quiz;
  final Color color;

  const ArabicQuestionView({
    super.key,
    required this.controller,
    required this.quiz,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Prompt(
          quiz: quiz,
          color: color,
          position: controller.index.value + 1,
          total: controller.quizzes.length,
        ),
        const SizedBox(height: 20),
        Obx(() {
          final answer = controller.answers[quiz.id];
          final result = controller.results[quiz.id];
          switch (quiz.type) {
            case ArabicQuizType.multipleSelect:
            case ArabicQuizType.multipleChoice:
            case ArabicQuizType.fillBlank:
            case ArabicQuizType.trueFalse:
              return _ChoiceList(
                quiz: quiz,
                answer: answer,
                result: result,
                color: color,
                onChanged: (value) => controller.setAnswer(quiz, value),
              );
            case ArabicQuizType.shortAnswer:
              return _ShortAnswer(
                key: ValueKey(quiz.id),
                locked: result != null,
                color: color,
                onChanged: (value) => controller.setAnswer(quiz, value),
              );
            case ArabicQuizType.matching:
              return _Matching(
                key: ValueKey(quiz.id),
                quiz: quiz,
                pairs: answer is Map ? Map<String, String>.from(answer) : {},
                result: result,
                onChanged: (value) => controller.setAnswer(quiz, value),
              );
            case ArabicQuizType.ordering:
              return _Ordering(
                quiz: quiz,
                order: answer is List ? List<String>.from(answer) : [],
                result: result,
                color: color,
                onChanged: (value) => controller.setAnswer(quiz, value),
              );
            default:
              return Text(
                'Jenis soal ini belum didukung. Perbarui aplikasi.',
                style: pRegular12,
              );
          }
        }),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  final ArabicQuiz quiz;
  final Color color;
  final int position;
  final int total;
  const _Prompt({
    required this.quiz,
    required this.color,
    required this.position,
    required this.total,
  });

  /// Same names the admin question builder uses.
  String get _typeLabel => switch (quiz.type) {
    ArabicQuizType.multipleChoice => 'Pilihan Ganda',
    ArabicQuizType.multipleSelect => 'Banyak Jawaban',
    ArabicQuizType.trueFalse => 'Benar / Salah',
    ArabicQuizType.shortAnswer => 'Isian Singkat',
    ArabicQuizType.matching => 'Menjodohkan',
    ArabicQuizType.ordering => 'Susun Urutan',
    ArabicQuizType.fillBlank => 'Lengkapi Kalimat',
    _ => 'Soal',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final hasArabic = quiz.arabicText != null && quiz.arabicText!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: arabicCardDecoration(context, accent: color, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SOAL $position/$total',
                style: pBold10.copyWith(color: color, letterSpacing: 1.1),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ArabicChip(label: _typeLabel, color: color),
                    if (quiz.points > 0)
                      ArabicChip(
                        label: '${quiz.points} poin',
                        icon: LucideIcons.zap,
                        color: Colors.amber.shade800,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (quiz.image != null) ...[
            const SizedBox(height: 14),
            ArabicImage(url: quiz.image!, height: 180),
          ],
          if (hasArabic) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                quiz.arabicText!,
                style: arabicTextStyle(size: 30, color: color),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
          if (quiz.question.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              quiz.question,
              style: pBold16.copyWith(height: 1.4, color: scheme.onSurface),
            ),
          ],
          if (quiz.audio != null) ...[
            const SizedBox(height: 14),
            ArabicAudioButton(url: quiz.audio!, color: color, size: 44),
          ],
        ],
      ),
    );
  }
}

// ─── Choice types ──────────────────────────────────────────────────────────

class _ChoiceList extends StatelessWidget {
  final ArabicQuiz quiz;
  final dynamic answer;
  final ArabicAnswerResult? result;
  final Color color;
  final ValueChanged<dynamic> onChanged;

  const _ChoiceList({
    required this.quiz,
    required this.answer,
    required this.result,
    required this.color,
    required this.onChanged,
  });

  bool get _multi => quiz.type == ArabicQuizType.multipleSelect;
  bool get _isBool => quiz.type == ArabicQuizType.trueFalse;

  void _tap(String id) {
    if (result != null) return;
    if (_multi) {
      final selected = _ids(answer);
      selected.contains(id) ? selected.remove(id) : selected.add(id);
      onChanged(selected.toList());
    } else {
      onChanged(_isBool ? id == 'true' : id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _ids(answer);
    final correct = result == null ? <String>{} : _ids(result!.correctAnswer);

    return Column(
      children: [
        if (_multi)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Pilih semua jawaban yang benar',
              style: pMedium12.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (var i = 0; i < quiz.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              option: quiz.options[i],
              letter: _multi ? null : String.fromCharCode(65 + i),
              multi: _multi,
              color: color,
              state: _stateOf(quiz.options[i].id, selected, correct),
              onTap: () => _tap(quiz.options[i].id),
            ),
          ),
      ],
    );
  }

  _TileState _stateOf(String id, Set<String> selected, Set<String> correct) {
    if (result == null) {
      return selected.contains(id) ? _TileState.selected : _TileState.idle;
    }
    if (correct.contains(id)) return _TileState.correct;
    if (selected.contains(id)) return _TileState.wrong;
    return _TileState.dimmed;
  }
}

enum _TileState { idle, selected, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  final ArabicOption option;
  final String? letter;
  final _TileState state;
  final bool multi;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    this.letter,
    required this.state,
    required this.multi,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    Color border = colorScheme.outlineVariant.withValues(alpha: 0.4);
    Color fill = isDark ? colorScheme.surfaceContainer : Colors.white;
    Color text = colorScheme.onSurface;
    IconData? trailing;

    switch (state) {
      case _TileState.selected:
        border = color;
        fill = color.withValues(alpha: 0.1);
      case _TileState.correct:
        border = _good;
        fill = _good.withValues(alpha: 0.12);
        trailing = LucideIcons.circleCheck;
      case _TileState.wrong:
        border = _bad;
        fill = _bad.withValues(alpha: 0.1);
        trailing = LucideIcons.circleX;
      case _TileState.dimmed:
        text = colorScheme.onSurface.withValues(alpha: 0.4);
      case _TileState.idle:
        break;
    }

    final label = option.text ?? '';
    final accent = state == _TileState.wrong
        ? _bad
        : state == _TileState.correct
        ? _good
        : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
            width: state == _TileState.idle || state == _TileState.dimmed
                ? 1
                : 2,
          ),
        ),
        child: Row(
          children: [
            if (letter != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: state == _TileState.dimmed
                      ? Colors.transparent
                      : accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: accent.withValues(
                      alpha: state == _TileState.dimmed ? 0.2 : 0.5,
                    ),
                  ),
                ),
                child: Text(
                  letter!,
                  style: pBold12.copyWith(
                    color: state == _TileState.dimmed ? text : accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (multi) ...[
              Icon(
                state == _TileState.selected ||
                        state == _TileState.correct ||
                        state == _TileState.wrong
                    ? LucideIcons.squareCheck
                    : LucideIcons.square,
                color: state == _TileState.dimmed ? text : accent,
                size: 22,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (option.image != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: label.isEmpty ? 0 : 8),
                      child: ArabicImage(
                        url: option.image!,
                        height: 90,
                        fit: BoxFit.contain,
                        radius: 8,
                      ),
                    ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: _containsArabic(label)
                          ? arabicTextStyle(size: 22, color: text)
                          : pSemiBold14.copyWith(color: text),
                      textAlign: _containsArabic(label)
                          ? TextAlign.center
                          : TextAlign.start,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, color: border),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Short answer ──────────────────────────────────────────────────────────

class _ShortAnswer extends StatelessWidget {
  final bool locked;
  final Color color;
  final ValueChanged<String> onChanged;

  const _ShortAnswer({
    super.key,
    required this.locked,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: !locked,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      style: pSemiBold16,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Ketik jawabanmu',
        hintStyle: pRegular14.copyWith(
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}

// ─── Matching ──────────────────────────────────────────────────────────────

const _pairColors = [
  Color(0xFF3B82F6),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
  Color(0xFFF97316),
];

/// Tap an item on the left, then its partner on the right.
class _Matching extends StatefulWidget {
  final ArabicQuiz quiz;
  final Map<String, String> pairs; // left id -> right id
  final ArabicAnswerResult? result;
  final ValueChanged<Map<String, String>> onChanged;

  const _Matching({
    super.key,
    required this.quiz,
    required this.pairs,
    required this.result,
    required this.onChanged,
  });

  @override
  State<_Matching> createState() => _MatchingState();
}

class _MatchingState extends State<_Matching> {
  String? _selectedLeft;

  bool get _locked => widget.result != null;

  Color _colorOf(String leftId) =>
      _pairColors[widget.quiz.left.indexWhere((o) => o.id == leftId) %
          _pairColors.length];

  void _tapLeft(String id) {
    if (_locked) return;
    setState(() => _selectedLeft = _selectedLeft == id ? null : id);
  }

  void _tapRight(String id) {
    if (_locked) return;
    final pairs = Map<String, String>.from(widget.pairs);
    final owner = pairs.entries.where((e) => e.value == id).firstOrNull?.key;

    if (_selectedLeft == null) {
      // Tapping a paired item without a selection unpairs it.
      if (owner != null) {
        pairs.remove(owner);
        widget.onChanged(pairs);
      }
      return;
    }
    if (owner != null) pairs.remove(owner);
    pairs[_selectedLeft!] = id;
    widget.onChanged(pairs);
    setState(() => _selectedLeft = null);
  }

  /// Right-side id the user paired with [leftId]'s pair, if any.
  String? _leftOfRight(String rightId) =>
      widget.pairs.entries.where((e) => e.value == rightId).firstOrNull?.key;

  @override
  Widget build(BuildContext context) {
    final correct = widget.result?.correctAnswer;
    bool pairIsRight(String leftId) =>
        correct is Map && correct[leftId]?.toString() == widget.pairs[leftId];

    return Column(
      children: [
        Text(
          _locked
              ? ' '
              : 'Pilih item di kiri, lalu pasangannya di kanan. Ketuk pasangan untuk melepasnya.',
          style: pRegular12.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final left in widget.quiz.left)
                    _MatchTile(
                      option: left,
                      color:
                          widget.pairs.containsKey(left.id) ||
                              _selectedLeft == left.id
                          ? _colorOf(left.id)
                          : null,
                      active: _selectedLeft == left.id,
                      verdict: _locked && widget.pairs.containsKey(left.id)
                          ? pairIsRight(left.id)
                          : null,
                      onTap: () => _tapLeft(left.id),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  for (final right in widget.quiz.right)
                    Builder(
                      builder: (_) {
                        final owner = _leftOfRight(right.id);
                        return _MatchTile(
                          option: right,
                          color: owner == null ? null : _colorOf(owner),
                          active: false,
                          verdict: _locked && owner != null
                              ? pairIsRight(owner)
                              : null,
                          onTap: () => _tapRight(right.id),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final ArabicOption option;
  final Color? color; // pair colour, null when unpaired
  final bool active;
  final bool? verdict; // set after checking
  final VoidCallback onTap;

  const _MatchTile({
    required this.option,
    required this.color,
    required this.active,
    required this.verdict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final border = verdict != null
        ? (verdict! ? _good : _bad)
        : color ?? colorScheme.outlineVariant.withValues(alpha: 0.5);
    final label = option.text ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color != null || verdict != null
                ? border.withValues(alpha: 0.12)
                : isDark
                ? colorScheme.surfaceContainer
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: color != null || active ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (option.image != null)
                Padding(
                  padding: EdgeInsets.only(bottom: label.isEmpty ? 0 : 6),
                  child: ArabicImage(
                    url: option.image!,
                    height: 56,
                    fit: BoxFit.contain,
                    radius: 8,
                  ),
                ),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: _containsArabic(label)
                      ? arabicTextStyle(size: 20)
                      : pSemiBold12,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ordering ──────────────────────────────────────────────────────────────

class _Ordering extends StatelessWidget {
  final ArabicQuiz quiz;
  final List<String> order;
  final ArabicAnswerResult? result;
  final Color color;
  final ValueChanged<List<String>> onChanged;

  const _Ordering({
    required this.quiz,
    required this.order,
    required this.result,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final byId = {for (final o in quiz.options) o.id: o};
    final locked = result != null;
    final border = locked
        ? (result!.isCorrect ? _good : _bad)
        : color.withValues(alpha: 0.5);

    return Column(
      children: [
        Text(
          'Seret untuk menyusun urutan yang benar',
          style: pRegular12.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (locked) return;
            final next = List<String>.from(order);
            if (newIndex > oldIndex) newIndex--;
            next.insert(newIndex, next.removeAt(oldIndex));
            onChanged(next);
          },
          children: [
            for (var i = 0; i < order.length; i++)
              Container(
                key: ValueKey(order[i]),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: locked
                      ? border.withValues(alpha: 0.1)
                      : isDark
                      ? colorScheme.surfaceContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: locked ? 2 : 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        '${i + 1}',
                        style: pBold12.copyWith(color: color),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _OrderLabel(option: byId[order[i]])),
                    if (!locked)
                      ReorderableDragStartListener(
                        index: i,
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OrderLabel extends StatelessWidget {
  final ArabicOption? option;
  const _OrderLabel({required this.option});

  @override
  Widget build(BuildContext context) {
    final label = option?.text ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (option?.image != null)
          Padding(
            padding: EdgeInsets.only(bottom: label.isEmpty ? 0 : 6),
            child: ArabicImage(
              url: option!.image!,
              height: 60,
              fit: BoxFit.contain,
              radius: 8,
            ),
          ),
        if (label.isNotEmpty)
          Text(
            label,
            style: _containsArabic(label)
                ? arabicTextStyle(size: 20)
                : pSemiBold14,
          ),
      ],
    );
  }
}

// ─── Feedback ──────────────────────────────────────────────────────────────

/// Banner shown after a question is checked: verdict, correct answer, explanation.
class ArabicFeedback extends StatelessWidget {
  final ArabicQuiz quiz;
  final ArabicAnswerResult result;

  const ArabicFeedback({super.key, required this.quiz, required this.result});

  String? _correctAnswerText() {
    final correct = result.correctAnswer;
    String optionText(List<ArabicOption> list, String id) =>
        list.where((o) => o.id == id).firstOrNull?.text ?? '';

    switch (quiz.type) {
      case ArabicQuizType.shortAnswer:
        return correct is List ? correct.join(' / ') : correct?.toString();
      case ArabicQuizType.matching:
        if (correct is! Map) return null;
        return correct.entries
            .map(
              (e) =>
                  '${optionText(quiz.left, e.key.toString())} — '
                  '${optionText(quiz.right, e.value.toString())}',
            )
            .join('\n');
      case ArabicQuizType.ordering:
        if (correct is! List) return null;
        return [
          for (var i = 0; i < correct.length; i++)
            '${i + 1}. ${optionText(quiz.options, correct[i].toString())}',
        ].join('\n');
      case ArabicQuizType.trueFalse:
        return correct == true ? 'Benar' : 'Salah';
      default:
        return _ids(correct)
            .map((id) => optionText(quiz.options, id))
            .where((t) => t.isNotEmpty)
            .join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ok = result.isCorrect;
    final color = ok ? _good : _bad;
    final answer = ok ? null : _correctAnswerText();
    final hasExplanation =
        result.explanation != null && result.explanation!.trim().isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ok ? LucideIcons.circleCheck : LucideIcons.circleX,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  ok ? 'Benar!' : 'Kurang tepat',
                  style: pBold14.copyWith(color: color),
                ),
              ],
            ),
            if (answer != null && answer.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Jawaban yang benar:', style: pSemiBold12),
              const SizedBox(height: 2),
              Text(answer, style: pRegular12.copyWith(height: 1.5)),
            ],
            if (hasExplanation) ...[
              const SizedBox(height: 8),
              Text(
                result.explanation!,
                style: pRegular12.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
