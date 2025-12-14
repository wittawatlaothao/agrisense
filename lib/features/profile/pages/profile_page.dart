import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยัน'),
        content: const Text('ต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('ออกจากระบบ')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'ออกจากระบบแล้ว');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('เกิดข้อผิดพลาด'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('อีเมล: ${_user?.email ?? '-'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('ออกจากระบบ'),
            ),
          ],
        ),
      ),
    );
  }
}
