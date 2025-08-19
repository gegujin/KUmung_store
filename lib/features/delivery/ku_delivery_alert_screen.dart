import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 상세 페이지로 이동할 때 사용할 Args/Route
import 'ku_delivery_detail_screen.dart';
import 'package:kumeong_store/models/latlng.dart' as model;

class KuDeliveryAlertScreen extends StatelessWidget {
  const KuDeliveryAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드 연동 시 알림 리스트 API 응답으로 대체
    // 각 알림에 출발/도착 좌표(startCoord/endCoord) 포함 (지금은 더미)
    final alerts = [
      {
        'text': '가까운 위치에 KU대리 신청이 있습니다!',
        'time': '38분전',
        'title': '의류',
        'sellerName': '거래자',
        'minutesAgo': 38,
        'start': '옥슨빌 S동',
        'end': '베스트마트',
        'price': 30000,
        'imageUrl': 'https://picsum.photos/800/600',
        'startCoord': model.LatLng(lat: 37.3219, lng: 126.8309), // TODO: API 값으로 교체
        'endCoord': model.LatLng(lat: 37.3352, lng: 126.8251),   // TODO: API 값으로 교체
        // 'deliveryRequestId': 'xxxx',
      },
      {
        'text': '설정 지역에 KU대리 신청이 2건 있습니다!',
        'time': '1시간전',
        'title': '잡화',
        'sellerName': '홍길동',
        'minutesAgo': 60,
        'start': 'KU정문',
        'end': '중앙도서관',
        'price': 12000,
        'imageUrl': 'https://picsum.photos/seed/2/800/600',
        'startCoord': model.LatLng(lat: 37.3000, lng: 126.8200), // TODO: API 값으로 교체
        'endCoord': model.LatLng(lat: 37.3055, lng: 126.8355),   // TODO: API 값으로 교체
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('배달 알림'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면 이동
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            title: Text(alert['text'] as String),
            trailing: Text(
              alert['time'] as String,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              // --- 백엔드 연동 가이드 ---
              // deliveryRequestId로 상세 조회 → KuDeliveryDetailArgs 매핑 → pushNamed
              final args = KuDeliveryDetailArgs(
                title: alert['title'] as String? ?? '배달',
                sellerName: alert['sellerName'] as String? ?? '거래자',
                minutesAgo: alert['minutesAgo'] as int? ?? 0,
                start: alert['start'] as String? ?? '-',
                end: alert['end'] as String? ?? '-',
                price: alert['price'] as int? ?? 0,
                imageUrl: alert['imageUrl'] as String? ?? '',
                startCoord: alert['startCoord'] as model.LatLng,
                endCoord: alert['endCoord'] as model.LatLng,
              );

              context.pushNamed(KuDeliveryDetailScreen.routeName, extra: args);
            },
          );
        },
      ),
    );
  }
}
