// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:kumeong_store/core/theme.dart';
// import 'package:go_router/go_router.dart';

// // (참고) PaymentResult는 앞으로 사용 안 해도 남겨둠(연동 시 활용 가능)
// class PaymentResult {
//   final String roomId;
//   final bool success;
//   final bool securePaid;
//   PaymentResult({
//     required this.roomId,
//     required this.success,
//     this.securePaid = false,
//   });
// }

// enum PaymentMethod {
//   walletTopup,   // 머니 충전 결제
//   accountEasy,   // 계좌 간편결제
//   cardEasy,      // 카드 간편결제
//   normalCard,    // 일반결제
//   samsungPay,    // 삼성페이
//   securePay,     // 안심결제
// }

// class SecurePaymentScreen extends StatefulWidget {
//   const SecurePaymentScreen({
//     super.key,
//     // ✅ 라우터(/pay/secure/:roomId/:productId)와 일치
//     required this.roomId,
//     required this.productId,

//     // 아래 값들은 없어도 동작(서버에서 재조회 가능)
//     this.productTitle = '상품 이름',
//     this.price = 0,
//     this.imageUrl,
//     this.categoryTop,
//     this.categorySub,
//     this.availablePoints = 0,
//     this.availableMoney = 0,
//     this.defaultAddress = '서울특별시 성동구 왕십리로 00, 101동 1001호',
//     this.partnerName = '판매자1',
//   });

//   final String roomId;
//   final String productId;   // ✅ 백엔드 검증/결제생성에 필수

//   final String productTitle;
//   final int price;
//   final String? imageUrl;
//   final String? categoryTop;
//   final String? categorySub;
//   final int availablePoints;
//   final int availableMoney;
//   final String defaultAddress;
//   final String partnerName;

//   @override
//   State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
// }

// class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
//   final _fmt = NumberFormat.decimalPattern('ko_KR');
//   final _pointCtrl = TextEditingController(text: '0');

//   late String _address;
//   PaymentMethod _method = PaymentMethod.securePay;
//   bool _moneyPriority = true;
//   bool _alwaysAll = false;

//   @override
//   void initState() {
//     super.initState();
//     _address = widget.defaultAddress;

//     // TODO(연동): 여기서 productId/roomId로 서버 조회하여
//     // 최신 가격/재고/배송지 후보/보유 포인트/머니 가져오기
//   }

//   int get _rawPointInput {
//     final raw = _pointCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
//     return raw.isEmpty ? 0 : int.parse(raw);
//   }

//   int get _maxUsablePoint => widget.availablePoints.clamp(0, widget.price);
//   int get _clampedPoint => _rawPointInput.clamp(0, _maxUsablePoint);
//   int get _finalPay => (widget.price - _clampedPoint).clamp(0, widget.price);

//   void _applyAll() {
//     setState(() {
//       _pointCtrl.text = _maxUsablePoint.toString();
//       _alwaysAll = true;
//     });
//   }

//   @override
//   void dispose() {
//     _pointCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final totalUsable = widget.availablePoints + widget.availableMoney;

//     return Scaffold(
//       backgroundColor: colors.background,
//       appBar: AppBar(
//         backgroundColor: colors.primary,
//         foregroundColor: colors.onPrimary,
//         title: const Text('안심결제'),
//         // ❌ 이전 페이지로 가는 BackButton 제거
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _sectionTitle(context, '배송지 확인'),
//           _addressCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '상품 확인'),
//           _productCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '포인트 · 머니 사용'),
//           _usagePanel(context, totalUsable),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 수단'),
//           _methodRadio(context, PaymentMethod.securePay, '안심결제', '에스크로 기반 안심결제'),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '안심결제는 본 앱에 돈을 맡긴 뒤 거래가 확정되면 판매자에게 지급하는 방식입니다.',
//               style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
//             ),
//           ),
//           _methodRadio(context, PaymentMethod.walletTopup, '머니 충전 결제', '우리앱 머니를 충전하여 결제'),
//           _methodRadio(context, PaymentMethod.accountEasy, '계좌 간편결제', '계좌 연결 후 간편 결제'),
//           _methodRadio(context, PaymentMethod.cardEasy, '카드 간편결제', '카드 등록 후 원클릭 결제'),
//           _methodRadio(context, PaymentMethod.normalCard, '일반결제', '일반 카드/계좌 결제'),
//           _methodRadio(context, PaymentMethod.samsungPay, '삼성페이', '삼성페이로 결제'),

//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 요약'),
//           _summaryCard(context),
//           const SizedBox(height: 100),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: SizedBox(
//           height: 48,
//           child: FilledButton(
//             onPressed: _onPay, // ✅ pop 대신 앞으로 이동
//             style: FilledButton.styleFrom(
//               backgroundColor: colors.primary,
//               foregroundColor: colors.onPrimary,
//             ),
//             child: const Text('결제하기'),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(BuildContext context, String t) {
//     final colors = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
//     );
//   }

