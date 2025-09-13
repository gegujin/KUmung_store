import 'package:flutter/material.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final _controller = TextEditingController();

  void _submitReport() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    // TODO: 서버 전송 API 연결
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('버그 리포트가 전송되었습니다. 감사합니다!')),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title:
            const Text('문제 신고 (버그 리포트)', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '발견한 문제나 버그를 알려주세요.\n로그와 함께 전송됩니다.',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '문제 상황을 자세히 입력해주세요',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitReport,
                child: const Text('전송하기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
