import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Connect with Muslims',
      description: 'Strengthen bonds within the Ummah. Experience a peaceful space designed for genuine faith-building, free from addictive feeds or superficial metrics.',
      icon: Icons.people_outline_rounded,
      accentColor: AppColors.gold,
    ),
    OnboardingData(
      title: 'Learn Islam',
      description: 'Access authenticated daily Quran verses, Hadiths, Duas, and ask your questions directly using the AI assistant designed to support your spiritual growth.',
      icon: Icons.menu_book_outlined,
      accentColor: AppColors.gold,
    ),
    OnboardingData(
      title: 'Grow Every Day',
      description: 'Keep track of your daily prayers and Quran reading. Establish beautiful habits, maintain streaks, and visualize your progress with premium metrics.',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.gold,
    ),
  ];

  Future<void> _completeOnboarding() async {
    await HiveService().setValue<bool>(
      HiveService.settingsBox,
      'completed_onboarding',
      true,
    );
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background arch pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.02 : 0.05,
              child: CustomPaint(
                painter: IslamicArchPainter(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  isFilled: true,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Beautiful Circle Vector Graphic
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    item.accentColor.withOpacity(0.2),
                                    item.accentColor.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark 
                                        ? AppColors.darkSurface 
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark 
                                            ? Colors.black.withOpacity(0.3) 
                                            : Colors.grey.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 54,
                                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            
                            // Text contents in GlassCard for premium feel
                            GlassCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: isDark ? Colors.white : AppColors.lightPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const IslamicDivider(width: 80),
                                  const SizedBox(height: 16),
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.7) 
                                          : Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Indicators and button panel
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8.0),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? AppColors.gold 
                                  : (isDark ? Colors.white30 : Colors.black12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 3,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