//   Widget _addressCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.location_on_outlined, color: colors.primary),
//           const SizedBox(width: 12),
//           Expanded(child: Text(_address, style: TextStyle(color: colors.onSurface))),
//           const SizedBox(width: 8),
//           OutlinedButton(
//             onPressed: () async {
//               final newAddr = await _mockPickAddress(context, _address);
//               if (newAddr != null) setState(() => _address = newAddr);
//             },
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: colors.primary),
//               foregroundColor: colors.primary,
//             ),
//             child: const Text('변경'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _productCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: kux.beigeSoft,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: kux.accentSoft),
//               image: widget.imageUrl != null
//                   ? DecorationImage(image: NetworkImage(widget.imageUrl!), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: widget.imageUrl == null
//                 ? Center(child: Text('이미지', style: TextStyle(color: colors.onSurface)))
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (widget.categoryTop != null || widget.categorySub != null)
//                   Text(
//                     '${widget.categoryTop ?? ''}'
//                     '${(widget.categoryTop != null && widget.categorySub != null) ? ' | ' : ''}'
//                     '${widget.categorySub ?? ''}',
//                     style: TextStyle(color: colors.onSurfaceVariant),
//                   ),
//                 const SizedBox(height: 2),
//                 Text(widget.productTitle,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
//                 const SizedBox(height: 4),
//                 Text('가격 ${_fmt.format(widget.price)}원',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _usagePanel(BuildContext context, int totalUsable) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final maxUsable = _maxUsablePoint;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text('사용 가능', style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(width: 6),
//               Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
//               const Spacer(),
//               Text('${_fmt.format(totalUsable)}원', style: const TextStyle(fontWeight: FontWeight.w700)),
//             ],
//           ),
//           const SizedBox(height: 10),

//           Row(
//             children: [
//               const Text('포인트'),
//               const Spacer(),
//               Text('${_fmt.format(widget.availablePoints)}원'),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               const Text('머니'),
//               const SizedBox(width: 6),
//               GestureDetector(
//                 onTap: () => setState(() => _moneyPriority = !_moneyPriority),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: kux.beigeSoft,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: kux.accentSoft),
//                   ),
//                   child: Text('우선사용${_moneyPriority ? ' ✔' : ''}', style: const TextStyle(fontSize: 12)),
//                 ),
//               ),
//               const Spacer(),
//               Text('${_fmt.format(widget.availableMoney)}원'),
//             ],
//           ),
//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _pointCtrl,
//                   keyboardType: TextInputType.number,
//                   onChanged: (_) {
//                     if (_alwaysAll) setState(() => _alwaysAll = false);
//                   },
//                   decoration: InputDecoration(
//                     labelText: '사용',
//                     filled: true,
//                     fillColor: colors.surface,
//                     suffixIcon: Padding(
//                       padding: const EdgeInsets.only(right: 12, top: 12),
//                       child: Text('원', style: TextStyle(color: colors.onSurface)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(color: kux.accentSoft),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               OutlinedButton(
//                 onPressed: _applyAll,
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: colors.primary),
//                   foregroundColor: colors.primary,
//                 ),
//                 child: const Text('전액사용'),
//               ),
//             ],
//           ),

//           CheckboxListTile(
//             value: _alwaysAll,
//             onChanged: (v) {
//               setState(() {
//                 _alwaysAll = v ?? false;
//                 if (_alwaysAll) _applyAll();
//               });
//             },
//             dense: true,
//             contentPadding: EdgeInsets.zero,
//             title: const Text('항상 전액사용'),
//             controlAffinity: ListTileControlAffinity.leading,
//           ),

//           if (_rawPointInput > maxUsable)
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 '사용 가능 포인트(${_fmt.format(maxUsable)}원)를 초과했어요.',
//                 style: const TextStyle(color: Colors.red, fontSize: 12),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _methodRadio(BuildContext context, PaymentMethod method, String title, String? subtitle) {
//     final colors = Theme.of(context).colorScheme;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: RadioListTile<PaymentMethod>(
//         value: method,
//         groupValue: _method,
//         onChanged: (v) => setState(() => _method = v!),
//         activeColor: colors.primary,
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: subtitle == null ? null : Text(subtitle),
//       ),
//     );
//   }

