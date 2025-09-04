import 'package:flutter/material.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart'; // 하단바

class BuyPage extends StatelessWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final List<Map<String, String>> purchases = [
      {"item": "무선 이어폰", "date": "2025-08-01", "price": "₩89,000"},
      {"item": "노트북 파우치", "date": "2025-07-20", "price": "₩25,000"},
      {"item": "책상용 스탠드", "date": "2025-07-05", "price": "₩45,000"},
    ];

    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('구매내역', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: purchases.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = purchases[index];
          return ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.green),
            title: Text(item["item"]!),
            subtitle: Text("구매일: ${item["date"]}"),
            trailing: Text(
              item["price"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
