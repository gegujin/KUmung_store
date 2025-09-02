import 'package:flutter/material.dart';

class SellPage extends StatelessWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text("판매내역", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: sellHistory.isEmpty
          ? const Center(child: Text("판매 내역이 없습니다."))
          : ListView.builder(
              itemCount: sellHistory.length,
              itemBuilder: (context, index) {
                final item = sellHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white70),
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
    );
  }
}
