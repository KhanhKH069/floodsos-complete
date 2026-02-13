//lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/auth_provider.dart';
import '../navigation/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Hồ sơ'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, _) {
          final user = provider.user;

          if (user == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Profile header
                _buildProfileHeader(user.name, user.email),

                const SizedBox(height: 24),

                // Account section
                _buildSection(
                  context,
                  'Tài khoản',
                  [
                    _buildMenuItem(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: user.email,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.phone,
                      title: 'Số điện thoại',
                      subtitle: user.phone ?? 'Chưa cập nhật',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.devices,
                      title: 'Thiết bị IoT',
                      subtitle: '2 thiết bị',
                      trailing: Icons.chevron_right,
                      onTap: () {},
                    ),
                  ],
                ),

                // Settings section
                _buildSection(
                  context,
                  'Cài đặt',
                  [
                    _buildSwitchMenuItem(
                      icon: Icons.notifications,
                      title: 'Thông báo',
                      subtitle: 'Nhận cảnh báo khẩn cấp',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildSwitchMenuItem(
                      icon: Icons.location_on,
                      title: 'Vị trí',
                      subtitle: 'Cho phép truy cập vị trí',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'Ngôn ngữ',
                      subtitle: 'Tiếng Việt',
                      trailing: Icons.chevron_right,
                      onTap: () {},
                    ),
                  ],
                ),

                // About section
                _buildSection(
                  context,
                  'Về ứng dụng',
                  [
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'Thông tin ứng dụng',
                      subtitle: 'Version 2.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Trợ giúp',
                      subtitle: 'Hướng dẫn sử dụng',
                      trailing: Icons.chevron_right,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip,
                      title: 'Chính sách bảo mật',
                      subtitle: '',
                      trailing: Icons.chevron_right,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Edit profile button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: ThemeConfig.primaryColor),
                    ),
                    child: const Text('✏️ Chỉnh sửa hồ sơ'),
                  ),
                ),

                const SizedBox(height: 12),

                // Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.dangerColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('🚪 Đăng xuất',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ThemeConfig.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ThemeConfig.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Icon(trailing, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ThemeConfig.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return ThemeConfig.primaryColor;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FloodSOS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version 2.0.0'),
            const SizedBox(height: 8),
            const Text('Hệ thống cảnh báo lũ lụt thông minh'),
            const SizedBox(height: 16),
            Text(
              'Developed with ❤️ for Vietnam',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.login,
                (route) => false,
              );
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: ThemeConfig.dangerColor),
            ),
          ),
        ],
      ),
    );
  }
}