//   Widget _summaryCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: kux.beigeSoft,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _row('상품 금액', '${_fmt.format(widget.price)}원'),
//           _row('포인트 사용', '- ${_fmt.format(_clampedPoint)}원'),
//           _row('결제 수단', _methodLabel(_method)),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: Divider(),
//           ),
//           _row('최종 결제 금액', '${_fmt.format(_finalPay)}원',
//               valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   Widget _row(String label, String value, {TextStyle? valueStyle}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Expanded(child: Text(label)),
//           Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   String _methodLabel(PaymentMethod m) {
//     switch (m) {
//       case PaymentMethod.securePay:
//         return '안심결제';
//       case PaymentMethod.walletTopup:
//         return '머니 충전 결제';
//       case PaymentMethod.accountEasy:
//         return '계좌 간편결제';
//       case PaymentMethod.cardEasy:
//         return '카드 간편결제';
//       case PaymentMethod.normalCard:
//         return '일반결제';
//       case PaymentMethod.samsungPay:
//         return '삼성페이';
//     }
//   }

//   /// ✅ pop 없이 “앞으로” 이동
//   void _onPay() async {
//     // TODO(연동): 서버에 결제 생성/승인 요청 → 성공 시 아래로 이동
//     final secure = (_method == PaymentMethod.securePay);

//     // 채팅방으로 이동하며, 결제 완료 상태를 extra로 전달
//     // (채팅방은 roomId로 서버에서 최신 상태를 fetch)
//     if (!mounted) return;
//     context.goNamed(
//       'chatRoom',
//       pathParameters: {'roomId': widget.roomId},
//       extra: {
//         'securePaid': secure,
//         'isKuDelivery': true, // 안심결제는 보통 배송 흐름, 필요시 수정
//         'partnerName': widget.partnerName,
//       },
//     );
//   }

//   // 다이얼로그는 페이지 뒤로가기(pop)과 별개라 유지
//   Future<String?> _mockPickAddress(BuildContext context, String current) async {
//     final ctrl = TextEditingController(text: current);
//     final result = await showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('배송지 변경'),
//         content: TextField(
//           controller: ctrl,
//           decoration: const InputDecoration(hintText: '주소 입력'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
//           FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('적용')),
//         ],
//       ),
//     );
//     return (result == null || result.isEmpty) ? null : result;
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme.dart';

// class PaymentResult {
//   final String roomId;
//   final bool success;
//   final bool securePaid;
//   PaymentResult({required this.roomId, required this.success, this.securePaid = false});
// }

// enum PaymentMethod {
//   walletTopup, accountEasy, cardEasy, normalCard, samsungPay, securePay,
// }

// class SecurePaymentScreen extends StatefulWidget {
//   const SecurePaymentScreen({
//     super.key,
//     required this.roomId,
//     required this.productId,
//     this.productTitle = '상품 이름',
//     this.price = 0,
//     this.imageUrl,
//     this.categoryTop,
//     this.categorySub,
//     this.availablePoints = 0,
//     this.availableMoney = 0,
//     this.defaultAddress = '서울특별시 성동구 왕십리로 00, 101동 1001호',
//     this.partnerName = '판매자1',
//   });

//   final String roomId;
//   final String productId;

//   final String productTitle;
//   final int price;
//   final String? imageUrl;
//   final String? categoryTop;
//   final String? categorySub;
//   final int availablePoints;
//   final int availableMoney;
//   final String defaultAddress;
//   final String partnerName;

//   @override
//   State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
// }

// class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
//   final _fmt = NumberFormat.decimalPattern('ko_KR');
//   final _pointCtrl = TextEditingController(text: '0');
//   late String _address;
//   PaymentMethod _method = PaymentMethod.securePay;
//   bool _moneyPriority = true;
//   bool _alwaysAll = false;

//   @override
//   void initState() {
//     super.initState();
//     _address = widget.defaultAddress;
//   }

//   int get _rawPointInput {
//     final raw = _pointCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
//     return raw.isEmpty ? 0 : int.parse(raw);
//   }

//   int get _maxUsablePoint => widget.availablePoints.clamp(0, widget.price);
//   int get _clampedPoint => _rawPointInput.clamp(0, _maxUsablePoint);
//   int get _finalPay => (widget.price - _clampedPoint).clamp(0, widget.price);

//   void _applyAll() {
//     setState(() {
//       _pointCtrl.text = _maxUsablePoint.toString();
//       _alwaysAll = true;
//     });
//   }

//   @override
//   void dispose() {
//     _pointCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final totalUsable = widget.availablePoints + widget.availableMoney;

