enum PostCategory {
  reminder,
  reflection,
  question,
  goodDeed,
}

class ModerationResult {
  final bool isApproved;
  final String? rejectionReason;

  ModerationResult({
    required this.isApproved,
    this.rejectionReason,
  });
}

class AiModerationService {
  static final AiModerationService _instance = AiModerationService._internal();
  factory AiModerationService() => _instance;
  AiModerationService._internal();

  // Words and terms restricted to ensure a pure, spiritual community environment
  static final List<String> _forbiddenTerms = [
    // Entertainment & inappropriate content
    'dance', 'dancing', 'tiktok', 'music', 'party', 'club', 'song', 'dj', 'reels',
    // Abuse & hate speech
    'hate', 'idiot', 'fool', 'curse', 'trash', 'scam', 'spam', 'abuse', 'harass',
  ];

  ModerationResult validatePostContent({
    required String title,
    required String content,
    required PostCategory category,
  }) {
    final combined = '$title $content'.toLowerCase();

    for (final term in _forbiddenTerms) {
      if (combined.contains(term)) {
        if (['dance', 'dancing', 'tiktok', 'music', 'party', 'song', 'dj', 'reels'].contains(term)) {
          return ModerationResult(
            isApproved: false,
            rejectionReason: 'UmmahConnect is dedicated purely to Islamic learning and spiritual growth. Entertainment posts, music clips, and dancing videos are not permitted.',
          );
        } else {
          return ModerationResult(
            isApproved: false,
            rejectionReason: 'Your post contains content flagged for potential disrespect, abuse, or spam. Please keep all contributions respectful and constructive.',
          );
        }
      }
    }

    return ModerationResult(isApproved: true);
  }

  ModerationResult validateCommentText(String comment) {
    final lower = comment.toLowerCase();
    for (final term in _forbiddenTerms) {
      if (lower.contains(term)) {
        return ModerationResult(
          isApproved: false,
          rejectionReason: 'Comments must remain respectful, courteous, and free of abusive language or spam.',
        );
      }
    }
    return ModerationResult(isApproved: true);
  }
}
