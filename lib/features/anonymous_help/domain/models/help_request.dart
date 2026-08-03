enum HelpCategory {
  food,
  advice,
  emergency,
  general,
}

class HelpRequest {
  final String id;
  final HelpCategory category;
  final String title;
  final String description;
  final String city;
  final DateTime timestamp;
  final int volunteerResponsesCount;
  final bool isFulfilled;

  HelpRequest({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.city,
    required this.timestamp,
    this.volunteerResponsesCount = 0,
    this.isFulfilled = false,
  });

  String get categoryLabel {
    switch (category) {
      case HelpCategory.food:
        return 'Food Assistance';
      case HelpCategory.advice:
        return 'Spiritual / Life Advice';
      case HelpCategory.emergency:
        return 'Emergency Help';
      case HelpCategory.general:
        return 'General Assistance';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      'city': city,
      'timestamp': timestamp.toIso8601String(),
      'volunteerResponsesCount': volunteerResponsesCount,
      'isFulfilled': isFulfilled,
    };
  }

  factory HelpRequest.fromMap(Map<dynamic, dynamic> map) {
    final catString = map['category'] ?? 'general';
    final category = HelpCategory.values.firstWhere(
      (e) => e.name == catString,
      orElse: () => HelpCategory.general,
    );

    return HelpRequest(
      id: map['id'] ?? '',
      category: category,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      city: map['city'] ?? 'Local Community',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      volunteerResponsesCount: map['volunteerResponsesCount'] ?? 0,
      isFulfilled: map['isFulfilled'] ?? false,
    );
  }

  HelpRequest copyWith({
    int? volunteerResponsesCount,
    bool? isFulfilled,
  }) {
    return HelpRequest(
      id: id,
      category: category,
      title: title,
      description: description,
      city: city,
      timestamp: timestamp,
      volunteerResponsesCount: volunteerResponsesCount ?? this.volunteerResponsesCount,
      isFulfilled: isFulfilled ?? this.isFulfilled,
    );
  }
}