//     return Scaffold(
//       backgroundColor: colors.background,
//       appBar: AppBar(
//         backgroundColor: colors.primary,
//         foregroundColor: colors.onPrimary,
//         title: const Text('안심결제'),
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _sectionTitle(context, '배송지 확인'),
//           _addressCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '상품 확인'),
//           _productCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '포인트 · 머니 사용'),
//           _usagePanel(context, totalUsable),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 수단'),
//           _methodRadio(context, PaymentMethod.securePay, '안심결제', '에스크로 기반 안심결제'),
//           _methodRadio(context, PaymentMethod.walletTopup, '머니 충전 결제', '우리앱 머니를 충전하여 결제'),
//           _methodRadio(context, PaymentMethod.accountEasy, '계좌 간편결제', '계좌 연결 후 간편 결제'),
//           _methodRadio(context, PaymentMethod.cardEasy, '카드 간편결제', '카드 등록 후 원클릭 결제'),
//           _methodRadio(context, PaymentMethod.normalCard, '일반결제', '일반 카드/계좌 결제'),
//           _methodRadio(context, PaymentMethod.samsungPay, '삼성페이', '삼성페이로 결제'),

//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 요약'),
//           _summaryCard(context),
//           const SizedBox(height: 100),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: SizedBox(
//           height: 48,
//           child: FilledButton(
//             onPressed: _onPay, // ✅ 결제 → 채팅방으로 앞으로 이동
//             style: FilledButton.styleFrom(
//               backgroundColor: colors.primary,
//               foregroundColor: colors.onPrimary,
//             ),
//             child: const Text('결제하기'),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- UI helpers (생략 없이 동작) ---
//   Widget _sectionTitle(BuildContext context, String t) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
//   );

