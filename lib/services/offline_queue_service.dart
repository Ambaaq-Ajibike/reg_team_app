import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'member_service.dart';
import '../models/guest_registration.dart';
import '../models/registration_response.dart';

enum OfflineActionType {
  memberRegistration,
  guestRegistration,
  memberCheckIn,
  manifestScan,
  participantCheckIn,
}

class OfflineAction {
  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isCompleted;

  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'],
      type: OfflineActionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class OfflineQueueService {
  static const String _queueKey = 'offline_queue';
  static const String _isOnlineKey = 'is_online';

  // Check if device is online
  static Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty && connectivityResult.first != ConnectivityResult.none;
      print('Connectivity check: $connectivityResult, isOnline: $isOnline');
      return isOnline;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Add action to offline queue
  static Future<void> addToQueue(OfflineAction action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      
      queue.add(action.toJson());
      await prefs.setString(_queueKey, jsonEncode(queue));
      
      print('Added action to queue: ${action.type} - ${action.id}');
      print('Queue now has ${queue.length} items');
    } catch (e) {
      print('Error adding to queue: $e');
      rethrow;
    }
  }

  // Get all pending actions from queue
  static Future<List<OfflineAction>> getPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      
      final pendingActions = queue
          .map((json) => OfflineAction.fromJson(json))
          .where((action) => !action.isCompleted)
          .toList();
      
      print('Retrieved ${pendingActions.length} pending actions from queue');
      return pendingActions;
    } catch (e) {
      print('Error getting pending actions: $e');
      return [];
    }
  }

  // Mark action as completed
  static Future<void> markActionCompleted(String actionId) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey) ?? '[]';
    final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
    
    for (int i = 0; i < queue.length; i++) {
      if (queue[i]['id'] == actionId) {
        queue[i]['isCompleted'] = true;
        break;
      }
    }
    
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  // Remove completed actions from queue
  static Future<void> removeCompletedActions() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey) ?? '[]';
    final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
    
    final pendingQueue = queue.where((action) => !action['isCompleted']).toList();
    await prefs.setString(_queueKey, jsonEncode(pendingQueue));
  }

  // Clear entire queue
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  // Get queue statistics
  static Future<Map<String, int>> getQueueStats() async {
    final actions = await getPendingActions();
    final stats = <String, int>{};
    
    for (final action in actions) {
      final typeName = action.type.toString().split('.').last;
      stats[typeName] = (stats[typeName] ?? 0) + 1;
    }
    
    return stats;
  }

  // Process offline queue
  static Future<Map<String, dynamic>> processQueue() async {
    final results = <String, dynamic>{
      'success': 0,
      'failed': 0,
      'errors': <String>[],
    };

    final actions = await getPendingActions();
    
    for (final action in actions) {
      try {
        switch (action.type) {
          case OfflineActionType.memberRegistration:
            await _processMemberRegistration(action);
            break;
          case OfflineActionType.guestRegistration:
            await _processGuestRegistration(action);
            break;
          case OfflineActionType.memberCheckIn:
            await _processMemberCheckIn(action);
            break;
          case OfflineActionType.manifestScan:
            await _processManifestScan(action);
            break;
          case OfflineActionType.participantCheckIn:
            await _processParticipantCheckIn(action);
            break;
        }
        
        await markActionCompleted(action.id);
        results['success']++;
      } catch (e) {
        results['failed']++;
        results['errors'].add('${action.type}: ${e.toString()}');
      }
    }
    
    await removeCompletedActions();
    return results;
  }

  // Process member registration
  static Future<void> _processMemberRegistration(OfflineAction action) async {
    final memberNumbers = List<String>.from(action.data['memberNumbers']);
    await ApiService.bulkRegisterMembers(memberNumbers);
  }

  // Process guest registration
  static Future<void> _processGuestRegistration(OfflineAction action) async {
    final requestData = action.data['request'];
    final request = GuestRegistrationRequest.fromJson(requestData);
    
    // Check if the guest owner member exists, if not use default
    try {
      final memberDetails = await ApiService.getMemberDetails(request.guestOwner);
      if (memberDetails == null) {
        // Member not found, use default member number
        print('Guest owner member ${request.guestOwner} not found, using default: 7917');
        final updatedRequest = GuestRegistrationRequest(
          guestOwner: '7917', // Default member number
          lastName: request.lastName,
          firstName: request.firstName,
          middleName: request.middleName,
          phoneNumber: request.phoneNumber,
          email: request.email,
          gender: request.gender,
          address: request.address,
        );
        await ApiService.registerGuest(updatedRequest);
      } else {
        // Member found, proceed with original request
        await ApiService.registerGuest(request);
      }
    } catch (e) {
      // If there's an error checking member, use default
      print('Error checking guest owner member, using default: 7917');
      final updatedRequest = GuestRegistrationRequest(
        guestOwner: '7917', // Default member number
        lastName: request.lastName,
        firstName: request.firstName,
        middleName: request.middleName,
        phoneNumber: request.phoneNumber,
        email: request.email,
        gender: request.gender,
        address: request.address,
      );
      await ApiService.registerGuest(updatedRequest);
    }
  }

  // Process member check-in
  static Future<void> _processMemberCheckIn(OfflineAction action) async {
    final memberNumber = action.data['memberNumber'];
    final userId = action.data['userId'];
    await MemberService().checkInMemberOffline(memberNumber, userId);
  }

  // Process manifest scan
  static Future<void> _processManifestScan(OfflineAction action) async {
    final qrCode = action.data['qrCode'];
    await ApiService.scanManifest(qrCode);
  }

  // Process participant check-in
  static Future<void> _processParticipantCheckIn(OfflineAction action) async {
    final regNo = action.data['regNo'];
    await ApiService.checkInParticipant(regNo);
  }

  // Add member registration to queue
  static Future<void> queueMemberRegistration(List<String> memberNumbers) async {
    print('Queueing member registration for: $memberNumbers');
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.memberRegistration,
      data: {'memberNumbers': memberNumbers},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Add guest registration to queue
  static Future<void> queueGuestRegistration(GuestRegistrationRequest request) async {
    print('Queueing guest registration for: ${request.firstName} ${request.lastName}');
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.guestRegistration,
      data: {'request': request.toJson()},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Add member check-in to queue
  static Future<void> queueMemberCheckIn(String memberNumber, String userId) async {
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.memberCheckIn,
      data: {'memberNumber': memberNumber, 'userId': userId},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Add manifest scan to queue
  static Future<void> queueManifestScan(String qrCode) async {
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.manifestScan,
      data: {'qrCode': qrCode},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Add participant check-in to queue
  static Future<void> queueParticipantCheckIn(String regNo) async {
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.participantCheckIn,
      data: {'regNo': regNo},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Test method to add a sample action
  static Future<void> addTestAction() async {
    print('Adding test action to queue');
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineActionType.memberRegistration,
      data: {'memberNumbers': ['TEST001', 'TEST002']},
      timestamp: DateTime.now(),
    );
    await addToQueue(action);
  }

  // Debug method to print queue contents
  static Future<void> debugPrintQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      print('Raw queue JSON: $queueJson');
      
      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      print('Queue has ${queue.length} total items');
      
      for (int i = 0; i < queue.length; i++) {
        print('Item $i: ${queue[i]}');
      }
      
      final pendingActions = await getPendingActions();
      print('Pending actions: ${pendingActions.length}');
    } catch (e) {
      print('Error debugging queue: $e');
    }
  }
} 