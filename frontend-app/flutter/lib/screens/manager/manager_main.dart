import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class ManagerMain extends ConsumerStatefulWidget {
  final VoidCallback onLogout;
  const ManagerMain({super.key, required this.onLogout});

  @override
  ConsumerState<ManagerMain> createState() => _ManagerMainState();
}

class _ManagerMainState extends ConsumerState<ManagerMain> {
  List<Map<String, dynamic>> _payments = [];
  bool _loading = false;
  final Set<int> _settling = {};
  String _filter = 'ALL'; // ALL | PENDING | COMPLETED | FAILED
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final all = await apiService.getPayments();
      if (mounted) {
        setState(() => _payments = all.cast<Map<String, dynamic>>());
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _settle(Map<String, dynamic> payment) async {
    final id = payment['id'] as int;
    setState(() => _settling.add(id));
    try {
      final updated = await apiService.confirmPayment(id);
      if (mounted) {
        final idx = _payments.indexWhere((p) => p['id'] == id);
        if (idx >= 0) {
          setState(() => _payments[idx] = updated);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ));
      }
    } finally {
      if (mounted) setState(() => _settling.remove(id));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'ALL') return _payments;
    return _payments.where((p) => p['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _payments.where((p) => p['status'] == 'PENDING').length;
    final completed = _payments.where((p) => p['status'] == 'COMPLETED').length;
    final total = _payments.fold<double>(
        0, (s, p) => s + ((p['amount'] as num?)?.toDouble() ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Manager — Settle',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Color(0xFF374151)),
            ),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary banner ────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Revenue',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFBFDBFE))),
                      const SizedBox(height: 4),
                      Text('\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                _summaryPill('$pending Pending', const Color(0xFFFCA5A5)),
                const SizedBox(width: 8),
                _summaryPill('$completed Paid', const Color(0xFF86EFAC)),
              ],
            ),
          ),

          // ── Filter chips ──────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final f in ['ALL', 'PENDING', 'COMPLETED', 'FAILED'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _filter == f
                              ? Colors.white
                              : const Color(0xFF374151)),
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Payment list ──────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      _loading ? 'Loading…' : 'No payments found.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                        _paymentCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _paymentCard(Map<String, dynamic> p) {
    final id = p['id'] as int;
    final status = p['status'] as String? ?? 'UNKNOWN';
    final amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
    final method = p['method'] as String? ?? '—';
    final trip = p['trip'] as Map?;
    final tripId = trip?['id'];
    final pickup = trip?['pickupAddress'] as String? ?? '—';
    final dropoff = trip?['dropoffAddress'] as String? ?? '—';
    final isSettling = _settling.contains(id);

    final (statusLabel, statusColor) = switch (status) {
      'COMPLETED' => ('Paid', const Color(0xFF10B981)),
      'PENDING'   => ('Pending', const Color(0xFFF59E0B)),
      'FAILED'    => ('Failed', const Color(0xFFDC2626)),
      'REFUNDED'  => ('Refunded', const Color(0xFF6B7280)),
      _           => (status, const Color(0xFF9CA3AF)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'COMPLETED'
              ? const Color(0xFF10B981).withValues(alpha: 0.2)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: trip id + amount + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long,
                    size: 18, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip #$tripId',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827))),
                    Text(method,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Text('\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 10),

          // Route summary
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(pickup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.location_on, size: 8, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(dropoff,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status badge + settle action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
              if (status == 'PENDING')
                isSettling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : ElevatedButton.icon(
                        onPressed: () => _settle(p),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Settle',
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NotificationService.instance.clearSubscriptions();
              ref.read(authProvider.notifier).logout();
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