//   Widget _addressCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.location_on_outlined, color: colors.primary),
//           const SizedBox(width: 12),
//           Expanded(child: Text(_address, style: TextStyle(color: colors.onSurface))),
//           const SizedBox(width: 8),
//           OutlinedButton(
//             onPressed: () async {
//               final newAddr = await _mockPickAddress(context, _address);
//               if (newAddr != null) setState(() => _address = newAddr);
//             },
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: colors.primary),
//               foregroundColor: colors.primary,
//             ),
//             child: const Text('변경'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _productCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 72, height: 72,
//             decoration: BoxDecoration(
//               color: kux.beigeSoft,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: kux.accentSoft),
//             ),
//             child: Center(child: Text('이미지', style: TextStyle(color: colors.onSurface))),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (widget.categoryTop != null || widget.categorySub != null)
//                   Text('${widget.categoryTop ?? ''}'
//                        '${(widget.categoryTop != null && widget.categorySub != null) ? ' | ' : ''}'
//                        '${widget.categorySub ?? ''}',
//                     style: TextStyle(color: colors.onSurfaceVariant)),
//                 const SizedBox(height: 2),
//                 Text(widget.productTitle,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
//                 const SizedBox(height: 4),
//                 Text('가격 ${_fmt.format(widget.price)}원',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _usagePanel(BuildContext context, int totalUsable) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final maxUsable = _maxUsablePoint;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             const Text('사용 가능', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(width: 6), Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
//             const Spacer(),
//             Text('${_fmt.format(totalUsable)}원', style: const TextStyle(fontWeight: FontWeight.w700)),
//           ]),
//           const SizedBox(height: 10),
//           Row(children: [const Text('포인트'), const Spacer(), Text('${_fmt.format(widget.availablePoints)}원')]),
//           const SizedBox(height: 6),
//           Row(children: [const Text('머니'), const Spacer(), Text('${_fmt.format(widget.availableMoney)}원')]),
//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(
//               child: TextField(
//                 controller: _pointCtrl,
//                 keyboardType: TextInputType.number,
//                 onChanged: (_) { if (_alwaysAll) setState(() => _alwaysAll = false); },
//                 decoration: InputDecoration(
//                   labelText: '사용',
//                   filled: true,
//                   fillColor: colors.surface,
//                   suffixIcon: Padding(
//                     padding: const EdgeInsets.only(right: 12, top: 12),
//                     child: Text('원', style: TextStyle(color: colors.onSurface)),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: kux.accentSoft),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             OutlinedButton(
//               onPressed: _applyAll,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: colors.primary),
//                 foregroundColor: colors.primary,
//               ),
//               child: const Text('전액사용'),
//             ),
//           ]),
//           CheckboxListTile(
//             value: _alwaysAll,
//             onChanged: (v) { setState(() { _alwaysAll = v ?? false; if (_alwaysAll) _applyAll(); }); },
//             dense: true, contentPadding: EdgeInsets.zero, title: const Text('항상 전액사용'),
//             controlAffinity: ListTileControlAffinity.leading,
//           ),
//           if (_rawPointInput > maxUsable)
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text('사용 가능 포인트(${_fmt.format(maxUsable)}원)를 초과했어요.',
//                 style: const TextStyle(color: Colors.red, fontSize: 12)),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _methodRadio(BuildContext context, PaymentMethod m, String title, String? sub) {
//     final colors = Theme.of(context).colorScheme;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: RadioListTile<PaymentMethod>(
//         value: m,
//         groupValue: _method,
//         onChanged: (v) => setState(() => _method = v!),
//         activeColor: colors.primary,
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: sub == null ? null : Text(sub),
//       ),
//     );
//   }

//   Widget _summaryCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: kux.beigeSoft,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _row('상품 금액', '${_fmt.format(widget.price)}원'),
//           _row('포인트 사용', '- ${_fmt.format(_clampedPoint)}원'),
//           _row('결제 수단', _method.toString().split('.').last),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
//           _row('최종 결제 금액', '${_fmt.format(_finalPay)}원',
//               valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   Widget _row(String label, String value, {TextStyle? valueStyle}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(children: [Expanded(child: Text(label)), Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600))]),
//   );

//   /// ✅ 결제 완료 → 채팅방으로 앞으로 이동 + 상태 플래그 전달
//   void _onPay() {
//     final secure = (_method == PaymentMethod.securePay);
//     if (!mounted) return;
//     context.goNamed(
//       'chatRoom',
//       pathParameters: {'roomId': widget.roomId},
//       extra: {
//         'securePaid': true,     // 결제/선택 완료
//         'isKuDelivery': secure, // 안심결제면 true, 아니면 false
//         'partnerName': widget.partnerName,
//       },
//     );
//   }

//   Future<String?> _mockPickAddress(BuildContext context, String current) async {
//     final ctrl = TextEditingController(text: current);
//     final result = await showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('배송지 변경'),
//         content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '주소 입력')),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
//           FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('적용')),
//         ],
//       ),
//     );
//     return (result == null || result.isEmpty) ? null : result;
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme.dart';

// class PaymentResult {
//   final String roomId;
//   final bool success;
//   final bool securePaid;
//   PaymentResult({required this.roomId, required this.success, this.securePaid = false});
// }

// enum PaymentMethod {
//   walletTopup, accountEasy, cardEasy, normalCard, samsungPay, securePay,
// }

// class SecurePaymentScreen extends StatefulWidget {
//   const SecurePaymentScreen({
//     super.key,
//     required this.roomId,
//     required this.productId,
//     this.productTitle = '상품 이름',
//     this.price = 0,
//     this.imageUrl,
//     this.categoryTop,
//     this.categorySub,
//     this.availablePoints = 0,
//     this.availableMoney = 0,
//     this.defaultAddress = '서울특별시 성동구 왕십리로 00, 101동 1001호',
//     this.partnerName = '판매자1',
//   });

//   final String roomId;
//   final String productId;

//   final String productTitle;
//   final int price;
//   final String? imageUrl;
//   final String? categoryTop;
//   final String? categorySub;
//   final int availablePoints;
//   final int availableMoney;
//   final String defaultAddress;
//   final String partnerName;

//   @override
//   State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
// }

// class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
//   final _fmt = NumberFormat.decimalPattern('ko_KR');
//   final _pointCtrl = TextEditingController(text: '0');
//   late String _address;
//   PaymentMethod _method = PaymentMethod.securePay;
//   bool _moneyPriority = true;
//   bool _alwaysAll = false;

//   @override
//   void initState() {
//     super.initState();
//     _address = widget.defaultAddress;
//   }

//   int get _rawPointInput {
//     final raw = _pointCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
//     return raw.isEmpty ? 0 : int.parse(raw);
//   }

//   int get _maxUsablePoint => widget.availablePoints.clamp(0, widget.price);
//   int get _clampedPoint => _rawPointInput.clamp(0, _maxUsablePoint);
//   int get _finalPay => (widget.price - _clampedPoint).clamp(0, widget.price);

//   void _applyAll() {
//     setState(() {
//       _pointCtrl.text = _maxUsablePoint.toString();
//       _alwaysAll = true;
//     });
//   }

//   @override
//   void dispose() {
//     _pointCtrl.dispose();
//     super.dispose();
//   }

//   // ✅ 공통 네비게이션 헬퍼
//   void _goChat({required bool isEscrow, required bool paid}) {
//     if (!mounted) return;
//     context.goNamed(
//       'chatRoom',
//       pathParameters: {'roomId': widget.roomId},
//       extra: {
//         'securePaid': paid,          // 구매확정/결제 완료 여부
//         'isKuDelivery': isEscrow,    // 배달 패널 표시 여부
//         'partnerName': widget.partnerName,
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final totalUsable = widget.availablePoints + widget.availableMoney;

//     return Scaffold(
//       backgroundColor: colors.background,
//       appBar: AppBar(
//         backgroundColor: colors.primary,
//         foregroundColor: colors.onPrimary,
//         title: const Text('안심결제'),
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _sectionTitle(context, '배송지 확인'),
//           _addressCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '상품 확인'),
//           _productCard(context),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '포인트 · 머니 사용'),
//           _usagePanel(context, totalUsable),
//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 수단'),
//           _methodRadio(context, PaymentMethod.securePay, '안심결제', '에스크로 기반 안심결제'),
//           _methodRadio(context, PaymentMethod.walletTopup, '머니 충전 결제', '우리앱 머니를 충전하여 결제'),
//           _methodRadio(context, PaymentMethod.accountEasy, '계좌 간편결제', '계좌 연결 후 간편 결제'),
//           _methodRadio(context, PaymentMethod.cardEasy, '카드 간편결제', '카드 등록 후 원클릭 결제'),
//           _methodRadio(context, PaymentMethod.normalCard, '일반결제', '일반 카드/계좌 결제'),
//           _methodRadio(context, PaymentMethod.samsungPay, '삼성페이', '삼성페이로 결제'),

//           const SizedBox(height: 16),
//           Divider(color: colors.outlineVariant),

//           _sectionTitle(context, '결제 요약'),
//           _summaryCard(context),
//           const SizedBox(height: 100),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: SizedBox(
//           height: 48,
//           child: FilledButton(
//             onPressed: _onPay, // ✅ 결제 → 채팅방으로 이동
//             style: FilledButton.styleFrom(
//               backgroundColor: colors.primary,
//               foregroundColor: colors.onPrimary,
//             ),
//             child: const Text('결제하기'),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- UI helpers ---
//   Widget _sectionTitle(BuildContext context, String t) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
//   );

//   Widget _addressCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.location_on_outlined, color: colors.primary),
//           const SizedBox(width: 12),
//           Expanded(child: Text(_address, style: TextStyle(color: colors.onSurface))),
//           const SizedBox(width: 8),
//           OutlinedButton(
//             onPressed: () async {
//               final newAddr = await _mockPickAddress(context, _address);
//               if (newAddr != null) setState(() => _address = newAddr);
//             },
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: colors.primary),
//               foregroundColor: colors.primary,
//             ),
//             child: const Text('변경'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _productCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 72, height: 72,
//             decoration: BoxDecoration(
//               color: kux.beigeSoft,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: kux.accentSoft),
//             ),
//             child: Center(child: Text('이미지', style: TextStyle(color: colors.onSurface))),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (widget.categoryTop != null || widget.categorySub != null)
//                   Text('${widget.categoryTop ?? ''}'
//                        '${(widget.categoryTop != null && widget.categorySub != null) ? ' | ' : ''}'
//                        '${widget.categorySub ?? ''}',
//                     style: TextStyle(color: colors.onSurfaceVariant)),
//                 const SizedBox(height: 2),
//                 Text(widget.productTitle,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
//                 const SizedBox(height: 4),
//                 Text('가격 ${_fmt.format(widget.price)}원',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _usagePanel(BuildContext context, int totalUsable) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     final maxUsable = _maxUsablePoint;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             const Text('사용 가능', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(width: 6), Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
//             const Spacer(),
//             Text('${_fmt.format(totalUsable)}원', style: const TextStyle(fontWeight: FontWeight.w700)),
//           ]),
//           const SizedBox(height: 10),
//           Row(children: [const Text('포인트'), const Spacer(), Text('${_fmt.format(widget.availablePoints)}원')]),
//           const SizedBox(height: 6),
//           Row(children: [const Text('머니'), const Spacer(), Text('${_fmt.format(widget.availableMoney)}원')]),
//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(
//               child: TextField(
//                 controller: _pointCtrl,
//                 keyboardType: TextInputType.number,
//                 onChanged: (_) { if (_alwaysAll) setState(() => _alwaysAll = false); },
//                 decoration: InputDecoration(
//                   labelText: '사용',
//                   filled: true,
//                   fillColor: colors.surface,
//                   suffixIcon: Padding(
//                     padding: const EdgeInsets.only(right: 12, top: 12),
//                     child: Text('원', style: TextStyle(color: colors.onSurface)),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: kux.accentSoft),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             OutlinedButton(
//               onPressed: _applyAll,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: colors.primary),
//                 foregroundColor: colors.primary,
//               ),
//               child: const Text('전액사용'),
//             ),
//           ]),
//           CheckboxListTile(
//             value: _alwaysAll,
//             onChanged: (v) { setState(() { _alwaysAll = v ?? false; if (_alwaysAll) _applyAll(); }); },
//             dense: true, contentPadding: EdgeInsets.zero, title: const Text('항상 전액사용'),
//             controlAffinity: ListTileControlAffinity.leading,
//           ),
//           if (_rawPointInput > maxUsable)
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text('사용 가능 포인트(${_fmt.format(maxUsable)}원)를 초과했어요.',
//                 style: const TextStyle(color: Colors.red, fontSize: 12)),
//             ),
//         ],
//       ),
//     );
//   }

//   // ✅ 라디오 선택 즉시 분기: 안심결제 외 수단 선택 시 바로 채팅룸 이동
//   Widget _methodRadio(BuildContext context, PaymentMethod m, String title, String? sub) {
//     final colors = Theme.of(context).colorScheme;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: RadioListTile<PaymentMethod>(
//         value: m,
//         groupValue: _method,
//         onChanged: (v) {
//           if (v == null) return;
//           setState(() => _method = v);
//           if (v != PaymentMethod.securePay) {
//             // 케이스 2: KU대리 + 비안심결제 → 배달현황만, 거래확정 버튼 없음
//             _goChat(isEscrow: true, paid: false);
//           }
//         },
//         activeColor: colors.primary,
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: sub == null ? null : Text(sub),
//       ),
//     );
//   }

//   Widget _summaryCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final kux = Theme.of(context).extension<KuColors>()!;
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: kux.beigeSoft,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kux.accentSoft),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _row('상품 금액', '${_fmt.format(widget.price)}원'),
//           _row('포인트 사용', '- ${_fmt.format(_clampedPoint)}원'),
//           _row('결제 수단', _method.toString().split('.').last),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
//           _row('최종 결제 금액', '${_fmt.format(_finalPay)}원',
//               valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   Widget _row(String label, String value, {TextStyle? valueStyle}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(children: [Expanded(child: Text(label)), Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600))]),
//   );

