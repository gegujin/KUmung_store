// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/theme.dart';
import 'core/router/app_router.dart'; // ✅ 새 라우터

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // timeago 한국어 등록
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  // ✅ 네이버 지도 SDK 초기화 (모바일만)
  if (!kIsWeb) {
    await NaverMapSdk.instance.initialize(
      clientId: '여기에_네이버맵_CLIENT_ID', // TODO: 실제 Client ID 로 교체
      // onAuthFailed: (e) => debugPrint('NaverMap auth failed: $e'),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 전역 탭 시 키보드 닫기(UX)
    return GestureDetector(
      onTap: () {
        final f = FocusManager.instance.primaryFocus;
        if (f != null && !f.hasPrimaryFocus) f.unfocus();
      },
      child: MaterialApp.router(
        title: 'KU멍가게',
        debugShowCheckedModeBanner: false,
        theme: appTheme,         // ✅ theme.dart
        routerConfig: appRouter, // ✅ app_router.dart의 GoRouter

        // ↓ Flutter SDK가 낮아 routerConfig 미지원 시 아래 3줄 사용
        // routeInformationProvider: appRouter.routeInformationProvider,
        // routeInformationParser: appRouter.routeInformationParser,
        // routerDelegate: appRouter.routerDelegate,
      ),
    );
  }
}
