import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/trip_model.dart';
import '../../services/api_service.dart';

/// Rider-side page shown after booking a ride.
///
/// Two phases:
///  1. **Finding Driver** – pulsing loader, trip preview, estimated fare,
///     cancel-request button.
///  2. **Driver Details** – map placeholder, ETA badge, driver profile card
///     (avatar, name, rating, car details, call/message), trip details,
///     fare info, safety features, cancel ride button.
///
/// A chat modal can be opened from phase 2 to message the driver.
class ActiveRidePage extends StatefulWidget {
  final TripModel trip;

  const ActiveRidePage({super.key, required this.trip});

  @override
  State<ActiveRidePage> createState() => _ActiveRidePageState();
}

class _ActiveRidePageState extends State<ActiveRidePage>
    with TickerProviderStateMixin {
  late TripModel _trip;
  Map<String, dynamic>? _driver;
  bool _cancelling = false;
  bool _showMessageModal = false;

  Timer? _pollTimer;

  // Animation controllers
  late AnimationController _pingController;
  late AnimationController _spinController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  // Message modal state
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      id: 1,
      sender: 'driver',
      text: "Hi! I'm on my way to pick you up.",
      time: '2:30 PM',
    ),
  ];
  final _messageCtrl = TextEditingController();
  final _messageScrollCtrl = ScrollController();

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadDriver();

    _pollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _pollTrip());

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pingController.dispose();
    _spinController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    _messageCtrl.dispose();
    _messageScrollCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ───────────────────────────────────────────────

  bool get _isSearching => _trip.status == 'REQUESTED' || _driver == null;

  Future<void> _loadDriver() async {
    if (_trip.driverId == null) return;
    try {
      final data = await apiService.getDriver(_trip.driverId!);
      if (mounted) setState(() => _driver = data);
    } catch (_) {}
  }

  Future<void> _pollTrip() async {
    try {
      final json = await apiService.getTrip(_trip.id);
      final updated = TripModel.fromJson(json);
      if (mounted) {
        setState(() => _trip = updated);
        if (_trip.driverId != null && _driver == null) _loadDriver();
      }
    } catch (_) {}
  }

  Future<void> _cancelTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Trip?'),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Cancel Trip',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await apiService.cancelTrip(_trip.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _callDriver() async {
    final phone = _driver?['phone'] as String?;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver phone not available')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── Message modal helpers ─────────────────────────────────────

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';

    setState(() {
      _messages.add(_ChatMessage(
        id: _messages.length + 1,
        sender: 'rider',
        text: text,
        time: timeStr,
      ));
      _messageCtrl.clear();
    });
    _scrollMessagesToBottom();

    // Simulate driver response after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final replyNow = TimeOfDay.now();
      final replyTime =
          '${replyNow.hourOfPeriod == 0 ? 12 : replyNow.hourOfPeriod}:${replyNow.minute.toString().padLeft(2, '0')} ${replyNow.period == DayPeriod.am ? 'AM' : 'PM'}';
      setState(() {
        _messages.add(_ChatMessage(
          id: _messages.length + 1,
          sender: 'driver',
          text: 'Got it! See you soon.',
          time: replyTime,
        ));
      });
      _scrollMessagesToBottom();
    });
  }

  void _scrollMessagesToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messageScrollCtrl.hasClients) {
        _messageScrollCtrl.animateTo(
          _messageScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Driver info helpers ───────────────────────────────────────

  String get _driverName =>
      _driver?['name'] as String? ?? 'Driver';

  String get _driverPhone =>
      _driver?['phone'] as String? ?? '+1 (555) 123-4567';

  double get _driverRating =>
      (_driver?['rating'] as num?)?.toDouble() ?? 4.9;

  String get _vehicleType =>
      _driver?['vehicleType'] as String? ?? 'Toyota Camry';

  String get _vehiclePlate =>
      _driver?['vehiclePlate'] as String? ?? 'ABC 1234';

  String get _vehicleColor =>
      _driver?['vehicleColor'] as String? ?? 'Black';

  int get _totalTrips =>
      (_driver?['totalTrips'] as num?)?.toInt() ?? 247;

  String get _driverInitials {
    final parts = _driverName.split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0] : '').join('').toUpperCase();
  }

  String get _arrivalTime => '3 minutes';

  String get _pickup => _trip.pickupAddress ?? 'Current Location';
  String get _dropoff => _trip.dropoffAddress ?? '123 Main St, Downtown';
  String get _estimatedFare =>
      _trip.fareAmount != null
          ? '\$${_trip.fareAmount!.toStringAsFixed(2)}'
          : '\$18.50';
  String get _distance =>
      _trip.distanceKm != null
          ? '${_trip.distanceKm!.toStringAsFixed(1)} km'
          : '5.2 km';

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildMapArea(),
              Expanded(child: _buildBottomSheet()),
            ],
          ),
          if (_showMessageModal) _buildMessageModal(),
        ],
      ),
    );
  }

  // ================================================================
  // MAP AREA
  // ================================================================

  Widget _buildMapArea() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
              ),
            ),
          ),

          // Center content
          Center(
            child: _isSearching
                ? _buildSearchingMapCenter()
                : _buildDriverFoundMapCenter(),
          ),

          // Close / back button (top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close,
                    size: 20, color: Color(0xFF374151)),
              ),
            ),
          ),

          // ETA badge (top-right, only when driver found)
          if (!_isSearching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      _arrivalTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Pulsing current-location dot (bottom-center)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(child: _buildPulsingDot()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingMapCenter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated ping ring + spinning loader
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ping ring
              AnimatedBuilder(
                animation: _pingController,
                builder: (_, __) => Transform.scale(
                  scale: 0.5 + _pingController.value * 0.8,
                  child: Opacity(
                    opacity: (1 - _pingController.value).clamp(0.0, 1.0),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFBFDBFE),
                        border: Border.all(
                            color: const Color(0xFF2563EB), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              // Static background circle
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDBEAFE),
                ),
              ),
              // Spinning loader icon
              AnimatedBuilder(
                animation: _spinController,
                builder: (_, child) => Transform.rotate(
                  angle: _spinController.value * 6.28318,
                  child: child,
                ),
                child: const Icon(Icons.sync,
                    size: 48, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Finding Driver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Searching nearby drivers...',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildDriverFoundMapCenter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceController,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -8 * _bounceController.value),
            child: child,
          ),
          child: const Icon(Icons.location_on,
              size: 64, color: Color(0xFF2563EB)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Live Tracking',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Driver is on the way',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildPulsingDot() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final scale = 1.0 + 0.4 * _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: (1 - _pulseController.value) * 0.4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // BOTTOM SHEET
  // ================================================================

  Widget _buildBottomSheet() {
    return Container(
      margin: const EdgeInsets.only(top: -32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _isSearching
                  ? _buildSearchingContent()
                  : _buildDriverFoundContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PHASE 1 – FINDING DRIVER
  // ================================================================

  Widget _buildSearchingContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Loading animation
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _spinController,
              builder: (_, child) => Transform.rotate(
                angle: _spinController.value * 6.28318,
                child: child,
              ),
              child: const Icon(Icons.sync,
                  size: 40, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Finding Your Driver',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We're matching you with the best available driver nearby",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Trip Preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 32,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: const Color(0xFFD1D5DB),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280))),
                          const SizedBox(height: 2),
                          Text(_pickup,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827))),
                        ],
                      ),
                    ),
                  ],
                ),
                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFFDC2626)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dropoff',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280))),
                          const SizedBox(height: 2),
                          Text(_dropoff,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Estimated Fare card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Fare',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                Text(
                  _estimatedFare,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bouncing progress dots
          _buildBouncingDots(),
          const SizedBox(height: 24),

          // Cancel Request button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelling ? null : _cancelTrip,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(
                    color: Color(0xFFE5E7EB), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _cancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Cancel Request',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBouncingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (_, __) {
            final delay = i * 0.33;
            final t = (_bounceController.value - delay).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, -6 * t),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ================================================================
  // PHASE 2 – DRIVER FOUND / EN ROUTE
  // ================================================================

  Widget _buildDriverFoundContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFF2563EB),
                        const Color(0xFF93C5FD),
                        _pulseController.value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Driver is on the way',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver Profile card
          _buildDriverProfileCard(),
          const SizedBox(height: 16),

          // Trip Details
          _buildTripDetailsSection(),
          const SizedBox(height: 16),

          // Fare Info card
          _buildFareInfoCard(),
          const SizedBox(height: 16),

          // Safety features
          _buildSafetyCard(),
          const SizedBox(height: 16),

          // Cancel Ride button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelling ? null : _cancelTrip,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(
                    color: Color(0xFFFECACA), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _cancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFDC2626)),
                    )
                  : const Text(
                      'Cancel Ride',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Driver profile card ────────────────────────────────────────

  Widget _buildDriverProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _driverInitials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name, rating, car info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Text(
                          _driverRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($_totalTrips trips)',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_vehicleColor $_vehicleType  •  $_vehiclePlate',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Call + Message buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _callDriver,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _showMessageModal = true),
                  icon: const Icon(Icons.message_outlined, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(
                        color: Color(0xFFE5E7EB), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          // Phone number
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phone:',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF6B7280))),
                Text(
                  _driverPhone,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Trip details section ───────────────────────────────────────

  Widget _buildTripDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),

        // Pickup
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: const Color(0xFFD1D5DB),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pickup',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(_pickup,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Dropoff
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.location_on,
                  size: 14, color: Color(0xFFDC2626)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dropoff',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(_dropoff,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Fare info card ─────────────────────────────────────────────

  Widget _buildFareInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Distance',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280))),
              Text(_distance,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Fare',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280))),
              Text(_estimatedFare,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Safety card ────────────────────────────────────────────────

  Widget _buildSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safety',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          // Share trip status
          InkWell(
            onTap: () {
              // Share trip action placeholder
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Share trip status',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF374151))),
                  Icon(Icons.arrow_forward,
                      size: 18, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
          // Emergency SOS
          InkWell(
            onTap: () {
              // Emergency SOS action placeholder
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Emergency SOS',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFFDC2626))),
                  Icon(Icons.emergency,
                      size: 18, color: Color(0xFFDC2626)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // MESSAGE MODAL
  // ================================================================

  Widget _buildMessageModal() {
    final initial = _driverInitials;

    return GestureDetector(
      onTap: () => setState(() => _showMessageModal = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent tap-through
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _driverName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF16A34A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showMessageModal = false),
                          child: const Icon(Icons.close,
                              size: 24, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  // ── Messages list ──
                  Flexible(
                    child: Container(
                      color: const Color(0xFFF9FAFB),
                      child: ListView.builder(
                        controller: _messageScrollCtrl,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isRider = msg.sender == 'rider';

                          return Align(
                            alignment: isRider
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width *
                                        0.65,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isRider
                                    ? const Color(0xFF2563EB)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      const Radius.circular(16),
                                  topRight:
                                      const Radius.circular(16),
                                  bottomLeft: Radius.circular(
                                      isRider ? 16 : 4),
                                  bottomRight: Radius.circular(
                                      isRider ? 4 : 16),
                                ),
                                boxShadow: isRider
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(
                                                  alpha: 0.05),
                                          blurRadius: 4,
                                          offset:
                                              const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: isRider
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: isRider
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isRider
                                          ? const Color(0xFFBFDBFE)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Quick replies ──
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _quickReplyChip(
                            "I'm waiting at the main entrance",
                          ),
                          const SizedBox(width: 8),
                          _quickReplyChip(
                            "I'll be there in 2 minutes",
                          ),
                          const SizedBox(width: 8),
                          _quickReplyChip('Thank you!'),
                        ],
                      ),
                    ),
                  ),

                  // ── Input ──
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageCtrl,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _messageCtrl,
                          builder: (_, value, __) {
                            final hasText =
                                value.text.trim().isNotEmpty;
                            return GestureDetector(
                              onTap: hasText ? _sendMessage : null,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: hasText
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.send,
                                  size: 20,
                                  color: hasText
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickReplyChip(String text) {
    return GestureDetector(
      onTap: () => _messageCtrl.text = text,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

// ── Local chat message model (for the demo message modal) ────────

class _ChatMessage {
  final int id;
  final String sender; // 'rider' | 'driver'
  final String text;
  final String time;

  const _ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
  });
}
