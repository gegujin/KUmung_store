import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('앱 정보', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('앱 이름'),
              subtitle: Text('KU멍가게'),
            ),
            const ListTile(
              leading: Icon(Icons.verified),
              title: Text('현재 버전'),
              subtitle: Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('업데이트 확인'),
              subtitle: const Text('스토어에서 최신 버전을 확인하세요.'),
              onTap: () {
                // TODO: 스토어 링크로 연결
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('업데이트 확인 기능은 추후 구현 예정입니다.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
