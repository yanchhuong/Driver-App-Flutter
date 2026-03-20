import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SettlePage extends ConsumerStatefulWidget {
  const SettlePage({super.key});

  @override
  ConsumerState<SettlePage> createState() => _SettlePageState();
}

class _SettlePageState extends ConsumerState<SettlePage> {
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final riderId = ref.read(authProvider).rider?.id;
      final raw = riderId != null
          ? await apiService.getRiderPayments(riderId)
          : await apiService.getPayments();
      if (mounted) {
        setState(() {
          _payments = raw.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // Overview calculations
  double get _totalAll =>
      _payments.fold(0.0, (s, p) => s + _amount(p));

  double get _totalReceived => _payments
      .where((p) => _status(p) == 'COMPLETED')
      .fold(0.0, (s, p) => s + _amount(p));

  double get _totalFee =>
      _payments.fold(0.0, (s, p) => s + _fee(p));

  static double _amount(Map<String, dynamic> p) =>
      (p['amount'] as num?)?.toDouble() ?? 0.0;

  static double _fee(Map<String, dynamic> p) =>
      _amount(p) * 0.05;

  static String _status(Map<String, dynamic> p) =>
      (p['status'] as String?) ?? 'PENDING';

  static String _paymentId(Map<String, dynamic> p) =>
      (p['id'] ?? '—').toString();

  static String _createdAt(Map<String, dynamic> p) {
    final raw = p['createdAt'] as String?;
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  int _ridesCount(Map<String, dynamic> p) {
    // Each payment record covers 1 trip/ride in the backend model
    return 1;
  }

  Map<String, dynamic>? _trip(Map<String, dynamic> p) {
    final t = p['trip'];
    return t is Map ? t.cast<String, dynamic>() : null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF2563EB),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Card
                _buildOverviewCard(),
                const SizedBox(height: 20),

                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Settle Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      // Export button (text style matching React)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download_outlined,
                                size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text('Export',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Payments list
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_payments.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildTransactionCard(ctx, _payments[i]),
                ),
                childCount: _payments.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Overview card (matches React: white card, 3-col centered stats) ──

  Widget _buildOverviewCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + title
          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3-stat grid (centered text, matching React layout)
          Row(
            children: [
              Expanded(
                child: _overviewStat(
                  'Total All',
                  '\$${_totalAll.toStringAsFixed(2)}',
                  const Color(0xFF111827),
                ),
              ),
              Expanded(
                child: _overviewStat(
                  'Total Received',
                  '\$${_totalReceived.toStringAsFixed(2)}',
                  const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _overviewStat(
                  'Total Fee (-)',
                  '-\$${_totalFee.toStringAsFixed(2)}',
                  const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // ── Transaction card (matches React card layout) ──

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> payment) {
    final status = _status(payment);
    final amount = _amount(payment);
    final rides = _ridesCount(payment);

    return GestureDetector(
      onTap: () => _showDetailSheet(context, payment),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt icon in gray background (matches React bg-gray-50)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_outlined,
                  size: 20, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 12),
            // Description + date + rides count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settlement Batch #${_paymentId(payment)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _createdAt(payment),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$rides ${rides == 1 ? 'Ride' : 'Rides'} included',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
            // Amount + status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                _statusBadge(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (label, bg, fg) = switch (status) {
      'COMPLETED' => (
          'Settled',
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D)
        ),
      'FAILED' => (
          'Failed',
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626)
        ),
      _ => (
          'Progress',
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }

  // ── Detail bottom sheet ──

  void _showDetailSheet(BuildContext context, Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        payment: payment,
        ridesCount: _ridesCount(payment),
      ),
    );
  }

  // ── Empty / Error states ──

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No settlements yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Completed trips will appear here',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 56, color: Color(0xFFDC2626)),
          const SizedBox(height: 12),
          const Text('Failed to load payments',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
          const SizedBox(height: 8),
          Text(_error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Sheet (matches React transaction detail modal) ───────────────────

class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> payment;
  final int ridesCount;

  const _DetailSheet({required this.payment, required this.ridesCount});

  double get _amount =>
      (payment['amount'] as num?)?.toDouble() ?? 0.0;

  String get _status => (payment['status'] as String?) ?? 'PENDING';

  String get _payId => (payment['id'] ?? '—').toString();

  String _fullDateTime() {
    final raw = payment['createdAt'] as String?;
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final amPm = d.hour >= 12 ? 'PM' : 'AM';
      final min = d.minute.toString().padLeft(2, '0');
      return '${months[d.month - 1]} ${d.day}, ${d.year} $hour:$min $amPm';
    } catch (_) {
      return raw;
    }
  }

  Map<String, dynamic>? get _trip {
    final t = payment['trip'];
    return t is Map ? t.cast<String, dynamic>() : null;
  }

  String get _detailsText {
    if (_status == 'COMPLETED') {
      return 'COD payment completed successfully';
    }
    return 'COD payment pending confirmation';
  }

  @override
  Widget build(BuildContext context) {
    final fee = _amount * 0.05;
    final trip = _trip;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Sticky header (matches React: "Transaction Details" + X button)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  const Text('Transaction Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827))),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.close,
                            size: 20, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(16),
                children: [
                  // Status badge centered (matches React)
                  Center(child: _statusBadgeLarge(_status)),
                  const SizedBox(height: 16),

                  // Transaction ID card (blue-50 background, matches React)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Transaction ID',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2563EB))),
                        const SizedBox(height: 4),
                        Text(_payId,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8))),
                        const SizedBox(height: 8),
                        Text(
                          '$ridesCount ${ridesCount == 1 ? 'Ride' : 'Rides'} included',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rides in This Settlement (matches React section)
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rides in This Settlement',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 12),
                        // Ride card (matches React bg-gray-50 rounded-lg)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ride ID + COD amount row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'DELIVERY-${trip?['id'] ?? _payId}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB)),
                                  ),
                                  Text(
                                    '\$${_amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Description
                              Text(
                                trip?['tripType'] == 'DELIVERY'
                                    ? 'Package Delivery'
                                    : 'Ride Trip',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 8),
                              // Pickup indicator
                              if (trip?['pickupAddress'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF22C55E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trip!['pickupAddress'] as String,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF374151)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Dropoff indicator
                              if (trip?['dropoffAddress'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Icon(Icons.location_on,
                                            size: 8,
                                            color: const Color(0xFFDC2626)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trip!['dropoffAddress'] as String,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF374151)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Service fee row (with divider, matching React)
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: Color(0xFFE5E7EB), width: 1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Service Fee',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      '\$${fee.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF111827)),
                                    ),
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

                  // Total Payment Breakdown (matches React section)
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Payment Breakdown',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 12),
                        // Receive Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Receive Amount',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280))),
                            Text(
                              '\$${_amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Total Fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Fee (-)',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280))),
                            Text(
                              '-\$${fee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                              color: Color(0xFFE5E7EB), height: 1),
                        ),
                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827))),
                            Text(
                              '\$${_amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settlement Date & Time (matches React layout)
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            const Text('Settlement Date & Time',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fullDateTime(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details (matches React "Details" section)
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Details',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 8),
                        Text(
                          _detailsText,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadgeLarge(String status) {
    final (label, bg, fg) = switch (status) {
      'COMPLETED' => (
          'Settled',
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D)
        ),
      'FAILED' => (
          'Failed',
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626)
        ),
      _ => (
          'Progress',
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}
