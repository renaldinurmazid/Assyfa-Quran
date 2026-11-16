import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/memorize_quran/level_detail_controller.dart';
import 'package:quran_app/models/memorization_detail_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class LevelDetailScreen extends StatelessWidget {
  const LevelDetailScreen({super.key});

  static const _accent = Color(0xFF20C997);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LevelDetailController());
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : AppColor.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          if (c.levelDetail.value == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('Gagal memuat data', style: pSemiBold16),
                ],
              ),
            );
          }

          final q = c.currentQuestion;
          if (q == null) return const SizedBox.shrink();

          return Column(
            children: [
              _buildHeader(context, c, isDark),
              Expanded(child: _buildBody(context, c, q, isDark)),
              _buildBottomButton(context, c, q, isDark),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LevelDetailController c,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Obx(
                () => LinearProgressIndicator(
                  value: c.progressValue,
                  minHeight: 12,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: _accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Text(
              '${c.currentStep.value + 1}/${c.totalSteps.value}',
              style: pMedium12.copyWith(
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LevelDetailController c,
    MemorizationQuestion q,
    bool isDark,
  ) {
    switch (q.type) {
      case 'info':
        return _buildInfoStep(context, q, isDark);
      case 'word-translation':
        return _buildWordTranslation(context, c, q, isDark);
      case 'word-scramble':
        return _buildWordScramble(context, c, q, isDark);
      case 'matching':
        return _buildMatching(context, c, q, isDark);
      default:
        return Center(
          child: Text('Tipe tidak dikenal: ${q.type}', style: pRegular14),
        );
    }
  }

  // ═══════════════════════════════════════
  // INFO STEP
  // ═══════════════════════════════════════
  Widget _buildInfoStep(
    BuildContext context,
    MemorizationQuestion q,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              q.arabic != null
                  ? Icons.auto_stories_rounded
                  : Icons.info_outline_rounded,
              color: _accent,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            q.title,
            style: pSemiBold20.copyWith(
              color: isDark ? Colors.white : AppColor.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (q.arabic != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                q.arabic!,
                style: const TextStyle(
                  fontFamily: 'LPMQ',
                  fontSize: 36,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            q.content,
            style: pRegular14.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (q.word != null) ...[
            const SizedBox(height: 24),
            _buildWordInfoCard(q.word!, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildWordInfoCard(MemorizationWord word, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.transliteration,
                    style: pSemiBold16.copyWith(color: _accent),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.translation,
                    style: pRegular12.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${word.occurrenceCount}x',
                  style: pMedium10.copyWith(color: _accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // WORD-TRANSLATION
  // ═══════════════════════════════════════
  Widget _buildWordTranslation(
    BuildContext context,
    LevelDetailController c,
    MemorizationQuestion q,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            q.title,
            style: pSemiBold18.copyWith(
              color: isDark ? Colors.white : AppColor.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            q.content,
            style: pRegular12.copyWith(
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          if (q.arabic != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHighlightedArabic(q.arabic!, q.highlightedWord, isDark),
                  if (q.reference != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      q.reference!,
                      style: pMedium10.copyWith(color: _accent),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...q.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            return Obx(() => _buildOptionTile(c, opt, idx, isDark));
          }),
        ],
      ),
    );
  }

  Widget _buildHighlightedArabic(
    String arabic,
    String? highlightedWord,
    bool isDark,
  ) {
    if (highlightedWord == null || highlightedWord.isEmpty) {
      return Text(
        arabic,
        style: const TextStyle(fontFamily: 'LPMQ', fontSize: 30, height: 1.8),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      );
    }

    final spans = <TextSpan>[];
    final regex = RegExp(RegExp.escape(highlightedWord));
    final matches = regex.allMatches(arabic);

    int lastMatchEnd = 0;
    for (final match in matches) {
      // Add text before match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: arabic.substring(lastMatchEnd, match.start),
            style: TextStyle(
              fontFamily: 'LPMQ',
              fontSize: 30,
              height: 1.8,
              color: isDark ? Colors.white : AppColor.textColor,
            ),
          ),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: arabic.substring(match.start, match.end),
          style: TextStyle(
            fontFamily: 'LPMQ',
            fontSize: 30,
            height: 1.8,
            color: _accent,
            backgroundColor: _accent.withValues(alpha: 0.1),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < arabic.length) {
      spans.add(
        TextSpan(
          text: arabic.substring(lastMatchEnd),
          style: TextStyle(
            fontFamily: 'LPMQ',
            fontSize: 30,
            height: 1.8,
            color: isDark ? Colors.white : AppColor.textColor,
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }

  Widget _buildOptionTile(
    LevelDetailController c,
    MemorizationOption opt,
    int idx,
    bool isDark,
  ) {
    final isSelected = c.selectedOptionId.value == opt.id;
    final answered = c.isAnswered.value;

    Color borderColor = isDark ? Colors.grey[800]! : const Color(0xFFE0E0E0);
    Color bgColor = isDark ? Colors.grey[900]! : Colors.white;

    if (answered && opt.isCorrect) {
      borderColor = _accent;
      bgColor = _accent.withValues(alpha: 0.08);
    } else if (answered && isSelected && !opt.isCorrect) {
      borderColor = Colors.redAccent;
      bgColor = Colors.redAccent.withValues(alpha: 0.08);
    } else if (isSelected) {
      borderColor = _accent;
      bgColor = _accent.withValues(alpha: 0.05);
    }

    return GestureDetector(
      onTap: () => c.selectOption(opt.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || (answered && opt.isCorrect) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx),
                  style: pSemiBold12.copyWith(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                opt.optionText,
                style: pMedium14.copyWith(
                  color: isDark ? Colors.white : AppColor.textColor,
                ),
              ),
            ),
            if (answered && opt.isCorrect)
              const Icon(Icons.check_circle_rounded, color: _accent, size: 22),
            if (answered && isSelected && !opt.isCorrect)
              const Icon(
                Icons.cancel_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // WORD-SCRAMBLE
  // ═══════════════════════════════════════
  Widget _buildWordScramble(
    BuildContext context,
    LevelDetailController c,
    MemorizationQuestion q,
    bool isDark,
  ) {
    // Initialize words on first build
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => c.initQuestionIfNeeded(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            q.title,
            style: pSemiBold18.copyWith(
              color: isDark ? Colors.white : AppColor.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            q.content,
            style: pRegular12.copyWith(
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          if (q.arabic != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    q.arabic!,
                    style: const TextStyle(
                      fontFamily: 'LPMQ',
                      fontSize: 28,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  if (q.reference != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      q.reference!,
                      style: pMedium10.copyWith(color: _accent),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Arranged area
          Text(
            'Susunan kamu:',
            style: pMedium12.copyWith(
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: c.isScrambleChecked.value
                      ? (c.isScrambleCorrect.value ? _accent : Colors.redAccent)
                      : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                  width: c.isScrambleChecked.value ? 2 : 1,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: c.arrangedWords.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => c.removeWordFromArrangement(entry.key),
                    child: _buildWordChip(entry.value, isDark, active: true),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Available words
          Text(
            'Kata tersedia:',
            style: pMedium12.copyWith(
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: c.availableWords.map((word) {
                return GestureDetector(
                  onTap: () => c.addWordToArrangement(word),
                  child: _buildWordChip(word, isDark, active: false),
                );
              }).toList(),
            ),
          ),
          // Feedback
          Obx(() {
            if (!c.isScrambleChecked.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.isScrambleCorrect.value
                      ? _accent.withValues(alpha: 0.08)
                      : Colors.redAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      c.isScrambleCorrect.value
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: c.isScrambleCorrect.value
                          ? _accent
                          : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.isScrambleCorrect.value
                            ? (q.explanation ?? 'Jawaban benar!')
                            : 'Jawaban: ${q.correctSequence?.join(' ') ?? ''}',
                        style: pRegular12.copyWith(
                          color: c.isScrambleCorrect.value
                              ? _accent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWordChip(String word, bool isDark, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? _accent.withValues(alpha: 0.1)
            : (isDark ? Colors.grey[800] : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? _accent
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
      child: Text(
        word,
        style: pMedium14.copyWith(
          color: active
              ? _accent
              : (isDark ? Colors.white : AppColor.textColor),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // MATCHING
  // ═══════════════════════════════════════
  Widget _buildMatching(
    BuildContext context,
    LevelDetailController c,
    MemorizationQuestion q,
    bool isDark,
  ) {
    final arabicList = q.options.map((o) => o.optionText).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            q.title,
            style: pSemiBold18.copyWith(
              color: isDark ? Colors.white : AppColor.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            q.content,
            style: pRegular12.copyWith(
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arabic column
              Expanded(
                child: Column(
                  children: arabicList.map((arabic) {
                    return Obx(() {
                      final isMatched = c.matchedPairs.containsKey(arabic);
                      final isSelected = c.selectedArabic.value == arabic;
                      return GestureDetector(
                        onTap: () => c.selectArabicWord(arabic),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? _accent.withValues(alpha: 0.08)
                                : isSelected
                                ? _accent.withValues(alpha: 0.12)
                                : (isDark ? Colors.grey[900] : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMatched
                                  ? _accent
                                  : isSelected
                                  ? _accent
                                  : (isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              arabic,
                              style: TextStyle(
                                fontFamily: 'LPMQ',
                                fontSize: 20,
                                color: isMatched
                                    ? _accent
                                    : (isDark
                                          ? Colors.white
                                          : AppColor.textColor),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Translation column
              Expanded(
                child: Column(
                  children: c.shuffledTranslations.map((translation) {
                    return Obx(() {
                      final isMatched = c.matchedPairs.containsValue(
                        translation,
                      );
                      final isIncorrect = c.incorrectMatch.value == translation;
                      return GestureDetector(
                        onTap: () => c.selectTranslation(translation),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? _accent.withValues(alpha: 0.08)
                                : isIncorrect
                                ? Colors.redAccent.withValues(alpha: 0.08)
                                : (isDark ? Colors.grey[900] : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMatched
                                  ? _accent
                                  : isIncorrect
                                  ? Colors.redAccent
                                  : (isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!),
                              width: isMatched || isIncorrect ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              translation,
                              style: pMedium14.copyWith(
                                color: isMatched
                                    ? _accent
                                    : (isDark
                                          ? Colors.white
                                          : AppColor.textColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ],
          ),
          Obx(() {
            if (!c.isMatchingComplete.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Semua cocok! Bagus sekali!',
                      style: pMedium12.copyWith(color: _accent),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // BOTTOM BUTTON
  // ═══════════════════════════════════════
  Widget _buildBottomButton(
    BuildContext context,
    LevelDetailController c,
    MemorizationQuestion q,
    bool isDark,
  ) {
    return Obx(() {
      String label;
      VoidCallback? onPressed;
      bool isEnabled;

      switch (q.type) {
        case 'info':
          label = c.currentStep.value < c.totalSteps.value - 1
              ? 'LANJUT'
              : 'SELESAI';
          isEnabled = true;
          onPressed = () => c.completeInfoStep();
          break;
        case 'word-translation':
          if (!c.isAnswered.value) {
            label = 'PERIKSA';
            isEnabled = c.selectedOptionId.value != null;
            onPressed = isEnabled ? () => c.checkAnswer() : null;
          } else {
            label = c.currentStep.value < c.totalSteps.value - 1
                ? 'LANJUT'
                : 'SELESAI';
            isEnabled = true;
            onPressed = () => c.nextStep();
          }
          break;
        case 'word-scramble':
          if (!c.isScrambleChecked.value) {
            final allPlaced =
                c.availableWords.isEmpty && c.arrangedWords.isNotEmpty;
            label = 'PERIKSA';
            isEnabled = allPlaced;
            onPressed = isEnabled ? () => c.checkScramble() : null;
          } else {
            label = c.currentStep.value < c.totalSteps.value - 1
                ? 'LANJUT'
                : 'SELESAI';
            isEnabled = true;
            onPressed = () => c.nextStep();
          }
          break;
        case 'matching':
          label = c.currentStep.value < c.totalSteps.value - 1
              ? 'LANJUT'
              : 'SELESAI';
          isEnabled = c.isMatchingComplete.value;
          onPressed = isEnabled ? () => c.nextStep() : null;
          break;
        default:
          label = 'LANJUT';
          isEnabled = true;
          onPressed = () => c.nextStep();
      }

      return Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? _accent
                  : (isDark ? Colors.grey[800] : const Color(0xFFE9ECEF)),
              foregroundColor: isEnabled ? Colors.white : Colors.blueGrey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: pSemiBold16.copyWith(
                color: isEnabled ? Colors.white : Colors.grey[400],
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      );
    });
  }
}
