// lib/views/user_profile_edit_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/user_viewmodel.dart';

class UserInfoTab extends ConsumerStatefulWidget {
  const UserInfoTab({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInfoTab> createState() => _UserProfileEditTabState();
}

class _UserProfileEditTabState extends ConsumerState<UserInfoTab> {
  late TextEditingController _nameController;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userViewModelProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _photoPath = user?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }
    try {
      await ref
          .read(userViewModelProvider.notifier)
          .updateUser(name: name, photoPath: _photoPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userViewModelProvider);

    // 로딩 상태 처리
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _photoPath != null ? FileImage(File(_photoPath!)) : null,
                child: _photoPath == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: user.name.isNotEmpty ? user.name : '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
