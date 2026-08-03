import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/dashboard/presentation/main_nav_shell.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/duas/presentation/dua_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';

// Version 2 Imports
import '../../features/community/presentation/community_feed_screen.dart';
import '../../features/community/presentation/create_post_screen.dart';
import '../../features/scholars/presentation/scholar_board_screen.dart';
import '../../features/scholars/presentation/ask_scholar_screen.dart';
import '../../features/anonymous_help/presentation/help_requests_screen.dart';
import '../../features/anonymous_help/presentation/create_help_request_screen.dart';
import '../../features/charity/presentation/charity_screen.dart';
import '../../features/directory/presentation/business_directory_screen.dart';
import '../../features/mosques/presentation/mosque_finder_screen.dart';
import '../../features/events/presentation/events_screen.dart';

// Step 3 AI Feature Imports
import '../../features/ai_tutor/presentation/ai_quran_tutor_screen.dart';
import '../../features/learning_path/presentation/learning_path_screen.dart';
import '../../features/ai_coach/presentation/ai_habit_coach_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) {
          final indexStr = state.uri.queryParameters['tab'];
          final initialIndex = indexStr != null ? int.tryParse(indexStr) ?? 0 : 0;
          return MainNavShell(initialTab: initialIndex);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/duas',
        builder: (context, state) => const DuaScreen(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),

      // Version 2 Feature Routes
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityFeedScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/scholars',
        builder: (context, state) => const ScholarBoardScreen(),
      ),
      GoRoute(
        path: '/ask-scholar',
        builder: (context, state) => const AskScholarScreen(),
      ),
      GoRoute(
        path: '/anonymous-help',
        builder: (context, state) => const HelpRequestsScreen(),
      ),
      GoRoute(
        path: '/request-help',
        builder: (context, state) => const CreateHelpRequestScreen(),
      ),
      GoRoute(
        path: '/charity',
        builder: (context, state) => const CharityScreen(),
      ),
      GoRoute(
        path: '/directory',
        builder: (context, state) => const BusinessDirectoryScreen(),
      ),
      GoRoute(
        path: '/mosques',
        builder: (context, state) => const MosqueFinderScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsScreen(),
      ),

      // Step 3 Advanced AI Routes
      GoRoute(
        path: '/ai-tutor',
        builder: (context, state) => const AiQuranTutorScreen(),
      ),
      GoRoute(
        path: '/learning-path',
        builder: (context, state) => const LearningPathScreen(),
      ),
      GoRoute(
        path: '/habit-coach',
        builder: (context, state) => const AiHabitCoachScreen(),
      ),
    ],
  );
});
