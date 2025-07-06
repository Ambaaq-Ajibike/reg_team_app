import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/offline_queue_service.dart';
import '../utils/toast_utils.dart';

class OfflineQueueScreen extends StatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  bool _isSyncing = false;
  List<OfflineAction> _pendingActions = [];
  Map<String, int> _queueStats = {};

  @override
  void initState() {
    super.initState();
    _loadPendingActions();
  }

  Future<void> _loadPendingActions() async {
    final actions = await OfflineQueueService.getPendingActions();
    final stats = await OfflineQueueService.getQueueStats();
    
    if (mounted) {
      setState(() {
        _pendingActions = actions;
        _queueStats = stats;
      });
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    try {
      final results = await OfflineQueueService.processQueue();
      if (!mounted) return;
      
      final successCount = results['success'] as int;
      final failedCount = results['failed'] as int;
      
      if (successCount > 0) {
        ToastUtils.showSuccessToast(context, 'Successfully synced $successCount items');
      }
      
      if (failedCount > 0) {
        ToastUtils.showWarningToast(context, '$failedCount items failed to sync');
      }
      
      if (successCount == 0 && failedCount == 0) {
        ToastUtils.showInfoToast(context, 'No pending items to sync');
      }
      
      context.pop(); // Return to home screen after sync
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        _loadPendingActions(); // Refresh the list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingActions,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              await OfflineQueueService.debugPrintQueue();
              await _loadPendingActions();
            },
          ),
        ],
      ),
      body: _isSyncing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Syncing data...'),
                ],
              ),
            )
          : Column(
              children: [
                // Queue statistics
                if (_queueStats.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Actions:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_queueStats.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))),
                      ],
                    ),
                  ),
                
                // Pending actions list
                Expanded(
                  child: _pendingActions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No pending actions',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _pendingActions.length,
                          itemBuilder: (context, index) {
                            final action = _pendingActions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  _getActionIcon(action.type),
                                  color: _getActionColor(action.type),
                                ),
                                title: Text(_getActionTitle(action.type)),
                                subtitle: Text(
                                  _getActionDescription(action),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  _formatTimestamp(action.timestamp),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Sync button
                if (_pendingActions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
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
                  ),
                
                // Test button (for debugging)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await OfflineQueueService.addTestAction();
                            await _loadPendingActions();
                            ToastUtils.showInfoToast(context, 'Test action added to queue');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Test Action'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await OfflineQueueService.clearQueue();
                            await _loadPendingActions();
                            ToastUtils.showInfoToast(context, 'Queue cleared');
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Queue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getActionIcon(OfflineActionType type) {
    switch (type) {
      case OfflineActionType.memberRegistration:
        return Icons.person_add;
      case OfflineActionType.guestRegistration:
        return Icons.person_add_alt;
      case OfflineActionType.memberCheckIn:
        return Icons.check_circle;
      case OfflineActionType.manifestScan:
        return Icons.qr_code_scanner;
      case OfflineActionType.participantCheckIn:
        return Icons.how_to_reg;
    }
  }

  Color _getActionColor(OfflineActionType type) {
    switch (type) {
      case OfflineActionType.memberRegistration:
        return Colors.blue;
      case OfflineActionType.guestRegistration:
        return Colors.green;
      case OfflineActionType.memberCheckIn:
        return Colors.orange;
      case OfflineActionType.manifestScan:
        return Colors.purple;
      case OfflineActionType.participantCheckIn:
        return Colors.teal;
    }
  }

  String _getActionTitle(OfflineActionType type) {
    switch (type) {
      case OfflineActionType.memberRegistration:
        return 'Member Registration';
      case OfflineActionType.guestRegistration:
        return 'Guest Registration';
      case OfflineActionType.memberCheckIn:
        return 'Member Check-in';
      case OfflineActionType.manifestScan:
        return 'Manifest Scan';
      case OfflineActionType.participantCheckIn:
        return 'Participant Check-in';
    }
  }

  String _getActionDescription(OfflineAction action) {
    switch (action.type) {
      case OfflineActionType.memberRegistration:
        final memberNumbers = List<String>.from(action.data['memberNumbers']);
        return 'Register ${memberNumbers.length} member(s)';
      case OfflineActionType.guestRegistration:
        final request = action.data['request'];
        return 'Guest: ${request['firstName']} ${request['lastName']}';
      case OfflineActionType.memberCheckIn:
        return 'Member: ${action.data['memberNumber']}';
      case OfflineActionType.manifestScan:
        return 'QR Code: ${action.data['qrCode']}';
      case OfflineActionType.participantCheckIn:
        return 'Registration: ${action.data['regNo']}';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 