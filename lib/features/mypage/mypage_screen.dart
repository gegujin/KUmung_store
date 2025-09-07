import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // ⭐ 별점 위젯
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바

// Screens
import '../mypage/point_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../friend/friend_screen.dart';
import '../mypage/heart_screen.dart';
import '../mypage/recent_post_screen.dart';
import '../mypage/sell_screen.dart';
import '../mypage/buy_screen.dart';

class MyPage extends StatelessWidget {
  /// 서버에서 받아올 별점 값 (기본 4.5)
  final double rating;

  const MyPage({super.key, this.rating = 4.5});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    Widget _buildDivider() {
      return const Divider(
        color: Color.fromARGB(255, 226, 226, 226),
        height: 1,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // 뒤로가기: 이전 화면으로 복귀
            Navigator.pop(context);
            // 만약 '홈으로 이동'이 의도라면 위 한 줄 대신 아래로 교체:
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          },
        ),
        title: const Text('마이페이지', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

            // ⭐ 별점 표시(Indicator)
            Center(
              child: RatingBarIndicator(
                rating: rating,              // 전달받은 값 사용
                itemCount: 5,
                itemSize: 28.0,
                unratedColor: const Color(0xFFE0E0E0),
                itemBuilder: (_, __) => const Icon(
                  Icons.star,
                  color: Color(0xFFF4A623),
                ),
                direction: Axis.horizontal,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              "$rating / 5.0",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

            // ▼ 목록
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
                  MaterialPageRoute(builder: (_) => const BuyPage()),
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
