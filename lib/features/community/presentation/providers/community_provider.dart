import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/community_post.dart';
import '../../services/ai_moderation_service.dart';

class CommunityNotifier extends StateNotifier<List<CommunityPost>> {
  final HiveService _hiveService = HiveService();
  static const String _postsKey = 'community_posts_v2';

  CommunityNotifier() : super([]) {
    _loadPosts();
  }

  void _loadPosts() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _postsKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => CommunityPost.fromMap(e as Map)).toList();
    } else {
      // Initial authentic community seed data
      state = [
        CommunityPost(
          id: 'post_1',
          authorName: 'Youssef Al-Mansoor',
          authorUid: 'user_1',
          category: PostCategory.reminder,
          title: 'The virtue of reciting Ayat al-Kursi before sleep',
          content: 'The Prophet (ﷺ) told us that whoever recites Ayat al-Kursi after every obligatory prayer, nothing stands between him and entering Paradise except death. Let us make this a daily habit!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          appreciationsCount: 24,
          comments: [
            PostComment(
              id: 'c1',
              authorName: 'Tariq Ziyad',
              text: 'JazaakAllah Khair for this reminder. SubhanAllah!',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
        ),
        CommunityPost(
          id: 'post_2',
          authorName: 'Fatima Zahra',
          authorUid: 'user_2',
          category: PostCategory.reflection,
          title: 'Reflecting on Surah Ad-Duha during trials',
          content: '"Your Lord has not taken leave of you, nor has He detested you." (93:3). When feeling overwhelmed, remember that Allah\'s relief is near. Hardship is always followed by ease.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          appreciationsCount: 42,
          comments: [],
        ),
        CommunityPost(
          id: 'post_3',
          authorName: 'Bilal Habashi',
          authorUid: 'user_3',
          category: PostCategory.goodDeed,
          title: 'Planted trees in our local community center',
          content: 'The Prophet (ﷺ) said: "There is no Muslim who plants a tree or sows seeds, and then a bird, or a person or an animal eats from it, but is regarded as a charitable gift for him."',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          appreciationsCount: 31,
          comments: [],
        ),
      ];
      _savePosts();
    }
  }

  Future<void> _savePosts() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _postsKey, list);
  }

  ModerationResult addPost({
    required String title,
    required String content,
    required PostCategory category,
    required String authorName,
    required String authorUid,
    String? authorPhoto,
  }) {
    final moderation = AiModerationService().validatePostContent(
      title: title,
      content: content,
      category: category,
    );

    if (!moderation.isApproved) {
      return moderation;
    }

    final newPost = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorUid: authorUid,
      authorPhoto: authorPhoto,
      category: category,
      title: title.trim(),
      content: content.trim(),
      timestamp: DateTime.now(),
      appreciationsCount: 0,
      comments: [],
    );

    state = [newPost, ...state];
    _savePosts();
    return ModerationResult(isApproved: true);
  }

  ModerationResult addComment(String postId, String text, String authorName) {
    final moderation = AiModerationService().validateCommentText(text);
    if (!moderation.isApproved) {
      return moderation;
    }

    final newComment = PostComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.map((post) {
      if (post.id == postId) {
        final updatedComments = [...post.comments, newComment];
        return post.copyWith(comments: updatedComments);
      }
      return post;
    }).toList();

    _savePosts();
    return ModerationResult(isApproved: true);
  }

  void toggleAppreciation(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(appreciationsCount: post.appreciationsCount + 1);
      }
      return post;
    }).toList();
    _savePosts();
  }
}

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, List<CommunityPost>>((ref) {
  return CommunityNotifier();
});
