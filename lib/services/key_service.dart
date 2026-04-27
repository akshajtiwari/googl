import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class KeyService {
  static Future<String?> fetchGeminiKey() async {
    final url = '${Config.backendBaseUrl}/keys/gemini';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body['key'] is String) return body['key'] as String;
      } catch (_) {}
      return null;
    }
    throw Exception('Failed to fetch Gemini key: ${resp.statusCode}');
  }

  static Future<String?> fetchGoogleKey() async {
    final url = '${Config.backendBaseUrl}/keys/google';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body['key'] is String) return body['key'] as String;
      } catch (_) {}
      return null;
    }
    throw Exception('Failed to fetch Google key: ${resp.statusCode}');
  }
}
