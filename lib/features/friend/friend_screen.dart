import 'package:flutter/material.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바
import '../friend/friend_detail_screen.dart';
import '../friend/friend_plus_screen.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // 더미 친구 데이터
  final List<String> friends = ['김수인', '김서진', '박민수', '최지우', '홍길동'];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    // 검색 필터
    final filteredFriends =
        friends.where((friend) => friend.contains(searchQuery)).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: mainColor,
            child: Row(
              children: [
                // 검색창
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "친구 검색",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // ✅ 친구 추가 버튼
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.white),
                  onPressed: () async {
                    final newFriends = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendPlusPage(currentFriends: friends),
                      ),
                    );

                    if (newFriends != null && newFriends.isNotEmpty) {
                      setState(() {
                        // ✅ 이미 있는 친구는 제외하고 추가
                        for (var friend in newFriends) {
                          if (!friends.contains(friend)) {
                            friends.add(friend);
                          }
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // ✅ 친구 수 표시
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "친구 ${filteredFriends.length}명",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ✅ 친구 목록
          Expanded(
            child: ListView.separated(
              itemCount: filteredFriends.length,
              separatorBuilder: (_, __) => const Divider(height: 30),
              itemBuilder: (_, index) {
                final friend = filteredFriends[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    child: Text(friend[0]), // 첫 글자로 프로필
                  ),
                  title: Text(friend),
                  onTap: () {
                    // 클릭 시 친구 상세 화면 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendDetailPage(friendName: friend),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ✅ 하단 네비게이션
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
