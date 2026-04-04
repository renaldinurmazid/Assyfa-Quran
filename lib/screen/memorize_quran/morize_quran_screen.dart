import 'package:flutter/material.dart';

import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:quran_app/theme/font.dart';

class MorizeQuranScreen extends StatelessWidget {
  const MorizeQuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Hafalan Quran", style: pSemiBold16),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
              ),
              child: Icon(
                Icons.leaderboard_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark
                          ? const Color(0xFF1A237E)
                          : const Color(0xFF1E88E5),
                      isDark
                          ? const Color(0xFF0D47A1)
                          : const Color(0xFF42A5F5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: isDark ? 0.5 : 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                              "Level saat ini",
                              style: pRegular12.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              "Langkah Mula",
                              style: pSemiBold20.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: Colors.amber[300],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "1,250 Pts",
                                style: pBold14.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          "Kata",
                          "1.420",
                          Icons.psychology_rounded,
                          Colors.white.withValues(alpha: 0.9),
                        ),
                        // _buildStatItem(
                        //   "Hafalan",
                        //   "2 Surat",
                        //   Icons.menu_book_rounded,
                        //   Colors.white.withValues(alpha: 0.9),
                        // ),
                        _buildStatItem(
                          "Rank",
                          "#12",
                          Icons.emoji_events_rounded,
                          Colors.amber[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Perjalanan Hafalanmu", style: pSemiBold18),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Selesaikan setiap level untuk membuka mutiara hikmah",
                style: pRegular12.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildLevelCard(
                    context,
                    level: "Level 1",
                    title: "Langkah Mula",
                    description: "Awali perjalananmu dengan niat yang tulus.",
                    imagePath: 'assets/images/png/step-1.png',
                    progress: "2/8",
                    progressPercent: 0.25,
                    color: isDark
                        ? Colors.deepPurple.withValues(alpha: 0.2)
                        : Colors.deepPurple.shade50,
                    progressColor: Colors.deepPurple,
                  ),
                  _buildLevelCard(
                    context,
                    level: "Level 2",
                    title: "Jejak Bermakna",
                    description: "Setiap langkah kecil membawamu lebih dekat.",
                    imagePath: 'assets/images/png/step-2.png',
                    progress: "0/12",
                    progressPercent: 0.0,
                    color: isDark
                        ? Colors.purple.withValues(alpha: 0.2)
                        : Colors.purple.shade50,
                    progressColor: Colors.purple,
                  ),
                  _buildLevelCard(
                    context,
                    level: "Level 3",
                    title: "Akar yang Kokoh",
                    description: "Kuatkan hafalanmu dengan akar yang dalam.",
                    imagePath: 'assets/images/png/step-3.png',
                    progress: "0/15",
                    progressPercent: 0.0,
                    color: isDark
                        ? Colors.deepPurple.withValues(alpha: 0.2)
                        : Colors.deepPurple.shade50,
                    progressColor: Colors.deepPurple,
                  ),
                  _buildLevelCard(
                    context,
                    level: "Level 4",
                    title: "Menjemput Hikmah",
                    description: "Temukan butir-butir hikmah di setiap ayat.",
                    imagePath: 'assets/images/png/step-4.png',
                    progress: "0/20",
                    progressPercent: 0.0,
                    isLocked: true,
                    color: isDark
                        ? Colors.purpleAccent.withValues(alpha: 0.2)
                        : Colors.purpleAccent,
                    progressColor: Colors.purpleAccent,
                  ),
                  _buildLevelCard(
                    context,
                    level: "Level 5",
                    title: "Puncak Kedekatan",
                    description:
                        "Rasanya sejuk di puncak kebersamaan dengan-Nya.",
                    imagePath: 'assets/images/png/step-5.png',
                    progress: "0/30",
                    progressPercent: 0.0,
                    isLocked: true,
                    color: isDark
                        ? Colors.deepPurple.withValues(alpha: 0.2)
                        : Colors.deepPurple.shade50,
                    progressColor: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color? iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: pSemiBold14.copyWith(color: Colors.white)),
        Text(
          label,
          style: pRegular10.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String level,
    required String title,
    required String description,
    required String imagePath,
    required String progress,
    required double progressPercent,
    required Color color,
    required Color progressColor,
    bool isLocked = false,
  }) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Opacity(
      opacity: isLocked ? 0.8 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 100,
                  color: color,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              level,
                              style: pMedium12.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (isLocked)
                              Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(title, style: pSemiBold14),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Progres Hafalan",
                                  style: pMedium10.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                Text(progress, style: pMedium12),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressPercent,
                                backgroundColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : Colors.grey[100],
                                color: isLocked
                                    ? colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.3,
                                      )
                                    : progressColor,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
