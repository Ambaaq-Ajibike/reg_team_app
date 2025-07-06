import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jalsa Registration'),
        actions: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivityProvider, child) {
              return IconButton(
                icon: Icon(
                  connectivityProvider.isOnline 
                      ? Icons.wifi 
                      : Icons.wifi_off,
                  color: connectivityProvider.isOnline 
                      ? Colors.green 
                      : Colors.red,
                ),
                onPressed: () {
                  if (!connectivityProvider.isOnline) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You are currently offline. Actions will be queued for sync.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              );
            },
          ),
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
              'assets/images/logo.png',
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
                  onTap: () => context.push('/scan'),
                ),
                _MenuCard(
                  icon: Icons.search,
                  title: 'Search Member',
                  onTap: () => context.push('/search'),
                ),
                _MenuCard(
                  icon: Icons.person_add,
                  title: 'Register Member',
                  onTap: () => context.push('/register-member'),
                ),
                _MenuCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Register Guest',
                  onTap: () => context.push('/register-guest'),
                ),
                _MenuCard(
                  icon: Icons.camera_alt,
                  title: 'Paper List',
                  onTap: () => context.push('/paper-list'),
                ),
                _MenuCard(
                  icon: Icons.sync,
                  title: 'Offline Queue',
                  onTap: () => context.push('/offline-queue'),
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
            Icon(icon, size: 48, color: Colors.green),
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