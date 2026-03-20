import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';

// ─── Section enum mirroring React's ProfileSection type ──────
enum _ProfileSection {
  main,
  vehicles,
  earnings,
  ratings,
  documents,
  paymentMethods,
  safety,
  help,
}

// ─── Data models for local state ─────────────────────────────

class _VehicleData {
  final int id;
  final String model;
  final String plate;
  final String color;
  final String year;
  final bool isActive;

  _VehicleData({
    required this.id,
    required this.model,
    required this.plate,
    required this.color,
    required this.year,
    required this.isActive,
  });

  _VehicleData copyWith({
    String? model,
    String? plate,
    String? color,
    String? year,
    bool? isActive,
  }) =>
      _VehicleData(
        id: id,
        model: model ?? this.model,
        plate: plate ?? this.plate,
        color: color ?? this.color,
        year: year ?? this.year,
        isActive: isActive ?? this.isActive,
      );
}

class _EarningData {
  final int id;
  final String week;
  final String amount;
  final int trips;
  final int hours;
  final String status;

  const _EarningData({
    required this.id,
    required this.week,
    required this.amount,
    required this.trips,
    required this.hours,
    required this.status,
  });
}

class _ReviewData {
  final int id;
  final String rider;
  final int rating;
  final String comment;
  final String date;

