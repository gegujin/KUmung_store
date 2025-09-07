import 'package:flutter/material.dart';

class NicknameChangePage extends StatelessWidget {
  const NicknameChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("닉네임 변경"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "새 닉네임",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 닉네임 변경 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("닉네임이 변경되었습니다.")),
                );
              },
              child: const Text("변경하기"),
            ),
          ],
        ),
      ),
    );
  }
}
