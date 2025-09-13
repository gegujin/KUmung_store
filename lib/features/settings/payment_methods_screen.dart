import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  // 임시 데이터 (추후 서버/DB 연동)
  final List<Map<String, dynamic>> _methods = [
    {
      'type': 'card',
      'brand': '국민카드',
      'number': '**** 1234',
      'isDefault': true,
    },
    {
      'type': 'card',
      'brand': '신한카드',
      'number': '**** 5678',
      'isDefault': false,
    },
    {
      'type': 'simple',
      'brand': '네이버페이',
      'isDefault': false,
    },
  ];

  void _addMethod() async {
    final brandCtrl = TextEditingController();
    final numberCtrl = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('결제수단 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brandCtrl,
              decoration:
                  const InputDecoration(labelText: '브랜드명 (예: 우리카드, 카카오페이)'),
            ),
            TextField(
              controller: numberCtrl,
              decoration: const InputDecoration(labelText: '카드번호 (마지막 4자리)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (brandCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'brand': brandCtrl.text.trim(),
                'number': numberCtrl.text.trim(),
              });
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _methods.add({
          'type': 'card',
          'brand': result['brand']!,
          'number': result['number']!.isNotEmpty
              ? '**** ${result['number']}'
              : '**** ****',
          'isDefault': false,
        });
      });
    }
  }

  void _removeMethod(int index) {
    setState(() => _methods.removeAt(index));
  }

  void _setDefault(int index) {
    setState(() {
      for (var m in _methods) {
        m['isDefault'] = false;
      }
      _methods[index]['isDefault'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('결제수단 관리', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = _methods[i];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                m['type'] == 'card'
                    ? Icons.credit_card
                    : Icons.account_balance_wallet,
                color: mainColor,
                size: 32,
              ),
              title: Text(
                m['type'] == 'card'
                    ? '${m['brand']} (${m['number']})'
                    : m['brand'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: m['isDefault'] == true
                  ? const Text('기본 결제수단', style: TextStyle(color: Colors.green))
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (m['isDefault'] != true)
                    IconButton(
                      tooltip: '기본으로 설정',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => _setDefault(i),
                    ),
                  IconButton(
                    tooltip: '삭제',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMethod(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMethod,
        icon: const Icon(Icons.add),
        label: const Text('결제수단 추가'),
      ),
    );
  }
}