//   /// ✅ 결제 버튼: 안심결제면 paid=true, 그 외면 paid=false
//   void _onPay() {
//     final isSecure = (_method == PaymentMethod.securePay);
//     // 케이스 3: 안심결제 → 배달현황 + 구매확정
//     // 케이스 2: 비안심결제 → 배달현황만
//     _goChat(isEscrow: true, paid: isSecure);
//   }

//   Future<String?> _mockPickAddress(BuildContext context, String current) async {
//     final ctrl = TextEditingController(text: current);
//     final result = await showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('배송지 변경'),
//         content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '주소 입력')),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
//           FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('적용')),
//         ],
//       ),
//     );
//     return (result == null || result.isEmpty) ? null : result;
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class PaymentResult {
  final String roomId;
  final bool success;
  final bool securePaid;
  PaymentResult({required this.roomId, required this.success, this.securePaid = false});
}

enum PaymentMethod {
  walletTopup, accountEasy, cardEasy, normalCard, samsungPay, securePay,
}

class SecurePaymentScreen extends StatefulWidget {
  const SecurePaymentScreen({
    super.key,
    required this.roomId,
    required this.productId,
    this.productTitle = '상품 이름',
    this.price = 0,
    this.imageUrl,
    this.categoryTop,
    this.categorySub,
    this.availablePoints = 0,
    this.availableMoney = 0,
    this.defaultAddress = '서울특별시 성동구 왕십리로 00, 101동 1001호',
    this.partnerName = '판매자1',
  });

