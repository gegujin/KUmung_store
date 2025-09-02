import 'package:flutter/material.dart';

class PasswordFindPage extends StatelessWidget {
  const PasswordFindPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('비밀번호 찾기'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사용 아이디와 이메일을 입력하세요.'),
            const SizedBox(height: 20),
            TextField(decoration: const InputDecoration(labelText: '아이디')),
            const SizedBox(height: 10),
            TextField(decoration: const InputDecoration(labelText: '이메일')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                // 지금은 프론트만 → AlertDialog 띄우기
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("비밀번호 찾기"),
                    content: const Text("입력하신 이메일로 임시 비밀번호를 전송했습니다."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                '비밀번호 찾기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
