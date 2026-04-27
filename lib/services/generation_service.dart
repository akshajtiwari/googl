import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class GenerationService {
  /// Sends a prompt and generation parameters to the backend.
  /// Expects the backend to return JSON: { "fields": ["Full name", "Email", ...] }
  static Future<List<String>> generateForm({
    required String prompt,
    required String model,
    required double temperature,
    required int maxTokens,
  }) async {
    final url = '${Config.backendBaseUrl}/generate/form';
    final resp = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'model': model,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body is Map && body['fields'] is List) {
        final List fields = body['fields'];
        return fields.map((e) => e.toString()).toList();
      }
      return [];
    }
    throw Exception('Generation failed: ${resp.statusCode} ${resp.body}');
  }
}
