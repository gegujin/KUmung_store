import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kumeong_store/features/chat/chat_list_screen.dart';
import 'package:kumeong_store/features/mypage/mypage_screen.dart';
import 'package:kumeong_store/features/mypage/heart_screen.dart'; // ✅ 관심목록

/// 공용 하단바
/// - currentIndex: 0 홈 / 1 채팅 / 2 관심목록 / 3 마이페이지
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2E7D6B), // 선택 아이템 색
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '1:1채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '관심목록'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이페이지'),
      ],
      onTap: (index) {
        if (index == currentIndex) return; // 같은 탭이면 무시

        switch (index) {
          case 0: // 홈
            context.goNamed('home'); // 홈 라우트 이름 맞게 변경 필요
            break;
          case 1: // 채팅
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
            break;
          case 2: // 관심목록
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeartPage()),
            );
            break;
          case 3: // 마이페이지
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPage()),
            );
            break;
        }
      },
    );
  }
}
