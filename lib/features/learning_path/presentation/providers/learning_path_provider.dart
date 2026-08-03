import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/learning_roadmap.dart';
import '../../services/ai_learning_roadmap_generator.dart';

class LearningPathNotifier extends StateNotifier<LearningRoadmap?> {
  final HiveService _hiveService = HiveService();
  static const String _roadmapKey = 'active_learning_roadmap_v3';

  LearningPathNotifier() : super(null) {
    _loadRoadmap();
  }

  void _loadRoadmap() async {
    final cached = _hiveService.getValue<Map>(HiveService.bookmarksBox, _roadmapKey);
    if (cached != null && cached.isNotEmpty) {
      state = LearningRoadmap.fromMap(cached);
    } else {
      // Default initial roadmap
      final defaultRoadmap = await AiLearningRoadmapGenerator().generateRoadmap('I want to learn Islam');
      state = defaultRoadmap;
      _saveRoadmap();
    }
  }

  Future<void> _saveRoadmap() async {
    if (state != null) {
      await _hiveService.setValue<Map>(HiveService.bookmarksBox, _roadmapKey, state!.toMap());
    }
  }

  Future<void> generateNewRoadmap(String prompt) async {
    final newRoadmap = await AiLearningRoadmapGenerator().generateRoadmap(prompt);
    state = newRoadmap;
    _saveRoadmap();
  }

  void toggleTaskCompletion(int weekNumber, String taskId) {
    if (state == null) return;

    final updatedModules = state!.modules.map((mod) {
      if (mod.weekNumber == weekNumber) {
        final updatedTasks = mod.tasks.map((task) {
          if (task.id == taskId) {
            return task.copyWith(isCompleted: !task.isCompleted);
          }
          return task;
        }).toList();
        return WeeklyModule(
          weekNumber: mod.weekNumber,
          title: mod.title,
          summary: mod.summary,
          tasks: updatedTasks,
        );
      }
      return mod;
    }).toList();

    state = LearningRoadmap(
      id: state!.id,
      goalPrompt: state!.goalPrompt,
      createdAt: state!.createdAt,
      modules: updatedModules,
    );
    _saveRoadmap();
  }
}

final learningPathNotifierProvider = StateNotifierProvider<LearningPathNotifier, LearningRoadmap?>((ref) {
  return LearningPathNotifier();
});
