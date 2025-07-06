import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/member_service.dart';
import '../utils/toast_utils.dart';

class OfflineQueueScreen extends StatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  bool _isSyncing = false;

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    try {
      await MemberService().syncOfflineData();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, 'Data synced successfully');
      context.pop(); // Return to home screen after sync
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Queue'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSyncing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Syncing data...'),
            ] else ...[
              const Icon(
                Icons.sync,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sync offline data with the server',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _syncData,
                icon: const Icon(Icons.sync),
                label: const Text('Sync Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 