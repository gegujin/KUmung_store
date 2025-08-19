// import 'package:flutter/material.dart';
// import 'package:flutter_naver_map/flutter_naver_map.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// // 앱 공용 LatLng 모델 (이미 프로젝트에 있음)
// import 'package:kumeong_store/models/latlng.dart' as model;
// import '../../core/theme.dart';

// /// 배달 현황 화면으로 전달할 안전한 Args
// class DeliveryStatusArgs {
//   final String orderId;                  // 방/주문 식별자
//   final String categoryName;             // 예: 의류
//   final String productTitle;             // 예: K로고 스타디움 점퍼
//   final String? imageUrl;                // 상품 썸네일
//   final int price;                       // 원 단위
//   final String startName;                // 출발지 표시명 (역지오코딩 결과)
//   final String endName;                  // 도착지 표시명
//   final int etaMinutes;                  // 예상 시간(분)
//   final String moveTypeText;             // 예: 도보로 이동중
//   final model.LatLng startCoord;         // 출발 좌표
//   final model.LatLng endCoord;           // 도착 좌표
//   final List<model.LatLng>? route;       // (선택) 경로 폴리라인 좌표들

//   DeliveryStatusArgs({
//     required this.orderId,
//     required this.categoryName,
//     required this.productTitle,
//     required this.imageUrl,
//     required this.price,
//     required this.startName,
//     required this.endName,
//     required this.etaMinutes,
//     required this.moveTypeText,
//     required this.startCoord,
//     required this.endCoord,
//     this.route,
//   });
// }

// class DeliveryStatusScreen extends StatefulWidget {
//   const DeliveryStatusScreen({super.key, required this.args});
//   final DeliveryStatusArgs args;

//   @override
//   State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
// }

// class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
//   NaverMapController? _mapCtrl;

//   @override
//   void dispose() {
//     _mapCtrl = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final a = widget.args;

//     String priceText = _formatPrice(a.price);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('배달 현황'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(12),
//         children: [
//           // 1) 상단 상품 미리보기
//           _ProductHeader(
//             imageUrl: a.imageUrl,
//             title: a.productTitle,
//           ),
//           const SizedBox(height: 12),

//           // 2) 메타 정보 (카테고리/출발/도착/가격/상태)
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: cs.surface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: cs.primaryContainer),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _RowLine(label: '카테고리', value: a.categoryName),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Expanded(child: _RowLine(label: '출발', value: a.startName)),
//                     const SizedBox(width: 8),
//                     Container(
//                       width: 1,
//                       height: 18,
//                       color: cs.outlineVariant,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(child: _RowLine(label: '도착', value: a.endName)),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 _RowLine(label: '가격', value: priceText),
//                 const SizedBox(height: 10),
//                 Text(
//                   '${a.moveTypeText} (예상시간 : ${a.etaMinutes}분)',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: cs.onBackground,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // 3) 네이버 지도 (경로+마커)
//           Container(
//             height: 360,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: cs.primaryContainer),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: _buildMapOrPlaceholder(kux),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildMapOrPlaceholder(KuColors kux) {
//   //   // flutter_naver_map 이 정상 설치되어 있다는 가정
//   //   final a = widget.args;
//   //   return NaverMap(
//   //     onMapReady: (controller) async {
//   //       _mapCtrl = controller;

//   //       // 출발/도착 마커
//   //       final start = NMarker(
//   //         id: 'start',
//   //         position: NLatLng(a.startCoord.lat, a.startCoord.lng),
//   //         caption: const NOverlayCaption(text: '출발'),
//   //       );
//   //       final end = NMarker(
//   //         id: 'end',
//   //         position: NLatLng(a.endCoord.lat, a.endCoord.lng),
//   //         caption: const NOverlayCaption(text: '도착'),
//   //       );
//   //       await controller.addOverlayAll({start, end});

//   //       // 경로(있으면 경로, 없으면 직선)
//   //       final points = (a.route != null && a.route!.isNotEmpty)
//   //           ? a.route!
//   //           : <model.LatLng>[
//   //               a.startCoord,
//   //               a.endCoord,
//   //             ];

//   //       final polyline = NPolylineOverlay(
//   //         id: 'route',
//   //         coords: points
//   //             .map((p) => NLatLng(p.lat, p.lng))
//   //             .toList(growable: false),
//   //         width: 6,
//   //       );
//   //       await controller.addOverlay(polyline);

