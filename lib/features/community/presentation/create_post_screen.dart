import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../services/ai_moderation_service.dart';
import 'providers/community_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  PostCategory _selectedCategory = PostCategory.reminder;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).user;
    final authorName = user?.name ?? 'Ummah Member';
    final authorUid = user?.uid ?? 'guest';

    final result = ref.read(communityNotifierProvider.notifier).addPost(
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory,
      authorName: authorName,
      authorUid: authorUid,
      authorPhoto: user?.photoUrl,
    );

    if (result.isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published successfully to the Ummah community!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      // Show AI moderation policy warning dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppColors.error),
                SizedBox(width: 8),
                Text('Content Moderation Notice'),
              ],
            ),
            content: Text(result.rejectionReason ?? 'Content violated community policies.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Understand & Edit'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Community Contribution'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Information Header Banner
                  GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: isDark ? AppColors.gold : AppColors.lightPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'UmmahConnect is dedicated to pure spiritual reminders, reflections, questions, and good deeds. Entertainment, music clips, or dancing videos are strictly filtered.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gold : AppColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PostCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      String label = 'Reminder';
                      if (cat == PostCategory.reflection) label = 'Reflection';
                      if (cat == PostCategory.question) label = 'Question';
                      if (cat == PostCategory.goodDeed) label = 'Good Deed';

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(label),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? (isDark ? Colors.black : Colors.white) 
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Title Input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title / Subject',
                      hintText: 'e.g. Reflection on Surah Ar-Rahman',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Content Input
                  TextFormField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Share your reminder or reflection...',
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter content' : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitPost,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Publish Contribution'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
