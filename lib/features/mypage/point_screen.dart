import 'package:flutter/material.dart';
import '../mypage/mypage_screen.dart';

class PointPage extends StatelessWidget {
  const PointPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text('포인트 내역', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: const [
                Text(
                  '내 포인트',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  '450원',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                ListTile(
                  title: Text('05.10 KU대리 (1.1km)'),
                  trailing: Text(
                    '+400원',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                Divider(color: Colors.grey),
                ListTile(
                  title: Text('05.09 KU대리 (0.9km)'),
                  trailing: Text(
                    '+300원',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                Divider(color: Colors.grey),
                ListTile(
                  title: Text('05.08 KU대리 (1.5km)'),
                  trailing: Text(
                    '+500원',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
