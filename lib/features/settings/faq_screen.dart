import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    final faqList = [
      {'q': '회원가입은 어떻게 하나요?', 'a': '학교 이메일을 입력하고 인증번호 확인 후 회원가입을 완료할 수 있습니다.'},
      {'q': '결제 수단을 변경 가능한가요?', 'a': '결제수단 관리에서 변경 가능합니다.'},
      {'q': '환불은 어떻게 받나요?', 'a': '환불 계좌를 등록하시면, 환불 발생 시 자동으로 입금됩니다.'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title:
            const Text('자주 묻는 질문 (FAQ)', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: faqList.length,
        itemBuilder: (ctx, i) {
          final faq = faqList[i];
          return ExpansionTile(
            title: Text(faq['q']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  faq['a']!,
                  style: const TextStyle(color: Colors.black87),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
