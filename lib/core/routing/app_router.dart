import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/register_address_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page_new.dart';
import '../../features/courses/presentation/pages/schools_page.dart';
import '../../features/gita/presentation/pages/gita_course_overview_page.dart';
import '../../features/gita/presentation/pages/gita_level_page.dart';
import '../../features/gita/presentation/pages/gita_chapter_page.dart';
import '../../features/gita/presentation/pages/shloka_viewer_page.dart';

/// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/register/address',
        name: 'register-address',
        builder: (context, state) {
          final biographicData = state.extra as Map<String, dynamic>? ?? {};
          return RegisterAddressPage(biographicData: biographicData);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePageNew(),
      ),
      GoRoute(
        path: '/schools',
        name: 'schools',
        builder: (context, state) => const SchoolsPage(),
      ),
      // Gita Routes
      GoRoute(
        path: '/gita',
        name: 'gita-overview',
        builder: (context, state) => const GitaCourseOverviewPage(),
      ),
      GoRoute(
        path: '/gita/levels/:levelNumber',
        name: 'gita-level',
        builder: (context, state) {
          final levelNumber = int.parse(state.pathParameters['levelNumber']!);
          return GitaLevelPage(levelNumber: levelNumber);
        },
      ),
      GoRoute(
        path: '/gita/chapters/:chapterNumber',
        name: 'gita-chapter',
        builder: (context, state) {
          final chapterNumber = int.parse(state.pathParameters['chapterNumber']!);
          return GitaChapterPage(chapterNumber: chapterNumber);
        },
      ),
      GoRoute(
        path: '/gita/shlokas/:chapterNumber/:shlokaNumber',
        name: 'shloka-viewer',
        builder: (context, state) {
          // For now, using chapter and shloka number to construct ID
          // In production, this should come from chapter data
          final chapterNumber = state.pathParameters['chapterNumber']!;
          final shlokaNumber = state.pathParameters['shlokaNumber']!;
          final shlokaId = 'shloka_${chapterNumber}_$shlokaNumber'; // Placeholder
          return ShlokaViewerPage(shlokaId: shlokaId);
        },
      ),
    ],
  );
}

