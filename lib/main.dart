import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/search_screen.dart';
import 'screens/paper_list_screen.dart';
import 'screens/offline_queue_screen.dart';
import 'screens/member_registration_screen.dart';
import 'screens/guest_registration_screen.dart';
import 'services/auth_service.dart';
import 'services/member_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await AuthService().init();
  await MemberService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jalsa Registration',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(onThemeToggle: toggleTheme),
        '/home': (context) => HomeScreen(onThemeToggle: toggleTheme),
        '/scan': (context) => const ScanScreen(),
        '/search': (context) => const SearchScreen(),
        '/paper-list': (context) => const PaperListScreen(),
        '/offline-queue': (context) => const OfflineQueueScreen(),
        '/register-member': (context) => const MemberRegistrationScreen(),
        '/register-guest': (context) => const GuestRegistrationScreen(),
      },
    );
  }
}
