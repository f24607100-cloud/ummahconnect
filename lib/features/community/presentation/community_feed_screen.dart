import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/community_post.dart';
import '../services/ai_moderation_service.dart';
import 'comments_sheet.dart';
import 'providers/community_provider.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final posts = ref.watch(communityNotifierProvider);
    final notifier = ref.read(communityNotifierProvider.notifier);

    // Filter posts by selected category
    final filteredPosts = posts.where((post) {
      if (_selectedCategoryFilter == 'All') return true;
      if (_selectedCategoryFilter == 'Reminders' && post.category == PostCategory.reminder) return true;
      if (_selectedCategoryFilter == 'Reflections' && post.category == PostCategory.reflection) return true;
      if (_selectedCategoryFilter == 'Questions' && post.category == PostCategory.question) return true;
      if (_selectedCategoryFilter == 'Good Deeds' && post.category == PostCategory.goodDeed) return true;
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Community Reflections'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Share Reminder'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Category filter bar
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'Reminders', 'Reflections', 'Questions', 'Good Deeds'].map((cat) {
                    final isSelected = _selectedCategoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? (isDark ? Colors.black : Colors.white) 
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategoryFilter = cat;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Posts List
              Expanded(
                child: filteredPosts.isEmpty
                    ? const Center(
                        child: Text(
                          'No contributions in this category yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Post Header
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1),
                                        child: Text(
                                          post.authorName[0].toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.authorName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Text(
                                              '${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, "0")}',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          post.categoryLabel.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Title & Content
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.content,
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),

                                  // Post Actions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Appreciation button (JazaakAllah Khair)
                                      OutlinedButton.icon(
                                        onPressed: () => notifier.toggleAppreciation(post.id),
                                        icon: const Icon(Icons.favorite_border, size: 16, color: AppColors.gold),
                                        label: Text('JazaakAllah Khair (${post.appreciationsCount})'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                                        ),
                                      ),

                                      // Comments button
                                      TextButton.icon(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => CommentsSheet(post: post),
                                          );
                                        },
                                        icon: const Icon(Icons.mode_comment_outlined, size: 16),
                                        label: Text('${post.comments.length} Comments'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
