import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/spiritual_habit.dart';
import '../../services/ai_habit_coach_service.dart';

class AiHabitCoachNotifier extends StateNotifier<SpiritualHabitLog> {
  final HiveService _hiveService = HiveService();
  static const String _habitKey = 'spiritual_habit_log_v3';

  AiHabitCoachNotifier() : super(SpiritualHabitLog()) {
    _loadLog();
  }

  void _loadLog() {
    final cached = _hiveService.getValue<Map>(HiveService.bookmarksBox, _habitKey);
    if (cached != null && cached.isNotEmpty) {
      state = SpiritualHabitLog.fromMap(cached);
    } else {
      _saveLog();
    }
  }

  Future<void> _saveLog() async {
    await _hiveService.setValue<Map>(HiveService.bookmarksBox, _habitKey, state.toMap());
  }

  void incrementDhikr() {
    state = state.copyWith(dhikrCount: state.dhikrCount + 1);
    _saveLog();
  }

  void resetDhikr() {
    state = state.copyWith(dhikrCount: 0);
    _saveLog();
  }

  void toggleTahajjud() {
    state = state.copyWith(prayedTahajjud: !state.prayedTahajjud);
    _saveLog();
  }

  void toggleFasting() {
    state = state.copyWith(isFastingToday: !state.isFastingToday);
    _saveLog();
  }

  void updateQuranPages(int pages) {
    state = state.copyWith(quranPagesRead: pages);
    _saveLog();
  }

  AiCoachInsight get currentInsight => AiHabitCoachService().generateInsight(state);
}

final aiHabitCoachNotifierProvider = StateNotifierProvider<AiHabitCoachNotifier, SpiritualHabitLog>((ref) {
  return AiHabitCoachNotifier();
});
