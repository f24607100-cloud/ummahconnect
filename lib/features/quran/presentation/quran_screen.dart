import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/surah_model.dart';
import '../services/quran_repository.dart';
import 'providers/quran_provider.dart';

class QuranProgressScreen extends ConsumerStatefulWidget {
  const QuranProgressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuranProgressScreen> createState() => _QuranProgressScreenState();
}

class _QuranProgressScreenState extends ConsumerState<QuranProgressScreen> {
  final QuranRepository _repository = QuranRepository();
  final TextEditingController _searchController = TextEditingController();

  late List<Surah> _allSurahs;
  List<Surah> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _allSurahs = _repository.getAllSurahs();
    _filteredSurahs = List.from(_allSurahs);
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredSurahs = List.from(_allSurahs);
      } else {
        final q = query.toLowerCase().trim();
        _filteredSurahs = _allSurahs.where((s) {
          return s.nameEnglish.toLowerCase().contains(q) ||
              s.nameArabic.contains(q) ||
              s.englishMeaning.toLowerCase().contains(q) ||
              s.number.toString() == q;
        }).toList();
      }
    });
  }

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

  void _showUpdateReadingLocationDialog(
      BuildContext context, WidgetRef ref, String currentSurah, int currentPage) {
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
                decoration:
                    const InputDecoration(labelText: 'Page Number (1-604)'),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quranState = ref.watch(quranNotifierProvider);
    final notifier = ref.read(quranNotifierProvider.notifier);

    // Find active surah object for quick launcher
    final activeSurahObj = _allSurahs.firstWhere(
      (s) => s.nameEnglish.toLowerCase() == quranState.currentSurah.toLowerCase(),
      orElse: () => _allSurahs.first,
    );

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
                  'Track your daily reading & read the Holy Quran',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                const Center(child: IslamicDivider(width: 100)),
                const SizedBox(height: 24),

                // Overall Reading Status & Quick Reader Banner
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
                                'Active Reading Bookmark',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.bookmark,
                                      color: AppColors.gold, size: 24),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.gold, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: AppColors.gold, size: 16),
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
                      const SizedBox(height: 16),

                      // Continue Reading Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book_rounded,
                            color: Colors.white),
                        label: Text('Read ${quranState.currentSurah} Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          context.push(
                              '/quran/reader?surah=${activeSurahObj.number}');
                        },
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
                            onTap: () => _showSetGoalDialog(
                                context, ref, quranState.dailyGoalPages),
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
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.black12,
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
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
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

                // Surahs Overview Header & Search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Surahs Overview (${_filteredSurahs.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt_outlined,
                          color: AppColors.gold, size: 20),
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

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _filterSurahs,
                  decoration: InputDecoration(
                    hintText: 'Search Surah by name or number...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterSurahs('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),

                // Surah List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredSurahs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _filteredSurahs[index];
                    final isCurrent = quranState.currentSurah.toLowerCase() ==
                        item.nameEnglish.toLowerCase();

                    return Card(
                      color: isCurrent
                          ? (isDark
                              ? AppColors.darkPrimary.withValues(alpha: 0.3)
                              : AppColors.lightPrimary.withValues(alpha: 0.08))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isCurrent
                            ? const BorderSide(color: AppColors.gold, width: 1)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        onTap: () {
                          // Select Surah as last read and open Quran Reader Screen!
                          notifier.updateCurrentLocation(
                              item.nameEnglish, item.startPage);
                          context.push('/quran/reader?surah=${item.number}');
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isCurrent ? AppColors.gold : Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.number.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? AppColors.gold : null,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item.nameEnglish,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              item.nameArabic,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${item.versesCount} Verses • ${item.revelationType} • "${item.englishMeaning}"',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'p. ${item.startPage}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isCurrent ? AppColors.gold : Colors.grey,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.gold,
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
