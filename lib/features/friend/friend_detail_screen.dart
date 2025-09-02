import 'package:flutter/material.dart';
import '../friend/friend_chat_screen.dart';

class FriendDetailPage extends StatelessWidget {
  final String friendName;

  const FriendDetailPage({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(friendName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Text(
                friendName[0],
                style: const TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            const SizedBox(height: 15),

            // 이름
            Text(
              friendName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 별점 (임시 더미)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 28),
              ),
            ),
            const SizedBox(height: 20),

            // 판매내역 (임시 더미)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "판매내역",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text("노트북 판매"),
                    subtitle: Text("2025-08-01"),
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text("책 판매"),
                    subtitle: Text("2025-07-25"),
                  ),
                ],
              ),
            ),

            // ✅ 채팅하기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendChatPage(friendName: friendName),
                    ),
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text(
                  "채팅하기",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
