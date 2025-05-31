import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'user';
  late SharedPreferences _prefs;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<User?> login(String username, String password) async {
    // Mock backend authentication
    await Future.delayed(const Duration(seconds: 1));
    
    if (username == 'admin' && password == 'password') {
      final user = User(
        id: '1',
        name: 'Admin User',
        role: 'admin',
      );
      
      // Store user data
      await _prefs.setString(_userKey, 'logged_in');
      return user;
    }
    
    return null;
  }

  Future<void> logout() async {
    await _prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getString(_userKey) != null;
  }
} 