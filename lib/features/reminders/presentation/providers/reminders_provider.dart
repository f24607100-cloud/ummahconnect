import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';

class DailyVerse {
  final String arabicText;
  final String englishTranslation;
  final String surahName;
  final int surahNumber;
  final int verseNumber;

  DailyVerse({
    required this.arabicText,
    required this.englishTranslation,
    required this.surahName,
    required this.surahNumber,
    required this.verseNumber,
  });
}

class DailyHadith {
  final String text;
  final String source;
  final String narrator;

  DailyHadith({
    required this.text,
    required this.source,
    required this.narrator,
  });
}

final dailyVerseProvider = Provider<DailyVerse>((ref) {
  // Return static premium Islamic verse of the day
  return DailyVerse(
    arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    englishTranslation: 'O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.',
    surahName: 'Al-Baqarah',
    surahNumber: 2,
    verseNumber: 153,
  );
});

final dailyHadithProvider = Provider<DailyHadith>((ref) {
  return DailyHadith(
    narrator: 'Narrated by Abu Hurairah',
    text: 'The Prophet (ﷺ) said: "Allah does not look at your outward appearance or your wealth, but He looks at your hearts and your deeds."',
    source: 'Sahih Muslim, 2564',
  );
});

// Bookmarks Notifier
class RemindersBookmarkNotifier extends StateNotifier<List<String>> {
  final HiveService _hiveService = HiveService();
  static const String _bookmarkKey = 'bookmarked_reminders';

  RemindersBookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final list = _hiveService.getValue<List>(HiveService.bookmarksBox, _bookmarkKey, defaultValue: []);
    state = List<String>.from(list!);
  }

  Future<void> toggleBookmark(String itemKey) async {
    final updated = List<String>.from(state);
    if (updated.contains(itemKey)) {
      updated.remove(itemKey);
    } else {
      updated.add(itemKey);
    }
    state = updated;
    await _hiveService.setValue<List<String>>(HiveService.bookmarksBox, _bookmarkKey, updated);
  }

  bool isBookmarked(String itemKey) => state.contains(itemKey);
}

final remindersBookmarkProvider = StateNotifierProvider<RemindersBookmarkNotifier, List<String>>((ref) {
  return RemindersBookmarkNotifier();
});
