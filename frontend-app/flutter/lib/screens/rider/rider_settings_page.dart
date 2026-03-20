import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Section descriptor ────────────────────────────────────────────────────

class _SectionItem {
  final String id;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final Color bgColor;

  const _SectionItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.bgColor,
  });
}

const List<_SectionItem> _sections = [
  _SectionItem(
    id: 'account',
    icon: Icons.person,
    label: 'Account Settings',
    subtitle: 'Manage your personal information',
    iconColor: Color(0xFF2563EB),
    bgColor: Color(0xFFEFF6FF),
  ),
  _SectionItem(
    id: 'notifications',
    icon: Icons.notifications,
    label: 'Notifications',
    subtitle: 'Control your alerts',
    iconColor: Color(0xFF16A34A),
    bgColor: Color(0xFFF0FDF4),
  ),
  _SectionItem(
    id: 'privacy',
    icon: Icons.shield,
    label: 'Privacy & Data',
    subtitle: 'Manage your privacy settings',
    iconColor: Color(0xFF9333EA),
    bgColor: Color(0xFFFAF5FF),
  ),
  _SectionItem(
    id: 'preferences',
    icon: Icons.language,
    label: 'App Preferences',
    subtitle: 'Language, theme & more',
    iconColor: Color(0xFFEA580C),
    bgColor: Color(0xFFFFF7ED),
  ),
  _SectionItem(
    id: 'security',
    icon: Icons.lock,
    label: 'Security',
    subtitle: 'Password & authentication',
    iconColor: Color(0xFFDC2626),
    bgColor: Color(0xFFFEF2F2),
  ),
  _SectionItem(
    id: 'data',
    icon: Icons.storage,
    label: 'Data & Storage',
    subtitle: 'Manage app data',
    iconColor: Color(0xFF6B7280),
    bgColor: Color(0xFFF9FAFB),
  ),
  _SectionItem(
    id: 'help',
    icon: Icons.help_outline,
    label: 'Help & Support',
    subtitle: 'Get assistance',
    iconColor: Color(0xFF2563EB),
    bgColor: Color(0xFFEFF6FF),
  ),
  _SectionItem(
    id: 'legal',
    icon: Icons.description,
    label: 'Legal',
    subtitle: 'Terms & policies',
    iconColor: Color(0xFF6B7280),
    bgColor: Color(0xFFF9FAFB),
  ),
  _SectionItem(
    id: 'about',
    icon: Icons.info_outline,
    label: 'About',
    subtitle: 'App info & version',
    iconColor: Color(0xFF6B7280),
    bgColor: Color(0xFFF9FAFB),
  ),
];

// ─── Widget ────────────────────────────────────────────────────────────────

class RiderSettingsPage extends ConsumerStatefulWidget {
  const RiderSettingsPage({super.key});

  @override
  ConsumerState<RiderSettingsPage> createState() => _RiderSettingsPageState();
}

class _RiderSettingsPageState extends ConsumerState<RiderSettingsPage> {
  // Navigation state
  String? _activeSection;

  // ── Account state ─────────────────────────────────────────────────────────
  String _name = 'Sarah Rider';
  String _email = 'sarah.rider@example.com';
  String _phone = '+1 (555) 123-4567';
  String _dob = '1995-05-15';
  String _gender = 'female';

  // ── Notifications state ───────────────────────────────────────────────────
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _rideUpdates = true;
  bool _promotions = true;
  bool _driverMessages = true;
  bool _tripReminders = true;
  bool _paymentReceipts = true;

  // ── Privacy state ─────────────────────────────────────────────────────────
  bool _shareLocation = true;
  bool _saveTripHistory = true;
  bool _shareRating = true;
  bool _allowDataCollection = true;
  bool _personalizedAds = false;

  // ── Preferences state ─────────────────────────────────────────────────────
  String _language = 'en';
  String _theme = 'light';
  String _units = 'imperial';
  String _mapStyle = 'standard';
  bool _autoConfirm = false;
  bool _voiceAssistant = true;

  // ── Security state ────────────────────────────────────────────────────────
  bool _twoFactor = false;
  bool _biometric = false;

