import 'package:flutter/material.dart';
import '../settings/password_change_screen.dart';
// import '../settings/email_check_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../settings/nickname_change_screen.dart';
import '../settings/delete_screen.dart';
import '../settings/logout_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary; // 테마 색상 적용
    final sectionTitleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.grey[600],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text('환경설정', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // 🔹 알림 설정
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("알림 설정", style: sectionTitleStyle),
          ),
          SwitchListTile(
            title: const Text("알림 받기"),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),

          // 🔹 계정 관리
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("계정 관리", style: sectionTitleStyle),
          ),
          ListTile(
            title: const Text("프로필 변경"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditPage()),
              );
            },
          ),
          ListTile(
            title: const Text("닉네임 변경"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NicknameChangePage()),
              );
            },
          ),
          ListTile(
            title: const Text("비밀번호 변경"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PasswordChangePage()),
              );
            },
          ),
          const Divider(),

          // 🔹 기타
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("기타", style: sectionTitleStyle),
          ),
          ListTile(
            title: const Text("회원 탈퇴"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountDeletePage()),
              );
            },
          ),
          ListTile(
            title: const Text("로그아웃"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogoutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
