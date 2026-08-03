import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/help_provider.dart';

class HelpRequestsScreen extends ConsumerWidget {
  const HelpRequestsScreen({Key? key}) : super(key: key);

  void _volunteerDialog(BuildContext context, WidgetRef ref, String reqId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.volunteer_activism, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Offer Volunteer Help'),
            ],
          ),
          content: const Text(
            'May Allah reward your intention! Offering help will send a private, secure message notification to this anonymous brother/sister so you can coordinate assistance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(helpNotifierProvider.notifier).volunteerHelp(reqId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Volunteer offer sent! JazaakAllah Khair.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Send Help Offer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requests = ref.watch(helpNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Anonymous Mutual Aid'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/request-help'),
        backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.privacy_tip_outlined),
        label: const Text('Need Help?'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: requests.isEmpty
              ? const Center(child: Text('No active help requests.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final item = requests[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_off_outlined, color: AppColors.gold, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Anonymous Brother/Sister • ${item.city}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.categoryLabel.toUpperCase(),
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

                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.volunteerResponsesCount} Volunteers Responded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _volunteerDialog(context, ref, item.id),
                                  icon: const Icon(Icons.handshake_outlined, size: 16),
                                  label: const Text('I Can Help'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
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
      ),
    );
  }
}
