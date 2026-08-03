import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/hive_service.dart';

class PrayerDayState {
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;

  PrayerDayState({
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
  });

  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    return count;
  }

  double get percent => completedCount / 5.0;

  Map<String, bool> toMap() {
    return {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  factory PrayerDayState.fromMap(Map<dynamic, dynamic> map) {
    return PrayerDayState(
      fajr: map['fajr'] ?? false,
      dhuhr: map['dhuhr'] ?? false,
      asr: map['asr'] ?? false,
      maghrib: map['maghrib'] ?? false,
      isha: map['isha'] ?? false,
    );
  }

  PrayerDayState copyWith({
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
  }) {
    return PrayerDayState(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}

class PrayerNotifier extends StateNotifier<PrayerDayState> {
  final HiveService _hiveService = HiveService();
  final String _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  PrayerNotifier() : super(PrayerDayState()) {
    _loadTodayPrayers();
  }

  void _loadTodayPrayers() {
    final data = _hiveService.getValue<Map>(HiveService.prayerBox, _todayKey);
    if (data != null) {
      state = PrayerDayState.fromMap(data);
    }
  }

  Future<void> togglePrayer(String prayerName) async {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        state = state.copyWith(fajr: !state.fajr);
        break;
      case 'dhuhr':
        state = state.copyWith(dhuhr: !state.dhuhr);
        break;
      case 'asr':
        state = state.copyWith(asr: !state.asr);
        break;
      case 'maghrib':
        state = state.copyWith(maghrib: !state.maghrib);
        break;
      case 'isha':
        state = state.copyWith(isha: !state.isha);
        break;
    }
    
    // Save to local Hive db
    await _hiveService.setValue<Map>(HiveService.prayerBox, _todayKey, state.toMap());
    
    // Update streak calculations
    await _calculateStreaks();
  }

  // Simple streak calculator
  Future<void> _calculateStreaks() async {
    int streak = 0;
    DateTime date = DateTime.now();
    
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(date);
      final data = _hiveService.getValue<Map>(HiveService.prayerBox, key);
      
      if (data != null) {
        final day = PrayerDayState.fromMap(data);
        if (day.completedCount == 5) {
          streak++;
        } else {
          // If checking today and it's not complete, don't break yet if it's today
          if (date.day == DateTime.now().day) {
            // today not fully complete, skip check but check yesterday
          } else {
            break;
          }
        }
      } else {
        if (date.day != DateTime.now().day) {
          break;
        }
      }
      date = date.subtract(const Duration(days: 1));
      
      // Safety break
      if (streak > 365) break;
    }
    
    await _hiveService.setValue<int>(HiveService.prayerBox, 'current_streak', streak);
  }

  int getStreak() {
    return _hiveService.getValue<int>(HiveService.prayerBox, 'current_streak', defaultValue: 0)!;
  }

  List<double> getWeeklyCompletion() {
    final List<double> weekly = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final data = _hiveService.getValue<Map>(HiveService.prayerBox, key);
      if (data != null) {
        final dayState = PrayerDayState.fromMap(data);
        weekly.add(dayState.completedCount.toDouble());
      } else {
        weekly.add(0.0);
      }
    }
    return weekly;
  }
}

// Providers
final prayerProvider = StateNotifierProvider<PrayerNotifier, PrayerDayState>((ref) {
  return PrayerNotifier();
});

final todayPrayerProgressProvider = Provider<double>((ref) {
  final prayerState = ref.watch(prayerProvider);
  return prayerState.percent;
});
