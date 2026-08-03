import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/scholar_provider.dart';
import 'widgets/verified_scholar_badge.dart';

class ScholarBoardScreen extends ConsumerWidget {
  const ScholarBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = ref.watch(scholarNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scholar Verified Q&A'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ask-scholar'),
        backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.help_outline),
        label: const Text('Ask a Scholar'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: questions.isEmpty
              ? const Center(child: Text('No questions yet. Be the first to ask!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final item = questions[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Asked by ${item.authorName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isAnswered 
                                        ? AppColors.success.withValues(alpha: 0.15) 
                                        : Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.isAnswered ? 'VERIFIED ANSWER' : 'PENDING REVIEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.isAnswered ? AppColors.success : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Question Title & Body
                            Text(
                              item.questionTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.questionBody,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),

                            // Scholar Answers Section
                            if (item.answers.isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: 8),
                              ...item.answers.map((ans) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    VerifiedScholarBadge(
                                      scholarName: ans.scholarName,
                                      title: ans.scholarTitle,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ans.answerText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.menu_book, size: 14, color: AppColors.gold),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Reference: ${ans.references}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Scholar review in progress. Answers are reviewed carefully before publishing.',
                                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
