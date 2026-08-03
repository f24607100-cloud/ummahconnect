import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../../core/services/hive_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to English')));
              },
              child: const Text('English (Default)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arabic translation set')));
              },
              child: const Text('العربية (Arabic)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Urdu translation set')));
              },
              child: const Text('اردو (Urdu)'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final hive = HiveService();
    final notifyToggle = hive.getValue<bool>(HiveService.settingsBox, 'notifications_enabled', defaultValue: true)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('App Settings'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preferences Group
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined, color: AppColors.gold),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: isDarkMode,
                          activeColor: AppColors.gold,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).toggleTheme(val);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.translate_outlined, color: AppColors.gold),
                        title: const Text('App Language'),
                        subtitle: const Text('English'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () => _showLanguageDialog(context),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined, color: AppColors.gold),
                        title: const Text('Prayer Reminders'),
                        subtitle: const Text('Athan & Quran reminders'),
                        trailing: Switch(
                          value: notifyToggle,
                          activeColor: AppColors.gold,
                          onChanged: (val) async {
                            await hive.setValue<bool>(HiveService.settingsBox, 'notifications_enabled', val);
                            // Simple UI rebuild trick
                            ref.invalidate(themeModeProvider); 
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Support & Support Group
                Text(
                  'Support & About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: AppColors.gold),
                        title: const Text('About UmmahConnect'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () => _showInfoDialog(
                          context, 
                          'About UmmahConnect',
                          'UmmahConnect is a premium, AI-powered Islamic community application built with the sole goal of helping Muslims increase their faith (Iman) through authentic learning, Quran and Salah tracking, and a mindful UI designed to prevent app-addiction.'
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.gold),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () => _showInfoDialog(
                          context, 
                          'Privacy Policy',
                          'Your privacy is our priority. UmmahConnect stores your tracking data locally on your device. Firebase is used exclusively for account authentication and synchronizing settings when you log in. We never sell, track, or distribute your private search logs or tracking habits.'
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.description_outlined, color: AppColors.gold),
                        title: const Text('Terms of Service'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () => _showInfoDialog(
                          context, 
                          'Terms of Service',
                          'By accessing or using UmmahConnect, you agree to respect the values of authentic Islamic knowledge. The AI assistant answers are provided for educational purposes and should not replace formal fatwas from qualified scholars.'
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.mail_outline_rounded, color: AppColors.gold),
                        title: const Text('Contact Support'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Support email: support@ummahconnect.com')),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.star_outline_rounded, color: AppColors.gold),
                        title: const Text('Rate Our App'),
                        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thank you for rating us! Jazaakumullahu Khairan.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
