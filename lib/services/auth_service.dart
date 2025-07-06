import 'package:reg_team_app/services/api_service.dart';
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

  Future<User?> login(String membershipNumber) async {
    final response = await ApiService.login(membershipNumber);
    
    if (response.status) {
      return User.fromJson(response.data.toJson());
    }
    
    return null;
  }

  Future<void> logout() async {
    await _prefs.remove("auth_token");
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getString("auth_token") != null;
  }
} 