import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';

class ArabicQuizScreen extends StatefulWidget {
  const ArabicQuizScreen({super.key});

  @override
  State<ArabicQuizScreen> createState() => _ArabicQuizScreenState();
}

class _ArabicQuizScreenState extends State<ArabicQuizScreen> {
  final ArabicQuranController controller = Get.find<ArabicQuranController>();
  late int lessonId;

  int currentIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  bool isCorrect = false;
  int totalXp = 0;
  int totalCorrect = 0;

  @override
  void initState() {
    super.initState();
    lessonId = Get.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchQuizzes(lessonId);
    });
  }

  void checkAnswer(String option) {
    if (isAnswered) return;

    final currentQuiz = controller.quizzes[currentIndex];
    setState(() {
      selectedOption = option;
      isAnswered = true;
      isCorrect = option == currentQuiz.correctAnswer;

      if (isCorrect) {
        totalCorrect++;
        totalXp += currentQuiz.xpReward;
      }
    });
  }

  void nextQuestion() async {
    if (currentIndex < controller.quizzes.length - 1) {
      setState(() {
        currentIndex++;
        isAnswered = false;
        selectedOption = null;
        isCorrect = false;
      });
    } else {
      // Finish Quiz
      final score = ((totalCorrect / controller.quizzes.length) * 100).toInt();
      final success = await controller.completeLesson(lessonId, score);

      if (success) {
        _showResultDialog(score);
      } else {
        AppToast.error(title: "Gagal", message: "Gagal menyimpan progres.");
      }
    }
  }

  void _showResultDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Pelajaran Selesai!",
            style: pSemiBold20,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 64,
                ),
              ),
              const SizedBox(height: 16),
              Text("Kamu mendapatkan $score / 100", style: pSemiBold16),
              const SizedBox(height: 8),
              Text(
                "XP Diperoleh: +$totalXp XP",
                style: pSemiBold16.copyWith(color: Colors.amber.shade700),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Get.back(); // close dialog
                  Get.back(); // go back to lesson list
                },
                child: Text(
                  "Lanjutkan",
                  style: pSemiBold16.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          if (controller.quizzes.isEmpty) return const SizedBox.shrink();
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / controller.quizzes.length,
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              minHeight: 8,
            ),
          );
        }),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingQuizzes.value && controller.quizzes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.quizzes.isEmpty) {
          return Center(
            child: Text(
              "Belum ada pertanyaan.",
              style: pRegular14.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          );
        }

        final quiz = controller.quizzes[currentIndex];

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (quiz.vocabulary != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        quiz.vocabulary!.arabicWord,
                        style: const TextStyle(
                          fontFamily: 'LPMQ',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (quiz.vocabulary!.transliteration.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quiz.vocabulary!.transliteration,
                          style: pSemiBold14.copyWith(
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (quiz.example != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.indigo.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        quiz.example!.arabicText,
                        style: const TextStyle(
                          fontFamily: 'LPMQ',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.example!.translationId,
                        style: pRegular12.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                quiz.question,
                style: pSemiBold16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: quiz.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = quiz.options[index];
                    final isSelected = option == selectedOption;
                    final isCorrectOption = option == quiz.correctAnswer;

                    Color bgColor = isDark
                        ? colorScheme.surfaceContainer
                        : Colors.white;
                    Color borderColor = colorScheme.outlineVariant.withValues(
                      alpha: 0.2,
                    );
                    Color textColor = colorScheme.onSurface;

                    if (isAnswered) {
                      if (isCorrectOption) {
                        bgColor = Colors.green.shade50;
                        borderColor = Colors.green;
                        textColor = Colors.green.shade800;
                      } else if (isSelected && !isCorrect) {
                        bgColor = Colors.red.shade50;
                        borderColor = Colors.red;
                        textColor = Colors.red.shade800;
                      } else {
                        bgColor = Colors.grey.withValues(alpha: 0.1);
                        textColor = Colors.grey;
                      }
                    } else if (isSelected) {
                      bgColor = Colors.teal.shade50;
                      borderColor = Colors.teal;
                    }

                    return InkWell(
                      onTap: () => checkAnswer(option),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width:
                                isSelected ||
                                    (isAnswered &&
                                        (isCorrectOption || isSelected))
                                ? 2
                                : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: pSemiBold14.copyWith(color: textColor),
                              ),
                            ),
                            if (isAnswered && isCorrectOption)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                            if (isAnswered && isSelected && !isCorrect)
                              const Icon(
                                Icons.cancel_rounded,
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (isAnswered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCorrect
                          ? Colors.green
                          : (isDark
                                ? colorScheme.surfaceContainerHighest
                                : Colors.grey[200]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: nextQuestion,
                    child: Text(
                      "Lanjutkan",
                      style: pSemiBold16.copyWith(
                        color: isCorrect ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
