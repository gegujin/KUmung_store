import 'package:flutter/material.dart';

class IdFindPage extends StatelessWidget {
  const IdFindPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 앱 전체에서 사용하는 테마 색 가져오기
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('아이디 찾기'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('가입 시 입력한 이메일을 입력하세요.'),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: '이메일'),
            ),
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
                    title: const Text("아이디 찾기"),
                    content: const Text("입력하신 이메일로 아이디를 전송했습니다."),
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
                '아이디 찾기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
