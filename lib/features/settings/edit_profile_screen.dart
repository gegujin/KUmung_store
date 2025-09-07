import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  File? _profileImage; // 갤러리에서 선택한 이미지 파일

  // 갤러리에서 이미지 선택
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 변경"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 위쪽 배치
          children: [
            const SizedBox(height: 40), // 앱바와 이미지 사이 여백
            CircleAvatar(
              radius: 70,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage("assets/default_profile.png")
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("프로필 사진 변경"),
            ),
          ],
        ),
      ),
    );
  }
}
