import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 공용 하단바
/// - currentIndex: 0 홈 / 1 채팅 / 2 관심목록 / 3 마이페이지
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});
  final int currentIndex;

  // 루트 라우트 네임 매핑
  static const _routeNames = ['home', 'chatList', 'favorites', 'mypage'];

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
        // ✅ 어떤 탭을 눌러도 해당 탭의 "루트" 네임드 라우트로 이동
        //    (서브페이지에 있어도 항상 루트로 점프)
        context.goNamed(_routeNames[index]);
      },
    );
  }
}
