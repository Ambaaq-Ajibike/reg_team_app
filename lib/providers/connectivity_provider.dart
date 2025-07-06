import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_queue_service.dart';


class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool _isAutoSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get isOnline => _isOnline;
  bool get isAutoSyncing => _isAutoSyncing;

  ConnectivityProvider() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      // Check initial connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult.isNotEmpty && connectivityResult.first != ConnectivityResult.none;
      notifyListeners();

      // Listen for connectivity changes
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> results) {
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        _onConnectivityChanged(result);
      });
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOffline && _isOnline) {
      // Device just came online, auto-sync
      _autoSync();
    }
    
    notifyListeners();
  }

  Future<void> _autoSync() async {
    if (_isAutoSyncing) return;

    try {
      _isAutoSyncing = true;
      notifyListeners();

      // Check if there are pending actions
      final pendingActions = await OfflineQueueService.getPendingActions();
      
      if (pendingActions.isNotEmpty) {
        debugPrint('Auto-syncing ${pendingActions.length} pending actions');
        
        final results = await OfflineQueueService.processQueue();
        final successCount = results['success'] as int;
        final failedCount = results['failed'] as int;
        
        debugPrint('Auto-sync completed: $successCount success, $failedCount failed');
        
        // Show notification if there were failures
        if (failedCount > 0) {
          // Note: We can't show toast here as we don't have context
          // The user can check the offline queue screen for details
          debugPrint('Auto-sync had $failedCount failures');
        }
      }
    } catch (e) {
      debugPrint('Error during auto-sync: $e');
    } finally {
      _isAutoSyncing = false;
      notifyListeners();
    }
  }

  Future<void> manualSync() async {
    if (_isAutoSyncing) return;
    await _autoSync();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
} 