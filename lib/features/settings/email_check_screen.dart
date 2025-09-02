import 'package:flutter/material.dart';

class EmailCheckPage extends StatelessWidget {
  final String userEmail;

  const EmailCheckPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("가입 이메일 확인", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬 시작
        children: [
          const SizedBox(height: 100), // 화면 상단에서 100px 아래로 위치
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "이메일 : $userEmail",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
