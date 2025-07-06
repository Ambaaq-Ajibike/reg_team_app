import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';

class MemberService {
  static const String _offlineQueueKey = 'offline_queue';
  late SharedPreferences _prefs;

  // Singleton pattern
  static final MemberService _instance = MemberService._internal();
  factory MemberService() => _instance;
  MemberService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Mock member data
  final List<Member> _mockMembers = [
    Member(
      id: '1',
      memberNumber: 'M001',
      name: 'John Doe',
      jamaat: 'London',
      circuit: 'UK South',
    ),
    Member(
      id: '2',
      memberNumber: 'M002',
      name: 'Jane Smith',
      jamaat: 'Manchester',
      circuit: 'UK North',
    ),
    // Add more mock members as needed
  ];

  Future<List<Member>> searchMembers({
    String? query,
    String? jamaat,
    String? circuit,
  }) async {
    // Mock backend search
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (query == null && jamaat == null && circuit == null) {
      return _mockMembers;
    }

    return _mockMembers.where((member) {
      bool matches = true;
      
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        matches = matches && (member.name.toLowerCase().contains(lowercaseQuery) ||
            member.memberNumber.toLowerCase().contains(lowercaseQuery));
      }
      
      if (jamaat != null && jamaat.isNotEmpty) {
        matches = matches && member.jamaat == jamaat;
      }
      
      if (circuit != null && circuit.isNotEmpty) {
        matches = matches && member.circuit == circuit;
      }
      
      return matches;
    }).toList();
  }

  Future<Member?> getMemberByTag(String tag) async {
    // Mock backend API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMembers.firstWhere(
      (member) => member.memberNumber == tag,
      orElse: () => throw Exception('Member not found'),
    );
  }

  Future<void> checkInMember(Member member, String userId) async {
    // Check if we're online (mock check)
    final bool isOnline = true; // In real app, check internet connectivity

    if (isOnline) {
      // Mock backend API call
      await Future.delayed(const Duration(milliseconds: 500));
      member.isCheckedIn = true;
      member.checkInTime = DateTime.now();
      member.checkedInBy = userId;
    } else {
      // Store in offline queue
      final queue = await _getOfflineQueue();
      queue.add(member.toJson());
      await _prefs.setString(_offlineQueueKey, jsonEncode(queue));
    }
  }

  Future<void> syncOfflineData() async {
    final queue = await _getOfflineQueue();
    if (queue.isEmpty) return;

    // Mock backend sync
    await Future.delayed(const Duration(seconds: 1));
    
    // Clear queue after successful sync
    await _prefs.remove(_offlineQueueKey);
  }

  Future<List<Map<String, dynamic>>> _getOfflineQueue() async {
    final String? queueStr = _prefs.getString(_offlineQueueKey);
    if (queueStr == null) return [];
    
    final List<dynamic> queueJson = jsonDecode(queueStr);
    return queueJson.cast<Map<String, dynamic>>();
  }
} 