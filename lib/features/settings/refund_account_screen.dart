import 'package:flutter/material.dart';

class RefundAccountPage extends StatefulWidget {
  const RefundAccountPage({super.key});

  @override
  State<RefundAccountPage> createState() => _RefundAccountPageState();
}

class _RefundAccountPageState extends State<RefundAccountPage> {
  String? _bankName;
  String? _accountNumber;
  String? _accountHolder;

  // 계좌 등록/수정
  Future<void> _editAccount() async {
    final bankCtrl = TextEditingController(text: _bankName);
    final numberCtrl = TextEditingController(text: _accountNumber);
    final holderCtrl = TextEditingController(text: _accountHolder);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('환불 계좌 등록/수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(
                  labelText: '은행명',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: '계좌번호',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: holderCtrl,
                decoration: const InputDecoration(
                  labelText: '예금주',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        _bankName = bankCtrl.text.trim();
        _accountNumber = numberCtrl.text.trim();
        _accountHolder = holderCtrl.text.trim();
      });
    }

    // 다이얼로그 닫힌 후 컨트롤러 정리
    bankCtrl.dispose();
    numberCtrl.dispose();
    holderCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          '환불 계좌 관리',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _bankName == null
            ? Center(
                child: Text(
                  '등록된 환불 계좌가 없습니다.\n아래 버튼을 눌러 등록해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              )
            : Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.account_balance, size: 32),
                  title: Text('$_bankName ($_accountNumber)'),
                  subtitle: Text('예금주: $_accountHolder'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _editAccount,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editAccount,
        tooltip: _bankName == null ? "계좌 등록" : "계좌 수정",
        child: Icon(_bankName == null ? Icons.add : Icons.edit),
      ),
    );
  }
}