  // ── Data & Storage state ──────────────────────────────────────────────────
  String _downloadMaps = 'wifi';
  String _downloadReceipts = 'always';

  // ── Controllers (Account) ─────────────────────────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _emailCtrl = TextEditingController(text: _email);
    _phoneCtrl = TextEditingController(text: _phone);
    _dobCtrl = TextEditingController(text: _dob);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _activeSection == null
          ? _buildSectionList()
          : _buildDetailSection(_activeSection!),
    );
  }

  // ─── Route to correct detail ───────────────────────────────────────────────

  Widget _buildDetailSection(String id) {
    switch (id) {
      case 'account':
        return _buildAccountSection();
      case 'notifications':
        return _buildNotificationsSection();
      case 'privacy':
        return _buildPrivacySection();
      case 'preferences':
        return _buildPreferencesSection();
      case 'security':
        return _buildSecuritySection();
      case 'data':
        return _buildDataSection();
      case 'help':
        return _buildHelpSection();
      case 'legal':
        return _buildLegalSection();
      case 'about':
        return _buildAboutSection();
      default:
        return _buildSectionList();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION LIST
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionList() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              size: 28, color: Color(0xFF374151)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              'Manage your preferences',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        toolbarHeight: 64,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _sections
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildSectionCard(s),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSectionCard(_SectionItem s) {
    return GestureDetector(
      onTap: () => setState(() => _activeSection = s.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: s.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(s.icon, color: s.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailHeader(String title) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 48, bottom: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      size: 28, color: Color(0xFF374151)),
                  onPressed: () => setState(() => _activeSection = null),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  /// Toggle switch row with optional subtitle (matches React's two-line toggle layout).
  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  /// Styled action button row with icon, label, optional subtitle, and chevron.
  /// Matches the React "button with bg-gray-50 rounded-lg" pattern used in
  /// Data Management, Manage Data, and Quick Actions sections.
  Widget _buildActionRow(
    String label, {
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor ?? const Color(0xFF6B7280)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>(
      String label, T value, List<DropdownMenuItem<T>> items,
      ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151))),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                onChanged: onChanged,
                items: items,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueButton(String label, VoidCallback onPressed,
      {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCOUNT SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAccountSection() {
    return Column(
      children: [
        _buildDetailHeader('Account Settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Photo – horizontal layout matching React
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Profile Photo'),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 40, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Upload Photo',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'JPG, PNG or GIF. Max 5MB.',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Personal Information
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Personal Information'),
                    _buildTextField('Full Name', _nameCtrl),
                    _buildTextField('Email', _emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    _buildTextField('Phone Number', _phoneCtrl,
                        keyboardType: TextInputType.phone),
                    _buildTextField('Date of Birth', _dobCtrl),
                    _buildDropdownField<String>(
                      'Gender',
                      _gender,
                      const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                        DropdownMenuItem(
                            value: 'prefer_not',
                            child: Text('Prefer not to say')),
                      ],
                      (v) => setState(() => _gender = v ?? _gender),
                    ),
                    const SizedBox(height: 4),
                    _buildBlueButton('Save Changes', () {
                      setState(() {
                        _name = _nameCtrl.text;
                        _email = _emailCtrl.text;
                        _phone = _phoneCtrl.text;
                        _dob = _dobCtrl.text;
                      });
                    }),
                  ],
                ),
              ),

              // Danger Zone
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFECACA), width: 2),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Once you delete your account, there is no going back.',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFB91C1C)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Account',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827))),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account deletion requested. You will receive a confirmation email.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNotificationsSection() {
    return Column(
      children: [
        _buildDetailHeader('Notifications'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Notification Channels'),
                    _buildSwitchRow(
                      'Push Notifications',
                      _pushEnabled,
                      (v) => setState(() => _pushEnabled = v),
                      subtitle: 'Receive alerts on your device',
                    ),
                    _buildSwitchRow(
                      'Email Notifications',
                      _emailEnabled,
                      (v) => setState(() => _emailEnabled = v),
                      subtitle: 'Receive updates via email',
                    ),
                    _buildSwitchRow(
                      'SMS Notifications',
                      _smsEnabled,
                      (v) => setState(() => _smsEnabled = v),
                      subtitle: 'Receive text messages',
                    ),
                  ],
                ),
              ),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('What to Notify'),
                    _buildSwitchRow('Ride Updates', _rideUpdates,
                        (v) => setState(() => _rideUpdates = v)),
                    _buildSwitchRow('Promotions & Offers', _promotions,
                        (v) => setState(() => _promotions = v)),
                    _buildSwitchRow('Driver Messages', _driverMessages,
                        (v) => setState(() => _driverMessages = v)),
                    _buildSwitchRow('Trip Reminders', _tripReminders,
                        (v) => setState(() => _tripReminders = v)),
                    _buildSwitchRow('Payment Receipts', _paymentReceipts,
                        (v) => setState(() => _paymentReceipts = v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVACY SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPrivacySection() {
    return Column(
      children: [
        _buildDetailHeader('Privacy & Data'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Privacy Controls'),
                    _buildSwitchRow(
                      'Share Location',
                      _shareLocation,
                      (v) => setState(() => _shareLocation = v),
                      subtitle: 'Allow the app to access your location',
                    ),
                    _buildSwitchRow(
                      'Save Trip History',
                      _saveTripHistory,
                      (v) => setState(() => _saveTripHistory = v),
                      subtitle: 'Keep a record of your trips',
                    ),
                    _buildSwitchRow(
                      'Share Rating with Drivers',
                      _shareRating,
                      (v) => setState(() => _shareRating = v),
                      subtitle: 'Let drivers see your rating',
                    ),
                    _buildSwitchRow(
                      'Data Collection',
                      _allowDataCollection,
                      (v) => setState(() => _allowDataCollection = v),
                      subtitle: 'Help improve our services',
                    ),
                    _buildSwitchRow(
                      'Personalized Ads',
                      _personalizedAds,
                      (v) => setState(() => _personalizedAds = v),
                      subtitle: 'See relevant promotions',
                    ),
                  ],
                ),
              ),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Data Management'),
                    _buildActionRow(
                      'Download My Data',
                      subtitle: 'Get a copy of your data',
                      icon: Icons.download,
                      iconColor: const Color(0xFF2563EB),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Your data export is being prepared. You will receive an email when it\'s ready.'),
                          ),
                        );
                      },
                    ),
                    _buildActionRow(
                      'Data Usage Report',
                      subtitle: 'See what data we collect',
                      icon: Icons.description,
                      iconColor: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PREFERENCES SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPreferencesSection() {
    return Column(
      children: [
        _buildDetailHeader('App Preferences'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Language'),
                    _buildDropdownField<String>(
                      'Language',
                      _language,
                      const [
                        DropdownMenuItem(
                            value: 'en', child: Text('English')),
                        DropdownMenuItem(
                            value: 'es', child: Text('Español')),
                        DropdownMenuItem(
                            value: 'fr', child: Text('Français')),
                        DropdownMenuItem(
                            value: 'de', child: Text('Deutsch')),
                        DropdownMenuItem(value: 'zh', child: Text('中文')),
                        DropdownMenuItem(value: 'ja', child: Text('日本語')),
                      ],
                      (v) => setState(() => _language = v ?? _language),
                    ),
                  ],
                ),
              ),
              // Theme
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Theme'),
                    Row(
                      children: [
                        _buildThemeButton('Light', 'light', Icons.wb_sunny),
                        const SizedBox(width: 8),
                        _buildThemeButton(
                            'Dark', 'dark', Icons.dark_mode),
                        const SizedBox(width: 8),
                        _buildThemeButton('Auto', 'auto', Icons.language),
                      ],
                    ),
                  ],
                ),
              ),
              // Distance Units
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Distance Units'),
                    Row(
                      children: [
                        _buildUnitsButton('Miles', 'imperial', 'Imperial'),
                        const SizedBox(width: 8),
                        _buildUnitsButton(
                            'Kilometers', 'metric', 'Metric'),
                      ],
                    ),
                  ],
                ),
              ),
              // Map Style
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Map Style'),
                    _buildDropdownField<String>(
                      'Map Style',
                      _mapStyle,
                      const [
                        DropdownMenuItem(
                            value: 'standard', child: Text('Standard')),
                        DropdownMenuItem(
                            value: 'satellite', child: Text('Satellite')),
                        DropdownMenuItem(
                            value: 'terrain', child: Text('Terrain')),
                        DropdownMenuItem(
                            value: 'hybrid', child: Text('Hybrid')),
                      ],
                      (v) => setState(() => _mapStyle = v ?? _mapStyle),
                    ),
                  ],
                ),
              ),
              // Other
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Other'),
                    _buildSwitchRow(
                      'Auto-confirm Pickup',
                      _autoConfirm,
                      (v) => setState(() => _autoConfirm = v),
                      subtitle: 'Skip confirmation step',
                    ),
                    _buildSwitchRow(
                      'Voice Assistant',
                      _voiceAssistant,
                      (v) => setState(() => _voiceAssistant = v),
                      subtitle: 'Enable voice commands',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeButton(String label, String value, IconData icon) {
    final bool selected = _theme == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _theme = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF374151),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitsButton(String label, String value, String sublabel) {
    final bool selected = _units == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _units = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECURITY SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSecuritySection() {
    return Column(
      children: [
        _buildDetailHeader('Security'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Password
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Password'),
                    _buildBlueButton(
                      'Change Password',
                      () => _showPasswordDialog(context),
                      icon: Icons.lock,
                    ),
                  ],
                ),
              ),

              // 2FA
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchRow(
                      'Two-Factor Authentication',
                      _twoFactor,
                      (v) => setState(() => _twoFactor = v),
                      subtitle: 'Add an extra layer of security',
                    ),
                    if (_twoFactor)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: Color(0xFF16A34A)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Two-factor authentication is enabled',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Biometric
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchRow(
                      'Biometric Login',
                      _biometric,
                      (v) => setState(() => _biometric = v),
                      subtitle: 'Use fingerprint or face ID',
                    ),
                  ],
                ),
              ),

              // Active Sessions
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Active Sessions'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Current Device',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF111827))),
                                SizedBox(height: 2),
                                Text('Chrome on MacOS',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280))),
                                SizedBox(height: 4),
                                Text('Last active: Now',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Sign Out All Other Devices',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogPasswordField(currentCtrl, 'Current Password'),
            const SizedBox(height: 12),
            _dialogPasswordField(newCtrl, 'New Password'),
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Minimum 8 characters',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ),
            ),
            _dialogPasswordField(confirmCtrl, 'Confirm New Password'),
          ],
        ),
        actions: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (newCtrl.text != confirmCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('New passwords do not match!')),
                        );
                        return;
                      }
                      if (newCtrl.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Password must be at least 8 characters!')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Password updated successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Update',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogPasswordField(
      TextEditingController ctrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
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
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA & STORAGE SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDataSection() {
    return Column(
      children: [
        _buildDetailHeader('Data & Storage'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Storage Usage
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Storage Usage'),
                    _buildStorageBar(
                        'App Cache', '24.5 MB', 0.35, const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildStorageBar('Trip History', '12.8 MB', 0.20,
                        const Color(0xFF16A34A)),
                    const SizedBox(height: 12),
                    _buildStorageBar('Downloaded Maps', '45.2 MB', 0.65,
                        const Color(0xFF9333EA)),
                    const Divider(
                        height: 24,
                        thickness: 1,
                        color: Color(0xFFE5E7EB)),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Storage',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827))),
                        Text('82.5 MB',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827))),
                      ],
                    ),
                  ],
                ),
              ),

              // Manage Data
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Manage Data'),
                    _buildActionRow(
                      'Clear Cache',
                      subtitle: 'Free up 24.5 MB',
                      icon: Icons.delete_outline,
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => _showClearCacheDialog(context),
                    ),
                    _buildActionRow(
                      'Offline Maps',
                      subtitle: 'Manage downloaded areas',
                      icon: Icons.storage,
                      iconColor: const Color(0xFF2563EB),
                    ),
                    _buildActionRow(
                      'Location History',
                      subtitle: 'View and delete history',
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),

              // Auto-Download
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Auto-Download'),
                    _buildDropdownField<String>(
                      'Download Maps',
                      _downloadMaps,
                      const [
                        DropdownMenuItem(
                            value: 'never', child: Text('Never')),
                        DropdownMenuItem(
                            value: 'wifi', child: Text('Only on Wi-Fi')),
                        DropdownMenuItem(
                            value: 'always', child: Text('Always')),
                      ],
                      (v) =>
                          setState(() => _downloadMaps = v ?? _downloadMaps),
                    ),
                    _buildDropdownField<String>(
                      'Download Receipts',
                      _downloadReceipts,
                      const [
                        DropdownMenuItem(
                            value: 'never', child: Text('Never')),
                        DropdownMenuItem(
                            value: 'wifi', child: Text('Only on Wi-Fi')),
                        DropdownMenuItem(
                            value: 'always', child: Text('Always')),
                      ],
                      (v) => setState(
                          () => _downloadReceipts = v ?? _downloadReceipts),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content:
            const Text('Clear all cached data? This will log you out.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cache cleared successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBar(
      String label, String size, double value, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280))),
            Text(size,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELP & SUPPORT SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHelpSection() {
    return Column(
      children: [
        _buildDetailHeader('Help & Support'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quick Actions
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Quick Actions'),
                    _buildActionRow(
                      'FAQs',
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFF2563EB),
                    ),
                    _buildActionRow(
                      'Chat with Support',
                      icon: Icons.chat_outlined,
                      iconColor: const Color(0xFF16A34A),
                    ),
                    _buildActionRow(
                      'Call Support',
                      icon: Icons.phone_outlined,
                      iconColor: const Color(0xFFEA580C),
                    ),
                    _buildActionRow(
                      'Email Support',
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF9333EA),
                    ),
                  ],
                ),
              ),

              // Popular Topics
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('Popular Topics'),
                    ...[
                      'How to request a ride',
                      'Payment methods',
                      'Cancellation policy',
                      'Safety features',
                      'Promotional codes',
                      'Lost items',
                    ].map((topic) => InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(topic,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF374151))),
                                ),
                                const Icon(Icons.chevron_right,
                                    size: 16, color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              // Contact info blue card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Immediate Help?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Our support team is available 24/7',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            size: 16, color: Color(0xFF1E3A5F)),
                        SizedBox(width: 8),
                        Text('+1 (800) 123-4567',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF1E3A5F))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email,
                            size: 16, color: Color(0xFF1E3A5F)),
                        SizedBox(width: 8),
                        Text('support@driveapp.com',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF1E3A5F))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGAL SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLegalSection() {
    const items = [
      {'title': 'Terms of Service', 'date': 'Last updated: Jan 15, 2026'},
      {'title': 'Privacy Policy', 'date': 'Last updated: Jan 15, 2026'},
      {'title': 'Cookie Policy', 'date': 'Last updated: Dec 10, 2025'},
      {'title': 'Community Guidelines', 'date': 'Last updated: Nov 5, 2025'},
      {'title': 'Licenses', 'date': 'Open source licenses'},
    ];

    return Column(
      children: [
        _buildDetailHeader('Legal'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (item) => GestureDetector(
                    onTap: () {},
                    child: _buildCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['date']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 20, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ABOUT SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAboutSection() {
    return Column(
      children: [
        _buildDetailHeader('About'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // App info card
              _buildCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.directions_car,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DriveApp',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your reliable ride-sharing companion',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Version 2.4.1',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),

              // Info items – divider-separated list matching React
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildAboutListItem("What's New"),
                    const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE5E7EB)),
                    _buildAboutListItem('Rate Us'),
                    const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE5E7EB)),
                    _buildAboutListItem('Share App'),
                  ],
                ),
              ),

              // Credits card
              _buildCard(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credits',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Made with love by the DriveApp Team',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\u00A9 2026 DriveApp Inc. All rights reserved.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),

              // Social buttons row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('\uD835\uDD4F'),
                    const SizedBox(width: 16),
                    _buildSocialButton('f'),
                    const SizedBox(width: 16),
                    _buildSocialButton('in'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutListItem(String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151)),
        ),
      ),
    );
  }
}
