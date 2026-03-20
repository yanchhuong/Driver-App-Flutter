import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  // 0=All, 1=Completed, 2=Cancelled, 3=Refunded
  int _activeFilter = 0;
  int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final riderId = ref.read(authProvider).rider?.id;
    if (riderId == null) return;
    await ref.read(riderTripProvider(riderId).notifier).load();
  }

  List<TripModel> _filtered(List<TripModel> trips) {
    switch (_activeFilter) {
      case 1:
        return trips.where((t) => t.status == 'COMPLETED').toList();
      case 2:
        return trips.where((t) => t.status == 'CANCELLED').toList();
      case 3:
        // No REFUNDED status in backend -- show empty for parity
        return [];
      default:
        return trips;
    }
  }

  // "This Week" helpers -- use all trips regardless of filter
  List<TripModel> _thisWeek(List<TripModel> trips) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return trips.where((t) {
      if (t.requestedAt == null) return false;
      try {
        final d = DateTime.parse(t.requestedAt!);
        return d.isAfter(start) || d.isAtSameMomentAs(start);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  double _totalSpent(List<TripModel> trips) => trips
      .where((t) => t.status == 'COMPLETED' && t.fareAmount != null)
      .fold(0.0, (s, t) => s + t.fareAmount!);

  double _totalDistance(List<TripModel> trips) => trips
      .where((t) => t.distanceKm != null)
      .fold(0.0, (s, t) => s + t.distanceKm!);

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tripDay = DateTime(d.year, d.month, d.day);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final amPm = d.hour >= 12 ? 'PM' : 'AM';
      final min = d.minute.toString().padLeft(2, '0');
      final time = '$hour:$min $amPm';

      if (tripDay == today) {
        return 'Today, $time';
      } else if (tripDay == yesterday) {
        return 'Yesterday, $time';
      }
      return '${months[d.month - 1]} ${d.day}, $time';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rider = ref.watch(authProvider).rider;
    if (rider == null) return const SizedBox();

    final tripState = ref.watch(riderTripProvider(rider.id));
    final allTrips = tripState.trips;
    final weekTrips = _thisWeek(allTrips);
    final filtered = _filtered(allTrips);
    final visible = filtered.take(_visibleCount).toList();

    final completedCount =
        allTrips.where((t) => t.status == 'COMPLETED').length;
    final cancelledCount =
        allTrips.where((t) => t.status == 'CANCELLED').length;

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF2563EB),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- This Week Gradient Card --
                _buildWeekCard(weekTrips),
                const SizedBox(height: 20),
                // -- Filter Chips --
                _buildFilterChips(
                    allTrips.length, completedCount, cancelledCount),
                // -- Section Title --
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Recent Trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -- Trip List --
          if (tripState.loading)
            const SliverFillRemaining(
              child: Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF2563EB))),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _buildTripCard(ctx, visible[i]),
                ),
                childCount: visible.length,
              ),
            ),
            // -- Load More --
            if (_visibleCount < filtered.length)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _visibleCount += 5),
                    child: const Text(
                      'Load More Trips',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // This Week Gradient Card
  // ================================================================

  Widget _buildWeekCard(List<TripModel> weekTrips) {
    final totalTrips = weekTrips.length;
    final totalSpent = _totalSpent(weekTrips);
    final totalDist = _totalDistance(weekTrips);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalTrips',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Trips',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totalDist.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // Filter Chips
  // ================================================================

  Widget _buildFilterChips(int total, int completed, int cancelled) {
    final chips = <_FilterChipData>[
      _FilterChipData(
        label: 'All Trips',
        count: total,
        index: 0,
        activeColor: const Color(0xFF2563EB),
        icon: null,
      ),
      _FilterChipData(
        label: 'Completed',
        count: completed,
        index: 1,
        activeColor: const Color(0xFF16A34A),
        icon: Icons.check_circle,
      ),
      _FilterChipData(
        label: 'Cancelled',
        count: cancelled,
        index: 2,
        activeColor: const Color(0xFFDC2626),
        icon: Icons.cancel,
      ),
      const _FilterChipData(
        label: 'Refunded',
        count: 0,
        index: 3,
        activeColor: Color(0xFF2563EB),
        icon: Icons.refresh,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final chip = chips[i];
          final active = _activeFilter == chip.index;
          return GestureDetector(
            onTap: () => setState(() {
              _activeFilter = chip.index;
              _visibleCount = 5;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? chip.activeColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chip.icon != null) ...[
                    Icon(
                      chip.icon,
                      size: 14,
                      color: active
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    chip.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${chip.count})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active
                          ? Colors.white.withValues(alpha: 0.75)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================================================
  // Trip Card
  // ================================================================

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final isDelivery = trip.isDelivery;
    final statusBadge = _getStatusBadgeData(trip.status);

    return GestureDetector(
      onTap: () => _showTripDetails(context, trip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header: date, type badge, status badge, fare, chevron --
            Row(
              children: [
                // Left side: date + badges
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(trip.requestedAt),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      // Type badge
                      _typeBadge(isDelivery),
                      // Status badge
                      _statusChip(statusBadge),
                    ],
                  ),
                ),
                // Fare + chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trip.fareAmount != null)
                      Text(
                        '\$${trip.fareAmount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        size: 16, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // -- Route --
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 2,
                      height: 16,
                      color: const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFFDC2626)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.pickupAddress ?? 'Pickup location',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        trip.dropoffAddress ?? 'Dropoff location',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // -- Footer: driver info + distance/duration --
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F4F6)),
                ),
              ),
              child: Row(
                children: [
                  // Driver avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        trip.driverId != null ? 'D' : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverId != null
                              ? 'Driver #${trip.driverId}'
                              : 'No driver assigned',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 12, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 2),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Distance + duration
                  Text(
                    _distanceDurationText(trip),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceDurationText(TripModel trip) {
    final parts = <String>[];
    if (trip.distanceKm != null) {
      parts.add('${trip.distanceKm!.toStringAsFixed(1)} km');
    }
    if (trip.distanceKm != null) {
      parts.add('~${(trip.distanceKm! * 3).round()} min');
    }
    return parts.join(' \u2022 ');
  }

  Widget _typeBadge(bool isDelivery) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDelivery
            ? const Color(0xFFF3E8FF)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDelivery ? 'Delivery' : 'Ride',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDelivery
              ? const Color(0xFF7C3AED)
              : const Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _statusChip(_StatusBadgeData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 12, color: data.fgColor),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: data.fgColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusBadgeData _getStatusBadgeData(String status) {
    switch (status) {
      case 'COMPLETED':
        return const _StatusBadgeData(
          icon: Icons.check_circle,
          bgColor: Color(0xFFDCFCE7),
          fgColor: Color(0xFF15803D),
          label: 'Completed',
        );
      case 'CANCELLED':
        return const _StatusBadgeData(
          icon: Icons.cancel,
          bgColor: Color(0xFFFEE2E2),
          fgColor: Color(0xFFDC2626),
          label: 'Cancelled',
        );
      case 'IN_PROGRESS':
        return const _StatusBadgeData(
          icon: Icons.pending,
          bgColor: Color(0xFFFEF3C7),
          fgColor: Color(0xFFF59E0B),
          label: 'In Progress',
        );
      case 'ACCEPTED':
        return const _StatusBadgeData(
          icon: Icons.info,
          bgColor: Color(0xFFE0E7FF),
          fgColor: Color(0xFF6366F1),
          label: 'Accepted',
        );
      default:
        return _StatusBadgeData(
          icon: Icons.error_outline,
          bgColor: const Color(0xFFF3F4F6),
          fgColor: const Color(0xFF6B7280),
          label: status,
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 72, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No trips found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Book your first ride to see your history here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ================================================================
  // Trip Detail Bottom Sheet
  // ================================================================

  void _showTripDetails(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TripDetailSheet(trip: trip),
    );
  }
}

// ================================================================
// Helper data classes
// ================================================================

class _FilterChipData {
  final String label;
  final int count;
  final int index;
  final Color activeColor;
  final IconData? icon;

  const _FilterChipData({
    required this.label,
    required this.count,
    required this.index,
    required this.activeColor,
    this.icon,
  });
}

class _StatusBadgeData {
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final String label;

  const _StatusBadgeData({
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.label,
  });
}

// =================================================================
// Trip Detail Sheet (loads driver info asynchronously)
// =================================================================

class _TripDetailSheet extends StatefulWidget {
  final TripModel trip;
  const _TripDetailSheet({required this.trip});

  @override
  State<_TripDetailSheet> createState() => _TripDetailSheetState();
}

class _TripDetailSheetState extends State<_TripDetailSheet> {
  Map<String, dynamic>? _driver;
  bool _loadingDriver = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip.driverId != null) {
      _loadDriver(widget.trip.driverId!);
    }
  }

  Future<void> _loadDriver(int driverId) async {
    setState(() => _loadingDriver = true);
    try {
      final d = await apiService.getDriver(driverId);
      if (mounted) setState(() => _driver = d);
    } catch (_) {
      // silently ignore -- UI will show fallback
    } finally {
      if (mounted) setState(() => _loadingDriver = false);
    }
  }

  String _formatFullDateTime(String? raw) {
    if (raw == null) return 'N/A';
    try {
      final d = DateTime.parse(raw);
      final months = [
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

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final isDelivery = trip.isDelivery;

    // Payment breakdown
    final fare = trip.fareAmount ?? 0.0;
    final serviceFee = fare * 0.05;
    final tax = fare * 0.03;
    const tip = 0.0; // No tip field in backend model
    final total = fare + serviceFee + tax + tip;

    final driverName =
        _driver?['name'] as String? ?? 'Driver #${trip.driverId ?? '-'}';
    final driverPhone = _driver?['phone'] as String? ?? '-';
    final vehicleType = _driver?['vehicleType'] as String? ?? '-';
    final vehiclePlate = _driver?['vehiclePlate'] as String? ?? '-';
    final driverRating = (_driver?['rating'] as num?)?.toDouble();
    final driverInitial =
        driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D';

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // -- Sticky header --
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close,
                          size: 20, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),

            // -- Scrollable body --
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // == Type Badge (centered) ==
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDelivery
                            ? const Color(0xFFF3E8FF)
                            : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDelivery
                            ? 'Delivery${trip.deliveryType != null ? ' \u00B7 ${trip.deliveryType}' : ''}'
                            : 'Ride',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDelivery
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // == Trip ID Card ==
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Trip ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isDelivery ? "DELIVERY" : "TRIP"}-${trip.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // == Driver Information ==
                  if (trip.driverId != null) ...[
                    _sectionCard(
                      title: 'Driver Information',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _loadingDriver
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          driverInitial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 12,
                                            color: Color(0xFFFBBF24)),
                                        const SizedBox(width: 2),
                                        Text(
                                          driverRating != null
                                              ? driverRating
                                                  .toStringAsFixed(1)
                                              : '4.8',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          _detailRow('Phone', driverPhone),
                          const SizedBox(height: 8),
                          _detailRow('Vehicle', vehicleType),
                          const SizedBox(height: 8),
                          _detailRow('Plate', vehiclePlate),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // == Trip Route ==
                  _sectionCard(
                    title: 'Trip Route',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 32,
                              color: const Color(0xFFD1D5DB),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pickup',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                trip.pickupAddress ?? 'Pickup location',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Drop-off',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                trip.dropoffAddress ?? 'Dropoff location',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // == Trip Statistics ==
                  _borderedCard(
                    title: 'Trip Statistics',
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trip.distanceKm != null
                                    ? '${trip.distanceKm!.toStringAsFixed(1)} km'
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trip.distanceKm != null
                                    ? '~${(trip.distanceKm! * 3).round()} min'
                                    : '-',
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
                  ),
                  const SizedBox(height: 12),

                  // == Payment Breakdown ==
                  _borderedCard(
                    title: 'Payment Breakdown',
                    child: Column(
                      children: [
                        _payRow('Base Fare',
                            '\$${fare.toStringAsFixed(2)}', false),
                        const SizedBox(height: 10),
                        _payRow('Service Fee',
                            '\$${serviceFee.toStringAsFixed(2)}', false),
                        const SizedBox(height: 10),
                        _payRow(
                            'Tax', '\$${tax.toStringAsFixed(2)}', false),
                        if (tip > 0) ...[
                          const SizedBox(height: 10),
                          _payRow(
                              'Tip', '\$${tip.toStringAsFixed(2)}', true),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE5E7EB)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Fare',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // == Payment Method ==
                  _borderedCard(
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money,
                                size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 8),
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cash',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // == Date & Time ==
                  _borderedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 8),
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatFullDateTime(trip.requestedAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // == Status & Reason (Cancelled) ==
                  if (trip.status == 'CANCELLED')
                    _borderedCard(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel,
                                  size: 16, color: Color(0xFFDC2626)),
                              SizedBox(width: 8),
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cancelled',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Reason: This trip was cancelled.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
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

  // -- Section card with gray background (matches React bg-gray-50) --
  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  // -- Bordered card with white background (matches React border + white bg) --
  Widget _borderedCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _payRow(String label, String value, bool isGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGreen
                ? const Color(0xFF16A34A)
                : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
