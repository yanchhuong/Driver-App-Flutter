import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DriverSettingsPage extends ConsumerStatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  ConsumerState<DriverSettingsPage> createState() => _DriverSettingsPageState();
}

class _DriverSettingsPageState extends ConsumerState<DriverSettingsPage> {
  // Active section for detail view
  String? _activeSection;

  // ── Existing state preserved ──────────────────────────────────
  final bool _tripRequests = true;
  final bool _earnings = true;
  bool _promotionsEnabled = false;

  // Vehicle info controllers (real API integration)
  late TextEditingController _vehicleTypeCtrl;
  late TextEditingController _vehiclePlateCtrl;
  bool _savingVehicle = false;

  // ── Account Settings state ────────────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emergencyNameCtrl;
  late TextEditingController _emergencyContactCtrl;

  // ── Vehicle section extra state ───────────────────────────────
  late TextEditingController _makeCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _plateCtrl;
  late TextEditingController _vinCtrl;
  String _seatingCapacity = '4';

  // ── Documents state ───────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _documents = {
    'license': {
      'name': "Driver's License",
      'icon': Icons.credit_card,
      'uploaded': true,
      'expiry': '2027-03-15',
      'verified': true,
    },
    'insurance': {
      'name': 'Insurance',
      'icon': Icons.shield,
      'uploaded': true,
      'expiry': '2026-12-31',
      'verified': true,
    },
    'registration': {
      'name': 'Vehicle Registration',
      'icon': Icons.directions_car,
      'uploaded': true,
      'expiry': '2026-06-30',
      'verified': true,
    },
    'background': {
      'name': 'Background Check',
      'icon': Icons.verified_user,
      'uploaded': true,
      'expiry': '2026-01-15',
      'verified': true,
    },
  };

  // ── Working Preferences state ─────────────────────────────────
  late TextEditingController _maxDistanceCtrl;
  bool _autoAccept = false;
  bool _acceptPool = true;
  bool _acceptDelivery = false;
  bool _acceptPets = true;

  // ── Navigation state ──────────────────────────────────────────
  String _navApp = 'builtin';
  bool _voiceGuidance = true;
  bool _avoidTolls = false;
  bool _avoidHighways = false;

  // ── Notifications state ───────────────────────────────────────
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _rideRequests = true;
  bool _riderMessages = true;
  bool _earningsReports = true;
  bool _maintenanceReminders = true;

  @override
  void initState() {
    super.initState();
    final driver = ref.read(authProvider).driver;
    _vehicleTypeCtrl =
        TextEditingController(text: driver?.vehicleType ?? '');
    _vehiclePlateCtrl =
        TextEditingController(text: driver?.vehiclePlate ?? '');

    _nameCtrl = TextEditingController(text: 'John Driver');
    _emailCtrl = TextEditingController(text: 'john.driver@example.com');
    _phoneCtrl = TextEditingController(text: '+1 (555) 987-6543');
    _dobCtrl = TextEditingController(text: '1988-03-20');
    _addressCtrl =
        TextEditingController(text: '123 Main St, City, State 12345');
    _emergencyNameCtrl = TextEditingController(text: 'Jane Driver');
    _emergencyContactCtrl =
        TextEditingController(text: '+1 (555) 111-2222');

    _makeCtrl = TextEditingController(text: 'Toyota');
    _modelCtrl = TextEditingController(text: 'Camry');
    _yearCtrl = TextEditingController(text: '2022');
    _colorCtrl = TextEditingController(text: 'Silver');
    _plateCtrl = TextEditingController(text: 'ABC-1234');
    _vinCtrl = TextEditingController(text: '1HGBH41JXMN109186');

    _maxDistanceCtrl = TextEditingController(text: '20');
  }

  @override
  void dispose() {
    _vehicleTypeCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _maxDistanceCtrl.dispose();
    super.dispose();
  }

  // ── Real API methods (preserved) ──────────────────────────────
  Future<void> _saveVehicleInfo() async {
    final driver = ref.read(authProvider).driver;
    if (driver == null) return;
    setState(() => _savingVehicle = true);
    final error = await ref.read(authProvider.notifier).updateDriverProfile(
          driver.id,
          name: driver.name,
          email: driver.email,
          phone: driver.phone,
          licenseNumber: driver.licenseNumber,
          vehicleType: _vehicleTypeCtrl.text.trim(),
          vehiclePlate: _vehiclePlateCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _savingVehicle = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Vehicle info updated!'),
      backgroundColor:
          error == null ? const Color(0xFF10B981) : const Color(0xFFDC2626),
    ));
  }

  Future<void> _updateStatus(String status) async {
    final driver = ref.read(authProvider).driver;
    if (driver == null) return;
    try {
      await apiService.updateDriverStatus(driver.id, status);
      await ref.read(authProvider.notifier).restoreSession();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ));
      }
    }
  }

  // ── Section definitions ───────────────────────────────────────
  static const List<Map<String, dynamic>> _sections = [
    {
      'id': 'account',
      'icon': Icons.person,
      'label': 'Account Settings',
      'subtitle': 'Personal information',
      'iconColor': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
    },
    {
      'id': 'vehicle',
      'icon': Icons.directions_car,
      'label': 'Vehicle Information',
      'subtitle': 'Your car details',
      'iconColor': Color(0xFF9333EA),
      'bgColor': Color(0xFFFAF5FF),
    },
    {
      'id': 'documents',
      'icon': Icons.description,
      'label': 'Documents',
      'subtitle': 'License, insurance & permits',
      'iconColor': Color(0xFFEA580C),
      'bgColor': Color(0xFFFFF7ED),
    },
    {
      'id': 'earnings',
      'icon': Icons.account_balance_wallet,
      'label': 'Earnings & Payouts',
      'subtitle': 'Payment preferences',
      'iconColor': Color(0xFF16A34A),
      'bgColor': Color(0xFFF0FDF4),
    },
    {
      'id': 'working',
      'icon': Icons.access_time,
      'label': 'Working Preferences',
      'subtitle': 'Trip acceptance settings',
      'iconColor': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
    },
    {
      'id': 'navigation',
      'icon': Icons.navigation,
      'label': 'Navigation',
      'subtitle': 'Route preferences',
      'iconColor': Color(0xFF4F46E5),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'id': 'notifications',
      'icon': Icons.notifications,
      'label': 'Notifications',
      'subtitle': 'Alert preferences',
      'iconColor': Color(0xFF16A34A),
      'bgColor': Color(0xFFF0FDF4),
    },
    {
      'id': 'security',
      'icon': Icons.lock,
      'label': 'Security',
      'subtitle': 'Password & authentication',
      'iconColor': Color(0xFFDC2626),
      'bgColor': Color(0xFFFEF2F2),
    },
    {
      'id': 'help',
      'icon': Icons.help_outline,
      'label': 'Help & Support',
      'subtitle': 'Get assistance',
      'iconColor': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
    },
    {
      'id': 'legal',
      'icon': Icons.description,
      'label': 'Legal',
      'subtitle': 'Terms & policies',
      'iconColor': Color(0xFF6B7280),
      'bgColor': Color(0xFFF9FAFB),
    },
    {
      'id': 'about',
      'icon': Icons.info_outline,
      'label': 'About',
      'subtitle': 'App info',
      'iconColor': Color(0xFF6B7280),
      'bgColor': Color(0xFFF9FAFB),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          _activeSection == null
              ? 'Settings'
              : _sections.firstWhere(
                  (s) => s['id'] == _activeSection,
                  orElse: () => {'label': 'Settings'},
                )['label'] as String,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF374151)),
        leading: _activeSection != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _activeSection = null),
              )
            : null,
      ),
      body: _activeSection == null
          ? _buildSectionList(driver)
          : _buildDetailView(_activeSection!),
    );
  }

  // ── Section list ──────────────────────────────────────────────
  Widget _buildSectionList(dynamic driver) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Availability card (persistent, above section list)
        _buildAvailabilityCard(driver),
        const SizedBox(height: 16),

        // 11 section cards
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _sections.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                  ),
                _buildSectionTile(_sections[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAvailabilityCard(dynamic driver) {
    final isOnline = driver?.isOnline ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFF9CA3AF).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF9CA3AF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle,
              size: 14,
              color: isOnline
                  ? const Color(0xFF10B981)
                  : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'You are visible to riders'
                      : 'You are not receiving trips',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: (v) => _updateStatus(v ? 'ONLINE' : 'OFFLINE'),
            activeThumbColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTile(Map<String, dynamic> section) {
    return InkWell(
      onTap: () => setState(() => _activeSection = section['id'] as String),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: section['bgColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                section['icon'] as IconData,
                size: 22,
                color: section['iconColor'] as Color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['label'] as String,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    section['subtitle'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ── Detail view dispatcher ────────────────────────────────────
  Widget _buildDetailView(String sectionId) {
    switch (sectionId) {
      case 'account':
        return _buildAccountSection();
      case 'vehicle':
        return _buildVehicleSection();
      case 'documents':
        return _buildDocumentsSection();
      case 'earnings':
        return _buildEarningsSection();
      case 'working':
        return _buildWorkingSection();
      case 'navigation':
        return _buildNavigationSection();
      case 'notifications':
        return _buildNotificationsSection();
      case 'security':
        return _buildSecuritySection();
      case 'help':
        return _buildHelpSection();
      case 'legal':
        return _buildLegalSection();
      case 'about':
        return _buildAboutSection();
      default:
        return const Center(child: Text('Section not found'));
    }
  }

  // ── 1. Account Settings ───────────────────────────────────────
  Widget _buildAccountSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile photo card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Upload Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Personal info form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Information',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 16),
              _formField(_nameCtrl, 'Full Name', 'Enter your full name'),
              const SizedBox(height: 12),
              _formField(_emailCtrl, 'Email', 'Enter your email',
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _formField(_phoneCtrl, 'Phone', 'Enter your phone number',
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _formField(_dobCtrl, 'Date of Birth', 'YYYY-MM-DD'),
              const SizedBox(height: 12),
              _formField(_addressCtrl, 'Address', 'Enter your address',
                  maxLines: 2),
              const SizedBox(height: 16),
              _primaryButton('Save Changes', () {}),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Emergency contact form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Emergency Contact',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 16),
              _formField(_emergencyNameCtrl, 'Contact Name',
                  'Enter contact name'),
              const SizedBox(height: 12),
              _formField(_emergencyContactCtrl, 'Phone',
                  'Enter contact phone',
                  keyboard: TextInputType.phone),
              const SizedBox(height: 16),
              _primaryButton('Update Emergency Contact', () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 2. Vehicle Information ────────────────────────────────────
  Widget _buildVehicleSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle photo placeholder
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car,
                  size: 48, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Upload'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Vehicle details form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vehicle Details',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 16),

              // Make / Model row
              Row(
                children: [
                  Expanded(
                    child: _formField(
                        _vehicleTypeCtrl, 'Make / Type', 'e.g. Toyota'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _formField(_modelCtrl, 'Model', 'e.g. Camry'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Year / Color row
              Row(
                children: [
                  Expanded(
                    child: _formField(_yearCtrl, 'Year', 'e.g. 2022',
                        keyboard: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        _formField(_colorCtrl, 'Color', 'e.g. Silver'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _formField(_vehiclePlateCtrl, 'License Plate', 'e.g. ABC-1234'),
              const SizedBox(height: 12),
              _formField(_vinCtrl, 'VIN', 'Enter VIN number'),
              const SizedBox(height: 12),

              // Seating Capacity dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seating Capacity',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _seatingCapacity,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: '2', child: Text('2 passengers')),
                      DropdownMenuItem(value: '4', child: Text('4 passengers')),
                      DropdownMenuItem(value: '6', child: Text('6 passengers')),
                      DropdownMenuItem(value: '8', child: Text('8 passengers')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _seatingCapacity = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savingVehicle ? null : _saveVehicleInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _savingVehicle
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Update Vehicle Info',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 3. Documents ──────────────────────────────────────────────
  Widget _buildDocumentsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._documents.entries.map((entry) {
          final doc = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(doc['icon'] as IconData,
                        size: 22, color: const Color(0xFFEA580C)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'] as String,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expires: ${doc['expiry']}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 4),
                        if (doc['verified'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View',
                            style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Update',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "We'll notify you 30 days before any document expires.",
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 4. Earnings & Payouts ─────────────────────────────────────
  Widget _buildEarningsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank Account',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle,
                        size: 22, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connected Account',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151))),
                        Text('****1234 (Chase Bank)',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _primaryButton('View Earnings History', () {}),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Withdraw Balance',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 5. Working Preferences ────────────────────────────────────
  Widget _buildWorkingSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trip Acceptance card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trip Acceptance',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),
              _formField(_maxDistanceCtrl, 'Max Distance (km)',
                  'Enter max distance',
                  keyboard: TextInputType.number),
              const SizedBox(height: 8),
              const Text(
                'Maximum distance from pickup point to accept a trip.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              _settingsSwitchTile(
                  'Auto-Accept Trips',
                  'Automatically accept nearby trip requests',
                  _autoAccept,
                  (v) => setState(() => _autoAccept = v)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Service Types card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Service Types',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ),
              _settingsSwitchTile('Pool Rides', 'Accept shared ride requests',
                  _acceptPool, (v) => setState(() => _acceptPool = v)),
              _settingsSwitchTile('Delivery Requests',
                  'Accept package delivery trips', _acceptDelivery,
                  (v) => setState(() => _acceptDelivery = v)),
              _settingsSwitchTile('Allow Pets',
                  'Accept riders travelling with pets', _acceptPets,
                  (v) => setState(() => _acceptPets = v)),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Preferred Areas card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preferred Areas',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 8),
              const Text(
                'Set preferred zones to receive more trip requests in areas you prefer to drive.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Manage Preferred Areas',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 6. Navigation ─────────────────────────────────────────────
  Widget _buildNavigationSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Navigation App dropdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Navigation App',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _navApp,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF2563EB), width: 2)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'builtin', child: Text('Built-in')),
                  DropdownMenuItem(
                      value: 'google', child: Text('Google Maps')),
                  DropdownMenuItem(
                      value: 'waze', child: Text('Waze')),
                  DropdownMenuItem(
                      value: 'apple', child: Text('Apple Maps')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _navApp = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Route Preferences card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Route Preferences',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ),
              _settingsSwitchTile('Voice Guidance',
                  'Turn-by-turn voice instructions', _voiceGuidance,
                  (v) => setState(() => _voiceGuidance = v)),
              _settingsSwitchTile('Avoid Tolls',
                  'Route around toll roads when possible', _avoidTolls,
                  (v) => setState(() => _avoidTolls = v)),
              _settingsSwitchTile('Avoid Highways',
                  'Prefer local roads over highways', _avoidHighways,
                  (v) => setState(() => _avoidHighways = v)),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 7. Notifications ──────────────────────────────────────────
  Widget _buildNotificationsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Channels
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Notification Channels',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ),
              _settingsSwitchTile('Push Notifications',
                  'Receive push alerts on your device', _pushEnabled,
                  (v) => setState(() => _pushEnabled = v)),
              _settingsSwitchTile('Email Notifications',
                  'Receive updates via email', _emailEnabled,
                  (v) => setState(() => _emailEnabled = v)),
              _settingsSwitchTile('SMS Notifications',
                  'Receive text message alerts', _smsEnabled,
                  (v) => setState(() => _smsEnabled = v)),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notification types
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Notification Types',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ),
              _settingsSwitchTile('Ride Requests',
                  'New trip and delivery requests', _rideRequests,
                  (v) => setState(() => _rideRequests = v)),
              _settingsSwitchTile('Rider Messages',
                  'In-trip messages from riders', _riderMessages,
                  (v) => setState(() => _riderMessages = v)),
              _settingsSwitchTile('Earnings Reports',
                  'Payment received and settlement', _earningsReports,
                  (v) => setState(() => _earningsReports = v)),
              _settingsSwitchTile('Promotions',
                  'Bonus trips and driver incentives', _promotionsEnabled,
                  (v) => setState(() => _promotionsEnabled = v)),
              _settingsSwitchTile('Maintenance Reminders',
                  'Vehicle service and inspection alerts',
                  _maintenanceReminders,
                  (v) => setState(() => _maintenanceReminders = v)),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 8. Security ───────────────────────────────────────────────
  Widget _buildSecuritySection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _navTile('Change Password', '', Icons.lock_outline, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Two-Factor Authentication', 'Off',
                  Icons.security_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Biometric Login', '', Icons.fingerprint, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Active Sessions', '', Icons.devices_outlined, () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 9. Help & Support ─────────────────────────────────────────
  Widget _buildHelpSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _navTile('FAQs', '', Icons.help_outline, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Contact Support', '', Icons.headset_mic_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Report an Issue', '', Icons.bug_report_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Driver Community', '', Icons.group_outlined, () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 10. Legal ─────────────────────────────────────────────────
  Widget _buildLegalSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _navTile('Terms of Service', '', Icons.description_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Privacy Policy', '', Icons.privacy_tip_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Driver Agreement', '', Icons.handshake_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Cookie Policy', '', Icons.cookie_outlined, () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── 11. About ─────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _navTile('App Version', '2.4.1', Icons.smartphone_outlined, () {},
                  showChevron: false),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('What\'s New', '', Icons.new_releases_outlined, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Rate the App', '', Icons.star_outline, () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              _navTile('Open Source Licenses', '',
                  Icons.code_outlined, () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Shared helper widgets ─────────────────────────────────────
  Widget _formField(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
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
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 2)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _settingsSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
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

  Widget _navTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF111827))),
            ),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280))),
            if (showChevron) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFF9CA3AF)),
            ],
          ],
        ),
      ),
    );
  }
}
