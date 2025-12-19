import 'package:agrisense/features/profile/pages/profile_tile.dart';
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
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ออกจากระบบ')),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Profile Header =====
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // 👉 ไปหน้าเปลี่ยนรูปโปรไฟล์
                    Navigator.pushNamed(context, '/edit_profile_image');
                  },
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: _user?.photoURL != null
                        ? NetworkImage(_user!.photoURL!)
                        : null,
                    child: _user?.photoURL == null
                        ? Icon(Icons.person,
                            size: 48, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.email ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'แตะเพื่อเปลี่ยนรูปโปรไฟล์',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ===== Settings List =====
          ProfileTile(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () {
              Navigator.pushNamed(context, '/change_password');
            },
          ),

          ProfileTile(
            icon: Icons.image_outlined,
            title: 'เปลี่ยนรูปโปรไฟล์',
            onTap: () {
              Navigator.pushNamed(context, '/edit_profile_image');
            },
          ),

          const SizedBox(height: 40),

          // ===== Logout =====
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text(
              'ออกจากระบบ',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
