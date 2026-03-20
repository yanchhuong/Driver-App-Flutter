import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/trip_model.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_chat_widget.dart';

class DriverInfoPage extends StatefulWidget {
  final TripModel trip;
  const DriverInfoPage({super.key, required this.trip});

  @override
  State<DriverInfoPage> createState() => _DriverInfoPageState();
}

class _DriverInfoPageState extends State<DriverInfoPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _driver;
  late TripModel _trip;
  bool _cancelling = false;
  bool _showChat = false;
  Timer? _statusTimer;

  late AnimationController _pingController;
  late AnimationController _spinController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadDriver();
    _statusTimer =
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
    _statusTimer?.cancel();
    _pingController.dispose();
    _spinController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
        if (_trip.driverId != null && _driver == null) {
          _loadDriver();
        }
      }
    } catch (_) {}
  }

  Future<void> _cancelTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Trip?'),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
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
              backgroundColor: const Color(0xFFDC2626)),
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

  bool get _isSearching =>
      _trip.status == 'REQUESTED' || _driver == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              _buildMapArea(),
              Expanded(
                child: _buildBottomCard(),
              ),
            ],
          ),
          if (_showChat) _buildChatModal(),
        ],
      ),
    );
  }

  // ── MAP AREA ──────────────────────────────────────────────────

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
                : _buildFoundMapCenter(),
          ),

          // X close button top-left
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 20, color: Color(0xFF374151)),
              ),
            ),
          ),

          // ETA badge top-right (only when driver found)
          if (!_isSearching)
            Positioned(
              top: 48,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 4),
                    Text('3 minutes',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                  ],
                ),
              ),
            ),

          // Pulsing location dot bottom-center
          Positioned(
            bottom: 28,
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
        // Animated ping + spinner
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ping ring
              AnimatedBuilder(
                animation: _pingController,
                builder: (_, __) => Transform.scale(
                  scale: 0.5 + _pingController.value * 0.8,
                  child: Opacity(
                    opacity: (1 - _pingController.value).clamp(0, 1),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF2563EB), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              // Spinner
              AnimatedBuilder(
                animation: _spinController,
                builder: (_, child) => Transform.rotate(
                  angle: _spinController.value * 6.28318,
                  child: child,
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Finding Driver',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF)),
        ),
      ],
    );
  }

  Widget _buildFoundMapCenter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceController,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -6 * _bounceController.value),
            child: child,
          ),
          child: const Icon(Icons.location_on,
              size: 48, color: Color(0xFF2563EB)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Live Tracking',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF)),
        ),
        const SizedBox(height: 2),
        const Text(
          'Driver is on the way',
          style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6)),
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
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── BOTTOM CARD ───────────────────────────────────────────────

  Widget _buildBottomCard() {
    return Container(
      margin: const EdgeInsets.only(top: -32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            _isSearching
                ? _buildSearchingContent()
                : _buildFoundContent(),
          ],
        ),
      ),
    );
  }

  // ── SEARCHING STATE CONTENT ───────────────────────────────────

  Widget _buildSearchingContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Large spinning loader
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _spinController,
              builder: (_, child) => Transform.rotate(
                angle: _spinController.value * 6.28318,
                child: child,
              ),
              child: const Icon(Icons.sync,
                  size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Finding Your Driver',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 8),
          const Text(
            "We're matching you with the best available driver nearby",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Trip details card
          _buildTripDetailsCard(),
          const SizedBox(height: 16),

          // Estimated fare card
          _buildFareCard(),
          const SizedBox(height: 24),

          // Bouncing dots
          _buildBouncingDots(),
          const SizedBox(height: 24),

          // Cancel request button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelling ? null : _cancelTrip,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _cancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Cancel Request',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
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
                width: 10,
                height: 10,
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

  // ── DRIVER FOUND STATE CONTENT ────────────────────────────────

  Widget _buildFoundContent() {
    final name = _driver?['name'] as String? ?? 'Driver';
    final phone = _driver?['phone'] as String? ?? '';
    final vehicleType = _driver?['vehicleType'] as String?;
    final vehiclePlate = _driver?['vehiclePlate'] as String?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                          const Color(0xFF2563EB),
                          const Color(0xFF93C5FD),
                          _pulseController.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Driver is on the way',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
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
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 3),
                              Text(
                                (_driver?['rating'] as num?)?.toStringAsFixed(1) ?? '5.0',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827)),
                              ),
                              const SizedBox(width: 4),
                              if ((_driver?['totalTrips'] as num?) != null)
                                Text(
                                  '${_driver!['totalTrips']} trips',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280)),
                                ),
                            ],
                          ),
                          if (vehicleType != null || vehiclePlate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                [vehicleType, vehiclePlate]
                                    .where((v) =>
                                        v != null && v.isNotEmpty)
                                    .join(' • '),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _callDriver,
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call Driver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showChat = true),
                        icon: const Icon(Icons.message_outlined,
                            size: 16),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          side: const BorderSide(
                              color: Color(0xFFD1D5DB)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(phone,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trip details
          _buildTripDetailsCard(),
          const SizedBox(height: 16),

          // Distance + fare card
          _buildFareCard(showDistance: true),
          const SizedBox(height: 16),

          // Safety card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.share_outlined,
                        size: 18, color: Color(0xFF374151)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Share trip status',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827))),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFF9CA3AF)),
                  ],
                ),
                SizedBox(height: 8),
                Divider(height: 1, color: Color(0xFFE5E7EB)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.emergency,
                        size: 18, color: Color(0xFFDC2626)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Emergency SOS',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFDC2626))),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cancel ride button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelling ? null : _cancelTrip,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _cancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFDC2626)))
                  : const Text('Cancel Ride',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED WIDGETS ─────────────────────────────────────────────

  Widget _buildTripDetailsCard() {
    final pickup = _trip.pickupAddress ?? 'Pickup location';
    final dropoff = _trip.dropoffAddress ?? 'Dropoff location';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trip Details',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(pickup,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF111827))),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
            child: Container(
                width: 2, height: 16, color: const Color(0xFFD1D5DB)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on,
                  size: 12, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dropoff,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF111827))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard({bool showDistance = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (showDistance && _trip.distanceKm != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distance',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFFBFDBFE))),
                  const SizedBox(height: 2),
                  Text(
                    '${_trip.distanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: showDistance
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                const Text('Estimated Fare',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFFBFDBFE))),
                const SizedBox(height: 2),
                Text(
                  '\$${_trip.fareAmount?.toStringAsFixed(2) ?? '—'}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CHAT MODAL ─────────────────────────────────────────────────

  Widget _buildChatModal() {
    final name = _driver?['name'] as String? ?? 'Driver';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return GestureDetector(
      onTap: () => setState(() => _showChat = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent tap-through
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  // Modal header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                            child: Text(initial,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827))),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Online',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF10B981))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showChat = false),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: Color(0xFF374151)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),

                  // Chat widget (constrained height)
                  SizedBox(
                    height: 420,
                    child: TripChatWidget(
                      tripId: _trip.id,
                      mySenderId: _trip.riderId,
                      mySenderName: 'Rider',
                      mySenderRole: 'RIDER',
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
}
