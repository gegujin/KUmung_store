// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/core/router/route_names.dart' as R;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<bool> _signIn() async {
    // TODO: 실제 로그인 로직
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'KU멍가게',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const TextField(
                decoration: InputDecoration(labelText: '아이디'),
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    // ✅ 로그인 플로우 밖의 서브 페이지 → pushNamed
                    onPressed: () => context.pushNamed(R.RouteNames.idFind),
                    child: const Text('아이디 찾기'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.pushNamed(R.RouteNames.passwordFind),
                    child: const Text('비밀번호 찾기'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () async {
                  final ok = await _signIn();
                  if (!context.mounted) return;
                  if (ok) {
                    // ✅ 쉘의 홈 브랜치로 '교체' 이동 → 하단바 즉시 표시
                    context.goNamed(R.RouteNames.home);
                  }
                },
                child:
                    const Text('로그인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: BorderSide(color: mainColor),
                ),
                onPressed: () =>
                    context.pushNamed(R.RouteNames.schoolSignUp),
                child: Text('회원가입', style: TextStyle(color: mainColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
