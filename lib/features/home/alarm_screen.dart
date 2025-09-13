import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../home/review_screen.dart'; // ReviewPage 불러오기

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // Theme 기반 색상

    return DefaultTabController(
      length: 2, // 탭 2개
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          title: const Text('알림', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: '활동'),
              Tab(text: 'KU대리'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 활동 탭
            AlarmList(
              notifications: [
                ['누군가 사용자의 상품을 좋아합니다!', '3시간 전'],
                ['000님과 대화를 안한지 24시간이 지났어요! 거래를 계속 진행해주세요!', '3시간 전'],
                ["'00 판매합니다!' 거래 후기를 작성해주세요!", '방금 전'],
              ],
            ),
            // KU대리 탭
            AlarmList(
              notifications: const [
                ["'00 판매합니다!' 전달을 완료했어요!", '3시간 전'],
                ["'00 판매합니다!' 전달을 진행합니다!", '3시간 전'],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 알림 리스트 위젯
class AlarmList extends StatelessWidget {
  final List<List<String>> notifications;

  const AlarmList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return InkWell(
          onTap: () {
            // ✅ 알림 내용에 따라 화면 이동 처리
            if (notification[0].contains('거래 후기를 작성해주세요')) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewPage()),
              );
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification[0],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      notification[1],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Color.fromARGB(255, 235, 235, 235),
                height: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
