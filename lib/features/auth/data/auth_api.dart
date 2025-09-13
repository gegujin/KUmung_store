import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('\/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      if (body is Map && body['ok'] == true && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      final msg = (body is Map && body['error'] is String)
          ? body['error'] as String
          : '로그인 실패';
      throw Exception(msg);
    }
    throw Exception('HTTP \: \');
  }
}
