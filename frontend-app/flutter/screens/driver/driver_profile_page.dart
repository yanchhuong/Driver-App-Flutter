import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DriverProfilePage extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const DriverProfilePage({super.key, required this.onLogout});

  @override
  ConsumerState<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends ConsumerState<DriverProfilePage> {
  bool isEditing = false;
  bool _togglingStatus = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    final driver = ref.read(authProvider).driver;
    _nameController =
        TextEditingController(text: driver?.name ?? '');
    _emailController =
        TextEditingController(text: driver?.email ?? '');
    _phoneController =
        TextEditingController(text: driver?.phone ?? '');
    _licenseController =
        TextEditingController(text: driver?.licenseNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _toggleOnlineStatus() async {
    final driver = ref.read(authProvider).driver;
    if (driver == null || _togglingStatus) return;
    setState(() => _togglingStatus = true);
    try {
      final newStatus = driver.isOnline ? 'OFFLINE' : 'AVAILABLE';
      await apiService.updateDriverStatus(driver.id, newStatus);
      // Refresh driver in auth state
      await ref.read(authProvider.notifier).restoreSession();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;
    if (driver == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF2563EB),
                      child: Text(
                        driver.name.isNotEmpty
                            ? driver.name[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: driver.isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  driver.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                Text(
                  driver.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                      fontSize: 14,
                      color: driver.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                // Online toggle
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _togglingStatus ? null : _toggleOnlineStatus,
                    icon: _togglingStatus
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(driver.isOnline
                            ? Icons.power_settings_new
                            : Icons.play_arrow),
                    label: Text(driver.isOnline
                        ? 'Go Offline'
                        : 'Go Online'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: driver.isOnline
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Edit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => isEditing = !isEditing),
                icon: Icon(isEditing ? Icons.close : Icons.edit, size: 18),
                label: Text(isEditing ? 'Cancel Editing' : 'Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Personal Information
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827))),
                const SizedBox(height: 16),
                _buildProfileField(
                    'Name', _nameController, Icons.person, isEditing),
                const SizedBox(height: 12),
                _buildProfileField(
                    'Email', _emailController, Icons.email, isEditing),
                const SizedBox(height: 12),
                _buildProfileField(
                    'Phone', _phoneController, Icons.phone, isEditing),
                const SizedBox(height: 12),
                _buildProfileField('License Number', _licenseController,
                    Icons.badge, isEditing),
              ],
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => isEditing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Menu Items
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildMenuItem('Trip History', Icons.history, () {}),
                _buildDivider(),
                _buildMenuItem('Earnings', Icons.attach_money, () {}),
                _buildDivider(),
                _buildMenuItem('Settings', Icons.settings, () {}),
                _buildDivider(),
                _buildMenuItem('Help & Support', Icons.help_outline, () {}),
                _buildDivider(),
                _buildMenuItem('Logout', Icons.logout,
                    () => _showLogoutDialog(context),
                    isDestructive: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      IconData icon, bool editable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: editable,
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor:
                editable ? Colors.white : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: editable
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String label, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: isDestructive
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF6B7280)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        color: isDestructive
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF111827))),
              ),
              Icon(Icons.chevron_right,
                  size: 20,
                  color: isDestructive
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
