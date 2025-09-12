import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 네이버 지도 열기
import 'dart:math' as math;

import 'package:kumeong_store/models/latlng.dart' as model;

const Color kuInfo = Color(0xFF147AD6);

/// 배달 현황 화면으로 전달할 Args
class DeliveryStatusArgs {
  final String orderId;
  final String categoryName;
  final String productTitle;
  final String? imageUrl;
  final int price;
  final String startName;
  final String endName;
  final int etaMinutes;
  final String moveTypeText;
  final model.LatLng startCoord;
  final model.LatLng endCoord;
  final List<model.LatLng>? route;

  DeliveryStatusArgs({
    required this.orderId,
    required this.categoryName,
    required this.productTitle,
    required this.imageUrl,
    required this.price,
    required this.startName,
    required this.endName,
    required this.etaMinutes,
    required this.moveTypeText,
    required this.startCoord,
    required this.endCoord,
    this.route,
  });
}

class DeliveryStatusScreen extends StatefulWidget {
  const DeliveryStatusScreen({super.key, required this.args});
  final DeliveryStatusArgs args;

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  NaverMapController? _mapCtrl;

  @override
  void dispose() {
    _mapCtrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    final priceText = _formatPrice(a.price);
    final distanceM = _distanceMeters(a.startCoord, a.endCoord);
    final distanceText = _formatDistance(distanceM);

    // 예시: 배달 단계 (실제 API에 따라 변경 가능)
    final timelineSteps = [
      TimelineStep(title: '주문 완료', done: true),
      TimelineStep(title: '픽업 중', done: true),
      TimelineStep(title: '배달 중', done: false),
      TimelineStep(title: '도착', done: false),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kuInfo,
        title: const Text('배달 현황'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 1) 상단 상품 미리보기
          ProductHeader(imageUrl: a.imageUrl, title: a.productTitle),
          const SizedBox(height: 12),

          // 2) 배달 연대기 (Timeline)
          DeliveryTimeline(steps: timelineSteps),
          const SizedBox(height: 12),

          // 3) 메타 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kuInfo),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowLine(label: '카테고리', value: a.categoryName),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: RowLine(label: '출발', value: a.startName)),
                    const SizedBox(width: 8),
                    Container(
                        width: 1, height: 18, color: kuInfo.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Expanded(child: RowLine(label: '도착', value: a.endName)),
                  ],
                ),
                const SizedBox(height: 6),
                RowLine(label: '가격', value: priceText),
                const SizedBox(height: 10),
                const SizedBox(height: 2),
                Text(
                  '${a.moveTypeText} (예상시간 : ${a.etaMinutes}분)',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: kuInfo),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4) 위치 카드 (웹 미리보기 + 모바일 실지도)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9EBF0)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 라인: 제목 + 액션
                Row(
                  children: [
                    const Text('위치',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF121319))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openInNaverMap(
                        start: a.startCoord,
                        end: a.endCoord,
                        startName: a.startName,
                        endName: a.endName,
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('네이버 지도로 보기'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 지도 썸네일/실지도 컨테이너
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kuInfo.withOpacity(0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildMapOrPlaceholder(),
                ),
                const SizedBox(height: 10),

                // 주소(= 도착지 이름) + 거리/시간
                Text(
                  a.endName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121319)),
                ),
                const SizedBox(height: 4),
                Text(
                  '출발지에서 $distanceText · ${a.moveTypeText} 약 ${a.etaMinutes}분',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 지도: 모바일=실지도, 웹=미리보기
  Widget _buildMapOrPlaceholder() {
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kuInfo.withOpacity(0.5)),
        ),
        child: const Center(
          child: Text(
            '웹 미리보기: 지도는 모바일에서 표시됩니다.',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final a = widget.args;

    return Stack(
      children: [
        NaverMap(
          onMapReady: (controller) async {
            _mapCtrl = controller;

            final start = NMarker(
              id: 'start',
              position: NLatLng(a.startCoord.lat, a.startCoord.lng),
              caption: const NOverlayCaption(text: '출발'),
            );
            final end = NMarker(
              id: 'end',
              position: NLatLng(a.endCoord.lat, a.endCoord.lng),
              caption: const NOverlayCaption(text: '도착'),
            );
            await controller.addOverlayAll({start, end});

            final points = (a.route != null && a.route!.isNotEmpty)
                ? a.route!
                : <model.LatLng>[a.startCoord, a.endCoord];

            final polyline = NPolylineOverlay(
              id: 'route',
              coords: points
                  .map((p) => NLatLng(p.lat, p.lng))
                  .toList(growable: false),
              width: 6,
              color: kuInfo,
            );
            await controller.addOverlay(polyline);

            final bounds = NLatLngBounds(
              southWest: NLatLng(_min(a.startCoord.lat, a.endCoord.lat),
                  _min(a.startCoord.lng, a.endCoord.lng)),
              northEast: NLatLng(_max(a.startCoord.lat, a.endCoord.lat),
                  _max(a.startCoord.lng, a.endCoord.lng)),
            );
            await controller.updateCamera(NCameraUpdate.fitBounds(bounds));
          },
          options: const NaverMapViewOptions(
            logoClickEnable: false,
            scaleBarEnable: false,
          ),
        ),
      ],
    );
  }

  // ───────── 유틸

  // 30,000원 포맷
  static String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      final next = idx - 1;
      if (next > 0 && next % 3 == 0) buf.write(',');
    }
    return '${buf.toString()}원';
  }

  // 거리(m) 계산 (Haversine)
  static double _distanceMeters(model.LatLng a, model.LatLng b) {
    const R = 6371000.0; // 지구 반지름(m)
    final dLat = _deg2rad(b.lat - a.lat);
    final dLon = _deg2rad(b.lng - a.lng);
    final la1 = _deg2rad(a.lat);
    final la2 = _deg2rad(b.lat);

    final h = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(la1) *
            math.cos(la2) *
            (math.sin(dLon / 2) * math.sin(dLon / 2));

    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  static double _deg2rad(double d) => d * (math.pi / 180.0);

  static String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)}km';
  }

  static double _min(double a, double b) => a < b ? a : b;
  static double _max(double a, double b) => a > b ? a : b;

  /// 네이버 지도(앱/웹)로 길찾기 열기
  Future<void> _openInNaverMap({
    required model.LatLng start,
    required model.LatLng end,
    required String startName,
    required String endName,
  }) async {
    final scheme = Uri.parse(
      'nmap://route/walk'
      '?slat=${start.lat}&slng=${start.lng}'
      '&sname=${Uri.encodeComponent(startName)}'
      '&dlat=${end.lat}&dlng=${end.lng}'
      '&dname=${Uri.encodeComponent(endName)}'
      '&appname=com.kumeong.store',
    );
    final web = Uri.parse(
      'https://map.naver.com/v5/directions'
      '?navigation=path'
      '&start=${start.lng},${start.lat},${Uri.encodeComponent(startName)}'
      '&destination=${end.lng},${end.lat},${Uri.encodeComponent(endName)}',
    );

    if (await canLaunchUrl(scheme)) {
      await launchUrl(scheme);
      return;
    }
    if (await canLaunchUrl(web)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('네이버 지도를 열 수 없습니다.')),
    );
  }
}

/// 상품 헤더 카드
class ProductHeader extends StatelessWidget {
  const ProductHeader({super.key, required this.imageUrl, required this.title});
  final String? imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kuInfo),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 110,
              height: 110,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Container(color: kuInfo.withOpacity(0.3))
                  : Image.network(imageUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 라벨:값 한 줄
class RowLine extends StatelessWidget {
  const RowLine({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: kuInfo, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

/// ───────── 배달 연대기 위젯 ─────────

class TimelineStep {
  final String title;
  final bool done;
  final DateTime? time;

  TimelineStep({required this.title, this.done = false, this.time});
}

class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({super.key, required this.steps});
  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final step = steps[index ~/ 2];
            return Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.done ? kuInfo : Colors.grey[300],
                  ),
                  child: step.done
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  step.title,
                  style: TextStyle(
                      fontSize: 12,
                      color: step.done ? kuInfo : Colors.grey[600]),
                ),
              ],
            );
          } else {
            final prevStep = steps[index ~/ 2];
            final nextStep = steps[index ~/ 2 + 1];
            final done = prevStep.done && nextStep.done;
            return Container(
              width: 40,
              height: 2,
              color: done ? kuInfo : Colors.grey[300],
            );
          }
        }),
      ),
    );
  }
}