//   //       // 카메라: 두 지점을 모두 포함하도록
//   //       final bounds = NLatLngBounds(
//   //         southWest: NLatLng(
//   //           _min(a.startCoord.lat, a.endCoord.lat),
//   //           _min(a.startCoord.lng, a.endCoord.lng),
//   //         ),
//   //         northEast: NLatLng(
//   //           _max(a.startCoord.lat, a.endCoord.lat),
//   //           _max(a.startCoord.lng, a.endCoord.lng),
//   //         ),
//   //       );
//   //       await controller.updateCamera(
//   //         NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(50)),
//   //       );
//   //     },
//   //     // 지도 기본 옵션(필요 시 조정)
//   //     options: const NaverMapViewOptions(
//   //       logoClickEnable: false,
//   //       scaleBarEnable: false,
//   //     ),
//   //   );
//   // }

//   Widget _buildMapOrPlaceholder(KuColors kux) {
//   // 🔒 웹(Chrome)에서는 flutter_naver_map 미지원 → 플레이스홀더로 대체
//     if (kIsWeb) {
//       return Center(
//         child: Text('웹 미리보기: 지도는 모바일에서 표시됩니다.'),
//       );
//     }

//     // ✅ 모바일(iOS/Android)에서는 기존 NaverMap 코드 그대로 사용
//     final a = widget.args;
//     return NaverMap(
//       onMapReady: (controller) async {
//         _mapCtrl = controller;

//         // (선택) 최신 API 방식 옵션 조정
//         await controller.updateOptions(const NaverMapViewOptions(
//           compassEnabled: false,
//           zoomControlEnabled: false,
//         ));

//         // 출발/도착 마커
//         final start = NMarker(
//           id: 'start',
//           position: NLatLng(a.startCoord.lat, a.startCoord.lng),
//           caption: const NOverlayCaption(text: '출발'),
//         );
//         final end = NMarker(
//           id: 'end',
//           position: NLatLng(a.endCoord.lat, a.endCoord.lng),
//           caption: const NOverlayCaption(text: '도착'),
//         );
//         await controller.addOverlayAll({start, end});

//         // 경로(있으면 경로, 없으면 직선)
//         final points = (a.route != null && a.route!.isNotEmpty)
//             ? a.route!
//             : <model.LatLng>[a.startCoord, a.endCoord];

//         final polyline = NPolylineOverlay(
//           id: 'route',
//           coords: points.map((p) => NLatLng(p.lat, p.lng)).toList(growable: false),
//           width: 6,
//         );
//         await controller.addOverlay(polyline);

//         // 카메라: 두 지점을 모두 포함
//         final bounds = NLatLngBounds(
//           southWest: NLatLng(
//             _min(a.startCoord.lat, a.endCoord.lat),
//             _min(a.startCoord.lng, a.endCoord.lng),
//           ),
//           northEast: NLatLng(
//             _max(a.startCoord.lat, a.endCoord.lat),
//             _max(a.startCoord.lng, a.endCoord.lng),
//           ),
//         );
//         await controller.updateCamera(
//           NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(50)),
//         );
//       },
//       options: const NaverMapViewOptions(
//         logoClickEnable: false,
//         scaleBarEnable: false,
//       ),
//     );
//   }

//   static String _formatPrice(int price) {
//     // 30,000원 형태
//     final s = price.toString();
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       final idx = s.length - i;
//       buf.write(s[i]);
//       final next = idx - 1;
//       if (next > 0 && next % 3 == 0) buf.write(',');
//     }
//     return '${buf.toString()}원';
//   }

//   static double _min(double a, double b) => a < b ? a : b;
//   static double _max(double a, double b) => a > b ? a : b;
// }

