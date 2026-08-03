import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/ai_habit_coach_provider.dart';

class AiHabitCoachScreen extends ConsumerWidget {
  const AiHabitCoachScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final log = ref.watch(aiHabitCoachNotifierProvider);
    final notifier = ref.read(aiHabitCoachNotifierProvider.notifier);
    final insight = notifier.currentInsight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Spiritual Habit Coach'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AI Motivational Insight Header Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: AppColors.gold, size: 26),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🔥 ${log.streakDays} DAY STREAK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.gold : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        insight.message,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote, color: AppColors.gold, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                insight.hadithReference,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Digital Tasbeeh Counter Card
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Digital Tasbeeh Counter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () => notifier.resetDhikr(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () => notifier.incrementDhikr(),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark 
                                  ? [AppColors.darkPrimary, AppColors.gold] 
                                  : [AppColors.lightPrimary, AppColors.lightSecondary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? AppColors.gold : AppColors.lightPrimary).withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${log.dhikrCount}',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'TAP DHIKR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'SubhanAllah • Alhamdulillah • Allahu Akbar • Astaghfirullah',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Spiritual Habit Tracker List
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Spiritual Habit Tracker',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        value: log.prayedTahajjud,
                        activeColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        title: const Text('Tahajjud (Night Prayer)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Prayed in the last third of the night', style: TextStyle(fontSize: 12)),
                        onChanged: (_) => notifier.toggleTahajjud(),
                      ),
                      const Divider(),

                      SwitchListTile(
                        value: log.isFastingToday,
                        activeColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        title: const Text('Voluntary Fasting Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Sunnah Monday / Thursday / Ayyam al-Beed', style: TextStyle(fontSize: 12)),
                        onChanged: (_) => notifier.toggleFasting(),
                      ),
                      const Divider(),

                      ListTile(
                        title: const Text('Daily Quran Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${log.quranPagesRead} Pages completed today'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (log.quranPagesRead > 0) {
                                  notifier.updateQuranPages(log.quranPagesRead - 1);
                                }
                              },
                            ),
                            Text('${log.quranPagesRead}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                notifier.updateQuranPages(log.quranPagesRead + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
