import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  AuthData? _userData;
  bool _isLoading = false;

  String? get token => _token;
  AuthData? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Initialize auth state from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    notifyListeners();
  }

  // Set authentication data
  void setAuthData(String token, AuthData userData) {
    _token = token;
    _userData = userData;
    _saveToStorage();
    notifyListeners();
  }

  // Clear authentication data
  Future<void> logout() async {
    _token = null;
    _userData = null;
    await _clearStorage();
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Save to local storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_userData != null) {
      await prefs.setString('user_data', _userData!.userName);
    }
  }

  // Clear local storage
  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Get authorization header
  String? get authorizationHeader {
    if (_token != null) {
      return 'Bearer $_token';
    }
    return null;
  }
} 