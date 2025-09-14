class Env {
  /// API 베이스 URL (개발 기본값: 에뮬레이터 로컬 서버)
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// 필요 시 Uri 형태로 사용
  static Uri get apiBaseUri => Uri.parse(apiBase);
}
