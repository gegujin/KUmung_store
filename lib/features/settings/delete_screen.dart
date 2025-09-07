import 'package:flutter/material.dart';

class AccountDeletePage extends StatelessWidget {
  const AccountDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 탈퇴"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            // TODO: 회원 탈퇴 기능 구현
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("회원 탈퇴가 처리되었습니다.")),
            );
          },
          child: const Text("회원 탈퇴하기"),
        ),
      ),
    );
  }
}
