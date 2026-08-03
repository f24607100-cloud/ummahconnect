import '../../services/ai_moderation_service.dart';

class PostComment {
  final String id;
  final String authorName;
  final String text;
  final DateTime timestamp;

  PostComment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PostComment.fromMap(Map<dynamic, dynamic> map) {
    return PostComment(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? 'Member',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorUid;
  final String? authorPhoto;
  final PostCategory category;
  final String title;
  final String content;
  final DateTime timestamp;
  final int appreciationsCount; // Peaceful alternative to likes
  final List<PostComment> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorUid,
    this.authorPhoto,
    required this.category,
    required this.title,
    required this.content,
    required this.timestamp,
    this.appreciationsCount = 0,
    this.comments = const [],
  });

  String get categoryLabel {
    switch (category) {
      case PostCategory.reminder:
        return 'Islamic Reminder';
      case PostCategory.reflection:
        return 'Reflection';
      case PostCategory.question:
        return 'Community Question';
      case PostCategory.goodDeed:
        return 'Good Deed';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorUid': authorUid,
      'authorPhoto': authorPhoto,
      'category': category.name,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'appreciationsCount': appreciationsCount,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  factory CommunityPost.fromMap(Map<dynamic, dynamic> map) {
    final catString = map['category'] ?? 'reminder';
    final category = PostCategory.values.firstWhere(
      (e) => e.name == catString,
      orElse: () => PostCategory.reminder,
    );

    final rawComments = map['comments'] as List? ?? [];

    return CommunityPost(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? 'Member',
      authorUid: map['authorUid'] ?? '',
      authorPhoto: map['authorPhoto'],
      category: category,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      appreciationsCount: map['appreciationsCount'] ?? 0,
      comments: rawComments.map((c) => PostComment.fromMap(c as Map)).toList(),
    );
  }

  CommunityPost copyWith({
    int? appreciationsCount,
    List<PostComment>? comments,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorUid: authorUid,
      authorPhoto: authorPhoto,
      category: category,
      title: title,
      content: content,
      timestamp: timestamp,
      appreciationsCount: appreciationsCount ?? this.appreciationsCount,
      comments: comments ?? this.comments,
    );
  }
}
