import 'package:flutter/material.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_list_screen.dart';

// KU대리 브랜드 색상
const Color kuInfo = Color(0xFF147AD6);

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
      isVerified = true;
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
        backgroundColor: kuInfo,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            // 이메일 인증
            const SizedBox(height: 20),
            const Text(
              "학교 이메일 인증",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "학교 이메일 (@kku.ac.kr)",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: kuInfo,
              ),
              child: const Text("인증번호 발송"),
            ),
            if (isCodeSent) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "인증번호 입력"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kuInfo,
                ),
                child: const Text("인증하기"),
              ),
            ],

            // 이동수단 선택
            const SizedBox(height: 30),
            const Text(
              "이동수단 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text("도보"),
              value: "도보",
              groupValue: selectedTransport,
              onChanged: (value) => setState(() => selectedTransport = value),
            ),
            RadioListTile<String>(
              title: const Text("자전거"),
              value: "자전거",
              groupValue: selectedTransport,
              onChanged: (value) => setState(() => selectedTransport = value),
            ),
            RadioListTile<String>(
              title: const Text("오토바이"),
              value: "오토바이",
              groupValue: selectedTransport,
              onChanged: (value) => setState(() => selectedTransport = value),
            ),
            RadioListTile<String>(
              title: const Text("기타"),
              value: "기타",
              groupValue: selectedTransport,
              onChanged: (value) => setState(() => selectedTransport = value),
            ),
            if (selectedTransport == "기타") ...[
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: "기타 이동수단을 입력하세요",
                ),
                onChanged: (value) {
                  // 기타 입력값으로 업데이트
                  selectedTransport = value;
                },
              ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),

      // 회원가입 완료 버튼 하단 고정
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completeSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: kuInfo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "회원가입 완료",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
