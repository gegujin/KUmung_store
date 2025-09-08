// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ===== Screens =====
import 'package:kumeong_store/features/home/home_screen.dart' show HomePage;
import 'package:kumeong_store/features/product/product_detail_screen.dart';
import 'package:kumeong_store/features/product/product_edit_screen.dart';
import 'package:kumeong_store/features/chat/chat_list_screen.dart';
import 'package:kumeong_store/features/mypage/mypage_screen.dart' show MyPage;
import 'package:kumeong_store/features/mypage/point_screen.dart' show PointPage;
import 'package:kumeong_store/features/mypage/heart_screen.dart' show HeartPage;
import 'package:kumeong_store/models/post.dart' show Product;

// ✅ 하단바 전역 1회 부착
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart';

/// 현재 경로로부터 하단 탭 인덱스 계산
int _indexForPath(String path) {
  if (path.startsWith('/chat')) return 1;
  if (path.startsWith('/favorites')) return 2;
  if (path.startsWith('/mypage')) return 3;
  return 0; // 기본: 홈
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final idx = _indexForPath(state.uri.path);
        return Scaffold(
          body: child,
          bottomNavigationBar: AppBottomNav(currentIndex: idx),
        );
      },
      routes: [
        // ───────────────── 0) HOME
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
          routes: [
            GoRoute(
              path: 'product/:productId',
              name: 'productDetail', // HomePage → goNamed('productDetail')
              builder: (context, state) {
                final id = state.pathParameters['productId']!;
                final extra = state.extra;
                return ProductDetailScreen(
                  productId: id,
                  initialProduct: extra is Product ? extra : null,
                );
              },
            ),
            GoRoute(
              path: 'edit/:productId',
              name: 'productEdit', // HomePage → goNamed('productEdit')
              builder: (context, state) {
                final id = state.pathParameters['productId']!;
                final extra = state.extra;
                return ProductEditScreen(
                  productId: id,
                  initialProduct: extra is Product ? extra : null,
                );
              },
            ),
          ],
        ),

        // ───────────────── 1) CHAT (루트 = 채팅 리스트)
        GoRoute(
          path: '/chat',
          name: 'chat',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChatListScreen()),
          routes: [
            GoRoute(
              path: 'room/:roomId',
              name: 'chatRoom',
              builder: (context, state) {
                final roomId = state.pathParameters['roomId']!;
                // 실제 ChatRoomScreen이 생기면 교체
                return _ChatRoomPlaceholder(roomId: roomId);
              },
            ),
          ],
        ),

        // ───────────────── 2) FAVORITES
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HeartPage()),
        ),

        // ───────────────── 3) MYPAGE
        GoRoute(
          path: '/mypage',
          name: 'mypage',
          pageBuilder: (context, state) =>
            const NoTransitionPage(child: MyPage()),
          routes: [
            GoRoute(
              path: 'points',
              name: 'points',
              builder: (context, state) => const PointPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── 임시 채팅방 화면(실제 ChatRoomScreen 작성 시 교체)
class _ChatRoomPlaceholder extends StatelessWidget {
  final String roomId;
  const _ChatRoomPlaceholder({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채팅방')),
      body: Center(child: Text('채팅방($roomId) 화면은 아직 연결되지 않았습니다.')),
    );
  }
}
