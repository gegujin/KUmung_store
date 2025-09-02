import 'package:flutter/material.dart';

class FriendPlusPage extends StatefulWidget {
  final List<String> currentFriends;

  const FriendPlusPage({super.key, required this.currentFriends});

  @override
  State<FriendPlusPage> createState() => _FriendPlusPageState();
}

class _FriendPlusPageState extends State<FriendPlusPage> {
  // 더미 유저 데이터
  final List<String> allUsers = [
    '김수인',
    '김서진',
    '박민수',
    '최지우',
    '홍길동',
    '이예솔',
    '정하늘',
    '한지민',
    '박지훈',
    '최민호',
  ];

  final List<String> addedFriends = []; // 추가 친구
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    // 검색 결과
    final searchResults = allUsers
        .where(
          (user) =>
              user.contains(searchQuery) &&
              !addedFriends.contains(user) &&
              !widget.currentFriends.contains(user),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text("친구 추가", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // 완료 버튼
          TextButton(
            onPressed: () {
              Navigator.pop(context, addedFriends);
            },
            child: const Text(
              "완료",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 검색창
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "아이디로 친구 검색",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          // ✅ 검색 결과
          Expanded(
            child: searchQuery.isEmpty
                ? const Center(child: Text("친구를 검색해보세요"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, index) {
                      final user = searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          child: Text(user[0]),
                        ),
                        title: Text(user),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              addedFriends.add(user);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
