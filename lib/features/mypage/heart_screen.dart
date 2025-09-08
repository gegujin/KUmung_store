import 'package:flutter/material.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바

class HeartPage extends StatefulWidget {
  const HeartPage({super.key});

  @override
  State<HeartPage> createState() => _HeartPageState();
}

class _HeartPageState extends State<HeartPage> {
  // 더미 데이터 (isLiked 추가)
  List<Map<String, dynamic>> likedProducts = [
    {
      'title': '컴공 과잠 팝니다',
      'location': '모시래마을',
      'time': '2일전',
      'likes': 5,
      'views': 30,
      'price': '30,000원',
      'isLiked': true,
    },
    {
      'title': '스마트폰 판매합니다',
      'location': '중앙동',
      'time': '1일전',
      'likes': 8,
      'views': 55,
      'price': '500,000원',
      'isLiked': true,
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      if (likedProducts[index]['isLiked']) {
        likedProducts[index]['isLiked'] = false;
        likedProducts[index]['likes'] =
            (likedProducts[index]['likes'] as int) - 1;
      } else {
        likedProducts[index]['isLiked'] = true;
        likedProducts[index]['likes'] =
            (likedProducts[index]['likes'] as int) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // Theme 색상 적용

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('관심목록', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: likedProducts.isEmpty
          ? const Center(child: Text("아직 좋아요한 상품이 없습니다."))
          : ListView.builder(
              itemCount: likedProducts.length,
              itemBuilder: (_, index) {
                final product = likedProducts[index];
                return InkWell(
                  onTap: () {
                    print("${product['title']} 클릭됨 (상품 상세로 이동 예정)");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상품 이미지
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 10),

                        // 상품 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 제목 + 하트
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product['title']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _toggleLike(index),
                                    child: Icon(
                                      product['isLiked']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: product['isLiked']
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // 위치 & 시간
                              Text(
                                '${product['location']} | ${product['time']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),

                              // 가격 + 찜/조회수
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('가격 ${product['price']}'),
                                  Text(
                                    '찜 ${product['likes']} 조회수 ${product['views']}',
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
      // bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
