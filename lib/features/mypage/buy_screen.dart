import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/core/widgets/app_bottom_nav.dart';
import 'package:kumeong_store/features/delivery/delivery_status_screen.dart';
import 'package:kumeong_store/models/latlng.dart' as model;
import 'package:kumeong_store/features/home/review_screen.dart';

class BuyPage extends StatelessWidget {
  const BuyPage({super.key});

  int _parsePriceToInt(String s) =>
      int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));

  String _formatKrw(int price) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> purchases = [
      {
        "item": "무선 이어폰",
        "date": "2025-08-01",
        "price": "₩89,000",
        "method": "KU대리",
        "deliveryStatus": "배달 진행 중",
        "orderId": "DEL-2025-1001",
        "categoryName": "디지털/모바일",
        "productTitle": "무선 이어폰",
        "imageUrl": null,
        "startName": "정문 택배함",
        "endName": "기숙사 1동 로비",
        "etaMinutes": 12,
        "moveTypeText": "도보",
        "startCoord": model.LatLng(lat: 37.5412, lng: 127.0728),
        "endCoord": model.LatLng(lat: 37.5419, lng: 127.0714),
        "route": <model.LatLng>[
          model.LatLng(lat: 37.5412, lng: 127.0728),
          model.LatLng(lat: 37.5415, lng: 127.0720),
          model.LatLng(lat: 37.5419, lng: 127.0714),
        ],
      },
      {
        "item": "노트북 파우치",
        "date": "2025-07-20",
        "price": "₩25,000",
        "method": "직접거래",
        "imageUrl": null,
      },
      {
        "item": "책상용 스탠드",
        "date": "2025-07-05",
        "price": "₩45,000",
        "method": "KU대리",
        "deliveryStatus": "배달 완료",
        "orderId": "DEL-2025-0002",
        "categoryName": "생활/가전",
        "productTitle": "책상용 스탠드",
        "imageUrl": null,
        "startName": "공학관 A동",
        "endName": "후문 CU 앞",
        "etaMinutes": 0,
        "moveTypeText": "도보",
        "startCoord": model.LatLng(lat: 37.5405, lng: 127.0725),
        "endCoord": model.LatLng(lat: 37.5415, lng: 127.0705),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: const Text('구매내역', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: purchases.isEmpty
          ? const Center(child: Text("구매 내역이 없습니다."))
          : ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final item = purchases[index];
                final String? imageUrl = item['imageUrl'] as String?;
                final String title = item['item'] as String? ?? '';
                final String date = item['date'] as String? ?? '-';
                final int priceInt =
                    _parsePriceToInt(item['price'] as String? ?? '0');

                final String method = (item['method'] as String?) ?? '직접거래';
                final bool isKuDelivery = method == 'KU대리';
                final String? deliveryStatus =
                    item['deliveryStatus'] as String?;
                final bool isInProgress = deliveryStatus == '배달 진행 중';
                final bool isCompleted = deliveryStatus == '배달 완료';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 84,
                                height: 84,
                                child: (imageUrl == null || imageUrl.isEmpty)
                                    ? Container(color: Colors.grey.shade300)
                                    : Image.network(imageUrl,
                                        fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                      children: [
                                        const TextSpan(
                                          text: '합계: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: _formatKrw(priceInt),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 태그 + 상태 텍스트
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                _pill(
                                  label: method,
                                  bg: isKuDelivery
                                      ? const Color(0xFFEFF6FF)
                                      : const Color(0xFFE8F5E9),
                                  fg: isKuDelivery
                                      ? const Color(0xFF1E88E5)
                                      : const Color(0xFF2E7D32),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getStatusText(isKuDelivery, isInProgress,
                                  isCompleted, method),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isKuDelivery
                                    ? (isInProgress
                                        ? Colors.orange
                                        : Colors.green)
                                    : (method == '직접거래'
                                        ? Colors.blueGrey
                                        : Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 버튼 영역
                        if (isKuDelivery && isInProgress) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: kuInfo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final args = DeliveryStatusArgs(
                                  orderId:
                                      (item['orderId'] as String?) ?? 'UNKNOWN',
                                  categoryName:
                                      (item['categoryName'] as String?) ?? '기타',
                                  productTitle:
                                      (item['productTitle'] as String?) ??
                                          (item['item'] as String? ?? '상품'),
                                  imageUrl: item['imageUrl'] as String?,
                                  price: priceInt,
                                  startName:
                                      (item['startName'] as String?) ?? '출발지',
                                  endName:
                                      (item['endName'] as String?) ?? '도착지',
                                  etaMinutes:
                                      (item['etaMinutes'] as int?) ?? 15,
                                  moveTypeText:
                                      (item['moveTypeText'] as String?) ?? '도보',
                                  startCoord: (item['startCoord']
                                          as model.LatLng?) ??
                                      model.LatLng(lat: 37.5400, lng: 127.0700),
                                  endCoord: (item['endCoord']
                                          as model.LatLng?) ??
                                      model.LatLng(lat: 37.5410, lng: 127.0720),
                                  route: item['route'] as List<model.LatLng>?,
                                );
                                context.pushNamed('delivery-status',
                                    extra: args);
                              },
                              child: const Text(
                                '배달 현황 보기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ] else if (isKuDelivery && isCompleted) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ReviewPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                '리뷰 작성하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 상태 배지(작은 칩)
  Widget _pill({
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 상태 텍스트 반환
  String _getStatusText(
      bool isKuDelivery, bool isInProgress, bool isCompleted, String method) {
    if (isKuDelivery) {
      if (isInProgress) return '배달 중';
      if (isCompleted) return '배달 완료';
      return '대기 중';
    } else {
      return '거래 중'; // 직접거래 기본 상태
    }
  }
}
