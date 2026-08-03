import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/quran_provider.dart';

class QuranProgressScreen extends ConsumerWidget {
  const QuranProgressScreen({Key? key}) : super(key: key);

  void _showSetGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Reading Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Daily Goal (Pages)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newGoal = int.tryParse(controller.text);
                if (newGoal != null && newGoal > 0) {
                  ref.read(quranNotifierProvider.notifier).updateGoal(newGoal);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateReadingLocationDialog(BuildContext context, WidgetRef ref, String currentSurah, int currentPage) {
    final surahController = TextEditingController(text: currentSurah);
    final pageController = TextEditingController(text: currentPage.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Last Read Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: surahController,
                decoration: const InputDecoration(labelText: 'Surah Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Page Number (1-604)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(pageController.text) ?? 1;
                ref.read(quranNotifierProvider.notifier).updateCurrentLocation(
                  surahController.text.trim(),
                  page,
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final quranState = ref.watch(quranNotifierProvider);
    final notifier = ref.read(quranNotifierProvider.notifier);

    // Famous Surah checklist mock
    final List<SurahMockItem> surahList = [
      SurahMockItem('Al-Fatihah', 7, 'Meccan', 1),
      SurahMockItem('Al-Baqarah', 286, 'Medinan', 2),
      SurahMockItem('Ali \'Imran', 200, 'Medinan', 50),
      SurahMockItem('An-Nisa\'', 176, 'Medinan', 77),
      SurahMockItem('Al-Ma\'idah', 120, 'Medinan', 106),
      SurahMockItem('Yaseen', 83, 'Meccan', 440),
      SurahMockItem('Al-Kahf', 110, 'Meccan', 293),
      SurahMockItem('Al-Mulk', 30, 'Meccan', 562),
      SurahMockItem('Al-Waqi\'ah', 96, 'Meccan', 534),
      SurahMockItem('Ar-Rahman', 78, 'Medinan', 531),
    ];

    return Scaffold(
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Quran Progress',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your daily reading, step by step',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                const Center(child: IslamicDivider(width: 100)),
                const SizedBox(height: 24),

                // Overall Reading Status Card
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reading Habit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.bookmark_outline, color: AppColors.gold, size: 24),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${quranState.currentSurah}, p. ${quranState.currentPage}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.gold, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${quranState.readingStreak}d streak',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Daily Pages Goal Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Goal Progress',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showSetGoalDialog(context, ref, quranState.dailyGoalPages),
                            child: const Text(
                              'Change Goal',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      LinearProgressIndicator(
                        value: quranState.percentToday,
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.gold : AppColors.lightPrimary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 10),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${quranState.pagesReadToday} of ${quranState.dailyGoalPages} pages read today',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${(quranState.percentToday * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Plus Minus logging buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.outlined(
                            icon: const Icon(Icons.remove),
                            onPressed: quranState.pagesReadToday > 0 
                                ? () => notifier.updatePagesRead(-1) 
                                : null,
                          ),
                          const SizedBox(width: 24),
                          const Text(
                            'Log Pages Read Today',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 24),
                          IconButton.outlined(
                            icon: const Icon(Icons.add),
                            onPressed: () => notifier.updatePagesRead(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Surah list section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Surahs Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt_outlined, color: AppColors.gold, size: 20),
                      onPressed: () => _showUpdateReadingLocationDialog(
                        context, 
                        ref, 
                        quranState.currentSurah, 
                        quranState.currentPage,
                      ),
                      tooltip: 'Set current position manually',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: surahList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = surahList[index];
                    final isCurrent = quranState.currentSurah.toLowerCase() == item.name.toLowerCase();

                    return Card(
                      color: isCurrent 
                          ? (isDark ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.lightPrimary.withOpacity(0.05))
                          : null,
                      child: ListTile(
                        onTap: () {
                          // Select Surah as last read
                          notifier.updateCurrentLocation(item.name, item.startPage);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated active reading to: ${item.name}, Page ${item.startPage}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent ? AppColors.gold : Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? AppColors.gold : null,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.verses} Verses • ${item.type}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page ${item.startPage}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrent ? AppColors.gold : Colors.grey,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isCurrent ? Icons.bookmark : Icons.bookmark_border,
                              color: isCurrent ? AppColors.gold : Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurahMockItem {
  final String name;
  final int verses;
  final String type;
  final int startPage;

  SurahMockItem(this.name, this.verses, this.type, this.startPage);
}
