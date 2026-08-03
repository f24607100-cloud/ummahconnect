class LessonTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  LessonTask({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  LessonTask copyWith({bool? isCompleted}) {
    return LessonTask(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
      };

  factory LessonTask.fromMap(Map<dynamic, dynamic> map) => LessonTask(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
      );
}

class WeeklyModule {
  final int weekNumber;
  final String title;
  final String summary;
  final List<LessonTask> tasks;

  WeeklyModule({
    required this.weekNumber,
    required this.title,
    required this.summary,
    required this.tasks,
  });

  double get completionPercentage {
    if (tasks.isEmpty) return 0.0;
    final done = tasks.where((t) => t.isCompleted).length;
    return done / tasks.length;
  }

  Map<String, dynamic> toMap() => {
        'weekNumber': weekNumber,
        'title': title,
        'summary': summary,
        'tasks': tasks.map((t) => t.toMap()).toList(),
      };

  factory WeeklyModule.fromMap(Map<dynamic, dynamic> map) {
    final rawTasks = map['tasks'] as List? ?? [];
    return WeeklyModule(
      weekNumber: map['weekNumber'] ?? 1,
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      tasks: rawTasks.map((t) => LessonTask.fromMap(t as Map)).toList(),
    );
  }
}

class LearningRoadmap {
  final String id;
  final String goalPrompt;
  final DateTime createdAt;
  final List<WeeklyModule> modules;

  LearningRoadmap({
    required this.id,
    required this.goalPrompt,
    required this.createdAt,
    required this.modules,
  });

  double get overallProgress {
    if (modules.isEmpty) return 0.0;
    final total = modules.fold<double>(0, (sum, m) => sum + m.completionPercentage);
    return total / modules.length;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'goalPrompt': goalPrompt,
        'createdAt': createdAt.toIso8601String(),
        'modules': modules.map((m) => m.toMap()).toList(),
      };

  factory LearningRoadmap.fromMap(Map<dynamic, dynamic> map) {
    final rawModules = map['modules'] as List? ?? [];
    return LearningRoadmap(
      id: map['id'] ?? '',
      goalPrompt: map['goalPrompt'] ?? 'I want to learn Islam',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      modules: rawModules.map((m) => WeeklyModule.fromMap(m as Map)).toList(),
    );
  }
}
