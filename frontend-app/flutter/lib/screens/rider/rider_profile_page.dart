import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

// ─── Data Models (local state only) ───────────────────────────

class _SavedPlace {
  String id;
  String name;
  String address;
  String iconType; // 'home' | 'work' | 'location' | 'heart' | 'star'

  _SavedPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.iconType,
  });
}

class _FavoriteDriver {
  String id;
  String name;
  double rating;
  int trips;
  String carModel;

  _FavoriteDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.trips,
    required this.carModel,
  });
}

class _Promotion {
  String id;
  String title;
  String code;
  String discount;
  String expiry;

  _Promotion({
    required this.id,
    required this.title,
    required this.code,
    required this.discount,
    required this.expiry,
  });
}

class _PaymentMethod {
  String id;
  String type; // 'Visa' | 'Mastercard' | 'American Express' | 'Discover' | 'Cash'
  String last4;
  String expiry;
  bool isDefault;

  _PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });
}

class _EmergencyContact {
  String id;
  String name;
  String phone;
  String relation;

  _EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });
}

// ─── Main Widget ───────────────────────────────────────────────

class RiderProfilePage extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const RiderProfilePage({super.key, required this.onLogout});

  @override
  ConsumerState<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends ConsumerState<RiderProfilePage> {
  // Section navigation
  String _activeSection = 'main';

  // Edit profile state
  bool _isEditing = false;
  bool _saving = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  // Local data
  final List<_SavedPlace> _savedPlaces = [
    _SavedPlace(
        id: '1',
        name: 'Home',
        address: '123 Main Street, Springfield, IL 62701',
        iconType: 'home'),
    _SavedPlace(
        id: '2',
        name: 'Work',
        address: '456 Business Ave, Springfield, IL 62702',
        iconType: 'work'),
    _SavedPlace(
        id: '3',
        name: "Mom's House",
        address: '789 Oak Drive, Springfield, IL 62703',
        iconType: 'location'),
  ];

  final List<_FavoriteDriver> _favoriteDrivers = [
    _FavoriteDriver(
        id: '1',
        name: 'John Smith',
        rating: 4.9,
        trips: 45,
        carModel: 'Toyota Camry 2022'),
    _FavoriteDriver(
        id: '2',
        name: 'Emily Johnson',
        rating: 5.0,
        trips: 32,
        carModel: 'Honda Accord 2023'),
    _FavoriteDriver(
        id: '3',
        name: 'Michael Brown',
        rating: 4.8,
        trips: 28,
        carModel: 'Tesla Model 3'),
  ];

  final List<_Promotion> _promotions = [
    _Promotion(
        id: '1',
        title: '20% Off Next Ride',
        code: 'RIDE20',
        discount: '20%',
        expiry: 'Mar 31, 2026'),
    _Promotion(
        id: '2',
        title: 'Free Delivery',
        code: 'FREEDEL',
        discount: 'Free',
        expiry: 'Apr 15, 2026'),
    _Promotion(
        id: '3',
        title: '\$5 Off Weekend Rides',
        code: 'WEEKEND5',
        discount: '\$5',
        expiry: 'Mar 25, 2026'),
  ];

  final List<_PaymentMethod> _paymentMethods = [
    _PaymentMethod(
        id: '1',
        type: 'Visa',
        last4: '4242',
        expiry: '12/26',
        isDefault: true),
    _PaymentMethod(
        id: '2',
        type: 'Mastercard',
        last4: '8888',
        expiry: '08/27',
        isDefault: false),
    _PaymentMethod(
        id: '3',
        type: 'Cash',
        last4: '',
        expiry: '',
        isDefault: false),
  ];

  final List<_EmergencyContact> _emergencyContacts = [
    _EmergencyContact(
        id: '1',
        name: 'Jane Doe',
        phone: '+1 555-0100',
        relation: 'Spouse'),
    _EmergencyContact(
        id: '2',
        name: 'Robert Doe',
        phone: '+1 555-0200',
        relation: 'Parent'),
  ];

  bool _shareTrip = true;

  @override
  void initState() {
    super.initState();
    final rider = ref.read(authProvider).rider;
    _nameCtrl = TextEditingController(text: rider?.name ?? '');
    _emailCtrl = TextEditingController(text: rider?.email ?? '');
    _phoneCtrl = TextEditingController(text: rider?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final rider = ref.read(authProvider).rider;
    if (rider == null) return;
    setState(() => _saving = true);
    final error = await ref.read(authProvider.notifier).updateRiderProfile(
          rider.id,
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Profile updated successfully!'),
      backgroundColor:
          error == null ? const Color(0xFF10B981) : const Color(0xFFDC2626),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final rider = ref.watch(authProvider).rider;
    if (rider == null) return const SizedBox();

    switch (_activeSection) {
      case 'saved-places':
        return _SavedPlacesSection(
          places: _savedPlaces,
          onBack: () => setState(() => _activeSection = 'main'),
          onUpdate: (places) => setState(() {
            _savedPlaces
              ..clear()
              ..addAll(places);
          }),
        );
      case 'favorite-drivers':
        return _FavoriteDriversSection(
          drivers: _favoriteDrivers,
          onBack: () => setState(() => _activeSection = 'main'),
          onUpdate: (drivers) => setState(() {
            _favoriteDrivers
              ..clear()
              ..addAll(drivers);
          }),
        );
      case 'promotions':
        return _PromotionsSection(
          promotions: _promotions,
          onBack: () => setState(() => _activeSection = 'main'),
          onUpdate: (promos) => setState(() {
            _promotions
              ..clear()
              ..addAll(promos);
          }),
        );
      case 'payment-methods':
        return _PaymentMethodsSection(
          methods: _paymentMethods,
          onBack: () => setState(() => _activeSection = 'main'),
          onUpdate: (methods) => setState(() {
            _paymentMethods
              ..clear()
              ..addAll(methods);
          }),
        );
      case 'safety':
        return _SafetySection(
          contacts: _emergencyContacts,
          shareTrip: _shareTrip,
          onBack: () => setState(() => _activeSection = 'main'),
          onContactsUpdate: (c) => setState(() {
            _emergencyContacts
              ..clear()
              ..addAll(c);
          }),
          onShareTripChanged: (v) => setState(() => _shareTrip = v),
        );
      case 'help':
        return _HelpSupportSection(
          onBack: () => setState(() => _activeSection = 'main'),
        );
      default:
        return _buildMainView(rider);
    }
  }

  Widget _buildMainView(dynamic rider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Profile Header (Blue Gradient Card) ───────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar + info + edit row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // White circle avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name / email / phone / memberSince
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEditing) ...[
                              Text(
                                rider.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rider.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              if (rider.phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  rider.phone,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Member since Mar 2023',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ] else ...[
                              _buildInlineField(_nameCtrl, 'Name'),
                              const SizedBox(height: 8),
                              _buildInlineField(_emailCtrl, 'Email'),
                              const SizedBox(height: 8),
                              _buildInlineField(_phoneCtrl, 'Phone'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit / Update+Cancel buttons
                      if (!_isEditing)
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = true),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit,
                                size: 20, color: Colors.white),
                          ),
                        )
                      else
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _saving ? null : _saveProfile,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                final r = ref.read(authProvider).rider;
                                _nameCtrl.text = r?.name ?? '';
                                _emailCtrl.text = r?.email ?? '';
                                _phoneCtrl.text = r?.phone ?? '';
                                setState(() => _isEditing = false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.close,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          iconColor: const Color(0xFFFDE047),
                          value: rider.rating.toStringAsFixed(1),
                          label: 'Rating',
                        ),
                        _buildStatItem(
                          value: '156',
                          label: 'Total Trips',
                        ),
                        _buildStatItem(
                          value: '${_savedPlaces.length}',
                          label: 'Saved Places',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Referral Banner ─────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Refer a Friend',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Get \$10 credit each',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Share',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items ────────────────────────────────────────
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuCard(
                  icon: Icons.location_on,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  label: 'Saved Places',
                  subtitle: 'Home, Work & more',
                  onTap: () =>
                      setState(() => _activeSection = 'saved-places'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFFEE2E2),
                  label: 'Favorite Drivers',
                  subtitle: 'Your preferred drivers',
                  onTap: () =>
                      setState(() => _activeSection = 'favorite-drivers'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.card_giftcard,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  label: 'Promotions',
                  subtitle: 'Deals & discounts',
                  onTap: () =>
                      setState(() => _activeSection = 'promotions'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.credit_card,
                  iconColor: const Color(0xFF9333EA),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Payment Methods',
                  subtitle: 'Manage cards & wallet',
                  onTap: () =>
                      setState(() => _activeSection = 'payment-methods'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.shield,
                  iconColor: const Color(0xFFEA580C),
                  iconBg: const Color(0xFFFFF7ED),
                  label: 'Safety',
                  subtitle: 'Emergency contacts',
                  onTap: () => setState(() => _activeSection = 'safety'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.help_outline,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  label: 'Help & Support',
                  subtitle: 'Get assistance',
                  onTap: () => setState(() => _activeSection = 'help'),
                ),
              ],
            ),
          ),

          // ── Logout Button ─────────────────────────────────────
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,
                            color: Color(0xFFDC2626), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Version ───────────────────────────────────────────
          const SizedBox(height: 24),
          const Text(
            'DriveApp v2.4.1',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInlineField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    IconData? icon,
    Color? iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Saved Places Section ──────────────────────────────────────

class _SavedPlacesSection extends StatefulWidget {
  final List<_SavedPlace> places;
  final VoidCallback onBack;
  final void Function(List<_SavedPlace>) onUpdate;

  const _SavedPlacesSection({
    required this.places,
    required this.onBack,
    required this.onUpdate,
  });

  @override
  State<_SavedPlacesSection> createState() => _SavedPlacesSectionState();
}

class _SavedPlacesSectionState extends State<_SavedPlacesSection> {
  late List<_SavedPlace> _places;

  @override
  void initState() {
    super.initState();
    _places = List.from(widget.places);
  }

  void _delete(String id) {
    setState(() => _places.removeWhere((p) => p.id == id));
    widget.onUpdate(_places);
  }

  IconData _placeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business_center;
      case 'heart':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'location':
      default:
        return Icons.location_on;
    }
  }

  Color _placeColor(String type) {
    switch (type) {
      case 'home':
        return const Color(0xFF2563EB);
      case 'work':
        return const Color(0xFF9333EA);
      case 'heart':
        return const Color(0xFFDC2626);
      case 'star':
        return const Color(0xFFCA8A04);
      case 'location':
      default:
        return const Color(0xFF16A34A);
    }
  }

  Color _placeBg(String type) {
    switch (type) {
      case 'home':
        return const Color(0xFFEFF6FF);
      case 'work':
        return const Color(0xFFF5F3FF);
      case 'heart':
        return const Color(0xFFFEF2F2);
      case 'star':
        return const Color(0xFFFEFCE8);
      case 'location':
      default:
        return const Color(0xFFF0FDF4);
    }
  }

  void _openModal({_SavedPlace? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    String iconType = existing?.iconType ?? 'home';

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing == null ? 'Add New Place' : 'Edit Place',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Place Name',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: _modalInputDeco('Home'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Address',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addrCtrl,
                      decoration: _modalInputDeco(
                          '123 Main Street, Springfield, IL 62701'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Icon Type',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: iconType,
                      decoration: _modalInputDeco(''),
                      items: const [
                        DropdownMenuItem(value: 'home', child: Text('Home')),
                        DropdownMenuItem(value: 'work', child: Text('Work')),
                        DropdownMenuItem(
                            value: 'location', child: Text('Location')),
                        DropdownMenuItem(value: 'heart', child: Text('Heart')),
                        DropdownMenuItem(value: 'star', child: Text('Star')),
                      ],
                      onChanged: (v) => setModal(() => iconType = v ?? 'home'),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text('Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151),
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            final name = nameCtrl.text.trim();
                            final addr = addrCtrl.text.trim();
                            if (name.isEmpty || addr.isEmpty) return;
                            setState(() {
                              if (existing == null) {
                                _places.add(_SavedPlace(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  name: name,
                                  address: addr,
                                  iconType: iconType,
                                ));
                              } else {
                                final i = _places
                                    .indexWhere((p) => p.id == existing.id);
                                if (i >= 0) {
                                  _places[i] = _SavedPlace(
                                    id: existing.id,
                                    name: name,
                                    address: addr,
                                    iconType: iconType,
                                  );
                                }
                              }
                            });
                            widget.onUpdate(_places);
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                  existing == null ? 'Add Place' : 'Update',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 15)),
                            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Saved Places', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add New Place button
              Material(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _openModal(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Add New Place',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Place cards
              ..._places.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _placeBg(p.iconType),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_placeIcon(p.iconType),
                                color: _placeColor(p.iconType), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 4),
                                Text(p.address,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconActionButton(
                                icon: Icons.edit,
                                color: const Color(0xFF2563EB),
                                hoverBg: const Color(0xFFDBEAFE),
                                onTap: () => _openModal(existing: p),
                              ),
                              _iconActionButton(
                                icon: Icons.delete_outline,
                                color: const Color(0xFFDC2626),
                                hoverBg: const Color(0xFFFEE2E2),
                                onTap: () => _delete(p.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_places.isEmpty) _emptyState('No saved places yet'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Favorite Drivers Section ──────────────────────────────────

class _FavoriteDriversSection extends StatefulWidget {
  final List<_FavoriteDriver> drivers;
  final VoidCallback onBack;
  final void Function(List<_FavoriteDriver>) onUpdate;

  const _FavoriteDriversSection({
    required this.drivers,
    required this.onBack,
    required this.onUpdate,
  });

  @override
  State<_FavoriteDriversSection> createState() =>
      _FavoriteDriversSectionState();
}

class _FavoriteDriversSectionState extends State<_FavoriteDriversSection> {
  late List<_FavoriteDriver> _drivers;

  @override
  void initState() {
    super.initState();
    _drivers = List.from(widget.drivers);
  }

  void _delete(String id) {
    setState(() => _drivers.removeWhere((d) => d.id == id));
    widget.onUpdate(_drivers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Favorite Drivers', onBack: widget.onBack),
        Expanded(
          child: _drivers.isEmpty
              ? _emptyState('No favorite drivers yet')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _drivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final d = _drivers[i];
                    final initials = d.name.isNotEmpty
                        ? d.name
                            .split(' ')
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?';
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF2563EB)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(d.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF111827))),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.favorite,
                                        size: 16, color: Color(0xFFEF4444)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Color(0xFFEAB308)),
                                    const SizedBox(width: 4),
                                    Text('${d.rating}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF374151))),
                                    const SizedBox(width: 8),
                                    Text(
                                        '\u2022 ${d.trips} trips with you',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280))),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(d.carModel,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          _iconActionButton(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFDC2626),
                            hoverBg: const Color(0xFFFEE2E2),
                            onTap: () => _delete(d.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Promotions Section ────────────────────────────────────────

class _PromotionsSection extends StatefulWidget {
  final List<_Promotion> promotions;
  final VoidCallback onBack;
  final void Function(List<_Promotion>) onUpdate;

  const _PromotionsSection({
    required this.promotions,
    required this.onBack,
    required this.onUpdate,
  });

  @override
  State<_PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<_PromotionsSection> {
  late List<_Promotion> _promos;

  @override
  void initState() {
    super.initState();
    _promos = List.from(widget.promotions);
  }

  void _openAddModal() {
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Promo Code'),
        content: TextField(
          controller: codeCtrl,
          decoration: _modalInputDeco('Enter promo code'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final code = codeCtrl.text.trim().toUpperCase();
              if (code.isEmpty) return;
              setState(() {
                _promos.add(_Promotion(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'New Promo',
                  code: code,
                  discount: '10%',
                  expiry: 'Dec 31, 2026',
                ));
              });
              widget.onUpdate(_promos);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A)),
            child:
                const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Promotions', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Promo Code button
              Material(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _openAddModal,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Add Promo Code',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Promo cards
              ..._promos.asMap().entries.map((entry) {
                final p = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFBBF7D0), width: 2),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.card_giftcard,
                                          size: 20,
                                          color: Color(0xFF16A34A)),
                                      const SizedBox(width: 8),
                                      Text(p.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF111827))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                p.discount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Expires: ${p.expiry}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280))),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Apply Now',
                                style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (_promos.isEmpty) _emptyState('No promotions yet'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Payment Methods Section ───────────────────────────────────

class _PaymentMethodsSection extends StatefulWidget {
  final List<_PaymentMethod> methods;
  final VoidCallback onBack;
  final void Function(List<_PaymentMethod>) onUpdate;

  const _PaymentMethodsSection({
    required this.methods,
    required this.onBack,
    required this.onUpdate,
  });

  @override
  State<_PaymentMethodsSection> createState() =>
      _PaymentMethodsSectionState();
}

class _PaymentMethodsSectionState extends State<_PaymentMethodsSection> {
  late List<_PaymentMethod> _methods;

  @override
  void initState() {
    super.initState();
    _methods = List.from(widget.methods);
  }

  void _setDefault(String id) {
    setState(() {
      for (final m in _methods) {
        m.isDefault = m.id == id;
      }
    });
    widget.onUpdate(_methods);
  }

  void _delete(String id) {
    setState(() => _methods.removeWhere((m) => m.id == id));
    widget.onUpdate(_methods);
  }

  String _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2, cleaned.length.clamp(2, 4))}';
    }
    return cleaned;
  }

  void _openModal({_PaymentMethod? existing}) {
    String type = existing?.type ?? 'Visa';
    final cardNumberCtrl = TextEditingController(
      text: existing != null && existing.last4.isNotEmpty
          ? '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 ${existing.last4}'
          : '',
    );
    final cardholderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController(text: existing?.expiry ?? '');
    final cvvCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing == null
                            ? 'Add Payment Method'
                            : 'Edit Payment Method',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Type',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: _modalInputDecoPurple(''),
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(
                            value: 'Mastercard', child: Text('Mastercard')),
                        DropdownMenuItem(
                            value: 'American Express',
                            child: Text('American Express')),
                        DropdownMenuItem(
                            value: 'Discover', child: Text('Discover')),
                      ],
                      onChanged: (v) => setModal(() => type = v ?? 'Visa'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Card Number',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cardNumberCtrl,
                      decoration:
                          _modalInputDecoPurple('1234 5678 9012 3456'),
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\s\u2022]')),
                      ],
                      onChanged: (v) {
                        final digits =
                            v.replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.length <= 16) {
                          final formatted = _formatCardNumber(digits);
                          if (formatted != v) {
                            cardNumberCtrl.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }
                        }
                      },
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              required maxLength}) =>
                          const SizedBox(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cardholder Name',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cardholderCtrl,
                      decoration: _modalInputDecoPurple('John Doe'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expiry Date',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151))),
                              const SizedBox(height: 8),
                              TextField(
                                controller: expiryCtrl,
                                decoration:
                                    _modalInputDecoPurple('MM/YY'),
                                maxLength: 5,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final formatted = _formatExpiry(v);
                                  if (formatted != v) {
                                    expiryCtrl.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                          offset: formatted.length),
                                    );
                                  }
                                },
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        required maxLength}) =>
                                    const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CVV',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151))),
                              const SizedBox(height: 8),
                              TextField(
                                controller: cvvCtrl,
                                decoration:
                                    _modalInputDecoPurple('123'),
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        required maxLength}) =>
                                    const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text('Cancel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Material(
                          color: const Color(0xFF9333EA),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              final cardNum = cardNumberCtrl.text
                                  .replaceAll(RegExp(r'\s'), '');
                              final last4 = cardNum.length >= 4
                                  ? cardNum.substring(cardNum.length - 4)
                                  : cardNum;
                              final expiry = expiryCtrl.text.trim();
                              if (last4.isEmpty) return;
                              setState(() {
                                if (existing == null) {
                                  _methods.add(_PaymentMethod(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    type: type,
                                    last4: last4,
                                    expiry: expiry,
                                    isDefault: _methods.isEmpty,
                                  ));
                                } else {
                                  final i = _methods.indexWhere(
                                      (m) => m.id == existing.id);
                                  if (i >= 0) {
                                    _methods[i] = _PaymentMethod(
                                      id: existing.id,
                                      type: type,
                                      last4: last4,
                                      expiry: expiry,
                                      isDefault: existing.isDefault,
                                    );
                                  }
                                }
                              });
                              widget.onUpdate(_methods);
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                    existing == null ? 'Add Card' : 'Update',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Payment Methods', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Payment Method button
              Material(
                color: const Color(0xFF9333EA),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _openModal(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Add Payment Method',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Payment cards
              ..._methods.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: m.isDefault
                            ? const Color(0xFFF5F3FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: m.isDefault
                              ? const Color(0xFFC084FC)
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFA855F7),
                                  Color(0xFF9333EA)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.credit_card,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(m.type,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF111827))),
                                    if (m.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9333EA),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text('Default',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                if (m.last4.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                      '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 ${m.last4}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280))),
                                  Text('Expires ${m.expiry}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF))),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (m.last4.isNotEmpty && !m.isDefault)
                                _iconActionButton(
                                  icon: Icons.check,
                                  color: const Color(0xFF9333EA),
                                  hoverBg: const Color(0xFFF3E8FF),
                                  onTap: () => _setDefault(m.id),
                                ),
                              if (m.last4.isNotEmpty)
                                _iconActionButton(
                                  icon: Icons.edit,
                                  color: const Color(0xFF2563EB),
                                  hoverBg: const Color(0xFFDBEAFE),
                                  onTap: () => _openModal(existing: m),
                                ),
                              if (!m.isDefault)
                                _iconActionButton(
                                  icon: Icons.delete_outline,
                                  color: const Color(0xFFDC2626),
                                  hoverBg: const Color(0xFFFEE2E2),
                                  onTap: () => _delete(m.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_methods.isEmpty)
                _emptyState('No payment methods yet'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Safety Section ────────────────────────────────────────────

class _SafetySection extends StatefulWidget {
  final List<_EmergencyContact> contacts;
  final bool shareTrip;
  final VoidCallback onBack;
  final void Function(List<_EmergencyContact>) onContactsUpdate;
  final void Function(bool) onShareTripChanged;

  const _SafetySection({
    required this.contacts,
    required this.shareTrip,
    required this.onBack,
    required this.onContactsUpdate,
    required this.onShareTripChanged,
  });

  @override
  State<_SafetySection> createState() => _SafetySectionState();
}

class _SafetySectionState extends State<_SafetySection> {
  late List<_EmergencyContact> _contacts;
  late bool _shareTrip;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.contacts);
    _shareTrip = widget.shareTrip;
  }

  void _openContactModal({_EmergencyContact? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final relCtrl = TextEditingController(text: existing?.relation ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existing == null
            ? 'Add Emergency Contact'
            : 'Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: _modalInputDeco('Full Name')),
            const SizedBox(height: 12),
            TextField(
                controller: phoneCtrl,
                decoration: _modalInputDeco('Phone Number'),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(
                controller: relCtrl,
                decoration: _modalInputDeco('Relation (e.g. Spouse)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final rel = relCtrl.text.trim();
              if (name.isEmpty || phone.isEmpty) return;
              setState(() {
                if (existing == null) {
                  _contacts.add(_EmergencyContact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    phone: phone,
                    relation: rel,
                  ));
                } else {
                  final i =
                      _contacts.indexWhere((c) => c.id == existing.id);
                  if (i >= 0) {
                    _contacts[i] = _EmergencyContact(
                      id: existing.id,
                      name: name,
                      phone: phone,
                      relation: rel,
                    );
                  }
                }
              });
              widget.onContactsUpdate(_contacts);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C)),
            child: Text(existing == null ? 'Add' : 'Save',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Safety', onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Contacts heading
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151)),
                ),
                const SizedBox(height: 12),

                // Add button
                Material(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _openContactModal(),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Add Emergency Contact',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Contact cards
                ...List.generate(_contacts.length, (i) {
                  final c = _contacts[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.transparent),
                            ),
                            child: const Center(
                              child: Icon(Icons.person,
                                  color: Color(0xFFEA580C), size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text(c.relation,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280))),
                                Text(c.phone,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          _iconActionButton(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFDC2626),
                            hoverBg: const Color(0xFFFEE2E2),
                            onTap: () {
                              setState(() => _contacts
                                  .removeWhere((x) => x.id == c.id));
                              widget.onContactsUpdate(_contacts);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (_contacts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No emergency contacts added.',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  ),

                const SizedBox(height: 24),
                const Text(
                  'Safety Features',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151)),
                ),
                const SizedBox(height: 12),

                // Share Trip Status toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield,
                          size: 20, color: Color(0xFFEA580C)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Share Trip Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF111827))),
                            SizedBox(height: 2),
                            Text('Share real-time location',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Switch(
                        value: _shareTrip,
                        onChanged: (v) {
                          setState(() => _shareTrip = v);
                          widget.onShareTripChanged(v);
                        },
                        activeThumbColor: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 911 Assistance
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    children: [
                      Icon(Icons.phone,
                          size: 20, color: Color(0xFFEA580C)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('911 Assistance',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF111827))),
                            SizedBox(height: 2),
                            Text('Quick access to emergency',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 20, color: Color(0xFF9CA3AF)),
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
}

// ─── Help & Support Section ────────────────────────────────────

class _HelpSupportSection extends StatelessWidget {
  final VoidCallback onBack;

  const _HelpSupportSection({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Help & Support', onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Us heading
                const Text(
                  'Contact Us',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151)),
                ),
                const SizedBox(height: 12),

                // Call Support card
                _buildContactCard(
                  icon: Icons.phone,
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  title: 'Call Support',
                  subtitle: '1-800-RIDE-APP',
                  onTap: () {},
                ),
                const SizedBox(height: 8),

                // FAQ card
                _buildContactCard(
                  icon: Icons.help_outline,
                  iconBg: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF9333EA),
                  title: 'FAQ',
                  subtitle: 'Common questions & answers',
                  onTap: () {},
                ),

                const SizedBox(height: 24),
                const Text(
                  'Frequently Asked',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151)),
                ),
                const SizedBox(height: 12),

                // FAQ items
                _buildFaqCard(
                  question: 'How do I cancel a ride?',
                  answer:
                      'You can cancel from the active ride screen within 2 minutes for free.',
                ),
                const SizedBox(height: 8),
                _buildFaqCard(
                  question: 'How do I get a refund?',
                  answer:
                      'Contact support within 48 hours of your trip for refund requests.',
                ),
                const SizedBox(height: 8),
                _buildFaqCard(
                  question: 'How do I update my payment?',
                  answer:
                      'Go to Payment Methods in your profile to add or remove cards.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF111827))),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(answer,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

// ─── Shared Utility Widgets ────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SectionHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          8, MediaQuery.of(context).padding.top + 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF374151), size: 20),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _iconActionButton({
  required IconData icon,
  required Color color,
  required Color hoverBg,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: hoverBg,
      splashColor: hoverBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color),
      ),
    ),
  );
}

Widget _emptyState(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined,
              size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(message,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
        ],
      ),
    ),
  );
}

InputDecoration _modalInputDeco(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

InputDecoration _modalInputDecoPurple(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
