import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/theme.dart';
import 'core/router.dart'; // ✅ 단일 라우터

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 전역 탭 시 키보드 닫기(UX 보완)
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusManager.instance.primaryFocus;
        if (currentFocus != null && !currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp.router(
        title: 'KU멍가게',
        debugShowCheckedModeBanner: false,
        theme: appTheme,      // ✅ theme.dart
        routerConfig: router, // ✅ go_router 최신 스타일

        // ↓↓↓ 만약 Flutter SDK가 낮아서 routerConfig를 못 쓴다면,
        // 아래 3개를 주석 해제하고 routerConfig 한 줄을 주석 처리하세요.
        // routeInformationProvider: router.routeInformationProvider,
        // routeInformationParser: router.routeInformationParser,
        // routerDelegate: router.routerDelegate,
      ),
    );
  }
}
