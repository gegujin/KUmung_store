import 'package:flutter/material.dart';
import 'package:kumeong_store/features/chat/chat_list_screen.dart';
import '../mypage/point_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../mypage/edit_profile_screen.dart';
import '../friend/friend_screen.dart';
import '../mypage/heart_screen.dart';
import '../mypage/recent_post_screen.dart';
import '../mypage/sell_screen.dart';
import '../mypage/buy_screen.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                  backgroundColor: const Color(0xFFAED581),
                ),
                child: const Text(
                  '프로필 수정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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
                  MaterialPageRoute(builder: (_) => const BuyPage()), // ✅ 연결
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '1:1채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          }
        },
      ),
    );
  }
}
