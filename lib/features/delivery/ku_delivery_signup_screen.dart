import 'package:flutter/material.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_list_screen.dart';

class KuDeliverySignupPage extends StatefulWidget {
  const KuDeliverySignupPage({super.key});

  @override
  State<KuDeliverySignupPage> createState() => _KuDeliverySignupPageState();
}

class _KuDeliverySignupPageState extends State<KuDeliverySignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool isCodeSent = false;
  bool isVerified = false;
  String? selectedTransport;

  // 이메일 인증번호 발송
  void _sendCode() {
    if (_emailController.text.endsWith("@kku.ac.kr")) {
      setState(() {
        isCodeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("인증번호가 발송되었습니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("학교 이메일(@kku.ac.kr)만 가능합니다.")),
      );
    }
  }

  // 인증번호 확인
  void _verifyCode() {
    setState(() {
      isVerified = true; // 입력한 값 상관없이 인증 완료 처리
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("이메일 인증이 완료되었습니다.")),
    );
  }

  // 회원가입 완료
  void _completeSignup() {
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일 인증을 완료해주세요.")),
      );
      return;
    }
    if (selectedTransport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이동수단을 선택해주세요.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("회원가입 완료! 이동수단: $selectedTransport")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const KuDeliveryFeedScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KU대리 회원가입"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "학교 이메일 인증",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "학교 이메일 (@kku.ac.kr)",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendCode,
              child: const Text("인증번호 발송"),
            ),
            if (isCodeSent) ...[
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "인증번호 입력"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text("인증하기"),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              "이동수단 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text("도보"),
              value: "도보",
              groupValue: selectedTransport,
              onChanged: (value) {
                setState(() {
                  selectedTransport = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("자전거"),
              value: "자전거",
              groupValue: selectedTransport,
              onChanged: (value) {
                setState(() {
                  selectedTransport = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("오토바이"),
              value: "오토바이",
              groupValue: selectedTransport,
              onChanged: (value) {
                setState(() {
                  selectedTransport = value;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _completeSignup,
              child: const Text("회원가입 완료"),
            ),
          ],
        ),
      ),
    );
  }
}
