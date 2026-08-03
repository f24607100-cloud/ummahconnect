import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/islamic_event.dart';

class EventsNotifier extends StateNotifier<List<IslamicEvent>> {
  final HiveService _hiveService = HiveService();
  static const String _eventsKey = 'islamic_events_v2';

  EventsNotifier() : super([]) {
    _loadEvents();
  }

  void _loadEvents() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _eventsKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => IslamicEvent.fromMap(e as Map)).toList();
    } else {
      state = [
        IslamicEvent(
          id: 'e_1',
          category: EventCategory.lecture,
          title: 'Purification of the Soul (Tazkiyat al-Nafs)',
          speaker: 'Dr. Sheikh Omar Suleiman',
          location: 'Masjid Al-Noor Main Auditorium',
          dateTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
          description: 'A deep lecture exploring practical steps to cleanse heart diseases like pride, envy, and anger, replacing them with Sincerity and Tawakkul.',
          rsvpCount: 184,
        ),
        IslamicEvent(
          id: 'e_2',
          category: EventCategory.quranClass,
          title: 'Weekend Tajweed & Memorization Circle',
          speaker: 'Qari Sheikh Abdullah Basfar',
          location: 'Al-Haram Quran Study Hall',
          dateTime: DateTime.now().add(const Duration(days: 4, hours: 2)),
          description: 'Interactive recitation improvement for Juz \'Amma with proper Makharij (pronunciation points) and rules of Tajweed.',
          rsvpCount: 92,
        ),
        IslamicEvent(
          id: 'e_3',
          category: EventCategory.workshop,
          title: 'Islamic Finance & Halal Investment Seminar',
          speaker: 'Dr. Mufti Muhammad Taqi Usmani',
          location: 'Community Convention Center',
          dateTime: DateTime.now().add(const Duration(days: 7, hours: 5)),
          description: 'Practical workshop on ethical wealth management, avoiding Riba, and navigating modern stock trading in accordance with Shariah.',
          rsvpCount: 260,
        ),
        IslamicEvent(
          id: 'e_4',
          category: EventCategory.eidEvent,
          title: 'Community Eid al-Fitr Festival & Youth Gathering',
          speaker: 'Community Youth Council',
          location: 'Central Mosque Gardens',
          dateTime: DateTime.now().add(const Duration(days: 14, hours: 1)),
          description: 'Family-friendly celebration with free food stalls, children\'s gifts, sports tournaments, and Islamic quiz challenges.',
          rsvpCount: 512,
        ),
      ];
      _saveEvents();
    }
  }

  Future<void> _saveEvents() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _eventsKey, list);
  }

  void toggleRsvp(String eventId) {
    state = state.map((event) {
      if (event.id == eventId) {
        final newIsRsvped = !event.isRsvped;
        final newCount = newIsRsvped ? event.rsvpCount + 1 : (event.rsvpCount - 1).clamp(0, 9999);
        return event.copyWith(isRsvped: newIsRsvped, rsvpCount: newCount);
      }
      return event;
    }).toList();
    _saveEvents();
  }
}

final eventsNotifierProvider = StateNotifierProvider<EventsNotifier, List<IslamicEvent>>((ref) {
  return EventsNotifier();
});
