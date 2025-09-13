import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/loading_spinner.dart';
import 'data/auth_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final data = await AuthApi.login(_email.text.trim(), _password.text);
      final token = (data['accessToken'] ?? data['token'])?.toString();
      if (!mounted) return;

      final preview = (token != null && token.length > 12)
          ? '${token.substring(0, 12)}...'
          : (token ?? '없음');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공 (토큰: $preview)')),
      );

      // 네임드 라우트 쓰면 context.goNamed('home')로 교체 가능
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        hintText: 'student@ku.ac.kr',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
                        if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                        if (v.length < 8) return '8자 이상 입력해주세요';
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const LoadingSpinner()
                            : const Text('로그인'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              context.push('/signup');
                            },
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
