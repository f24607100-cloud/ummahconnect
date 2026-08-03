import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../assistant/presentation/assistant_screen.dart';
import '../../prayer/presentation/prayer_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../quran/presentation/quran_screen.dart';
import 'home_screen.dart';

class MainNavShell extends ConsumerWidget {
  final int initialTab;

  const MainNavShell({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sync current tab with Riverpod provider state
    final currentTab = ref.watch(mainTabControllerProvider);
    
    // Screens list
    final List<Widget> screens = [
      const HomeScreen(),
      const PrayerTrackerScreen(),
      const AssistantScreen(),
      const QuranProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) {
            ref.read(mainTabControllerProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: isDark ? AppColors.gold : AppColors.lightPrimary,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time_filled),
              label: 'Prayer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Quran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
