import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jalsa Registration'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 100,
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _MenuCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Member',
                  onTap: () => Navigator.pushNamed(context, '/scan'),
                ),
                _MenuCard(
                  icon: Icons.search,
                  title: 'Search Member',
                  onTap: () => Navigator.pushNamed(context, '/search'),
                ),
                _MenuCard(
                  icon: Icons.person_add,
                  title: 'Register Member',
                  onTap: () => Navigator.pushNamed(context, '/register-member'),
                ),
                _MenuCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Register Guest',
                  onTap: () => Navigator.pushNamed(context, '/register-guest'),
                ),
                _MenuCard(
                  icon: Icons.camera_alt,
                  title: 'Paper List',
                  onTap: () => Navigator.pushNamed(context, '/paper-list'),
                ),
                _MenuCard(
                  icon: Icons.sync,
                  title: 'Offline Queue',
                  onTap: () => Navigator.pushNamed(context, '/offline-queue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 