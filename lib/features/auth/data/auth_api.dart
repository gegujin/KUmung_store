import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // base + path 안전 결합
    final uri = Env.apiBaseUri.resolve('/auth/login');

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);

    // { ok: true, data: {...} } 패턴
    if (body is Map && body['ok'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    // 바로 토큰을 주는 단순 Map 패턴
    if (body is Map<String, dynamic>) {
      return body;
    }

    final msg = (body is Map && body['error'] is String)
        ? body['error'] as String
        : '로그인 응답 형식이 올바르지 않습니다';
    throw Exception(msg);
  }
}
