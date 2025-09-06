import 'package:flutter/material.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  // 더미 데이터
  final List<Map<String, String>> sellHistory = [
    {
      'title': '아이패드 프로 11인치',
      'location': '중앙동',
      'time': '3시간 전',
      'price': '850,000원',
      'status': '거래완료',
    },
    {
      'title': '컴퓨터 모니터 27인치',
      'location': '신촌',
      'time': '1일 전',
      'price': '120,000원',
      'status': '판매중',
    },
    {
      'title': '책상 의자 세트',
      'location': '모시래마을',
      'time': '2일 전',
      'price': '50,000원',
      'status': '거래완료',
    },
  ];

  String selectedFilter = "전체";

  List<Map<String, String>> get filteredList {
    List<Map<String, String>> list = [...sellHistory];

    switch (selectedFilter) {
      case "판매중":
        list = list.where((item) => item['status'] == '판매중').toList();
        break;
      case "거래완료":
        list = list.where((item) => item['status'] == '거래완료').toList();
        break;
      case "가격 높은 순":
        list.sort((a, b) =>
            _parsePrice(b['price']!).compareTo(_parsePrice(a['price']!)));
        break;
      case "가격 낮은 순":
        list.sort((a, b) =>
            _parsePrice(a['price']!).compareTo(_parsePrice(b['price']!)));
        break;
    }
    return list;
  }

  int _parsePrice(String price) {
    return int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  void _openFilterSheet() {
    final mainColor = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              "필터 선택",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildFilterOption("전체", mainColor),
            _buildFilterOption("판매중", mainColor),
            _buildFilterOption("거래완료", mainColor),
            _buildFilterOption("가격 높은 순", mainColor),
            _buildFilterOption("가격 낮은 순", mainColor),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String filter, Color mainColor) {
    return ListTile(
      title: Text(filter),
      trailing:
          selectedFilter == filter ? Icon(Icons.check, color: mainColor) : null,
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: const Text("판매내역", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔽 리스트 영역
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("판매 내역이 없습니다."))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image, color: Colors.white70),
                          ),
                          title: Text(
                            item['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item['location']} · ${item['time']}"),
                              const SizedBox(height: 4),
                              Text(
                                "상태: ${item['status']}",
                                style: TextStyle(
                                  color: item['status'] == '판매중'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            item['price']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            print("${item['title']} 클릭됨 (상품 상세로 이동 예정)");
                          },
                        ),
                      );
                    },
                  ),
          ),
          // 🔽 상품 아래 필터 버튼
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '거리순, 최신순으로 정렬 가능',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      elevation: 2,
                    ),
                    onPressed: _openFilterSheet,
                    child: const Text('필터'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
