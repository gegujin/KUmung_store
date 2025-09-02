import 'package:flutter/material.dart';

class HeartPage extends StatelessWidget {
  const HeartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    // 더미 데이터
    final List<Map<String, String>> likedProducts = [
      {
        'title': '컴공 과잠 팝니다',
        'location': '모시래마을',
        'time': '2일전',
        'likes': '5',
        'views': '30',
        'price': '30,000원',
      },
      {
        'title': '스마트폰 판매합니다',
        'location': '중앙동',
        'time': '1일전',
        'likes': '8',
        'views': '55',
        'price': '500,000원',
      },
    ];

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
                              Text(
                                product['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${product['location']} | ${product['time']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '찜 ${product['likes']} 조회수 ${product['views']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('가격 ${product['price']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
