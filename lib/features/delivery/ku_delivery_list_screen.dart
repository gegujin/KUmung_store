import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
// import 'package:kumeong_store/core/theme.dart';
import 'ku_delivery_detail_screen.dart';
import 'package:kumeong_store/models/latlng.dart' as model;

/// 배달(라이더) 피드 화면
/// - 알림 아이콘
/// - 배달 카드 리스트
/// - 하단: 정렬 설명 + 필터 버튼
/// - 하단 네비: 메인화면/채팅/마이페이지 (앞방향 네비만)

const Color kuInfo = Color(0xFF147AD6); // ✅ KU 파란색 강조 컬러

/// 배달(라이더) 피드 화면
class KuDeliveryFeedScreen extends StatefulWidget {
  const KuDeliveryFeedScreen({super.key});

  @override
  State<KuDeliveryFeedScreen> createState() => _KuDeliveryFeedScreenState();
}

class _KuDeliveryFeedScreenState extends State<KuDeliveryFeedScreen> {
  final _fmt = NumberFormat.decimalPattern('ko_KR');

  /// TODO(연동): 서버에서 받아올 리스트
  List<_DeliveryItem> items = [
    _DeliveryItem(
      categoryTop: '의류',
      postedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      fromName: '옥슨빌 S동',
      toName: '베스트마트',
      price: 30000,
      imageUrl: 'https://picsum.photos/seed/ku1/200/200',
      distanceM: 650,
    ),
    _DeliveryItem(
      categoryTop: '전자제품',
      postedAt: DateTime.now().subtract(const Duration(minutes: 48)),
      fromName: '학생회관(K1)',
      toName: '해오름학사(K10)',
      price: 45000,
      imageUrl: 'https://picsum.photos/seed/ku2/200/200',
      distanceM: 1800,
    ),
  ];

  _Sort sort = _Sort.newest;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final sorted = [...items]..sort((a, b) {
        switch (sort) {
          case _Sort.distance:
            return a.distanceM.compareTo(b.distanceM);
          case _Sort.newest:
            return b.postedAt.compareTo(a.postedAt);
        }
      });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kuInfo,
        foregroundColor: Colors.white,
        title: const Text('배달 창'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => context.pushNamed('kuDeliveryAlerts'),
          )
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.only(top: 12, bottom: 120),
        itemCount: sorted.length + 1,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, idx) {
          if (idx == sorted.length) {
            // 하단: 정렬 설명 + 필터 버튼
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '거리순, 최신순으로 정렬 가능',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kuInfo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      elevation: 2,
                    ),
                    onPressed: _openFilterSheet,
                    child: const Text('필터'),
                  ),
                ],
              ),
            );
          }

          final it = sorted[idx];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _DeliveryCard(
              imageUrl: it.imageUrl,
              categoryTop: it.categoryTop,
              postedAgo: timeago.format(it.postedAt, locale: 'ko', clock: now),
              fromName: it.fromName,
              toName: it.toName,
              priceText: '가격: ${_fmt.format(it.price)}원',
              onTap: () {
                final minutesAgo =
                    DateTime.now().difference(it.postedAt).inMinutes;

                final args = KuDeliveryDetailArgs(
                  title: it.categoryTop,
                  sellerName: '거래자',
                  minutesAgo: minutesAgo,
                  start: it.fromName,
                  end: it.toName,
                  price: it.price,
                  imageUrl: it.imageUrl,
                  startCoord: model.LatLng(lat: 37.3219, lng: 126.8309),
                  endCoord: model.LatLng(lat: 37.3352, lng: 126.8251),
                );

                context.pushNamed(KuDeliveryDetailScreen.routeName,
                    extra: args);
              },
            ),
          );
        },
      ),

      // 하단 네비게이션
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home_rounded,
                label: '메인화면',
                onTap: () => context.goNamed('home'),
              ),
              _NavButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '채팅',
                onTap: () => context.goNamed('chatList'),
              ),
              _NavButton(
                icon: Icons.person_outline_rounded,
                label: '마이 페이지',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('마이페이지는 추후 연결됩니다.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<_Sort>(
      context: context,
      showDragHandle: true,
      builder: (c) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: kuInfo),
              title: const Text('최신순'),
              onTap: () => Navigator.pop(c, _Sort.newest),
            ),
            ListTile(
              leading: const Icon(Icons.social_distance, color: kuInfo),
              title: const Text('거리순'),
              onTap: () => Navigator.pop(c, _Sort.distance),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) setState(() => sort = value);
    });
  }
}

enum _Sort { newest, distance }

class _DeliveryItem {
  final String categoryTop;
  final DateTime postedAt;
  final String fromName;
  final String toName;
  final int price;
  final String imageUrl;
  final int distanceM;

  _DeliveryItem({
    required this.categoryTop,
    required this.postedAt,
    required this.fromName,
    required this.toName,
    required this.price,
    required this.imageUrl,
    required this.distanceM,
  });
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.imageUrl,
    required this.categoryTop,
    required this.postedAgo,
    required this.fromName,
    required this.toName,
    required this.priceText,
    this.onTap,
  });

  final String imageUrl;
  final String categoryTop;
  final String postedAgo;
  final String fromName;
  final String toName;
  final String priceText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 | 등록 시간
                  Row(
                    children: [
                      Text(categoryTop,
                          style: const TextStyle(color: Colors.black)),
                      const SizedBox(width: 8),
                      const Text('｜', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(postedAgo,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 출발 / 도착
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _pill('출발: $fromName'),
                      _pill('도착: $toName'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 가격
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kuInfo, // ✅ 가격 강조
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kuInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kuInfo),
      ),
      child: Text(
        text,
        style: const TextStyle(color: kuInfo, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kuInfo),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: kuInfo, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
