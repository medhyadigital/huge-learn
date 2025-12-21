import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/register_address_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page_new.dart';
import '../../features/courses/presentation/pages/schools_page.dart';

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
    ],
  );
}

