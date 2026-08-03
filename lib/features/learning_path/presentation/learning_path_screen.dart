import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/learning_path_provider.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;

  void _showNewRoadmapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Generate AI Learning Path'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tell the AI what you want to learn in Islam (e.g. "I am a beginner wanting to learn Salah", "Understanding Tajweed & Quran", "Daily Sunnah Habits"):',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promptController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. I want to learn Islam',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prompt = _promptController.text.trim();
                if (prompt.isEmpty) return;

                Navigator.pop(context);
                setState(() => _isGenerating = true);

                await ref.read(learningPathNotifierProvider.notifier).generateNewRoadmap(prompt);

                if (!mounted) return;
                setState(() => _isGenerating = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New AI Islamic Learning Roadmap generated!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Generate Roadmap'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roadmap = ref.watch(learningPathNotifierProvider);
    final notifier = ref.read(learningPathNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Islamic Learning Path'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewRoadmapDialog,
        backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('New Goal Roadmap'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: _isGenerating
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 16),
                      Text(
                        'AI Synthesizing Personalized Learning Roadmap...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : roadmap == null
                  ? const Center(child: Text('No roadmap created yet.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card with Progress Bar
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.map_outlined, color: AppColors.gold, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Goal: "${roadmap.goalPrompt}"',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Roadmap Progress', style: TextStyle(fontSize: 12)),
                                    Text(
                                      '${(roadmap.overallProgress * 100).toInt()}% COMPLETED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: roadmap.overallProgress,
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? AppColors.gold : AppColors.lightPrimary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Weekly Modules List
                          ...roadmap.modules.map((module) {
                            final pctInt = (module.completionPercentage * 100).toInt();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            module.title,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: pctInt == 100 
                                                ? AppColors.success.withValues(alpha: 0.15) 
                                                : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$pctInt%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: pctInt == 100 ? AppColors.success : (isDark ? AppColors.gold : AppColors.lightPrimary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      module.summary,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const Divider(height: 20),

                                    // Lesson Tasks Checkboxes
                                    ...module.tasks.map((task) {
                                      return CheckboxListTile(
                                        value: task.isCompleted,
                                        activeColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                                        checkColor: isDark ? Colors.black : Colors.white,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        subtitle: Text(
                                          task.description,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        onChanged: (_) {
                                          notifier.toggleTaskCompletion(module.weekNumber, task.id);
                                        },
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
