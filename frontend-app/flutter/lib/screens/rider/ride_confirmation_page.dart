import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';
import '../../services/api_service.dart';
import '../../services/realtime_service.dart';
import 'driver_info_page.dart';

class RideConfirmationPage extends ConsumerStatefulWidget {
  final String pickup;
  final String dropoff;
  final String tripType; // 'RIDE' or 'DELIVERY'
  final String? deliveryType; // 'EXPRESS' or 'NORMAL'
  final double? fareAmount;
  final double? codAmount;
  final double? packageValue;
  final String? packageDescription;
  final String? recipientName;
  final String? recipientPhone;

  const RideConfirmationPage({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.tripType,
    this.deliveryType,
    this.fareAmount,
    this.codAmount,
    this.packageValue,
    this.packageDescription,
    this.recipientName,
    this.recipientPhone,
  });

  @override
  ConsumerState<RideConfirmationPage> createState() =>
      _RideConfirmationPageState();
}

class _RideConfirmationPageState extends ConsumerState<RideConfirmationPage> {
  String _paymentMethod = 'cash';
  String _rideType = 'ride'; // 'ride' or 'delivery'
  String _deliverySpeed = 'normal'; // 'normal' or 'express'
  String _couponCode = '';
  String _driverNote = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize rideType and deliverySpeed from widget props
    if (widget.tripType == 'DELIVERY') {
      _rideType = 'delivery';
      if (widget.deliveryType == 'EXPRESS') {
        _deliverySpeed = 'express';
      }
    }
  }

  String get _resolvedTripType {
    if (_rideType == 'delivery') return 'DELIVERY';
    return 'RIDE';
  }

  String? get _resolvedDeliveryType {
    if (_rideType != 'delivery') return null;
    return _deliverySpeed == 'express' ? 'EXPRESS' : 'NORMAL';
  }

  String get _serviceLabel {
    if (_rideType == 'delivery') {
      return _deliverySpeed == 'express' ? 'Express Delivery' : 'Standard Delivery';
    }
    return 'Ride';
  }

  String get _serviceSeats {
    if (_rideType == 'delivery') return 'Package';
    return '4 seats';
  }

  String get _fareDisplay {
    if (widget.fareAmount != null) {
      return '\$${widget.fareAmount!.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  String get _estimatedTime => '~ 12 min';

  Future<void> _confirmTrip() async {
    final rider = ref.read(authProvider).rider;
    if (rider == null) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'riderId': rider.id,
      'tripType': _resolvedTripType,
      if (_resolvedTripType == 'DELIVERY' && _resolvedDeliveryType != null)
        'deliveryType': _resolvedDeliveryType,
      if (_resolvedTripType == 'DELIVERY' && widget.packageDescription != null)
        'packageDescription': widget.packageDescription,
      if (_resolvedTripType == 'DELIVERY' && widget.recipientName != null)
        'recipientName': widget.recipientName,
      if (_resolvedTripType == 'DELIVERY' && widget.recipientPhone != null)
        'recipientPhone': widget.recipientPhone,
      'pickupLatitude': 0.0,
      'pickupLongitude': 0.0,
      'pickupAddress': widget.pickup,
      'dropoffLatitude': 0.0,
      'dropoffLongitude': 0.0,
      'dropoffAddress': widget.dropoff,
      if (widget.fareAmount != null) 'fareAmount': widget.fareAmount,
      if (_resolvedTripType == 'DELIVERY' && widget.codAmount != null)
        'codAmount': widget.codAmount,
      if (_resolvedTripType == 'DELIVERY' && widget.packageValue != null)
        'packageValue': widget.packageValue,
    };

    final trip = await ref
        .read(riderTripProvider(rider.id).notifier)
        .requestTrip(data);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (trip != null) {
      Navigator.of(context).pop(); // pop confirmation page
      _showTripWaitingDialog(trip, rider.id);
    } else {
      final err = ref.read(riderTripProvider(rider.id)).error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err ?? 'Failed to request trip')));
    }
  }

  void _showTripWaitingDialog(TripModel trip, int riderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TripWaitingDialog(
        initialTrip: trip,
        riderId: riderId,
        onAccepted: (acceptedTrip) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverInfoPage(trip: acceptedTrip),
            ),
          );
        },
        onCancelled: () {},
      ),
    );
  }

  // ── Modal helpers ────────────────────────────────────────────────

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cash option
                  _buildPaymentOption(
                    ctx,
                    label: 'Cash',
                    icon: Icons.account_balance_wallet,
                    iconColor: const Color(0xFF16A34A),
                    isSelected: _paymentMethod == 'cash',
                    selectedBorderColor: const Color(0xFF16A34A),
                    selectedBgColor: const Color(0xFFF0FDF4),
                    selectedDotColor: const Color(0xFF16A34A),
                    onTap: () {
                      setState(() => _paymentMethod = 'cash');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Card option
                  _buildPaymentOption(
                    ctx,
                    label: 'Card',
                    icon: Icons.account_balance_wallet,
                    iconColor: const Color(0xFF2563EB),
                    isSelected: _paymentMethod == 'card',
                    selectedBorderColor: const Color(0xFF2563EB),
                    selectedBgColor: const Color(0xFFEFF6FF),
                    selectedDotColor: const Color(0xFF2563EB),
                    onTap: () {
                      setState(() => _paymentMethod = 'card');
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E7EB),
                        foregroundColor: const Color(0xFF374151),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext ctx, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required Color selectedBorderColor,
    required Color selectedBgColor,
    required Color selectedDotColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedBorderColor : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedDotColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCouponModal() {
    final controller = TextEditingController(text: _couponCode);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply Coupon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFEA580C),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          foregroundColor: const Color(0xFF374151),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _couponCode = controller.text.trim());
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String localRideType = _rideType;
        String localDeliverySpeed = _deliverySpeed;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Ride Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ride option
                    _buildRideTypeOption(
                      setModalState: setModalState,
                      label: 'Ride',
                      subtitle: 'Standard ride service',
                      icon: Icons.compare_arrows,
                      isSelected: localRideType == 'ride',
                      selectedColor: const Color(0xFF2563EB),
                      selectedBgColor: const Color(0xFFEFF6FF),
                      onTap: () {
                        setModalState(() => localRideType = 'ride');
                      },
                    ),
                    const SizedBox(height: 12),

                    // Delivery option
                    _buildRideTypeOption(
                      setModalState: setModalState,
                      label: 'Delivery',
                      subtitle: 'Package delivery service',
                      icon: Icons.inventory_2_outlined,
                      isSelected: localRideType == 'delivery',
                      selectedColor: const Color(0xFFEA580C),
                      selectedBgColor: const Color(0xFFFFF7ED),
                      onTap: () {
                        setModalState(() => localRideType = 'delivery');
                      },
                    ),

                    // Delivery speed options
                    if (localRideType == 'delivery') ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      const Text(
                        'Delivery Speed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Normal delivery
                      _buildDeliverySpeedOption(
                        setModalState: setModalState,
                        label: 'Normal',
                        subtitle: 'Standard delivery time',
                        timeLabel: _estimatedTime,
                        icon: Icons.inventory_2_outlined,
                        isSelected: localDeliverySpeed == 'normal',
                        selectedColor: const Color(0xFFEA580C),
                        selectedBgColor: const Color(0xFFFFF7ED),
                        onTap: () {
                          setModalState(() => localDeliverySpeed = 'normal');
                        },
                      ),
                      const SizedBox(height: 8),

                      // Express delivery
                      _buildDeliverySpeedOption(
                        setModalState: setModalState,
                        label: 'Express',
                        subtitle: 'Priority fast delivery',
                        timeLabel: '~6 min',
                        icon: Icons.flash_on,
                        isSelected: localDeliverySpeed == 'express',
                        selectedColor: const Color(0xFF7C3AED),
                        selectedBgColor: const Color(0xFFF5F3FF),
                        showFastBadge: true,
                        timeLabelColor: const Color(0xFF7C3AED),
                        onTap: () {
                          setModalState(() => localDeliverySpeed = 'express');
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _rideType = localRideType;
                            _deliverySpeed = localDeliverySpeed;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRideTypeOption({
    required StateSetter setModalState,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
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
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySpeedOption({
    required StateSetter setModalState,
    required String label,
    required String subtitle,
    required String timeLabel,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBgColor,
    required VoidCallback onTap,
    bool showFastBadge = false,
    Color? timeLabelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (showFastBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Fast',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timeLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: timeLabelColor ?? const Color(0xFF111827),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNoteModal() {
    final controller = TextEditingController(text: _driverNote);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Note for Driver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Add instructions for your driver...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFEA580C),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          foregroundColor: const Color(0xFF374151),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _driverNote = controller.text.trim());
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Map Section (top 55%) ──
          SizedBox(
            height: mapHeight,
            child: Stack(
              children: [
                // Map placeholder
                Container(
                  width: double.infinity,
                  height: mapHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDBEAFE),
                        Color(0xFFF0FDF4),
                        Color(0xFFDBEAFE),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map View',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Back button (top left)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: _CircleButton(
                    icon: Icons.chevron_left,
                    iconSize: 26,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),

                // Close button (top right)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: _CircleButton(
                    icon: Icons.close,
                    iconSize: 22,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),

                // "My Location" badge (top center)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      child: const Text(
                        'My Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Sheet ──
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Pull handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Where to?" header
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Color(0xFFEA580C),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Where to?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selected ride type card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Service icon circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _serviceLabel.isNotEmpty
                                          ? _serviceLabel[0]
                                          : 'R',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Service name and destination
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_serviceLabel ($_serviceSeats)',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.dropoff,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Price and time
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _fareDisplay,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                    Text(
                                      _estimatedTime,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action buttons grid (4 columns)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ActionButton(
                                icon: Icons.account_balance_wallet,
                                label: _paymentMethod == 'cash'
                                    ? 'Cash'
                                    : 'Card',
                                iconColor: _paymentMethod == 'cash'
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF6B7280),
                                bgColor: _paymentMethod == 'cash'
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF3F4F6),
                                onTap: _showPaymentModal,
                              ),
                              _ActionButton(
                                icon: Icons.confirmation_num_outlined,
                                label: 'Coupon',
                                iconColor: const Color(0xFF6B7280),
                                bgColor: const Color(0xFFF3F4F6),
                                onTap: _showCouponModal,
                              ),
                              _ActionButton(
                                icon: Icons.menu,
                                label: 'Option',
                                iconColor: const Color(0xFF6B7280),
                                bgColor: const Color(0xFFF3F4F6),
                                onTap: _showOptionsModal,
                              ),
                              _ActionButton(
                                icon: Icons.description_outlined,
                                label: 'Note',
                                iconColor: const Color(0xFF6B7280),
                                bgColor: const Color(0xFFF3F4F6),
                                onTap: _showNoteModal,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Confirm + Cancel buttons
                          Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDBEAFE),
                                    foregroundColor: const Color(0xFF1D4ED8),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Color(0xFFBFDBFE),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Confirm button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting ? null : _confirmTrip,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    disabledBackgroundColor:
                                        const Color(0xFF93C5FD),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Confirm Booking',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle Button (Back / Close overlaid on map) ─────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: const Color(0xFF111827)),
      ),
    );
  }
}

// ── Action Button (Cash/Coupon/Option/Note) ──────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip Waiting Dialog ──────────────────────────────────────────

class _TripWaitingDialog extends StatefulWidget {
  final TripModel initialTrip;
  final int riderId;
  final void Function(TripModel) onAccepted;
  final VoidCallback onCancelled;

  const _TripWaitingDialog({
    required this.initialTrip,
    required this.riderId,
    required this.onAccepted,
    required this.onCancelled,
  });

  @override
  State<_TripWaitingDialog> createState() => _TripWaitingDialogState();
}

class _TripWaitingDialogState extends State<_TripWaitingDialog> {
  Timer? _pollTimer;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _subscribePusher();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    RealtimeService.instance.unsubscribeRiderChannel(widget.riderId);
    super.dispose();
  }

  /// Listen for the Pusher `trip-accepted-rider` event on `rider-{riderId}`.
  void _subscribePusher() {
    RealtimeService.instance.subscribeRiderChannel(
      widget.riderId,
      (tripId) {
        // Only react if it matches our trip
        if (tripId == widget.initialTrip.id) {
          _handleAccepted();
        }
      },
    );
  }

  /// Fallback: poll the API every 3 seconds in case Pusher is unavailable.
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_accepted) return;
      try {
        final data = await apiService.getTrip(widget.initialTrip.id);
        final status = data['status'] as String? ?? '';
        if (status == 'ACCEPTED' || status == 'IN_PROGRESS') {
          _handleAccepted();
        }
      } catch (_) {}
    });
  }

  /// Close the dialog and notify parent that a driver accepted.
  void _handleAccepted() {
    if (_accepted || !mounted) return;
    _accepted = true;
    _pollTimer?.cancel();
    RealtimeService.instance.unsubscribeRiderChannel(widget.riderId);

    // Re-fetch the trip to get full driver info
    apiService.getTrip(widget.initialTrip.id).then((data) {
      if (!mounted) return;
      final updatedTrip = TripModel.fromJson(data);
      Navigator.of(context).pop(); // close dialog
      widget.onAccepted(updatedTrip);
    }).catchError((_) {
      // Even if fetch fails, still close and pass original trip
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAccepted(widget.initialTrip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB))),
                ),
                const Icon(Icons.search, size: 32, color: Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Finding a Driver',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
            const SizedBox(height: 6),
            const Text('Please wait while we find\nthe nearest driver...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _pollTimer?.cancel();
                RealtimeService.instance
                    .unsubscribeRiderChannel(widget.riderId);
                Navigator.of(context).pop();
                widget.onCancelled();
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }
}
