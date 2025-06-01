import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reg_team_app/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<dynamic> login(endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");
    final response = await http.post(url, headers: {
                      'Content-Type': "application/json",
                    },
                    body: jsonEncode(body));
    if(response.statusCode == 200){
      
      final token = response.headers["token"];
      if(token != null){
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
      }

      return jsonDecode(response.body);

    }
    else{
      throw Exception("Failed login request, ${response.statusCode} - ${response.body}");
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
}
