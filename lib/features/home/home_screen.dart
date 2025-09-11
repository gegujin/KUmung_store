import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_signup_screen.dart';
import 'package:kumeong_store/models/post.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart';
import '../product/product_list_screen.dart';
import '../home/alarm_screen.dart';
import 'package:kumeong_store/core/ui/hero_tags.dart';
import '../../core/theme.dart';
import '../mypage/mypage_screen.dart';
import 'package:kumeong_store/core/router/route_names.dart' as R;

// ✅ KU 전용 색상 상수
const Color kuInfo = Color(0xFF147AD6);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> allProducts = [
    {
      'title': 'Willson 농구공 팝니다',
      'location': '신촌운동장',
      'time': '2일전',
      'likes': 1,
      'views': 5,
      'price': '25,000원',
      'isLiked': true,
    },
    {
      'title': '컴공 과잠 팝니다',
      'location': '모시래마을',
      'time': '3일전',
      'likes': 1,
      'views': 5,
      'price': '30,000원',
      'isLiked': true,
    },
    {
      'title': '스마트폰 판매합니다',
      'location': '중앙동',
      'time': '1일전',
      'likes': 0,
      'views': 20,
      'price': '500,000원',
      'isLiked': false,
    },
  ];

  String searchText = '';
  bool _isMenuOpen = false; // ✅ 메뉴 열림/닫힘 상태

  void _toggleLike(int index) {
    setState(() {
      final liked = allProducts[index]['isLiked'] as bool;
      final likes = allProducts[index]['likes'] as int;
      allProducts[index]['isLiked'] = !liked;
      allProducts[index]['likes'] = liked ? likes - 1 : likes + 1;
    });
  }

  void _toggleFabMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    final filteredProducts = allProducts
        .where((p) => (p['title'] as String)
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    // ❗️demoProduct가 프로젝트에 이미 존재한다고 가정 (models/post.dart)
    // 존재하지 않는다면 'demo-product'로 대체
    final productId = (demoProduct.id.isNotEmpty) ? demoProduct.id : 'demo-product';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: mainColor,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => context.pushNamed(R.RouteNames.categories), // ✅
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '상품 검색',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                ),
                onChanged: (v) => setState(() => searchText = v),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () => context.pushNamed(R.RouteNames.alarms), // ✅
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 상품 리스트
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 120), // ✅ FAB/메뉴 영역 여유
            itemCount: filteredProducts.length,
            itemBuilder: (_, index) {
              final product = filteredProducts[index];

              return InkWell(
                onTap: () => context.pushNamed( // ✅ 상세는 push
                  R.RouteNames.productDetail,
                  pathParameters: {'productId': productId},
                  extra: demoProduct,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _toggleLike(index),
                                child: Icon(
                                  (product['isLiked'] as bool)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (product['isLiked'] as bool) ? Colors.red : Colors.grey,
                                  size: 22,
                                ),
                              ),
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

          // ✅ (옵션) 바깥 터치로 메뉴 닫기용 투명 오버레이
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleFabMenu,
                child: const SizedBox.shrink(),
              ),
            ),

          // FAB 메뉴
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            right: 16,
            bottom: _isMenuOpen ? 100 : 80,
            curve: Curves.easeOut,

            // ✅ 핵심: 닫혀 있을 땐 터치 완전 차단 (히트 테스트 불가)
            child: IgnorePointer(
              ignoring: !_isMenuOpen,
              child: AnimatedOpacity(
                opacity: _isMenuOpen ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.delivery_dining,
                      iconColor: kuInfo,
                      label: 'KU대리',
                      onTap: () {
                        _toggleFabMenu();
                        context.pushNamed(R.RouteNames.kuDeliverySignup); // ✅
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F5)),
                    _MenuItem(
                      icon: Icons.add_box_outlined,
                      iconColor: Color(0xFFFF6A00),
                      label: '상품 등록',
                      onTap: () {
                        _toggleFabMenu();
                        context.pushNamed( // ✅
                          R.RouteNames.productEdit,
                          pathParameters: {'productId': productId},
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ✅ FAB: 루트에서만 히어로 참여 + 고유 태그(브랜치 네임스페이스)
      floatingActionButton: HeroMode(
        enabled: (ModalRoute.of(context)?.isFirst ?? true),
        child: FloatingActionButton(
          heroTag: heroTagFab('home'),
          backgroundColor: mainColor,
          onPressed: _toggleFabMenu,
          child: Icon(_isMenuOpen ? Icons.close : Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
