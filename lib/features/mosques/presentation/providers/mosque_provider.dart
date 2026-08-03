import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/mosque_location.dart';

class MosqueNotifier extends StateNotifier<List<MosqueLocation>> {
  final HiveService _hiveService = HiveService();
  static const String _mosqueKey = 'mosque_finder_v2';

  MosqueNotifier() : super([]) {
    _loadMosques();
  }

  void _loadMosques() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _mosqueKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => MosqueLocation.fromMap(e as Map)).toList();
    } else {
      state = [
        MosqueLocation(
          id: 'm_1',
          name: 'Masjid Al-Haram (Central Mosque)',
          address: 'Al Haram District, Makkah',
          distanceKm: 0.8,
          jummahTime: '12:15 PM (Khutbah) / 12:45 PM (Prayer)',
          prayerTimes: {
            'Fajr': '04:42 AM',
            'Dhuhr': '12:22 PM',
            'Asr': '03:41 PM',
            'Maghrib': '06:56 PM',
            'Isha': '08:26 PM',
          },
          imagePlaceholder: 'makkah',
        ),
        MosqueLocation(
          id: 'm_2',
          name: 'Masjid An-Nabawi',
          address: 'Al Haram District, Medina',
          distanceKm: 1.4,
          jummahTime: '12:20 PM (Khutbah) / 12:50 PM (Prayer)',
          prayerTimes: {
            'Fajr': '04:45 AM',
            'Dhuhr': '12:25 PM',
            'Asr': '03:45 PM',
            'Maghrib': '06:58 PM',
            'Isha': '08:28 PM',
          },
          imagePlaceholder: 'medina',
        ),
        MosqueLocation(
          id: 'm_3',
          name: 'Masjid Quba (First Mosque)',
          address: 'Quba District, Medina',
          distanceKm: 3.2,
          jummahTime: '12:30 PM (Khutbah) / 01:00 PM (Prayer)',
          prayerTimes: {
            'Fajr': '04:46 AM',
            'Dhuhr': '12:26 PM',
            'Asr': '03:46 PM',
            'Maghrib': '06:59 PM',
            'Isha': '08:29 PM',
          },
          imagePlaceholder: 'quba',
        ),
        MosqueLocation(
          id: 'm_4',
          name: 'Masjid Al-Qiblatayn',
          address: 'Al Qiblatayn District, Medina',
          distanceKm: 4.5,
          jummahTime: '12:30 PM (Khutbah) / 01:00 PM (Prayer)',
          prayerTimes: {
            'Fajr': '04:47 AM',
            'Dhuhr': '12:27 PM',
            'Asr': '03:47 PM',
            'Maghrib': '07:00 PM',
            'Isha': '08:30 PM',
          },
          imagePlaceholder: 'qiblatayn',
        ),
      ];
      _saveMosques();
    }
  }

  Future<void> _saveMosques() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _mosqueKey, list);
  }
}

final mosqueNotifierProvider = StateNotifierProvider<MosqueNotifier, List<MosqueLocation>>((ref) {
  return MosqueNotifier();
});