// class _ProductHeader extends StatelessWidget {
//   const _ProductHeader({required this.imageUrl, required this.title});
//   final String? imageUrl;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Container(
//       decoration: BoxDecoration(
//         color: cs.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: cs.primaryContainer),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: SizedBox(
//               width: 110,
//               height: 110,
//               child: (imageUrl == null || imageUrl!.isEmpty)
//                   ? Container(color: cs.secondaryContainer)
//                   : Image.network(imageUrl!, fit: BoxFit.cover),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RowLine extends StatelessWidget {
//   const _RowLine({required this.label, required this.value});
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: '$label: ',
//             style: TextStyle(
//               color: cs.onSurfaceVariant,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           TextSpan(
//             text: value,
//             style: TextStyle(color: cs.onBackground),
//           ),
//         ],
//         style: const TextStyle(fontSize: 15),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:kumeong_store/models/latlng.dart' as model;
import '../../core/theme.dart';

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
    final cs = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    final a = widget.args;

    final priceText = _formatPrice(a.price);

    return Scaffold(
      appBar: AppBar(title: const Text('배달 현황')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 1) 상단 상품 미리보기
          ProductHeader(imageUrl: a.imageUrl, title: a.productTitle),
          const SizedBox(height: 12),

          // 2) 메타 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primaryContainer),
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
                    Container(width: 1, height: 18, color: cs.outlineVariant),
                    const SizedBox(width: 8),
                    Expanded(child: RowLine(label: '도착', value: a.endName)),
                  ],
                ),
                const SizedBox(height: 6),
                RowLine(label: '가격', value: priceText),
                const SizedBox(height: 10),
                Text(
                  '${a.moveTypeText} (예상시간 : ${a.etaMinutes}분)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onBackground),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3) 네이버 지도
          Container(
            height: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primaryContainer),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildMapOrPlaceholder(kux),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOrPlaceholder(KuColors kux) {
    // 웹(Chrome)은 미지원 → 플레이스홀더
    if (kIsWeb) {
      return const Center(child: Text('웹 미리보기: 지도는 모바일에서 표시됩니다.'));
    }

    final a = widget.args;

    // 지도를 감싸서 버튼 오버레이
    return Stack(
      children: [
        NaverMap(
          // 최신 버전에서 onCameraChange 시그니처가 다를 수 있으므로 사용 안 함
          onMapReady: (controller) async {
            _mapCtrl = controller;

            // 출발/도착 마커
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

            // 경로(없으면 직선)
            final points = (a.route != null && a.route!.isNotEmpty)
                ? a.route!
                : <model.LatLng>[a.startCoord, a.endCoord];

            final polyline = NPolylineOverlay(
              id: 'route',
              coords: points.map((p) => NLatLng(p.lat, p.lng)).toList(growable: false),
              width: 6,
            );
            await controller.addOverlay(polyline);

            // 두 지점이 모두 보이도록 카메라 (패딩 인자 없는 버전 호환)
            final bounds = NLatLngBounds(
              southWest: NLatLng(
                _min(a.startCoord.lat, a.endCoord.lat),
                _min(a.startCoord.lng, a.endCoord.lng),
              ),
              northEast: NLatLng(
                _max(a.startCoord.lat, a.endCoord.lat),
                _max(a.startCoord.lng, a.endCoord.lng),
              ),
            );
            await controller.updateCamera(NCameraUpdate.fitBounds(bounds));
          },
          options: const NaverMapViewOptions(
            logoClickEnable: false,
            scaleBarEnable: false,
          ),
        ),

        // 우측 하단: 커스텀 줌 +/-
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            children: [
              _roundBtn(
                icon: Icons.add,
                tooltip: '확대',
                onTap: () => _mapCtrl?.updateCamera(NCameraUpdate.zoomIn()),
              ),
              const SizedBox(height: 8),
              _roundBtn(
                icon: Icons.remove,
                tooltip: '축소',
                onTap: () => _mapCtrl?.updateCamera(NCameraUpdate.zoomOut()),
              ),
              const SizedBox(height: 8),
              _roundBtn(
                icon: Icons.explore,
                tooltip: '뷰 리셋',
                onTap: () async {
                  final ctrl = _mapCtrl;
                  if (ctrl == null) return;

                  // 두 지점이 모두 보이도록 다시 맞추기 (나침반 초기화 대용)
                  final b = NLatLngBounds(
                    southWest: NLatLng(
                      _min(a.startCoord.lat, a.endCoord.lat),
                      _min(a.startCoord.lng, a.endCoord.lng),
                    ),
                    northEast: NLatLng(
                      _max(a.startCoord.lat, a.endCoord.lat),
                      _max(a.startCoord.lng, a.endCoord.lng),
                    ),
                  );
                  await ctrl.updateCamera(NCameraUpdate.fitBounds(b));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 둥근 버튼 헬퍼
  Widget _roundBtn({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final cs = Theme.of(context).colorScheme;
    final btn = Material(
      color: cs.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: cs.onSurface),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

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

  static double _min(double a, double b) => a < b ? a : b;
  static double _max(double a, double b) => a > b ? a : b;
}

/// 상품 헤더 카드
class ProductHeader extends StatelessWidget {
  const ProductHeader({super.key, required this.imageUrl, required this.title});
  final String? imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primaryContainer),
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
                  ? Container(color: cs.secondaryContainer)
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
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: cs.onBackground),
          ),
        ],
      ),
    );
  }
}
