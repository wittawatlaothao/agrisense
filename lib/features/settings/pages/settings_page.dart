import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ออกจากระบบ'),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== User Info Card =====
          Card(
            child: ListTile(
              leading: Icon(
                Icons.account_circle,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                _user?.email ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('บัญชีผู้ใช้'),
            ),
          ),

          const SizedBox(height: 24),

          // ===== Settings Section =====
          Text(
            'การตั้งค่า',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),

          SettingsTile(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () {
              Navigator.pushNamed(context, '/change_password');
            },
          ),

          SettingsTile(
            icon: Icons.dashboard_customize,
            title: 'ตั้งค่าแดชบอร์ด',
            onTap: () {
              Navigator.pushNamed(context, '/dashboard_config');
            },
          ),

          SettingsTile(
            icon: Icons.settings_input_component,
            title: 'ตั้งค่าอุปกรณ์และเซ็นเซอร์',
            onTap: () {
              Navigator.pushNamed(context, '/hardware_config');
            },
          ),

          SettingsTile(
            icon: Icons.camera_alt,
            title: 'ตั้งค่ากล้อง (Raspberry Pi)',
            onTap: () {
              Navigator.pushNamed(context, '/camera_config');
            },
          ),

          // SettingsTile(
          //   icon: Icons.photo_library,
          //   title: 'ภาพถ่ายจากกล้อง',
          //   onTap: () {
          //     Navigator.pushNamed(context, '/camera_captures');
          //   },
          // ),

          const SizedBox(height: 40),

          // ===== Logout =====
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