  const _ReviewData({
    required this.id,
    required this.rider,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class _DocumentData {
  final int id;
  final String type;
  final String number;
  final String expiry;
  final String status;

  const _DocumentData({
    required this.id,
    required this.type,
    required this.number,
    required this.expiry,
    required this.status,
  });
}

class _PayoutMethodData {
  final int id;
  final String type;
  final String name;
  final String last4;
  final bool isDefault;

  const _PayoutMethodData({
    required this.id,
    required this.type,
    required this.name,
    required this.last4,
    required this.isDefault,
  });

  _PayoutMethodData copyWith({
    String? type,
    String? name,
    String? last4,
    bool? isDefault,
  }) =>
      _PayoutMethodData(
        id: id,
        type: type ?? this.type,
        name: name ?? this.name,
        last4: last4 ?? this.last4,
        isDefault: isDefault ?? this.isDefault,
      );
}

// ─── Main Page Widget ────────────────────────────────────────

class DriverProfilePage extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const DriverProfilePage({super.key, required this.onLogout});

  @override
  ConsumerState<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends ConsumerState<DriverProfilePage> {
  _ProfileSection _activeSection = _ProfileSection.main;

  // Stats from API
  int _totalTrips = 0;
  double _weeklyEarnings = 0.0;

  // Profile edit
  bool _showProfileModal = false;
  late TextEditingController _editNameCtrl;
  late TextEditingController _editEmailCtrl;
  late TextEditingController _editPhoneCtrl;
  bool _savingProfile = false;

  // Vehicles
  List<_VehicleData> _vehicles = [
    _VehicleData(id: 1, model: 'Toyota Camry 2022', plate: 'ABC-1234', color: 'Silver', year: '2022', isActive: true),
    _VehicleData(id: 2, model: 'Honda Accord 2023', plate: 'XYZ-5678', color: 'Black', year: '2023', isActive: false),
  ];
  bool _showVehicleModal = false;
  int? _editingVehicleId;
  late TextEditingController _vModelCtrl;
  late TextEditingController _vPlateCtrl;
  late TextEditingController _vColorCtrl;
  late TextEditingController _vYearCtrl;

  // Earnings
  final List<_EarningData> _earningsHistory = const [
    _EarningData(id: 1, week: 'Mar 10 - Mar 16, 2026', amount: '\$1,245.50', trips: 52, hours: 38, status: 'Paid'),
    _EarningData(id: 2, week: 'Mar 3 - Mar 9, 2026', amount: '\$1,180.00', trips: 48, hours: 35, status: 'Paid'),
    _EarningData(id: 3, week: 'Feb 24 - Mar 2, 2026', amount: '\$1,320.75', trips: 55, hours: 42, status: 'Paid'),
    _EarningData(id: 4, week: 'Feb 17 - Feb 23, 2026', amount: '\$985.25', trips: 42, hours: 28, status: 'Paid'),
  ];

  // Ratings & Reviews
  final List<_ReviewData> _ratingsData = const [
    _ReviewData(id: 1, rider: 'Sarah Johnson', rating: 5, comment: 'Excellent driver! Very professional and friendly.', date: 'Mar 18, 2026'),
    _ReviewData(id: 2, rider: 'Mike Davis', rating: 5, comment: 'Great ride, smooth driving. Highly recommend!', date: 'Mar 17, 2026'),
    _ReviewData(id: 3, rider: 'Emily Chen', rating: 4, comment: 'Good service, arrived on time.', date: 'Mar 16, 2026'),
    _ReviewData(id: 4, rider: 'Alex Brown', rating: 5, comment: 'Best driver I\'ve had! Clean car and great conversation.', date: 'Mar 15, 2026'),
  ];

  // Documents
  final List<_DocumentData> _documents = const [
    _DocumentData(id: 1, type: 'Driver License', number: 'DL-123456', expiry: 'Dec 31, 2026', status: 'Verified'),
    _DocumentData(id: 2, type: 'Vehicle Registration', number: 'VR-789012', expiry: 'Jun 30, 2026', status: 'Verified'),
    _DocumentData(id: 3, type: 'Insurance Certificate', number: 'IC-345678', expiry: 'Sep 15, 2026', status: 'Verified'),
    _DocumentData(id: 4, type: 'Background Check', number: 'BC-901234', expiry: 'Mar 1, 2027', status: 'Verified'),
  ];

  // Payout Methods
  List<_PayoutMethodData> _payoutMethods = [
    const _PayoutMethodData(id: 1, type: 'Bank Account', name: 'Chase Bank', last4: '4567', isDefault: true),
    const _PayoutMethodData(id: 2, type: 'PayPal', name: 'john.driver@example.com', last4: '', isDefault: false),
  ];
  bool _showPayoutModal = false;
  int? _editingPayoutId;
  late TextEditingController _payoutBankNameCtrl;
  late TextEditingController _payoutAccountNameCtrl;
  late TextEditingController _payoutAccountNumberCtrl;
  late TextEditingController _payoutRoutingNumberCtrl;
  String _payoutTypeSelection = 'Bank Account';

  // ─── Colors (matching React Tailwind classes) ──────────────
  static const _blue600 = Color(0xFF2563EB);
  static const _blue700 = Color(0xFF1D4ED8);
  static const _blue50 = Color(0xFFEFF6FF);
  static const _green600 = Color(0xFF16A34A);
  static const _green700 = Color(0xFF15803D);
  static const _green100 = Color(0xFFDCFCE7);
  static const _green50 = Color(0xFFF0FDF4);
  static const _yellow400 = Color(0xFFFACC15);
  static const _yellow500 = Color(0xFFEAB308);
  static const _yellow50 = Color(0xFFFEF9C3);
  static const _purple600 = Color(0xFF9333EA);
  static const _purple700 = Color(0xFF7E22CE);
  static const _purple50 = Color(0xFFFAF5FF);
  static const _purple400 = Color(0xFFC084FC);
  static const _orange600 = Color(0xFFEA580C);
  static const _orange50 = Color(0xFFFFF7ED);
  static const _red600 = Color(0xFFDC2626);
  static const _red50 = Color(0xFFFEF2F2);
  static const _red200 = Color(0xFFFECACA);
  static const _gray50 = Color(0xFFF9FAFB);
  static const _gray100 = Color(0xFFF3F4F6);
  static const _gray200 = Color(0xFFE5E7EB);
  static const _gray300 = Color(0xFFD1D5DB);
  static const _gray400 = Color(0xFF9CA3AF);
  static const _gray500 = Color(0xFF6B7280);
  static const _gray600 = Color(0xFF4B5563);
  static const _gray700 = Color(0xFF374151);
  static const _gray900 = Color(0xFF111827);

  @override
  void initState() {
    super.initState();
    _loadStats();
    final driver = ref.read(authProvider).driver;
    _editNameCtrl = TextEditingController(text: driver?.name ?? '');
    _editEmailCtrl = TextEditingController(text: driver?.email ?? '');
    _editPhoneCtrl = TextEditingController(text: driver?.phone ?? '');
    _vModelCtrl = TextEditingController();
    _vPlateCtrl = TextEditingController();
    _vColorCtrl = TextEditingController();
    _vYearCtrl = TextEditingController();
    _payoutBankNameCtrl = TextEditingController();
    _payoutAccountNameCtrl = TextEditingController();
    _payoutAccountNumberCtrl = TextEditingController();
    _payoutRoutingNumberCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _editNameCtrl.dispose();
    _editEmailCtrl.dispose();
    _editPhoneCtrl.dispose();
    _vModelCtrl.dispose();
    _vPlateCtrl.dispose();
    _vColorCtrl.dispose();
    _vYearCtrl.dispose();
    _payoutBankNameCtrl.dispose();
    _payoutAccountNameCtrl.dispose();
    _payoutAccountNumberCtrl.dispose();
    _payoutRoutingNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final driver = ref.read(authProvider).driver;
    if (driver == null) return;
    try {
      final list = await apiService.getTrips(driverId: driver.id, status: 'COMPLETED');
      final trips = list.map((j) => TripModel.fromJson(j as Map<String, dynamic>)).toList();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekTrips = trips.where((t) {
        if (t.completedAt == null) return false;
        try {
          final d = DateTime.parse(t.completedAt!);
          return !d.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day));
        } catch (_) {
          return false;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _totalTrips = trips.length;
          _weeklyEarnings = weekTrips.fold(0.0, (s, t) => s + (t.fareAmount ?? 0));
        });
      }
    } catch (_) {}
  }

  // ── Profile handlers ───────────────────────────────────────
  void _openEditProfile() {
    final driver = ref.read(authProvider).driver;
    _editNameCtrl.text = driver?.name ?? '';
    _editEmailCtrl.text = driver?.email ?? '';
    _editPhoneCtrl.text = driver?.phone ?? '';
    setState(() => _showProfileModal = true);
  }

  Future<void> _saveProfile() async {
    final driver = ref.read(authProvider).driver;
    if (driver == null) return;
    setState(() => _savingProfile = true);
    final error = await ref.read(authProvider.notifier).updateDriverProfile(
          driver.id,
          name: _editNameCtrl.text.trim(),
          email: _editEmailCtrl.text.trim(),
          phone: _editPhoneCtrl.text.trim(),
          licenseNumber: driver.licenseNumber,
        );
    if (!mounted) return;
    setState(() {
      _savingProfile = false;
      if (error == null) _showProfileModal = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Profile updated successfully!'),
      backgroundColor: error == null ? _green600 : _red600,
    ));
  }

  // ── Vehicle handlers ───────────────────────────────────────
  void _openAddVehicle() {
    _editingVehicleId = null;
    _vModelCtrl.text = '';
    _vPlateCtrl.text = '';
    _vColorCtrl.text = '';
    _vYearCtrl.text = '';
    setState(() => _showVehicleModal = true);
  }

  void _openEditVehicle(_VehicleData v) {
    _editingVehicleId = v.id;
    _vModelCtrl.text = v.model;
    _vPlateCtrl.text = v.plate;
    _vColorCtrl.text = v.color;
    _vYearCtrl.text = v.year;
    setState(() => _showVehicleModal = true);
  }

  void _saveVehicle() {
    setState(() {
      if (_editingVehicleId != null) {
        _vehicles = _vehicles
            .map((v) => v.id == _editingVehicleId
                ? v.copyWith(
                    model: _vModelCtrl.text,
                    plate: _vPlateCtrl.text,
                    color: _vColorCtrl.text,
                    year: _vYearCtrl.text,
                  )
                : v)
            .toList();
      } else {
        final newId = _vehicles.isEmpty ? 1 : _vehicles.map((v) => v.id).reduce((a, b) => a > b ? a : b) + 1;
        _vehicles.add(_VehicleData(
          id: newId,
          model: _vModelCtrl.text,
          plate: _vPlateCtrl.text,
          color: _vColorCtrl.text,
          year: _vYearCtrl.text,
          isActive: false,
        ));
      }
      _showVehicleModal = false;
    });
  }

  void _deleteVehicle(int id) {
    setState(() {
      _vehicles = _vehicles.where((v) => v.id != id).toList();
    });
  }

  void _setActiveVehicle(int id) {
    setState(() {
      _vehicles = _vehicles.map((v) => v.copyWith(isActive: v.id == id)).toList();
    });
  }

  // ── Payout handlers ───────────────────────────────────────
  void _openAddPayout() {
    _editingPayoutId = null;
    _payoutTypeSelection = 'Bank Account';
    _payoutBankNameCtrl.text = '';
    _payoutAccountNameCtrl.text = '';
    _payoutAccountNumberCtrl.text = '';
    _payoutRoutingNumberCtrl.text = '';
    setState(() => _showPayoutModal = true);
  }

  void _openEditPayout(_PayoutMethodData m) {
    _editingPayoutId = m.id;
    _payoutTypeSelection = m.type;
    _payoutBankNameCtrl.text = m.name;
    _payoutAccountNameCtrl.text = m.name;
    _payoutAccountNumberCtrl.text = m.last4.isNotEmpty ? '****${m.last4}' : '';
    _payoutRoutingNumberCtrl.text = '';
    setState(() => _showPayoutModal = true);
  }

  void _savePayout() {
    setState(() {
      final acctNum = _payoutAccountNumberCtrl.text;
      final last4 = acctNum.length >= 4 ? acctNum.substring(acctNum.length - 4) : acctNum;
      final displayName = _payoutTypeSelection == 'Bank Account'
          ? (_payoutBankNameCtrl.text.isNotEmpty ? _payoutBankNameCtrl.text : _payoutAccountNameCtrl.text)
          : _payoutAccountNameCtrl.text;

      if (_editingPayoutId != null) {
        _payoutMethods = _payoutMethods
            .map((m) => m.id == _editingPayoutId
                ? m.copyWith(type: _payoutTypeSelection, name: displayName, last4: last4)
                : m)
            .toList();
      } else {
        final newId = _payoutMethods.isEmpty ? 1 : _payoutMethods.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
        _payoutMethods.add(_PayoutMethodData(
          id: newId,
          type: _payoutTypeSelection,
          name: displayName,
          last4: last4,
          isDefault: false,
        ));
      }
      _showPayoutModal = false;
    });
  }

  void _deletePayout(int id) {
    setState(() {
      _payoutMethods = _payoutMethods.where((m) => m.id != id).toList();
    });
  }

  void _setDefaultPayout(int id) {
    setState(() {
      _payoutMethods = _payoutMethods.map((m) => m.copyWith(isDefault: m.id == id)).toList();
    });
  }

  // ── Logout dialog ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _red600),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;
    if (driver == null) return const SizedBox();
    ref.watch(driverTripProvider(driver.id));

    switch (_activeSection) {
      case _ProfileSection.vehicles:
        return _buildVehiclesSection();
      case _ProfileSection.earnings:
        return _buildEarningsSection(driver.rating);
      case _ProfileSection.ratings:
        return _buildRatingsSection(driver.rating);
      case _ProfileSection.documents:
        return _buildDocumentsSection();
      case _ProfileSection.paymentMethods:
        return _buildPayoutMethodsSection();
      case _ProfileSection.safety:
        return _buildSafetySection();
      case _ProfileSection.help:
        return _buildHelpSection();
      case _ProfileSection.main:
        return _buildMainSection(driver);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SECTION APP BAR (sticky top bar with back arrow)
  // ═════════════════════════════════════════════════════════════
  Widget _buildSectionAppBar(String title) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _activeSection = _ProfileSection.main),
            icon: const Icon(Icons.arrow_back, color: _gray700, size: 22),
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _gray900)),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // MAIN SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildMainSection(dynamic driver) {
    final activeVehicle = _vehicles.where((v) => v.isActive).isNotEmpty ? _vehicles.firstWhere((v) => v.isActive) : null;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile Header Card ─────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue600, _blue700],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: _blue600.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar + info + edit button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar circle
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, size: 40, color: _blue600),
                          ),
                          const SizedBox(width: 16),
                          // Name / email / phone / member since
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  driver.email,
                                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  driver.phone,
                                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Member since Jan 2024',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                          // Edit button
                          GestureDetector(
                            onTap: _openEditProfile,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats grid
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                        ),
                        child: Row(
                          children: [
                            // Rating
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Color(0xFFFDE047)),
                                      const SizedBox(width: 4),
                                      Text(
                                        driver.rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Rating', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                                ],
                              ),
                            ),
                            // Trips
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '$_totalTrips',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Trips', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                                ],
                              ),
                            ),
                            // This Week
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '\$${_weeklyEarnings.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('This Week', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Active Vehicle Card ─────────────────────────
              if (activeVehicle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gray200),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _blue50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_car, size: 24, color: _blue600),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Active Vehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                              const SizedBox(height: 2),
                              Text(activeVehicle.model, style: const TextStyle(fontSize: 14, color: _gray700)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _gray100, borderRadius: BorderRadius.circular(4)),
                                    child: Text(activeVehicle.plate, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: _gray700)),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(' \u2022 ', style: TextStyle(color: _gray400, fontSize: 12)),
                                  Text(activeVehicle.color, style: const TextStyle(fontSize: 12, color: _gray600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // ── Menu Items ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuCard(Icons.directions_car, 'My Vehicles', 'Manage your vehicles', _blue600, _blue50, () => setState(() => _activeSection = _ProfileSection.vehicles)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.account_balance_wallet, 'Earnings', 'View earnings history', _green600, _green50, () => setState(() => _activeSection = _ProfileSection.earnings)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.star, 'Ratings & Reviews', 'See what riders say', const Color(0xFFCA8A04), _yellow50, () => setState(() => _activeSection = _ProfileSection.ratings)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.description, 'Documents', 'Licenses & permits', _gray600, _gray50, () => setState(() => _activeSection = _ProfileSection.documents)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.credit_card, 'Payout Methods', 'Manage payouts', _purple600, _purple50, () => setState(() => _activeSection = _ProfileSection.paymentMethods)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.shield, 'Safety & Insurance', 'Coverage information', _orange600, _orange50, () => setState(() => _activeSection = _ProfileSection.safety)),
                    const SizedBox(height: 12),
                    _buildMenuCard(Icons.help_outline, 'Help & Support', 'Get assistance', _blue600, _blue50, () => setState(() => _activeSection = _ProfileSection.help)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Logout Button ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _showLogoutDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _red50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _red200, width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20, color: _red600),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _red600)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── App Version ─────────────────────────────────
              const Center(
                child: Text('DriveApp Driver v2.4.1', style: TextStyle(fontSize: 12, color: _gray400)),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // ── Edit Profile Modal ────────────────────────────
        if (_showProfileModal) _buildProfileModal(),
      ],
    );
  }

  // ─── Menu card widget ──────────────────────────────────────
  Widget _buildMenuCard(IconData icon, String label, String subtitle, Color iconColor, Color iconBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: _gray600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: _gray400),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // PROFILE EDIT MODAL
  // ═════════════════════════════════════════════════════════════
  Widget _buildProfileModal() {
    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => setState(() => _showProfileModal = false),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        // Modal
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_blue600, _blue700]),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      GestureDetector(
                        onTap: () => setState(() => _showProfileModal = false),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalField('Full Name', _editNameCtrl),
                      const SizedBox(height: 16),
                      _buildModalField('Email Address', _editEmailCtrl, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildModalField('Phone Number', _editPhoneCtrl, keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                // Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showProfileModal = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(color: _gray100, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _gray700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _savingProfile ? null : _saveProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(color: _blue600, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: _savingProfile
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // VEHICLES SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildVehiclesSection() {
    return Stack(
      children: [
        Container(
          color: _gray50,
          child: Column(
            children: [
              _buildSectionAppBar('My Vehicles'),
              const Divider(height: 1, color: _gray200),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Add button
                      GestureDetector(
                        onTap: _openAddVehicle,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: _blue600, borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add New Vehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Vehicle list
                      ..._vehicles.map((vehicle) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: vehicle.isActive ? const Color(0xFFEFF6FF) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: vehicle.isActive ? const Color(0xFF60A5FA) : _gray200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Car icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: vehicle.isActive ? const Color(0xFFDBEAFE) : _gray100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.directions_car, size: 24, color: vehicle.isActive ? _blue600 : _gray600),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(vehicle.model, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                                            ),
                                            if (vehicle.isActive) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(color: _blue600, borderRadius: BorderRadius.circular(12)),
                                                child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: _gray200, borderRadius: BorderRadius.circular(4)),
                                              child: Text(vehicle.plate, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: _gray700)),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(' \u2022 ', style: TextStyle(fontSize: 12, color: _gray600)),
                                            Text(vehicle.color, style: const TextStyle(fontSize: 13, color: _gray600)),
                                            const SizedBox(width: 4),
                                            const Text(' \u2022 ', style: TextStyle(fontSize: 12, color: _gray600)),
                                            Text(vehicle.year, style: const TextStyle(fontSize: 13, color: _gray600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!vehicle.isActive)
                                        _iconActionButton(Icons.check, _blue600, () => _setActiveVehicle(vehicle.id)),
                                      _iconActionButton(Icons.edit, _blue600, () => _openEditVehicle(vehicle)),
                                      if (!vehicle.isActive)
                                        _iconActionButton(Icons.delete_outline, _red600, () => _deleteVehicle(vehicle.id)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Vehicle Modal
        if (_showVehicleModal) _buildVehicleModal(),
      ],
    );
  }

  Widget _buildVehicleModal() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showVehicleModal = false),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_blue600, _blue700]),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _editingVehicleId != null ? 'Edit Vehicle' : 'Add New Vehicle',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showVehicleModal = false),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModalField('Vehicle Model', _vModelCtrl, hint: 'Toyota Camry 2022'),
                      const SizedBox(height: 16),
                      _buildModalField('License Plate', _vPlateCtrl, hint: 'ABC-1234'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildModalField('Color', _vColorCtrl, hint: 'Silver')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModalField('Year', _vYearCtrl, hint: '2022')),
                        ],
                      ),
                    ],
                  ),
                ),
                // Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showVehicleModal = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(color: _gray100, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _gray700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _saveVehicle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(color: _blue600, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: Text(
                              _editingVehicleId != null ? 'Update' : 'Add Vehicle',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // EARNINGS SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildEarningsSection(double rating) {
    const totalEarnings = '\$42,680.00';
    final weeklyEarnings = '\$${_weeklyEarnings.toStringAsFixed(2)}';

    return Container(
      color: _gray50,
      child: Column(
        children: [
          _buildSectionAppBar('Earnings'),
          const Divider(height: 1, color: _gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Earnings Summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_green600, _green700]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _green600.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Lifetime Earnings', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 8),
                        const Text(totalEarnings, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.3)))),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This Week', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                                    const SizedBox(height: 4),
                                    Text(weeklyEarnings, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Trips', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                                    const SizedBox(height: 4),
                                    Text('$_totalTrips', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Earnings History
                  const Text('Earnings History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _gray900)),
                  const SizedBox(height: 12),
                  ..._earningsHistory.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _gray200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: _gray500),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(e.week, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _gray700)),
                                  ),
                                  Text(e.amount, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _green600)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${e.trips} trips', style: const TextStyle(fontSize: 12, color: _gray600)),
                                  const SizedBox(width: 8),
                                  const Text('\u2022', style: TextStyle(fontSize: 12, color: _gray600)),
                                  const SizedBox(width: 8),
                                  Text('${e.hours} hours', style: const TextStyle(fontSize: 12, color: _gray600)),
                                  const SizedBox(width: 8),
                                  const Text('\u2022', style: TextStyle(fontSize: 12, color: _gray600)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: _green100, borderRadius: BorderRadius.circular(12)),
                                    child: Text(e.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green700)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // RATINGS & REVIEWS SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildRatingsSection(double rating) {
    return Container(
      color: _gray50,
      child: Column(
        children: [
          _buildSectionAppBar('Ratings & Reviews'),
          const Divider(height: 1, color: _gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_yellow400, _yellow500]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _yellow400.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 48, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on $_totalTrips trips',
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reviews list
                  const Text('Recent Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _gray900)),
                  const SizedBox(height: 12),
                  ..._ratingsData.map((review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _gray200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with initials
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), _blue600]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  review.rider.split(' ').map((n) => n[0]).join(''),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(review.rider, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _gray900)),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: _yellow500),
                                            const SizedBox(width: 2),
                                            Text('${review.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _gray900)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(review.comment, style: const TextStyle(fontSize: 13, color: _gray600)),
                                    const SizedBox(height: 4),
                                    Text(review.date, style: const TextStyle(fontSize: 12, color: _gray400)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DOCUMENTS SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildDocumentsSection() {
    return Container(
      color: _gray50,
      child: Column(
        children: [
          _buildSectionAppBar('Documents'),
          const Divider(height: 1, color: _gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _documents.map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _gray200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.description, size: 24, color: _green600),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                                  const SizedBox(height: 4),
                                  Text('ID: ${doc.number}', style: const TextStyle(fontSize: 13, color: _gray600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('Expires: ${doc.expiry}', style: const TextStyle(fontSize: 12, color: _gray500)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(12)),
                                        child: Text(doc.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _green600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _iconActionButton(Icons.edit, _blue600, () {}),
                          ],
                        ),
                      ),
                    )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // PAYOUT METHODS SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildPayoutMethodsSection() {
    return Stack(
      children: [
        Container(
          color: _gray50,
          child: Column(
            children: [
              _buildSectionAppBar('Payout Methods'),
              const Divider(height: 1, color: _gray200),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Add button
                      GestureDetector(
                        onTap: _openAddPayout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: _purple600, borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add Payout Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Payout methods list
                      ..._payoutMethods.map((method) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: method.isDefault ? _purple50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: method.isDefault ? _purple400 : _gray200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Card icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFFA855F7), _purple600]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.credit_card, size: 24, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(method.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                                            if (method.isDefault) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(color: _purple600, borderRadius: BorderRadius.circular(12)),
                                                child: const Text('Default', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(method.name, style: const TextStyle(fontSize: 13, color: _gray600)),
                                        if (method.last4.isNotEmpty)
                                          Text('\u2022\u2022\u2022\u2022 ${method.last4}', style: const TextStyle(fontSize: 12, color: _gray500)),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!method.isDefault)
                                        _iconActionButton(Icons.check, _purple600, () => _setDefaultPayout(method.id)),
                                      _iconActionButton(Icons.edit, _blue600, () => _openEditPayout(method)),
                                      if (!method.isDefault)
                                        _iconActionButton(Icons.delete_outline, _red600, () => _deletePayout(method.id)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Payout Modal
        if (_showPayoutModal) _buildPayoutModal(),
      ],
    );
  }

  Widget _buildPayoutModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showPayoutModal = false),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_purple600, _purple700]),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _editingPayoutId != null ? 'Edit Payout Method' : 'Add Payout Method',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showPayoutModal = false),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Account Type dropdown
                            const Text('Account Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _gray700)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: _gray300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _payoutTypeSelection,
                                  isExpanded: true,
                                  items: ['Bank Account', 'PayPal', 'Venmo']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => _payoutTypeSelection = val!);
                                    setModalState(() {});
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_payoutTypeSelection == 'Bank Account') ...[
                              _buildModalField('Bank Name', _payoutBankNameCtrl, hint: 'Chase Bank'),
                              const SizedBox(height: 16),
                              _buildModalField('Account Name', _payoutAccountNameCtrl, hint: 'John Driver'),
                              const SizedBox(height: 16),
                              _buildModalField('Account Number', _payoutAccountNumberCtrl, hint: '1234567890'),
                              const SizedBox(height: 16),
                              _buildModalField('Routing Number', _payoutRoutingNumberCtrl, hint: '123456789'),
                            ] else ...[
                              _buildModalField('Email Address', _payoutAccountNameCtrl, hint: 'john.driver@example.com', keyboardType: TextInputType.emailAddress),
                            ],
                          ],
                        ),
                      ),
                      // Buttons
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showPayoutModal = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(color: _gray100, borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _gray700)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _savePayout,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(color: _purple600, borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _editingPayoutId != null ? 'Update' : 'Add Method',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SAFETY & INSURANCE SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildSafetySection() {
    return Container(
      color: _gray50,
      child: Column(
        children: [
          _buildSectionAppBar('Safety & Insurance'),
          const Divider(height: 1, color: _gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Insurance Coverage card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: _orange50, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.shield, size: 24, color: _orange600),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Insurance Coverage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                                  SizedBox(height: 4),
                                  Text('You are covered by our comprehensive insurance policy while driving.',
                                      style: TextStyle(fontSize: 13, color: _gray600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: _gray50, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              _buildCoverageRow('Liability Coverage', '\$1,000,000'),
                              const SizedBox(height: 8),
                              _buildCoverageRow('Collision Coverage', '\$50,000'),
                              const SizedBox(height: 8),
                              _buildCoverageRow('Uninsured Motorist', '\$1,000,000'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Safety Features card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Safety Features', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                        const SizedBox(height: 16),
                        _buildSafetyFeatureRow('24/7 Support', 'Emergency assistance available anytime'),
                        const SizedBox(height: 12),
                        _buildSafetyFeatureRow('Incident Report', 'Report any safety concerns instantly'),
                        const SizedBox(height: 12),
                        _buildSafetyFeatureRow('GPS Tracking', 'All trips are tracked for your safety'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _gray600)),
        Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _gray900)),
      ],
    );
  }

  Widget _buildSafetyFeatureRow(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: _blue50, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 20, color: _blue600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _gray900)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: _gray600)),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // HELP & SUPPORT SECTION
  // ═════════════════════════════════════════════════════════════
  Widget _buildHelpSection() {
    const faqs = [
      'How do I update my vehicle information?',
      'When will I receive my earnings?',
      'How do I report an incident?',
      'What insurance coverage do I have?',
    ];

    return Container(
      color: _gray50,
      child: Column(
        children: [
          _buildSectionAppBar('Help & Support'),
          const Divider(height: 1, color: _gray200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Contact Support
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contact Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                        const SizedBox(height: 12),
                        // Live Chat
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: _blue50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(color: _blue600, shape: BoxShape.circle),
                                  child: const Icon(Icons.help_outline, size: 20, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Live Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _gray900)),
                                      SizedBox(height: 2),
                                      Text('Chat with our support team', style: TextStyle(fontSize: 12, color: _gray600)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 20, color: _gray400),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Call Support
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(color: _green600, shape: BoxShape.circle),
                                  child: const Icon(Icons.people, size: 20, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Call Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _gray900)),
                                      SizedBox(height: 2),
                                      Text('1-800-DRIVEAPP (24/7)', style: TextStyle(fontSize: 12, color: _gray600)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 20, color: _gray400),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // FAQs
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FAQs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _gray900)),
                        const SizedBox(height: 12),
                        ...faqs.map((faq) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(faq, style: const TextStyle(fontSize: 13, color: _gray700))),
                                      const Icon(Icons.chevron_right, size: 16, color: _gray400),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═════════════════════════════════════════════════════════════

  Widget _buildModalField(String label, TextEditingController controller,
      {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _gray700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: _gray900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _gray400),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: false,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gray300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gray300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue600, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _iconActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
