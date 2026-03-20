import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_chat_widget.dart';

class ActiveTripPage extends ConsumerStatefulWidget {
  final TripModel initialTrip;
  final int driverId;

  const ActiveTripPage({
    super.key,
    required this.initialTrip,
    required this.driverId,
  });

  @override
  ConsumerState<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends ConsumerState<ActiveTripPage> {
  late TripModel _trip;
  List<Map<String, dynamic>> _activities = [];
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.initialTrip;
    _loadActivities();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (!mounted) return;
    try {
      final data = await apiService.getTrip(_trip.id);
      final updated = TripModel.fromJson(data);
      if (mounted) setState(() => _trip = updated);
      if (updated.status == 'COMPLETED' || updated.status == 'CANCELLED') {
        _timer?.cancel();
      }
      await _loadActivities();
    } catch (_) {}
  }

  Future<void> _loadActivities() async {
    try {
      final list = await apiService.getTripActivities(_trip.id);
      if (mounted) setState(() => _activities = list.cast<Map<String, dynamic>>());
    } catch (_) {}
  }

  Future<void> _arrive() async {
    setState(() => _loading = true);
    try {
      final data = await apiService.arriveTrip(_trip.id, widget.driverId);
      if (mounted) {
        setState(() { _trip = TripModel.fromJson(data); _loading = false; });
        _loadActivities();
      }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _showError('$e'); }
    }
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final data = await apiService.startTrip(_trip.id);
      if (mounted) {
        setState(() { _trip = TripModel.fromJson(data); _loading = false; });
        _loadActivities();
      }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _showError('$e'); }
    }
  }

  Future<void> _showCompleteDialog() async {
    final distCtrl = TextEditingController(text: '5.0');
    final fareCtrl = TextEditingController(text: '12.50');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: distCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Distance (km)', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fareCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Fare amount (\$)', border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Complete')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final dist = double.tryParse(distCtrl.text) ?? 0;
    final fare = double.tryParse(fareCtrl.text) ?? 0;
    setState(() => _loading = true);
    try {
      final data = await apiService.completeTrip(_trip.id, dist, fare);
      if (mounted) {
        setState(() { _trip = TripModel.fromJson(data); _loading = false; });
        _loadActivities();
        _timer?.cancel();
      }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _showError('$e'); }
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Cancel Trip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final data = await apiService.cancelTrip(_trip.id);
      if (mounted) {
        setState(() { _trip = TripModel.fromJson(data); _loading = false; });
        _loadActivities();
        _timer?.cancel();
      }
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _showError('$e'); }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFDC2626)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.read(authProvider).driver;
    final isFinished = _trip.status == 'COMPLETED' || _trip.status == 'CANCELLED';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Active Trip',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          if (!isFinished)
            TextButton(
              onPressed: _loading ? null : _cancel,
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFDC2626))),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(),
            const SizedBox(height: 16),
            _buildTripDetailsCard(),
            const SizedBox(height: 16),
            _buildActivityTimeline(),
            const SizedBox(height: 16),
            if (!isFinished && driver != null)
              SizedBox(
                height: 320,
                child: TripChatWidget(
                  tripId: _trip.id,
                  mySenderId: widget.driverId,
                  mySenderName: driver.name,
                  mySenderRole: 'DRIVER',
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Action card ──────────────────────────────────────────────

  Widget _buildActionCard() {
    final status = _trip.status;
    Color headerColor;
    String headerText;
    String subText;
    IconData headerIcon;

    if (status == 'COMPLETED') {
      headerColor = const Color(0xFF10B981);
      headerText = 'Trip Completed';
      subText = 'Fare: \$${_trip.fareAmount?.toStringAsFixed(2) ?? '—'}  ·  ${_trip.distanceKm?.toStringAsFixed(1) ?? '—'} km';
      headerIcon = Icons.check_circle;
    } else if (status == 'CANCELLED') {
      headerColor = const Color(0xFFDC2626);
      headerText = 'Trip Cancelled';
      subText = 'This trip has been cancelled';
      headerIcon = Icons.cancel;
    } else if (status == 'IN_PROGRESS') {
      headerColor = const Color(0xFF2563EB);
      headerText = 'Trip In Progress';
      subText = 'En route to destination';
      headerIcon = Icons.navigation;
    } else if (_trip.arrivedAt != null) {
      headerColor = const Color(0xFF7C3AED);
      headerText = 'Arrived at Pickup';
      subText = 'Waiting for rider — tap Start Trip when ready';
      headerIcon = Icons.location_on;
    } else {
      headerColor = const Color(0xFFF59E0B);
      headerText = 'Trip Accepted';
      subText = 'Heading to pickup location';
      headerIcon = Icons.directions_car;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(headerIcon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(headerText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(subText, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_trip.status != 'COMPLETED' && _trip.status != 'CANCELLED')
            Padding(padding: const EdgeInsets.all(16), child: _buildActionButton()),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final status = _trip.status;

    if (status == 'ACCEPTED' && _trip.arrivedAt == null) {
      return _actionBtn(
        label: "I've Arrived",
        icon: Icons.location_on,
        color: const Color(0xFF7C3AED),
        onTap: _arrive,
      );
    }
    if (status == 'ACCEPTED' && _trip.arrivedAt != null) {
      return _actionBtn(
        label: 'Start Trip',
        icon: Icons.play_arrow,
        color: const Color(0xFF2563EB),
        onTap: _start,
      );
    }
    if (status == 'IN_PROGRESS') {
      return _actionBtn(
        label: 'Complete Trip',
        icon: Icons.flag,
        color: const Color(0xFF10B981),
        onTap: _showCompleteDialog,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : onTap,
        icon: _loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon),
        label: Text(_loading ? 'Updating…' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Trip details card ────────────────────────────────────────

  Widget _buildTripDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trip Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          _infoRow(Icons.radio_button_checked, const Color(0xFF10B981), 'Pickup', _trip.pickupAddress ?? '—'),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on, const Color(0xFFDC2626), 'Drop-off', _trip.dropoffAddress ?? '—'),
          if (_trip.isDelivery && _trip.packageDescription != null) ...[
            const Divider(height: 20),
            _infoRow(Icons.inventory_2_outlined, const Color(0xFFF59E0B), 'Package', _trip.packageDescription!),
          ],
          if (_trip.isDelivery && _trip.recipientName != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.person_outline, const Color(0xFF6B7280), 'Recipient',
                '${_trip.recipientName}${_trip.recipientPhone != null ? ' · ${_trip.recipientPhone}' : ''}'),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }

  // ── Activity timeline ────────────────────────────────────────

  Widget _buildActivityTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          if (_activities.isEmpty)
            const Text('No activity yet', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)))
          else
            ...List.generate(_activities.length, (i) {
              return _buildActivityItem(_activities[i], i == _activities.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isLast) {
    final type = activity['activityType'] as String? ?? '';
    final role = activity['performedByRole'] as String? ?? 'SYSTEM';
    final name = activity['performedByName'] as String? ?? 'System';
    final note = activity['note'] as String?;
    final createdAt = activity['createdAt'] as String? ?? '';

    final (Color dotColor, IconData icon, String label) = switch (type) {
      'TRIP_REQUESTED' => (const Color(0xFF6B7280), Icons.add_circle_outline, 'Trip Requested'),
      'TRIP_ACCEPTED'  => (const Color(0xFF2563EB), Icons.check_circle_outline, 'Trip Accepted'),
      'DRIVER_ARRIVED' => (const Color(0xFF7C3AED), Icons.location_on, 'Driver Arrived'),
      'TRIP_STARTED'   => (const Color(0xFFF59E0B), Icons.play_circle_outline, 'Trip Started'),
      'TRIP_COMPLETED' => (const Color(0xFF10B981), Icons.check_circle, 'Trip Completed'),
      'TRIP_CANCELLED' => (const Color(0xFFDC2626), Icons.cancel, 'Trip Cancelled'),
      _                => (const Color(0xFF6B7280), Icons.info_outline, type),
    };

    final timeStr = createdAt.length >= 16 ? createdAt.substring(11, 16) : createdAt;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.15), shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: dotColor),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: const Color(0xFFE5E7EB))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                      Text(timeStr, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  Text('By $name ($role)', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  if (note != null) ...[
                    const SizedBox(height: 4),
                    Text(note, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