  final String roomId;
  final String productId;

  final String productTitle;
  final int price;
  final String? imageUrl;
  final String? categoryTop;
  final String? categorySub;
  final int availablePoints;
  final int availableMoney;
  final String defaultAddress;
  final String partnerName;

  @override
  State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
}

class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
  final _fmt = NumberFormat.decimalPattern('ko_KR');
  final _pointCtrl = TextEditingController(text: '0');
  late String _address;
  PaymentMethod _method = PaymentMethod.securePay;
  bool _moneyPriority = true;
  bool _alwaysAll = false;

  @override
  void initState() {
    super.initState();
    _address = widget.defaultAddress;
  }

  int get _rawPointInput {
    final raw = _pointCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return raw.isEmpty ? 0 : int.parse(raw);
  }

  int get _maxUsablePoint => widget.availablePoints.clamp(0, widget.price);
  int get _clampedPoint => _rawPointInput.clamp(0, _maxUsablePoint);
  int get _finalPay => (widget.price - _clampedPoint).clamp(0, widget.price);

  void _applyAll() {
    setState(() {
      _pointCtrl.text = _maxUsablePoint.toString();
      _alwaysAll = true;
    });
  }

  @override
  void dispose() {
    _pointCtrl.dispose();
    super.dispose();
  }

  // ✅ 공통 네비게이션 헬퍼
  void _goChat({required bool isEscrow, required bool paid}) {
    if (!mounted) return;
    context.goNamed(
      'chatRoom',
      pathParameters: {'roomId': widget.roomId},
      extra: {
        'securePaid': paid,          // 구매확정/결제 완료 여부
        'isKuDelivery': isEscrow,    // 배달 패널 표시 여부
        'partnerName': widget.partnerName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    final totalUsable = widget.availablePoints + widget.availableMoney;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('안심결제'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, '배송지 확인'),
          _addressCard(context),
          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),

          _sectionTitle(context, '상품 확인'),
          _productCard(context),
          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),

          _sectionTitle(context, '포인트 · 머니 사용'),
          _usagePanel(context, totalUsable),
          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),

          _sectionTitle(context, '결제 수단'),
          _methodRadio(context, PaymentMethod.securePay, '안심결제', '에스크로 기반 안심결제'),
          _methodRadio(context, PaymentMethod.walletTopup, '머니 충전 결제', '우리앱 머니를 충전하여 결제'),
          _methodRadio(context, PaymentMethod.accountEasy, '계좌 간편결제', '계좌 연결 후 간편 결제'),
          _methodRadio(context, PaymentMethod.cardEasy, '카드 간편결제', '카드 등록 후 원클릭 결제'),
          _methodRadio(context, PaymentMethod.normalCard, '일반결제', '일반 카드/계좌 결제'),
          _methodRadio(context, PaymentMethod.samsungPay, '삼성페이', '삼성페이로 결제'),

          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),

          _sectionTitle(context, '결제 요약'),
          _summaryCard(context),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _onPay, // ✅ 결제 → 채팅방으로 이동
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: const Text('결제하기'),
          ),
        ),
      ),
    );
  }

  // --- UI helpers ---
  Widget _sectionTitle(BuildContext context, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
  );

  Widget _addressCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kux.accentSoft),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(_address, style: TextStyle(color: colors.onSurface))),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              final newAddr = await _mockPickAddress(context, _address);
              if (newAddr != null) setState(() => _address = newAddr);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.primary),
              foregroundColor: colors.primary,
            ),
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kux.accentSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: kux.beigeSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kux.accentSoft),
            ),
            child: Center(child: Text('이미지', style: TextStyle(color: colors.onSurface))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.categoryTop != null || widget.categorySub != null)
                  Text('${widget.categoryTop ?? ''}'
                       '${(widget.categoryTop != null && widget.categorySub != null) ? ' | ' : ''}'
                       '${widget.categorySub ?? ''}',
                    style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(widget.productTitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
                const SizedBox(height: 4),
                Text('가격 ${_fmt.format(widget.price)}원',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _usagePanel(BuildContext context, int totalUsable) {
    final colors = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    final maxUsable = _maxUsablePoint;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kux.accentSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('사용 가능', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6), Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
            const Spacer(),
            Text('${_fmt.format(totalUsable)}원', style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Row(children: [const Text('포인트'), const Spacer(), Text('${_fmt.format(widget.availablePoints)}원')]),
          const SizedBox(height: 6),
          Row(children: [const Text('머니'), const Spacer(), Text('${_fmt.format(widget.availableMoney)}원')]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _pointCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) { if (_alwaysAll) setState(() => _alwaysAll = false); },
                decoration: InputDecoration(
                  labelText: '사용',
                  filled: true,
                  fillColor: colors.surface,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 12),
                    child: Text('원', style: TextStyle(color: colors.onSurface)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kux.accentSoft),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _applyAll,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary),
                foregroundColor: colors.primary,
              ),
              child: const Text('전액사용'),
            ),
          ]),
          CheckboxListTile(
            value: _alwaysAll,
            onChanged: (v) { setState(() { _alwaysAll = v ?? false; if (_alwaysAll) _applyAll(); }); },
            dense: true, contentPadding: EdgeInsets.zero, title: const Text('항상 전액사용'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_rawPointInput > maxUsable)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('사용 가능 포인트(${_fmt.format(maxUsable)}원)를 초과했어요.',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ✅ 라디오 선택 시 이동하지 않음 — 버튼에서만 분기
  Widget _methodRadio(BuildContext context, PaymentMethod m, String title, String? sub) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: RadioListTile<PaymentMethod>(
        value: m,
        groupValue: _method,
        onChanged: (v) {
          if (v == null) return;
          setState(() => _method = v);
        },
        activeColor: colors.primary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: sub == null ? null : Text(sub),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final kux = Theme.of(context).extension<KuColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kux.beigeSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kux.accentSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('상품 금액', '${_fmt.format(widget.price)}원'),
          _row('포인트 사용', '- ${_fmt.format(_clampedPoint)}원'),
          _row('결제 수단', _method.toString().split('.').last),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _row('최종 결제 금액', '${_fmt.format(_finalPay)}원',
              valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }

  /// ✅ 결제 버튼: 안심결제면 paid=true, 그 외면 paid=false → 채팅룸 이동
  void _onPay() {
    final isSecure = (_method == PaymentMethod.securePay);
    _goChat(isEscrow: true, paid: isSecure);
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [Expanded(child: Text(label)), Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600))]),
  );

  Future<String?> _mockPickAddress(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('배송지 변경'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '주소 입력')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('적용')),
        ],
      ),
    );
    return (result == null || result.isEmpty) ? null : result;
  }
}
