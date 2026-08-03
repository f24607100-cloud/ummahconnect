import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/widgets/islamic_ornaments.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for the animation to play out nicely
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final hiveService = HiveService();
    final completedOnboarding = hiveService.getValue<bool>(
      HiveService.settingsBox,
      'completed_onboarding',
      defaultValue: false,
    );
    final isLoggedIn = hiveService.getValue<bool>(
      HiveService.settingsBox,
      'is_logged_in',
      defaultValue: false,
    );

    if (!completedOnboarding!) {
      context.go('/onboarding');
    } else if (isLoggedIn!) {
      context.go('/main');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightPrimary,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle Mihrab arch vector decoration
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.03 : 0.07,
              child: CustomPaint(
                painter: IslamicArchPainter(
                  color: AppColors.gold,
                  isFilled: true,
                ),
              ),
            ),
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom Islamic vector logo (Star & Crescent)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.star_border_purple500_outlined, // Islamic star symbol mockup icon
                              size: 64,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'UmmahConnect',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.gold,
                            fontFamily: 'Outfit',
                            fontSize: 36,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-Powered Islamic Community',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const IslamicDivider(
                          width: 150,
                          color: AppColors.gold,
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
    );
  }
}
