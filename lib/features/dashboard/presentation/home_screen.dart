import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../prayer/presentation/providers/prayer_provider.dart';
import '../../quran/presentation/providers/quran_provider.dart';
import '../../reminders/presentation/providers/reminders_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getIslamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Assalamu Alaikum (Tahajjud time)';
    if (hour < 12) return 'Assalamu Alaikum (Sabah al-Khair)';
    if (hour < 17) return 'Assalamu Alaikum';
    return 'Assalamu Alaikum (Masa\' al-Khair)';
  }

  String _getSimulatedHijriDate() {
    // Hijri offset estimation for illustration
    final now = DateTime.now();
    // Simplified representation for visual aesthetics
    final months = [
      'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    final hijriYear = now.year - 579;
    final monthIdx = (now.month + 3) % 12;
    final day = (now.day + 12) % 30 + 1;
    return '$day ${months[monthIdx]} $hijriYear AH';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userName = user?.name ?? 'Ummah Member';
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStr = DateFormat('EEEE, d MMMM y').format(DateTime.now());
    
    // Dynamic values from providers (which we will define soon)
    final prayerPercent = ref.watch(todayPrayerProgressProvider);
    final quranPercent = ref.watch(todayQuranProgressProvider);
    
    final dailyVerse = ref.watch(dailyVerseProvider);
    
    return Scaffold(
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Greeting & Dates)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getIslamicGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Custom Profile Photo/Avatar shortcut
                    GestureDetector(
                      onTap: () {
                        // Switch to Profile Tab
                        ref.read(mainTabControllerProvider.notifier).state = 4;
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 1.5),
                          image: user?.photoUrl != null
                              ? DecorationImage(image: NetworkImage(user!.photoUrl!), fit: BoxFit.cover)
                              : null,
                          color: isDark ? AppColors.darkSurface : Colors.white,
                        ),
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, color: AppColors.gold)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Dates Panel
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      '$todayStr • ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    Text(
                      _getSimulatedHijriDate(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Quick Summary Progress Cards in a Row
                Row(
                  children: [
                    // Prayer Progress Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(mainTabControllerProvider.notifier).state = 1,
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Salah', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: prayerPercent,
                                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? AppColors.gold : AppColors.lightPrimary,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(prayerPercent * 100).toInt()}% completed',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Quran Reading Progress Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(mainTabControllerProvider.notifier).state = 3,
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quran', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Icon(
                                    Icons.menu_book_outlined,
                                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: quranPercent,
                                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? AppColors.gold : AppColors.lightPrimary,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(quranPercent * 100).toInt()}% of daily goal',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // AI Assistant Banner Card
                GestureDetector(
                  onTap: () => ref.read(mainTabControllerProvider.notifier).state = 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark 
                            ? [AppColors.darkPrimary, AppColors.darkSurface] 
                            : [AppColors.lightPrimary, AppColors.lightSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.psychology_outlined,
                            size: 130,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.gold, width: 0.5),
                                    ),
                                    child: const Text(
                                      'AI ASSISTANT',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Explore authentic knowledge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ask about Surahs, Sunnah, Wudu, and Salah guides.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Today's Quran Verse card
                Text(
                  'Verse of the Day',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dailyVerse.arabicText,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Regular', // fits Arabic well
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const IslamicDivider(width: 80),
                        const SizedBox(height: 12),
                        Text(
                          '"${dailyVerse.englishTranslation}"',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '— Surah ${dailyVerse.surahName} (${dailyVerse.surahNumber}:${dailyVerse.verseNumber})',
                          textAlign: Alignment.centerLeft.x < 0 ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.gold : AppColors.lightPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quick Actions section
                Text(
                  'Community Services & Tools',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.people_outline,
                      label: 'Community',
                      onTap: () => context.push('/community'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.verified_outlined,
                      label: 'Scholar Q&A',
                      onTap: () => context.push('/scholars'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.shield_outlined,
                      label: 'Anonymous Aid',
                      onTap: () => context.push('/anonymous-help'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.mosque_outlined,
                      label: 'Mosque Finder',
                      onTap: () => context.push('/mosques'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.storefront_outlined,
                      label: 'Halal Directory',
                      onTap: () => context.push('/directory'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Charity Relief',
                      onTap: () => context.push('/charity'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.event_outlined,
                      label: 'Islamic Events',
                      onTap: () => context.push('/events'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.menu_book_outlined,
                      label: 'Read Quran',
                      onTap: () => ref.read(mainTabControllerProvider.notifier).state = 3,
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.bookmark_added_outlined,
                      label: 'Dua Library',
                      onTap: () => context.push('/duas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? AppColors.gold : AppColors.lightPrimary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple StateProvider to manage the active bottom navigation tab index
final mainTabControllerProvider = StateProvider<int>((ref) => 0);
