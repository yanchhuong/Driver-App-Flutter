import 'dart:async';
import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';

/// Full-screen bottom sheet shown to a driver when a new trip request arrives.
/// Auto-dismisses after [_kTimeout] seconds if the driver takes no action.
class TripRequestSheet extends StatefulWidget {
  final TripModel trip;
  final int driverId;
  final void Function(TripModel) onAccepted;
  final VoidCallback onRejected;

  const TripRequestSheet({
    super.key,
    required this.trip,
    required this.driverId,
    required this.onAccepted,
    required this.onRejected,
  });

  /// Show as a non-dismissible bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required TripModel trip,
    required int driverId,
    required void Function(TripModel) onAccepted,
    required VoidCallback onRejected,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripRequestSheet(
        trip: trip,
        driverId: driverId,
        onAccepted: onAccepted,
        onRejected: onRejected,
      ),
    );
  }

  @override
  State<TripRequestSheet> createState() => _TripRequestSheetState();
}

class _TripRequestSheetState extends State<TripRequestSheet>
    with SingleTickerProviderStateMixin {
  static const _kTimeout = 30; // seconds

  late AnimationController _timerCtrl;
  late Timer _countdown;
  int _remaining = _kTimeout;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();

    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _kTimeout),
    )..forward();

    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _reject();
      }
    });
  }

  @override
  void dispose() {
    _countdown.cancel();
    _timerCtrl.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    _countdown.cancel();
    setState(() => _accepting = true);
    try {
      final data = await apiService.acceptTrip(widget.trip.id, widget.driverId);
      final accepted = TripModel.fromJson(data);
      if (mounted) Navigator.of(context).pop();
      widget.onAccepted(accepted);
    } catch (e) {
      if (!mounted) return;
      setState(() => _accepting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _reject() {
    _countdown.cancel();
    if (mounted) Navigator.of(context).pop();
    widget.onRejected();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final isDelivery = trip.isDelivery;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: isDelivery
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF2563EB),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDelivery
                        ? Icons.inventory_2_outlined
                        : Icons.directions_car,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivery ? 'Delivery Request' : 'Ride Request',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isDelivery && trip.deliveryType != null)
                        Text(
                          trip.deliveryType == 'EXPRESS'
                              ? '⚡ Express delivery'
                              : '📦 Normal delivery',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                // Countdown ring
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _timerCtrl,
                        builder: (_, __) => CircularProgressIndicator(
                          value: 1.0 - _timerCtrl.value,
                          strokeWidth: 3,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      ),
                      Text(
                        '$_remaining',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Trip details ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                _routeRow(
                  icon: Icons.circle,
                  iconColor: const Color(0xFF10B981),
                  label: 'Pickup',
                  value: trip.pickupAddress ?? 'Location pending',
                ),
                _routeDivider(),
                _routeRow(
                  icon: Icons.location_on,
                  iconColor: const Color(0xFFDC2626),
                  label: trip.isDelivery ? 'Delivery to' : 'Drop-off',
                  value: trip.dropoffAddress ?? 'Destination pending',
                ),

                const Divider(height: 28, color: Color(0xFFE5E7EB)),

                // Stats row
                Row(
                  children: [
                    _statChip(
                      Icons.attach_money,
                      trip.fareAmount != null
                          ? '\$${trip.fareAmount!.toStringAsFixed(2)}'
                          : 'TBD',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    if (trip.distanceKm != null)
                      _statChip(
                        Icons.straighten,
                        '${trip.distanceKm!.toStringAsFixed(1)} km',
                        const Color(0xFF2563EB),
                      ),
                    const SizedBox(width: 8),
                    _statChip(
                      Icons.person_outline,
                      'Rider #${trip.riderId}',
                      const Color(0xFF6B7280),
                    ),
                  ],
                ),

                // Package info (delivery only)
                if (isDelivery && trip.packageDescription != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.packageDescription!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── Buttons ───────────────────────────────────
                Row(
                  children: [
                    // Reject
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _accepting ? null : _reject,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side:
                              const BorderSide(color: Color(0xFFDC2626)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Accept
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _accepting ? null : _accept,
                        icon: _accepting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                            _accepting ? 'Accepting…' : 'Accept Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 7, top: 4, bottom: 4),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            width: 1.5,
            height: 5,
            margin: const EdgeInsets.only(bottom: 2),
            color: const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
