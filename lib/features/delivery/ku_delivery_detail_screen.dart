import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kumeong_store/models/latlng.dart' as model;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

const Color kuInfo = Color(0xFF147AD6);

class KuDeliveryDetailArgs {
  final String title;
  final String sellerName;
  final int minutesAgo;
  final String start;
  final String end;
  final int price;
  final String imageUrl;
  final String? sellerAvatarUrl;
  final model.LatLng startCoord;
  final model.LatLng endCoord;

  const KuDeliveryDetailArgs({
    required this.title,
    required this.sellerName,
    required this.minutesAgo,
    required this.start,
    required this.end,
    required this.price,
    required this.imageUrl,
    required this.startCoord,
    required this.endCoord,
    this.sellerAvatarUrl,
  });
}

class KuDeliveryDetailScreen extends StatefulWidget {
  static const String routeName = 'ku-delivery-detail';
  final KuDeliveryDetailArgs args;
  const KuDeliveryDetailScreen({super.key, required this.args});

  @override
  State<KuDeliveryDetailScreen> createState() => _KuDeliveryDetailScreenState();
}

class _KuDeliveryDetailScreenState extends State<KuDeliveryDetailScreen> {
  NaverMapController? _mapController;

  String get _priceText {
    final p = widget.args.price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      final idx = widget.args.price.toString().length - i;
      buf.write(p[i]);
      if (idx > 1 && idx % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kuInfo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '배달 상세페이지',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {/* TODO: 공유 */},
          ),
          PopupMenuButton<String>(
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'report', child: Text('신고하기')),
              PopupMenuItem(value: 'block', child: Text('차단하기')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 이미지(한눈에 보이게)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              height: 300,
              child: Center(
                child: Image.network(
                  widget.args.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, prog) => prog == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(color: kuInfo)),
                  errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 48, color: Colors.grey)),
                ),
              ),
            ),
          ),
          const Divider(height: 24),

          // 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (widget.args.sellerAvatarUrl == null ||
                              widget.args.sellerAvatarUrl!.isEmpty)
                          ? null
                          : NetworkImage(widget.args.sellerAvatarUrl!),
                      child: (widget.args.sellerAvatarUrl == null ||
                              widget.args.sellerAvatarUrl!.isEmpty)
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.args.sellerName,
                              style: t.titleMedium?.copyWith(color: kuInfo)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(widget.args.title, style: t.bodyMedium),
                              const SizedBox(width: 8),
                              const Text('·'),
                              const SizedBox(width: 8),
                              Text('${widget.args.minutesAgo}분 전',
                                  style: t.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('출발: ${widget.args.start}',
                                  style: t.bodySmall
                                      ?.copyWith(color: Colors.grey[700])),
                              const SizedBox(width: 12),
                              Text('도착: ${widget.args.end}',
                                  style: t.bodySmall
                                      ?.copyWith(color: Colors.grey[700])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('가격: $_priceText원',
                    style: t.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700, color: kuInfo)),
              ],
            ),
          ),

          // 네이버맵 미리보기 + "지도 보기"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: t.titleMedium?.copyWith(color: cs.onSurface),
                          children: [
                            const TextSpan(text: '거래 희망 장소  '),
                            TextSpan(
                              text: widget.args.end,
                              style: t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700, color: kuInfo),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openNaverRoute,
                      icon: const Icon(Icons.open_in_new, color: kuInfo),
                      label:
                          const Text('지도 보기', style: TextStyle(color: kuInfo)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: NaverMap(
                      options: NaverMapViewOptions(
                        initialCameraPosition: NCameraPosition(
                          target: NLatLng(widget.args.endCoord.lat,
                              widget.args.endCoord.lng),
                          zoom: 15,
                        ),
                        locationButtonEnable: true,
                      ),
                      onMapReady: (controller) async {
                        _mapController = controller;

                        final startMarker = NMarker(
                          id: 'start',
                          position: NLatLng(widget.args.startCoord.lat,
                              widget.args.startCoord.lng),
                          caption: const NOverlayCaption(text: '출발'),
                        );
                        final endMarker = NMarker(
                          id: 'end',
                          position: NLatLng(widget.args.endCoord.lat,
                              widget.args.endCoord.lng),
                          caption: const NOverlayCaption(text: '도착'),
                        );
                        await controller
                            .addOverlayAll({startMarker, endMarker});

                        final routeLine = NPolylineOverlay(
                          id: 'route',
                          coords: [
                            NLatLng(widget.args.startCoord.lat,
                                widget.args.startCoord.lng),
                            NLatLng(widget.args.endCoord.lat,
                                widget.args.endCoord.lng),
                          ],
                          width: 6,
                          color: kuInfo,
                        );
                        await controller.addOverlay(routeLine);

                        final midLat = (widget.args.startCoord.lat +
                                widget.args.endCoord.lat) /
                            2;
                        final midLng = (widget.args.startCoord.lng +
                                widget.args.endCoord.lng) /
                            2;

                        await controller.updateCamera(
                          NCameraUpdate.fromCameraPosition(
                            NCameraPosition(
                              target: NLatLng(midLat, midLng),
                              zoom: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kuInfo),
              onPressed: () => context.pushNamed('request-delivery', extra: {
                'title': widget.args.title,
                'start': widget.args.start,
                'end': widget.args.end,
                'price': widget.args.price,
              }),
              child: const Text('KU대리 진행하기',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNaverRoute() async {
    model.LatLng? my;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (await Geolocator.isLocationServiceEnabled() &&
          (perm == LocationPermission.always ||
              perm == LocationPermission.whileInUse)) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        my = model.LatLng(lat: pos.latitude, lng: pos.longitude);
      }
    } catch (_) {}

    final s = my ?? widget.args.startCoord;
    final d = widget.args.endCoord;

    final scheme = Uri.parse(
      'nmap://route/walk'
      '?slat=${s.lat}&slng=${s.lng}&sname=${Uri.encodeComponent(my != null ? "현재 위치" : widget.args.start)}'
      '&dlat=${d.lat}&dlng=${d.lng}&dname=${Uri.encodeComponent(widget.args.end)}'
      '&appname=com.yourcompany.yourapp',
    );

    if (await canLaunchUrl(scheme)) {
      await launchUrl(scheme);
    } else {
      final web = Uri.parse(
        'https://map.naver.com/v5/directions?navigation=path'
        '&start=${s.lng},${s.lat},${Uri.encodeComponent(my != null ? "현재 위치" : widget.args.start)}'
        '&destination=${d.lng},${d.lat},${Uri.encodeComponent(widget.args.end)}',
      );
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }
}
