import 'package:flutter/material.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바

class RecentPostPage extends StatelessWidget {
  const RecentPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // Theme 색상 적용

    // 더미 데이터 (최신순 정렬 가정)
    final List<Map<String, String>> recentPosts = [
      {
        'title': '아이패드 팝니다',
        'location': '중앙동',
        'time': '1시간 전',
        'price': '400,000원',
        'views': '12',
      },
      {
        'title': '컴공 과잠 팝니다',
        'location': '모시래마을',
        'time': '5시간 전',
        'price': '30,000원',
        'views': '8',
      },
      {
        'title': '책상 나눔합니다',
        'location': '신촌',
        'time': '1일 전',
        'price': '무료나눔',
        'views': '22',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('최근 본 게시글', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: recentPosts.isEmpty
          ? const Center(child: Text("최근 본 게시물이 없습니다."))
          : ListView.builder(
              itemCount: recentPosts.length,
              itemBuilder: (_, index) {
                final post = recentPosts[index];
                return InkWell(
                  onTap: () {
                    print("${post['title']} 클릭됨 (상품 상세로 이동 예정)");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // 사진(임시)
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 10),

                        // 게시물 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${post['location']} · ${post['time']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('가격 ${post['price']}'),
                                  Text(
                                    '조회수 ${post['views']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
