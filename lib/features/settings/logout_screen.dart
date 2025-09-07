import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그아웃"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: 로그아웃 처리 (예: 로그인 화면으로 이동)
            Navigator.popUntil(context, (route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("로그아웃 되었습니다.")),
            );
          },
          child: const Text("로그아웃하기"),
        ),
      ),
    );
  }
}
