class ScholarAnswer {
  final String id;
  final String scholarName;
  final String scholarTitle;
  final String answerText;
  final String references;
  final DateTime timestamp;

  ScholarAnswer({
    required this.id,
    required this.scholarName,
    required this.scholarTitle,
    required this.answerText,
    required this.references,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scholarName': scholarName,
      'scholarTitle': scholarTitle,
      'answerText': answerText,
      'references': references,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScholarAnswer.fromMap(Map<dynamic, dynamic> map) {
    return ScholarAnswer(
      id: map['id'] ?? '',
      scholarName: map['scholarName'] ?? 'Sheikh Abdullah',
      scholarTitle: map['scholarTitle'] ?? 'Verified Scholar',
      answerText: map['answerText'] ?? '',
      references: map['references'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ScholarQuestion {
  final String id;
  final String authorName;
  final String questionTitle;
  final String questionBody;
  final DateTime timestamp;
  final bool isAnswered;
  final List<ScholarAnswer> answers;

  ScholarQuestion({
    required this.id,
    required this.authorName,
    required this.questionTitle,
    required this.questionBody,
    required this.timestamp,
    this.isAnswered = false,
    this.answers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'questionTitle': questionTitle,
      'questionBody': questionBody,
      'timestamp': timestamp.toIso8601String(),
      'isAnswered': isAnswered,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }

  factory ScholarQuestion.fromMap(Map<dynamic, dynamic> map) {
    final rawAnswers = map['answers'] as List? ?? [];
    return ScholarQuestion(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? 'Member',
      questionTitle: map['questionTitle'] ?? '',
      questionBody: map['questionBody'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isAnswered: map['isAnswered'] ?? false,
      answers: rawAnswers.map((a) => ScholarAnswer.fromMap(a as Map)).toList(),
    );
  }
}
