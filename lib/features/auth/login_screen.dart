import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../auth/school_sign_screen.dart';
import '../auth/id_find_screen.dart';
import '../auth/password_find_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 0, 59, 29);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬
            children: [
              const SizedBox(height: 60), // 상단 여백
              Text(
                'KU멍가게',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(labelText: '아이디'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IdFindPage()),
                      );
                    },
                    child: const Text('아이디 찾기'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PasswordFindPage(),
                        ),
                      );
                    },
                    child: const Text('비밀번호 찾기'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                child: const Text('로그인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  side: BorderSide(color: mainColor),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SchoolSignUpPage()),
                  );
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(color: Color.fromARGB(255, 0, 59, 29)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
