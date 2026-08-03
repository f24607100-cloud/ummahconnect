import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/scholar_qna.dart';

class ScholarNotifier extends StateNotifier<List<ScholarQuestion>> {
  final HiveService _hiveService = HiveService();
  static const String _qnaKey = 'scholar_qna_v2';

  ScholarNotifier() : super([]) {
    _loadQuestions();
  }

  void _loadQuestions() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _qnaKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => ScholarQuestion.fromMap(e as Map)).toList();
    } else {
      state = [
        ScholarQuestion(
          id: 'q_1',
          authorName: 'Ibrahim K.',
          questionTitle: 'What should I do if I miss a Rak\'ah during Congregational Prayer?',
          questionBody: 'If I join the congregation while the Imam is in Ruku, does that Rak\'ah count?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isAnswered: true,
          answers: [
            ScholarAnswer(
              id: 'ans_1',
              scholarName: 'Dr. Sheikh Ahmad Al-Tayyeb',
              scholarTitle: 'Senior Islamic Fiqh Scholar',
              answerText: 'If you join the Imam while he is in Ruku (and you bow before he stands back up), that Rak\'ah counts for you. Continue following the Imam, and after he completes Salam, stand up to complete any missed Rak\'ahs.',
              references: 'Sahih al-Bukhari 789; Fiqh us-Sunnah Vol. 1',
              timestamp: DateTime.now().subtract(const Duration(hours: 18)),
            ),
          ],
        ),
        ScholarQuestion(
          id: 'q_2',
          authorName: 'Amina S.',
          questionTitle: 'Ruling on using inhalers while fasting in Ramadan',
          questionBody: 'Does using an asthma inhaler invalidate the fast?',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isAnswered: true,
          answers: [
            ScholarAnswer(
              id: 'ans_2',
              scholarName: 'Sheikh Muhammad Al-Shinqiti',
              scholarTitle: 'Verified Fiqh Council Scholar',
              answerText: 'The majority of contemporary scholars and international Fiqh academies have ruled that using asthma inhalers does not invalidate the fast because the gas vapor goes directly to the lungs for medical necessity and is not considered food or drink.',
              references: 'International Islamic Fiqh Academy Resolution 93',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
        ),
      ];
      _saveQuestions();
    }
  }

  Future<void> _saveQuestions() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _qnaKey, list);
  }

  void askQuestion(String title, String body, String authorName) {
    final newQuestion = ScholarQuestion(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      questionTitle: title.trim(),
      questionBody: body.trim(),
      timestamp: DateTime.now(),
      isAnswered: false,
      answers: [],
    );

    state = [newQuestion, ...state];
    _saveQuestions();
  }
}

final scholarNotifierProvider = StateNotifierProvider<ScholarNotifier, List<ScholarQuestion>>((ref) {
  return ScholarNotifier();
});
