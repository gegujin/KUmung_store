import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/features/chat/chat_list_screen.dart';
import 'package:kumeong_store/models/post.dart'; // demoProduct 사용
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바
import '../product/product_list_screen.dart';
import '../home/alarm_screen.dart';
import '../mypage/mypage_screen.dart';
import '../../core/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 더미 상품 데이터
  final List<Map<String, dynamic>> allProducts = [
    {
      'title': '컴공 과잠 팝니다',
      'location': '모시래마을',
      'time': '2일전',
      'likes': 1,
      'views': 5,
      'price': '30,000원',
      'isLiked': false,
    },
    {
      'title': '스마트폰 판매합니다',
      'location': '중앙동',
      'time': '1일전',
      'likes': 3,
      'views': 20,
      'price': '500,000원',
      'isLiked': false,
    },
    {
      'title': '책상 나눔합니다',
      'location': '신촌',
      'time': '3일전',
      'likes': 0,
      'views': 10,
      'price': '15,000원',
      'isLiked': false,
    },
    {
      'title': '컴공 과잠 새상품',
      'location': '모시래마을',
      'time': '5일전',
      'likes': 2,
      'views': 7,
      'price': '35,000원',
      'isLiked': false,
    },
  ];

  String searchText = '';

  void _toggleLike(int index) {
    setState(() {
      if (allProducts[index]['isLiked']) {
        allProducts[index]['isLiked'] = false;
        allProducts[index]['likes'] = (allProducts[index]['likes'] as int) - 1;
      } else {
        allProducts[index]['isLiked'] = true;
        allProducts[index]['likes'] = (allProducts[index]['likes'] as int) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // Theme 기반 색상
    final kux = Theme.of(context).extension<KuColors>()!;

    // 검색어 기반 필터링
    List<Map<String, dynamic>> filteredProducts = allProducts
        .where((product) =>
            product['title']!.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    final productId =
        (demoProduct.id.isNotEmpty) ? demoProduct.id : 'demo-product';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: mainColor,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryPage()),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: '상품 검색',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlarmPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (_, index) {
          final product = filteredProducts[index];
          return InkWell(
            onTap: () {
              context.goNamed(
                'productDetail',
                pathParameters: {'productId': productId},
                extra: demoProduct,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 80, color: Colors.grey[300]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 + 하트
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product['title'],
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
                        Text(
                          '${product['location']} | ${product['time']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: kuInfo,
            child: const Text('KU대리', style: TextStyle(color: Colors.white)),
            onPressed: () {
              context.pushNamed('deliveryFeed');
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: mainColor,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              context.goNamed(
                'productEdit',
                pathParameters: {'productId': productId},
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
