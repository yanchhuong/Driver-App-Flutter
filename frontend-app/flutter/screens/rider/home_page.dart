import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';

enum _ServiceType { ride, delivery }
enum _DeliveryType { express, normal }

final _serviceTypeProvider = StateProvider<_ServiceType>((_) => _ServiceType.ride);
final _deliveryTypeProvider = StateProvider<_DeliveryType>((_) => _DeliveryType.normal);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _pickupCtrl  = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _pkgDescCtrl = TextEditingController();
  final _recipientNameCtrl  = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _pkgDescCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestTrip() async {
    if (_pickupCtrl.text.trim().isEmpty || _dropoffCtrl.text.trim().isEmpty) {
      _snack('Please enter pickup and dropoff locations');
      return;
    }

    final rider = ref.read(authProvider).rider;
    if (rider == null) return;

    final serviceType = ref.read(_serviceTypeProvider);
    final deliveryType = ref.read(_deliveryTypeProvider);
    final isDelivery = serviceType == _ServiceType.delivery;

    if (isDelivery && _recipientNameCtrl.text.trim().isEmpty) {
      _snack('Please enter recipient name');
      return;
    }

    // Show searching dialog
    _showSearchingDialog();

    final data = <String, dynamic>{
      'riderId': rider.id,
      'tripType': isDelivery ? 'DELIVERY' : 'RIDE',
      if (isDelivery) 'deliveryType': deliveryType == _DeliveryType.express ? 'EXPRESS' : 'NORMAL',
      if (isDelivery) 'packageDescription': _pkgDescCtrl.text.trim(),
      if (isDelivery) 'recipientName': _recipientNameCtrl.text.trim(),
      if (isDelivery) 'recipientPhone': _recipientPhoneCtrl.text.trim(),
      'pickupLatitude': 0.0,
      'pickupLongitude': 0.0,
      'pickupAddress': _pickupCtrl.text.trim(),
      'dropoffLatitude': 0.0,
      'dropoffLongitude': 0.0,
      'dropoffAddress': _dropoffCtrl.text.trim(),
    };

    final trip = await ref
        .read(riderTripProvider(rider.id).notifier)
        .requestTrip(data);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close searching dialog

    if (trip != null) {
      _showTripCreatedDialog(trip);
    } else {
      final err = ref.read(riderTripProvider(rider.id)).error;
      _snack(err ?? 'Failed to request trip');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final serviceType  = ref.watch(_serviceTypeProvider);
    final deliveryType = ref.watch(_deliveryTypeProvider);
    final isDelivery   = serviceType == _ServiceType.delivery;
    final tripState    = ref.watch(
        riderTripProvider(ref.watch(authProvider).rider?.id ?? 0));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Map placeholder
          Container(
            height: 250,
            color: const Color(0xFFE5E7EB),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('Live Map View',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.white,
                    mini: true,
                    child: const Icon(Icons.my_location,
                        color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),

          // Booking form
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Service type (RIDE / DELIVERY) ──
                const Text('Service Type',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _typeCard(
                        icon: Icons.directions_car,
                        label: 'Ride',
                        subtitle: 'Go anywhere',
                        selected: serviceType == _ServiceType.ride,
                        onTap: () => ref
                            .read(_serviceTypeProvider.notifier)
                            .state = _ServiceType.ride,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Delivery',
                        subtitle: 'Send a package',
                        selected: serviceType == _ServiceType.delivery,
                        onTap: () => ref
                            .read(_serviceTypeProvider.notifier)
                            .state = _ServiceType.delivery,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Delivery sub-type ──
                if (isDelivery) ...[
                  const Text('Delivery Speed',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _deliveryChip(
                          label: 'Express',
                          icon: Icons.bolt,
                          color: const Color(0xFFDC2626),
                          selected:
                              deliveryType == _DeliveryType.express,
                          onTap: () => ref
                              .read(_deliveryTypeProvider.notifier)
                              .state = _DeliveryType.express,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _deliveryChip(
                          label: 'Normal',
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF2563EB),
                          selected:
                              deliveryType == _DeliveryType.normal,
                          onTap: () => ref
                              .read(_deliveryTypeProvider.notifier)
                              .state = _DeliveryType.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Locations ──
                _locationField(
                  label: 'Pickup Location',
                  ctrl: _pickupCtrl,
                  icon: Icons.circle,
                  iconColor: const Color(0xFF10B981),
                  hint: 'Enter pickup location',
                ),
                const SizedBox(height: 12),
                _locationField(
                  label: isDelivery ? 'Delivery Address' : 'Dropoff Location',
                  ctrl: _dropoffCtrl,
                  icon: Icons.location_on,
                  iconColor: const Color(0xFFDC2626),
                  hint: isDelivery
                      ? 'Recipient address'
                      : 'Enter destination',
                ),

                // ── Delivery extras ──
                if (isDelivery) ...[
                  const SizedBox(height: 12),
                  _textField(
                      _pkgDescCtrl, 'Package Description',
                      Icons.inventory_2_outlined,
                      'e.g. Electronics — Handle with care'),
                  const SizedBox(height: 12),
                  _textField(_recipientNameCtrl, 'Recipient Name',
                      Icons.person_outline, 'Full name'),
                  const SizedBox(height: 12),
                  _textField(_recipientPhoneCtrl, 'Recipient Phone',
                      Icons.phone_outlined, '+1 234 567 8900',
                      keyboard: TextInputType.phone),
                ],

                const SizedBox(height: 20),

                // ── Error ──
                if (tripState.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(tripState.error!,
                        style: const TextStyle(
                            color: Color(0xFFDC2626), fontSize: 13)),
                  ),

                // ── Submit ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tripState.loading ? null : _requestTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: tripState.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : Text(
                            isDelivery
                                ? 'Send Package'
                                : 'Request Ride',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _typeCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF6B7280)),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  Widget _deliveryChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? color : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Widget _locationField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required Color iconColor,
    required String hint,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                Icon(icon, size: 18, color: iconColor),
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
          ),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint, {
    TextInputType keyboard = TextInputType.text,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
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
          ),
        ),
      ],
    );
  }

  void _showSearchingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB))),
                  ),
                  const Icon(Icons.search,
                      size: 40, color: Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Submitting Trip',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const SizedBox(height: 8),
              const Text('Connecting to server...',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripCreatedDialog(TripModel trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 12),
            Text('Trip Requested!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Trip ID', '#${trip.id}'),
            _infoRow('Type',
                trip.isDelivery ? '📦 Delivery (${trip.deliveryType})' : '🚗 Ride'),
            _infoRow('From', trip.pickupAddress ?? '—'),
            _infoRow('To', trip.dropoffAddress ?? '—'),
            _infoRow('Status', trip.status),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text('Waiting for a driver to accept',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF2563EB))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB)),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ),
        ],
      ),
    );
  }
}
