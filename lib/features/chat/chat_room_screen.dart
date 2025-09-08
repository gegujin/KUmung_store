import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../delivery/delivery_status_screen.dart';
import '../../models/latlng.dart' as model;

enum PayMethod { none, escrow, direct }

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.partnerName,
    this.roomId,
    this.isKuDelivery = false,
    this.securePaid = false,
  });

  final String partnerName;
  final String? roomId;
  final bool isKuDelivery; // 복귀 시 에스크로(배달) 여부 표시
  final bool securePaid; // 복귀 시 결제/선택 완료 여부 표시

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late PayMethod _payMethod;
  late bool _securePaid;
  late bool _tradeStarted; // 한번이라도 선택/결제하면 true → '거래 진행하기' 영구 숨김

  bool get _showDeliveryPanel => _payMethod == PayMethod.escrow;
  bool get _showConfirmButton => _payMethod == PayMethod.escrow && _securePaid;
  bool get _showPayButton => !_tradeStarted; // 핵심: 한 번 선택되면 다시 안 보임

  final _messages = <_ChatMessage>[
    _ChatMessage(text: '안녕하세요! 아직 구매 가능할까요?', isMe: true),
    _ChatMessage(text: '네 가능해요 🙌', isMe: false),
  ];

  @override
  void initState() {
    super.initState();
    // 복귀 시 extra로 넘어온 flag 기반 초기화
    _securePaid = widget.securePaid;

    if (widget.isKuDelivery) {
      _payMethod = PayMethod.escrow; // 배달(KU대리/안심결제) 흐름
    } else if (!widget.isKuDelivery && _securePaid) {
      _payMethod = PayMethod.direct; // 직접결제 선택 완료
    } else {
      _payMethod = PayMethod.none; // 아직 미선택
    }

    _tradeStarted = _payMethod != PayMethod.none || _securePaid;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _goToDeliveryStatus() {
    final args = DeliveryStatusArgs(
      orderId: widget.roomId ?? 'room-demo',
      categoryName: '의류',
      productTitle: 'K 로고 스타디움 점퍼',
      imageUrl: null,
      price: 30000,
      startName: '옥손빌 S동',
      endName: '베스트마트',
      etaMinutes: 17,
      moveTypeText: '도보로 이동중',
      startCoord: model.LatLng(lat: 36.9885, lng: 127.9221),
      endCoord: model.LatLng(lat: 36.9928, lng: 127.9363),
      route: null,
    );
    context.push('/delivery/status', extra: args);
  }

  /// 거래 방식 선택 화면으로 이동 → 결과는 paymentMethod에서 처리
  Future<void> _goTradeMethod() async {
    final roomId = widget.roomId ?? 'room-demo';
    const productId = 'demo-product';

    await context.pushNamed(
      'tradeConfirm',
      queryParameters: {
        'roomId': roomId,
        'productId': productId,
      },
    );
    // 돌아올 때 채팅방 상태는 라우트에서 새로 주입되는 constructor 파라미터로 반영됨
  }

  void _send() {
    final txt = _textCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: txt, isMe: true, ts: DateTime.now()));
    });
    _textCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openAttachSheet() {
    final kux = Theme.of(context).extension<KuColors>()!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        Widget item(IconData icon, String label, VoidCallback onTap) {
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(ctx).pop();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kux.accentSoft.withOpacity(.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(label, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                item(Icons.photo_library_outlined, '앨범', () => _toast('앨범 열기')),
                item(
                    Icons.photo_camera_outlined, '카메라', () => _toast('카메라 열기')),
                item(Icons.message_outlined, '자주쓰는 문구', () => _toast('문구 선택')),
                item(Icons.place_outlined, '장소', () => _toast('장소 공유')),
                item(Icons.event_outlined, '약속', () => _toast('약속 잡기')),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 구매 확정 → 배달 패널 숨기고, 버튼은 계속 숨김 유지
  void _onConfirmPurchase() {
    setState(() {
      _payMethod = PayMethod.none;
      _securePaid = false;
      _tradeStarted = true;
    });
    _toast('구매 확정되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.partnerName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
          tooltip: '홈으로',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) =>
                  _MessageBubble(message: _messages[i]),
            ),
          ),
          if (_showDeliveryPanel) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _ProgressPanel(
                showConfirm: _showConfirmButton,
                onTrack: _goToDeliveryStatus,
                onConfirm: _onConfirmPurchase,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InputBar(
                  controller: _textCtrl,
                  onSend: _send,
                  onAttach: _openAttachSheet),
              const SizedBox(height: 10),
              if (_showPayButton)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _goTradeMethod,
                    child: const Text('거래 진행하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.showConfirm,
    required this.onTrack,
    required this.onConfirm,
  });

  final bool showConfirm;
  final VoidCallback onTrack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final kux = Theme.of(context).extension<KuColors>()!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primaryContainer),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('거래가 진행 중입니다.\n구매 확정을 하시면 버튼을 눌러주세요.\n(구매 확정은 3일 뒤 자동 확정됩니다.)',
              style: TextStyle(color: cs.onBackground)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTrack,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: kux.mintSoft,
                    side: BorderSide(color: kux.accentSoft),
                  ),
                  child:
                      Text('배달 현황', style: TextStyle(color: cs.onBackground)),
                ),
              ),
              const SizedBox(width: 12),
              if (showConfirm)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onConfirm,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kux.greenSoft,
                      side: BorderSide(color: kux.accentSoft),
                    ),
                    child:
                        Text('구매 확정', style: TextStyle(color: cs.onBackground)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar(
      {required this.controller, required this.onSend, required this.onAttach});
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primaryContainer),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(onPressed: onAttach, icon: const Icon(Icons.add)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '메시지 입력',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(onPressed: onSend, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final kux = Theme.of(context).extension<KuColors>()!;
    final cs = Theme.of(context).colorScheme;
    final isMe = message.isMe;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin:
          EdgeInsets.only(left: isMe ? 48 : 8, right: isMe ? 8 : 48, bottom: 8),
      decoration: BoxDecoration(
        color: isMe ? kux.accentSoft.withOpacity(0.6) : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kux.accentSoft),
      ),
      child: Text(message.text, style: TextStyle(color: cs.onBackground)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 2),
            child: CircleAvatar(radius: 16, backgroundColor: Colors.grey),
          ),
        Flexible(child: bubble),
      ],
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isMe, this.ts});
  final String text;
  final bool isMe;
  final DateTime? ts;
}
