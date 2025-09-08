// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 상세 화면들 (같은 폴더라면 ./ 로 써도 됩니다)
import './edit_profile_screen.dart';
import './password_change_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 섹션 헤더 스타일
  TextStyle get _sectionStyle => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: .2,
      );

  // 알림 상태
  bool _notificationsEnabled = true; // 전체 알림
  bool _notifDelivery = true;        // 배달 상태 알림
  bool _soundModeIsSound = true;     // 켜짐=소리 / 꺼짐=진동
  TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEnd   = const TimeOfDay(hour: 7,  minute: 0);

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text('환경설정', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ───────────────── 1) 알림설정
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text('알림설정', style: _sectionStyle),
          ),
          SwitchListTile(
            title: const Text('알림 받기'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          SwitchListTile(
            title: const Text('배달 상태 알림'),
            subtitle: const Text('픽업/이동 중/도착 등 상태 업데이트'),
            value: _notifDelivery,
            onChanged: _notificationsEnabled
                ? (v) => setState(() => _notifDelivery = v)
                : null,
          ),
          ListTile(
            title: const Text('방해 금지 시간대'),
            subtitle: Text(
              '${_fmt(_dndStart)} ~ ${_fmt(_dndEnd)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _notificationsEnabled ? _pickDndRange : null,
          ),
          // 소리/진동 통합 스위치 (켜짐=소리, 꺼짐=진동)
          SwitchListTile(
            title: Text(_soundModeIsSound ? '소리' : '진동'),
            subtitle: const Text('알림 음향 모드'),
            value: _soundModeIsSound,
            onChanged: _notificationsEnabled
                ? (v) => setState(() => _soundModeIsSound = v)
                : null,
          ),
          const Divider(height: 1),

          // ───────────────── 2) 결제, 정산
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('결제, 정산', style: _sectionStyle),
          ),
          ListTile(
            title: const Text('결제수단 관리 (카드, 간편결제)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const _TempScaffold(
                  title: '결제수단 관리',
                  body: '카드/간편결제 관리 화면(추후 구현)',
                );
              }));
            },
          ),
          ListTile(
            title: const Text('환불 계좌 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const _TempScaffold(
                  title: '환불 계좌 관리',
                  body: '환불 계좌 등록/수정 화면(추후 구현)',
                );
              }));
            },
          ),
          const Divider(height: 1),

          // ───────────────── 3) 계정관리
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('계정관리', style: _sectionStyle),
          ),
          ListTile(
            title: const Text('프로필 변경'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            title: const Text('비밀번호 변경'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PasswordChangePage()),
              );
            },
          ),
          const Divider(height: 1),

          // ───────────────── 4) 고객지원
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('고객지원', style: _sectionStyle),
          ),
          ListTile(
            title: const Text('자주 묻는 질문(FAQ)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const _TempScaffold(title: 'FAQ', body: '자주 묻는 질문 목록(추후 구현)');
              }));
            },
          ),
          ListTile(
            title: const Text('문제 신고(버그 리포트·로그 전송)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그가 준비되면 전송 기능과 연결할게요.')),
              );
            },
          ),
          ListTile(
            title: const Text('앱 버전 / 업데이트 확인'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'KU멍가게',
                applicationVersion: '1.0.0',
                children: const [
                  Text('최신 버전 여부는 스토어/배포 채널과 연동하여 확인할 수 있어요.'),
                ],
              );
            },
          ),
          const Divider(height: 1),

          // ───────────────── 5) 기타 (로그아웃/회원탈퇴)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('기타', style: _sectionStyle),
          ),
          // ✅ 로그아웃: GoRouter로 로그인 화면 이동(스택 리셋)
          ListTile(
            title: const Text('로그아웃'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              // TODO: 세션/토큰 정리 로직 삽입
              if (!mounted) return;
              context.goNamed('login');
            },
          ),
          // ✅ 회원탈퇴: 확인 → 완료 안내 → 로그인 이동
          ListTile(
            title: const Text('회원탈퇴', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final ok = await _confirmWithdraw(context);
              if (ok != true || !mounted) return;

              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: const Text('회원탈퇴 됐습니다.'),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // 다이얼로그 닫기
                        if (!mounted) return;
                        context.goNamed('login'); // 로그인으로 이동
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 방해 금지 시간대 선택
  Future<void> _pickDndRange() async {
    final start = await showTimePicker(context: context, initialTime: _dndStart);
    if (!mounted || start == null) return;
    final end = await showTimePicker(context: context, initialTime: _dndEnd);
    if (!mounted || end == null) return;
    setState(() {
      _dndStart = start;
      _dndEnd = end;
    });
  }

  // HH:mm 포맷
  String _fmt(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // 회원탈퇴 확인 다이얼로그 (우상단 X 포함)
  Future<bool?> _confirmWithdraw(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
        title: Row(
          children: [
            const Expanded(child: Text('회원탈퇴를 진행하시겠습니까?')),
            IconButton(
              tooltip: '닫기',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
        content: const Text('확인을 누르면 계정이 삭제되며, 이 작업은 취소할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('아니오'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 임시 화면(플레이스홀더)
class _TempScaffold extends StatelessWidget {
  const _TempScaffold({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: Text(body)),
    );
  }
}
