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

  // ───────── FAB 오버레이 메뉴
  OverlayEntry? _menuEntry;

  void _openFabMenu() {
    if (_menuEntry != null) return;
    final productId = (demoProduct.id.isNotEmpty) ? demoProduct.id : 'demo-product';

    _menuEntry = OverlayEntry(
      builder: (ctx) => _FabVerticalMenu(
        // 부모 context를 전달받아 라우팅 실행
        onClose: _closeFabMenu,
        onPost: () {
          _closeFabMenu();
          context.goNamed('productEdit', pathParameters: {'productId': productId});
        },
        onKuDelivery: () {
          _closeFabMenu();
          context.pushNamed('deliveryFeed');
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_menuEntry!);
  }

  void _closeFabMenu() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  @override
  void dispose() {
    _closeFabMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;
    final kux = Theme.of(context).extension<KuColors>()!;

    final filteredProducts = allProducts
        .where((p) => (p['title'] as String)
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    final productId = (demoProduct.id.isNotEmpty) ? demoProduct.id : 'demo-product';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ← 오타 수정된 속성
        backgroundColor: mainColor,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '상품 검색',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                ),
                onChanged: (v) => setState(() => searchText = v),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmPage())),
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
              context.goNamed('productDetail', pathParameters: {'productId': productId}, extra: demoProduct);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(product['title'], style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                            GestureDetector(
                              onTap: () => _toggleLike(index),
                              child: Icon(
                                product['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                color: product['isLiked'] ? Colors.red : Colors.grey,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${product['location']} | ${product['time']}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('가격 ${product['price']}'),
                            Text('찜 ${product['likes']} 조회수 ${product['views']}', style: const TextStyle(color: Colors.grey)),
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

      // 메인 버튼 1개만 두고, 누르면 우측 하단에 세로 메뉴를 띄움
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: _openFabMenu,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

/// ───────────────────────── FAB 세로 메뉴(스크린샷 스타일)
class _FabVerticalMenu extends StatelessWidget {
  const _FabVerticalMenu({
    required this.onClose,
    required this.onPost,
    required this.onKuDelivery,
  });

  final VoidCallback onClose;
  final VoidCallback onPost;
  final VoidCallback onKuDelivery;

  @override
  Widget build(BuildContext context) {
    // 화면 클릭 시 닫기 위해 반투명 배리어 + Positioned 메뉴
    return Stack(
      children: [
        // 반투명 배경 (탭하면 닫힘)
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
        ),
        // 메뉴 박스 + 닫기버튼 (오른쪽 아래)
        Positioned(
          right: 16,
          bottom: 92, // 하단바+FAB 위로 살짝 띄우기
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1) KU대리 / 2) 상품 등록 — 세로 정렬
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.delivery_dining,
                    iconColor: const Color(0xFF147AD6), // kuInfo
                    label: 'KU대리',
                    onTap: onKuDelivery,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  _MenuItem(
                    icon: Icons.add_box_outlined,
                    iconColor: const Color(0xFFFF6A00),
                    label: '상품 등록',
                    onTap: onPost,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 둥근 X 버튼 (닫기)
              FloatingActionButton.small(
                heroTag: '_fab_close',
                backgroundColor: Colors.white,
                onPressed: onClose,
                child: const Icon(Icons.close, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
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
            BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
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