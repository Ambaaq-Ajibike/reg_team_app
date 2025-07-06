import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/search_screen.dart';
import '../screens/paper_list_screen.dart';
import '../screens/offline_queue_screen.dart';
import '../screens/member_registration_screen.dart';
import '../screens/guest_registration_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static late VoidCallback _themeToggleCallback;

  static void setThemeToggleCallback(VoidCallback callback) {
    _themeToggleCallback = callback;
  }

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoginRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          onThemeToggle: _themeToggleCallback,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(
          onThemeToggle: _themeToggleCallback,
        ),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/paper-list',
        name: 'paper-list',
        builder: (context, state) => const PaperListScreen(),
      ),
      GoRoute(
        path: '/offline-queue',
        name: 'offline-queue',
        builder: (context, state) => const OfflineQueueScreen(),
      ),
      GoRoute(
        path: '/register-member',
        name: 'register-member',
        builder: (context, state) => const MemberRegistrationScreen(),
      ),
      GoRoute(
        path: '/register-guest',
        name: 'register-guest',
        builder: (context, state) => const GuestRegistrationScreen(),
      ),
    ],
  );
} 
}