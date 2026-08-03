import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/reminders_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  void _shareItem(String content) {
    Share.share(content);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(dailyVerseProvider);
    final hadith = ref.watch(dailyHadithProvider);
    final bookmarkNotifier = ref.read(remindersBookmarkProvider.notifier);

    // Mock daily dua
    final dailyDuaText = 'رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ';
    final dailyDuaTrans = 'Rabbana taqabbal minna innaka antas-Samee\'ul-Aleem.';
    final dailyDuaTranslation = '"Our Lord, accept [this] from us. Indeed You are the All-Hearing, the All-Knowing."';
    final dailyDuaRef = 'Surah Al-Baqarah, 127';

    // Mock quote
    final quoteText = '"He who has a thousand friends has not a friend to spare, and he who has one enemy will meet him everywhere." — Ali Ibn Abi Talib (R.A)';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Daily Reminders'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quran Verse Section
                _buildReminderCard(
                  context,
                  title: 'Daily Quran Verse',
                  arabic: verse.arabicText,
                  english: '"${verse.englishTranslation}"',
                  meta: '— Surah ${verse.surahName} (${verse.surahNumber}:${verse.verseNumber})',
                  itemKey: 'quran_verse_today',
                  isBookmarked: bookmarkNotifier.isBookmarked('quran_verse_today'),
                  onBookmark: () => bookmarkNotifier.toggleBookmark('quran_verse_today'),
                  onShare: () => _shareItem('${verse.arabicText}\n\n"${verse.englishTranslation}"\n— Surah ${verse.surahName} (${verse.surahNumber}:${verse.verseNumber})'),
                ),
                const SizedBox(height: 20),

                // Hadith Section
                _buildReminderCard(
                  context,
                  title: 'Daily Hadith',
                  english: hadith.text,
                  meta: '${hadith.narrator} • ${hadith.source}',
                  itemKey: 'hadith_today',
                  isBookmarked: bookmarkNotifier.isBookmarked('hadith_today'),
                  onBookmark: () => bookmarkNotifier.toggleBookmark('hadith_today'),
                  onShare: () => _shareItem('${hadith.text}\n— ${hadith.narrator} (${hadith.source})'),
                ),
                const SizedBox(height: 20),

                // Daily Dua Section
                _buildReminderCard(
                  context,
                  title: 'Dua of the Day',
                  arabic: dailyDuaText,
                  english: '$dailyDuaTrans\n\n$dailyDuaTranslation',
                  meta: '— $dailyDuaRef',
                  itemKey: 'dua_today',
                  isBookmarked: bookmarkNotifier.isBookmarked('dua_today'),
                  onBookmark: () => bookmarkNotifier.toggleBookmark('dua_today'),
                  onShare: () => _shareItem('$dailyDuaText\n\n$dailyDuaTrans\n$dailyDuaTranslation\n— $dailyDuaRef'),
                ),
                const SizedBox(height: 20),

                // Islamic Quote Section
                _buildReminderCard(
                  context,
                  title: 'Islamic Wisdom',
                  english: quoteText,
                  itemKey: 'quote_today',
                  isBookmarked: bookmarkNotifier.isBookmarked('quote_today'),
                  onBookmark: () => bookmarkNotifier.toggleBookmark('quote_today'),
                  onShare: () => _shareItem(quoteText),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context, {
    required String title,
    String? arabic,
    required String english,
    String? meta,
    required String itemKey,
    required bool isBookmarked,
    required VoidCallback onBookmark,
    required VoidCallback onShare,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.gold : AppColors.lightPrimary,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    onPressed: onBookmark,
                    tooltip: 'Bookmark',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 20,
                    ),
                    onPressed: onShare,
                    tooltip: 'Share',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (arabic != null) ...[
            Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const IslamicDivider(width: 60),
            const SizedBox(height: 12),
          ],
          Text(
            english,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (meta != null) ...[
            const SizedBox(height: 8),
            Text(
              meta,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
