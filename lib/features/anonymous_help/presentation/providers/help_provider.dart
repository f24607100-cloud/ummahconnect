import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/help_request.dart';

class HelpNotifier extends StateNotifier<List<HelpRequest>> {
  final HiveService _hiveService = HiveService();
  static const String _helpKey = 'anonymous_help_v2';

  HelpNotifier() : super([]) {
    _loadRequests();
  }

  void _loadRequests() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _helpKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => HelpRequest.fromMap(e as Map)).toList();
    } else {
      state = [
        HelpRequest(
          id: 'hr_1',
          category: HelpCategory.food,
          title: 'I need food assistance for a family of four this week',
          description: 'Passing through a temporary difficult period. Looking for basic halal groceries or food pack assistance in Makkah district.',
          city: 'Makkah',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          volunteerResponsesCount: 3,
        ),
        HelpRequest(
          id: 'hr_2',
          category: HelpCategory.advice,
          title: 'Need advice on overcoming anxiety during prayer',
          description: 'Experiencing severe intrusive thoughts during Salah. Seeking gentle advice from brothers/sisters on how to build Khushoo\'.',
          city: 'Medina',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          volunteerResponsesCount: 5,
        ),
        HelpRequest(
          id: 'hr_3',
          category: HelpCategory.emergency,
          title: 'Urgent advice regarding hospital admission procedures',
          description: 'Need guidance on family medical assistance resources in the area. Identity remains anonymous.',
          city: 'Riyadh',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          volunteerResponsesCount: 2,
        ),
      ];
      _saveRequests();
    }
  }

  Future<void> _saveRequests() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _helpKey, list);
  }

  void createRequest({
    required HelpCategory category,
    required String title,
    required String description,
    required String city,
  }) {
    final newReq = HelpRequest(
      id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      title: title.trim(),
      description: description.trim(),
      city: city.trim(),
      timestamp: DateTime.now(),
      volunteerResponsesCount: 0,
    );

    state = [newReq, ...state];
    _saveRequests();
  }

  void volunteerHelp(String id) {
    state = state.map((req) {
      if (req.id == id) {
        return req.copyWith(volunteerResponsesCount: req.volunteerResponsesCount + 1);
      }
      return req;
    }).toList();
    _saveRequests();
  }
}

final helpNotifierProvider = StateNotifierProvider<HelpNotifier, List<HelpRequest>>((ref) {
  return HelpNotifier();
});
