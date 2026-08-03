import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';

class QuranProgressState {
  final String currentSurah;
  final int currentPage;
  final int pagesReadToday;
  final int dailyGoalPages;
  final int readingStreak;
  final int totalPagesRead;

  QuranProgressState({
    this.currentSurah = 'Al-Baqarah',
    this.currentPage = 1,
    this.pagesReadToday = 0,
    this.dailyGoalPages = 5,
    this.readingStreak = 0,
    this.totalPagesRead = 0,
  });

  double get percentToday {
    if (dailyGoalPages == 0) return 0.0;
    final pct = pagesReadToday / dailyGoalPages;
    return pct > 1.0 ? 1.0 : pct;
  }

  Map<String, dynamic> toMap() {
    return {
      'currentSurah': currentSurphNameFix,
      'currentPage': currentPage,
      'pagesReadToday': pagesReadToday,
      'dailyGoalPages': dailyGoalPages,
      'readingStreak': readingStreak,
      'totalPagesRead': totalPagesRead,
    };
  }

  // Fixing minor typo inside toMap helper variable mapping
  String get currentSurphNameFix => currentSurah;

  factory QuranProgressState.fromMap(Map<dynamic, dynamic> map) {
    return QuranProgressState(
      currentSurah: map['currentSurah'] ?? 'Al-Baqarah',
      currentPage: map['currentPage'] ?? 1,
      pagesReadToday: map['pagesReadToday'] ?? 0,
      dailyGoalPages: map['dailyGoalPages'] ?? 5,
      readingStreak: map['readingStreak'] ?? 0,
      totalPagesRead: map['totalPagesRead'] ?? 0,
    );
  }

  QuranProgressState copyWith({
    String? currentSurah,
    int? currentPage,
    int? pagesReadToday,
    int? dailyGoalPages,
    int? readingStreak,
    int? totalPagesRead,
  }) {
    return QuranProgressState(
      currentSurah: currentSurah ?? this.currentSurah,
      currentPage: currentPage ?? this.currentPage,
      pagesReadToday: pagesReadToday ?? this.pagesReadToday,
      dailyGoalPages: dailyGoalPages ?? this.dailyGoalPages,
      readingStreak: readingStreak ?? this.readingStreak,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
    );
  }
}

class QuranNotifier extends StateNotifier<QuranProgressState> {
  final HiveService _hiveService = HiveService();
  static const String _quranKey = 'user_quran_progress';

  QuranNotifier() : super(QuranProgressState()) {
    _loadProgress();
  }

  void _loadProgress() {
    final data = _hiveService.getValue<Map>(HiveService.quranBox, _quranKey);
    if (data != null) {
      state = QuranProgressState.fromMap(data);
    }
  }

  Future<void> updatePagesRead(int delta) async {
    final todayRead = state.pagesReadToday + delta;
    final totalRead = state.totalPagesRead + delta;
    
    int newStreak = state.readingStreak;
    if (state.pagesReadToday == 0 && todayRead > 0) {
      newStreak = state.readingStreak + 1;
    } else if (todayRead <= 0) {
      todayRead == 0;
      newStreak = (state.readingStreak - 1).clamp(0, 365);
    }

    state = state.copyWith(
      pagesReadToday: todayRead.clamp(0, 100),
      totalPagesRead: totalRead.clamp(0, 604),
      readingStreak: newStreak,
    );

    await _saveState();
  }

  Future<void> updateCurrentLocation(String surah, int page) async {
    state = state.copyWith(
      currentSurah: surah,
      currentPage: page.clamp(1, 604),
    );
    await _saveState();
  }

  Future<void> updateGoal(int newGoal) async {
    state = state.copyWith(
      dailyGoalPages: newGoal.clamp(1, 100),
    );
    await _saveState();
  }

  Future<void> resetToday() async {
    state = state.copyWith(pagesReadToday: 0);
    await _saveState();
  }

  Future<void> _saveState() async {
    await _hiveService.setValue<Map>(HiveService.quranBox, _quranKey, state.toMap());
  }
}

// Providers
final quranNotifierProvider = StateNotifierProvider<QuranNotifier, QuranProgressState>((ref) {
  return QuranNotifier();
});

final todayQuranProgressProvider = Provider<double>((ref) {
  final quranState = ref.watch(quranNotifierProvider);
  return quranState.percentToday;
});
