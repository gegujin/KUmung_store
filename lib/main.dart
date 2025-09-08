import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/theme.dart';
import 'core/router/app_router.dart'; // ✅ 새 라우터 경로로 변경

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
        theme: appTheme,        // ✅ theme.dart
        routerConfig: appRouter, // ✅ app_router.dart의 GoRouter

        // ↓↓↓ Flutter SDK가 낮아 routerConfig를 못 쓰면 아래 3줄 사용
        // routeInformationProvider: appRouter.routeInformationProvider,
        // routeInformationParser: appRouter.routeInformationParser,
        // routerDelegate: appRouter.routerDelegate,
      ),
    );
  }
}
