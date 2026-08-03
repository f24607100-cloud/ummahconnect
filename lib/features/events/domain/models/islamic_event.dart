enum EventCategory {
  lecture,
  quranClass,
  workshop,
  eidEvent,
}

class IslamicEvent {
  final String id;
  final EventCategory category;
  final String title;
  final String speaker;
  final String location;
  final DateTime dateTime;
  final String description;
  final int rsvpCount;
  final bool isRsvped;

  IslamicEvent({
    required this.id,
    required this.category,
    required this.title,
    required this.speaker,
    required this.location,
    required this.dateTime,
    required this.description,
    this.rsvpCount = 0,
    this.isRsvped = false,
  });

  String get categoryLabel {
    switch (category) {
      case EventCategory.lecture:
        return 'Islamic Lecture';
      case EventCategory.quranClass:
        return 'Quran Class';
      case EventCategory.workshop:
        return 'Interactive Workshop';
      case EventCategory.eidEvent:
        return 'Eid Gathering';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'speaker': speaker,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'rsvpCount': rsvpCount,
      'isRsvped': isRsvped,
    };
  }

  factory IslamicEvent.fromMap(Map<dynamic, dynamic> map) {
    final catString = map['category'] ?? 'lecture';
    final category = EventCategory.values.firstWhere(
      (e) => e.name == catString,
      orElse: () => EventCategory.lecture,
    );

    return IslamicEvent(
      id: map['id'] ?? '',
      category: category,
      title: map['title'] ?? '',
      speaker: map['speaker'] ?? '',
      location: map['location'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
      rsvpCount: map['rsvpCount'] ?? 0,
      isRsvped: map['isRsvped'] ?? false,
    );
  }

  IslamicEvent copyWith({
    int? rsvpCount,
    bool? isRsvped,
  }) {
    return IslamicEvent(
      id: id,
      category: category,
      title: title,
      speaker: speaker,
      location: location,
      dateTime: dateTime,
      description: description,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      isRsvped: isRsvped ?? this.isRsvped,
    );
  }
}
