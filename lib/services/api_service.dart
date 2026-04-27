import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$API_BASE_URL/auth/login');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: \n${res.body}');
  }

  static Future<Map<String, dynamic>> generateForm(
      String token, Map<String, dynamic> payload) async {
    final url = Uri.parse('$API_BASE_URL/forms/generate');
    final res = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(payload));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Form generation failed: \n${res.body}');
  }

  static Future<Map<String, dynamic>> chat(String token, String message) async {
    final url = Uri.parse('$API_BASE_URL/chat');
    final res = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'message': message}));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Chat failed: \n${res.body}');
  }
}
