import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_team_app/constants/api_constants.dart';
import 'package:reg_team_app/models/member_details.dart';
import 'package:reg_team_app/models/registration_response.dart';
import 'package:reg_team_app/models/guest_registration.dart';
import 'package:reg_team_app/models/auth_response.dart';
import 'package:reg_team_app/models/scan_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<AuthResponse> login(String userName) async {
    final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Auth/token');
    final response = await http.post(
      url,
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userName': userName,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(jsonResponse);
      
      // Extract token from response headers
      final token = response.headers['token'];
      if (token != null && authResponse.status) {
        // Store token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }

      return authResponse;
    } else {
      throw Exception('Login failed: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<dynamic> postRequest(BuildContext context, endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");
    final response = await http.post(url, 
    headers: {
      "Content-Type": 'application/json',
      "Authorization": "Bearer $token"
    },
    body: jsonEncode(body));
    if(response.statusCode == 401){
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }
    else if(response.statusCode == 200){
      return response.body;
    }
    else{
      throw Exception("Failed post request, ${response.statusCode} - ${response.body}");
    }
  }

  static Future<MemberDetails?> getMemberDetails(String memberNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Members/$memberNumber');
      final response = await http.get(
        url,
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['succeeded'] == true && jsonResponse['data'] != null) {
          return MemberDetails.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching member details: $e');
      return null;
    }
  }

  static Future<RegistrationResponse?> bulkRegisterMembers(List<String> memberNumbers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Participants/members/bulk-registration');
      final response = await http.post(
        url,
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(memberNumbers),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return RegistrationResponse.fromJson(jsonResponse);
      }
      return null;
    } catch (e) {
      print('Error bulk registering members: $e');
      return null;
    }
  }

  static Future<GuestRegistrationResponse?> registerGuest(GuestRegistrationRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Participants/guests');
      final response = await http.post(
        url,
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GuestRegistrationResponse.fromJson(jsonResponse);
      }
      return null;
    } catch (e) {
      print('Error registering guest: $e');
      return null;
    }
  }

  static Future<ScanResponse?> checkInParticipant(String regNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Participants/inapp-checkin?regNo=$regNo');
      final response = await http.put(
        url,
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ScanResponse.fromJson(jsonResponse);
      }
      return null;
    } catch (e) {
      print('Error checking in participant: $e');
      return null;
    }
  }

  static Future<ScanResponse?> scanManifest(String qrCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('https://jarms.ahmadiyyanigeria.net/api/Manifests/inapp-scan?QRCode=$qrCode');
      final response = await http.get(
        url,
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ScanResponse.fromJson(jsonResponse);
      }
      return null;
    } catch (e) {
      print('Error scanning manifest: $e');
      return null;
    }
  }
}
