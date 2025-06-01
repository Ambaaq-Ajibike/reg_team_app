import 'package:http/http.dart' as http;
import 'package:reg_team_app/constants/api_constants.dart';
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
    final response = await ApiService.login("Auth/token", {
      "userName": membershipNumber
    });
    
    final userDetails = User.fromJson(response["data"]);
    
    return userDetails;
  }

  Future<void> logout() async {
    await _prefs.remove("auth_token");
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getString("auth_token") != null;
  }
} 