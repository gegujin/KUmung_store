import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 🔧 라우트 이름 상수 가져오기
import 'package:kumeong_store/core/router/route_names.dart';

/// 공용 하단바
/// - currentIndex: 0 홈 / 1 채팅 / 2 관심목록 / 3 마이페이지
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});
  final int currentIndex;

  // 🔧 라우트 이름 매핑 수정: 'chatList' → RouteNames.chat
  static const _routeNames = [
    RouteNames.home,
    RouteNames.chat,       // ✅ 이게 채팅 리스트 루트(/chat)입니다
    RouteNames.favorites,
    RouteNames.mypage,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2E7D6B),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '1:1채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '관심목록'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이페이지'),
      ],
      onTap: (index) {
        // ✅ 각 탭의 루트로 점프
        context.goNamed(_routeNames[index]);
      },
    );
  }
}
