import 'package:flutter/material.dart';
import 'package:kumeong_store/features/chat/chat_list_screen.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바
import '../mypage/point_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../friend/friend_screen.dart';
import '../mypage/heart_screen.dart';
import '../mypage/recent_post_screen.dart';
import '../mypage/sell_screen.dart';
import '../mypage/buy_screen.dart';

class MyPage extends StatelessWidget {
  // ⭐ 서버에서 받아올 별점 값 (지금은 기본값 4.5)
  final double rating;

  const MyPage({super.key, this.rating = 4.5});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // Theme 색상 적용

    Widget _buildDivider() {
      return const Divider(
        color: Color.fromARGB(255, 226, 226, 226),
        height: 1,
      );
    }

    // ⭐ 별 아이콘 생성 함수
    List<Widget> _buildStars(double rating) {
      List<Widget> stars = [];
      for (int i = 1; i <= 5; i++) {
        if (i <= rating.floor()) {
          stars.add(const Icon(Icons.star, color: Colors.amber, size: 28));
        } else if (i - rating <= 0.5) {
          stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 28));
        } else {
          stars.add(
              const Icon(Icons.star_border, color: Colors.amber, size: 28));
        }
      }
      return stars;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
        title: const Text('마이페이지', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
            const SizedBox(height: 10),
            const Text('사용자 이름', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            // ⭐ 별점 표시 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._buildStars(rating),
                const SizedBox(width: 8),
                Text(
                  "$rating / 5.0",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PointPage()),
                    );
                  },
                  icon: const Icon(Icons.monetization_on, size: 20),
                  label: const Text('포인트', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('450원', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('친구목록'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendsPage()),
                );
              },
            ),
            _buildDivider(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('관심목록'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HeartPage()),
                );
              },
            ),
            _buildDivider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('최근 본 게시글'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecentPostPage()),
                );
              },
            ),
            _buildDivider(),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('판매내역'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellPage()),
                );
              },
            ),
            _buildDivider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('구매내역'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyPage()), // 연결
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
