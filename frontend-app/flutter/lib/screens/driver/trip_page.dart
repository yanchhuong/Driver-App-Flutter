import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_chat_widget.dart';
import 'active_trip_page.dart';

// ---------------------------------------------------------------------------
// Filter enum & provider
// ---------------------------------------------------------------------------

enum TripFilter { all, completed, inProgress, scheduled, cancelled }

final tripFilterProvider = StateProvider<TripFilter>((ref) => TripFilter.all);

// ---------------------------------------------------------------------------
// TripPage
// ---------------------------------------------------------------------------

class TripPage extends ConsumerStatefulWidget {
  const TripPage({super.key});

  @override
  ConsumerState<TripPage> createState() => _TripPageState();
}

class _TripPageState extends ConsumerState<TripPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final driverId = ref.read(authProvider).driver?.id;
    if (driverId == null) return;
    await ref.read(driverTripProvider(driverId).notifier).loadMyTrips();
  }

  List<TripModel> _filter(List<TripModel> trips, TripFilter f) {
    if (f == TripFilter.all) return trips;
    return trips.where((t) {
      switch (f) {
        case TripFilter.completed:
          return t.status == 'COMPLETED';
        case TripFilter.inProgress:
          return t.status == 'ACCEPTED' || t.status == 'IN_PROGRESS';
        case TripFilter.scheduled:
          return t.status == 'REQUESTED';
        case TripFilter.cancelled:
          return t.status == 'CANCELLED';
        default:
          return true;
      }
    }).toList();
  }

  // ── Status helpers ──────────────────────────────────────────

  Color _statusBg(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFFDCFCE7);
      case 'CANCELLED':
        return const Color(0xFFFEE2E2);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFFDBEAFE);
      case 'REQUESTED':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFF2563EB);
      case 'REQUESTED':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBorder(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFFBBF7D0);
      case 'CANCELLED':
        return const Color(0xFFFECACA);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFFBFDBFE);
      case 'REQUESTED':
        return const Color(0xFFFED7AA);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Complete';
      case 'CANCELLED':
        return 'Cancel';
      case 'IN_PROGRESS':
        return 'Progress';
      case 'ACCEPTED':
        return 'Progress';
      case 'REQUESTED':
        return 'Schedule';
      default:
        return status;
    }
  }

  String _rideTypeEmoji(TripModel trip) {
    if (trip.isDelivery) {
      if (trip.deliveryType == 'EXPRESS') return '⚡';
      return '📦';
    }
    return '🚗';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tripDay = DateTime(dt.year, dt.month, dt.day);

      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final time = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';

      if (tripDay == today) return 'Today, $time';
      if (tripDay == yesterday) return 'Yesterday, $time';

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, $time';
    } catch (_) {
      return dateStr.length > 16 ? dateStr.substring(0, 16) : dateStr;
    }
  }

  // ── Actions ─────────────────────────────────────────────────

  void _showTripDetails(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TripDetailsModal(
        trip: trip,
        driver: ref.read(authProvider).driver!,
        onStatusUpdated: () => _load(),
      ),
    );
  }

  void _handleRideAgain(TripModel trip) {
    // Logic to create a new ride with same pickup/dropoff
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride again from ${trip.pickupAddress ?? "pickup"}'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  // ── Filter chip color helpers (matching React active colors) ─

  Color _filterActiveColor(TripFilter f) {
    switch (f) {
      case TripFilter.all:
        return const Color(0xFF2563EB);
      case TripFilter.completed:
        return const Color(0xFF16A34A);
      case TripFilter.inProgress:
        return const Color(0xFF2563EB);
      case TripFilter.scheduled:
        return const Color(0xFFEA580C);
      case TripFilter.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;
    if (driver == null) return const SizedBox();

    final tripState = ref.watch(driverTripProvider(driver.id));
    final filter = ref.watch(tripFilterProvider);
    final filtered = _filter(tripState.trips, filter);

    // Find active trip (ACCEPTED or IN_PROGRESS)
    final activeTrip = tripState.trips
        .where((t) => t.status == 'ACCEPTED' || t.status == 'IN_PROGRESS')
        .fold<TripModel?>(null, (prev, t) => prev ?? t);

    return Column(
      children: [
        // Resume active trip banner
        if (activeTrip != null)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActiveTripPage(
                  initialTrip: activeTrip,
                  driverId: driver.id,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.navigation, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Active trip — tap to resume',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trip History',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_list,
                    size: 20, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ),

        // Status filter tabs
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All', TripFilter.all, filter),
              const SizedBox(width: 8),
              _buildFilterChip('Complete', TripFilter.completed, filter),
              const SizedBox(width: 8),
              _buildFilterChip('In Progress', TripFilter.inProgress, filter),
              const SizedBox(width: 8),
              _buildFilterChip('Scheduled', TripFilter.scheduled, filter),
              const SizedBox(width: 8),
              _buildFilterChip('Cancelled', TripFilter.cancelled, filter),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Trip list
        Expanded(
          child: tripState.loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length + 1, // +1 for load-more
                        itemBuilder: (ctx, i) {
                          if (i < filtered.length) {
                            return _buildTripCard(ctx, filtered[i]);
                          }
                          // Load More button
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: TextButton(
                                onPressed: _load,
                                child: const Text(
                                  'Load More Trips',
                                  style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ── Filter chip ─────────────────────────────────────────────

  Widget _buildFilterChip(
      String label, TripFilter filter, TripFilter active) {
    final isActive = filter == active;
    final activeColor = _filterActiveColor(filter);
    return GestureDetector(
      onTap: () => ref.read(tripFilterProvider.notifier).state = filter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF374151),
            )),
      ),
    );
  }

  // ── Trip card (matches React card layout) ───────────────────

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final dateStr = _formatDate(trip.requestedAt);
    final riderLabel = 'Rider #${trip.riderId}';
    final initial = riderLabel.isNotEmpty ? riderLabel[0] : 'R';
    final isComplete = trip.status == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: avatar + name, cost + status ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                // Name + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(riderLabel,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827)),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Text(_rideTypeEmoji(trip),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(dateStr,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ),
                ),
                // Cost + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.fareAmount != null
                          ? '\$${trip.fareAmount!.toStringAsFixed(2)}'
                          : '\$0.00',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusBg(trip.status),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusBorder(trip.status)),
                      ),
                      child: Text(_statusLabel(trip.status),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusFg(trip.status))),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Note ──
            if (trip.packageDescription != null &&
                trip.packageDescription!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description,
                        size: 14, color: Color(0xFFCA8A04)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(trip.packageDescription!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF854D0E))),
                    ),
                  ],
                ),
              ),

            // ── Route ──
            // Pickup
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                      color: Color(0xFF2563EB), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pickup',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                      Text(trip.pickupAddress ?? 'Pickup location',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Dropoff
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    size: 8, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dropoff',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                      Text(trip.dropoffAddress ?? 'Dropoff location',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827))),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Rating (completed trips) ──
            if (isComplete) ...[
              Row(
                children: [
                  const Text('Rider Rating:',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(width: 4),
                  ...List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      size: 14,
                      color: i < 5
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD1D5DB),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Action buttons ──
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
              ),
              child: Row(
                children: [
                  if (isComplete)
                    Expanded(
                      child: _cardButton(
                        label: 'Ride Again',
                        icon: Icons.refresh,
                        color: Colors.white,
                        bg: const Color(0xFF2563EB),
                        onTap: () => _handleRideAgain(trip),
                      ),
                    ),
                  if (isComplete) const SizedBox(width: 8),
                  Expanded(
                    child: _cardButton(
                      label: 'View Details',
                      icon: Icons.chevron_right,
                      color: const Color(0xFF374151),
                      bg: const Color(0xFFF3F4F6),
                      onTap: () => _showTripDetails(trip),
                      iconRight: true,
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

  Widget _cardButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
    bool iconRight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!iconRight) Icon(icon, size: 16, color: color),
            if (!iconRight) const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            if (iconRight) const SizedBox(width: 6),
            if (iconRight) Icon(icon, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description,
                  size: 32, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 12),
            const Text('No trips found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
            const SizedBox(height: 4),
            const Text('No trips match the selected filter',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Trip Details Modal (bottom sheet, matches React modal)
// ===========================================================================

class _TripDetailsModal extends StatefulWidget {
  final TripModel trip;
  final dynamic driver; // DriverModel
  final VoidCallback onStatusUpdated;

  const _TripDetailsModal({
    required this.trip,
    required this.driver,
    required this.onStatusUpdated,
  });

  @override
  State<_TripDetailsModal> createState() => _TripDetailsModalState();
}

class _TripDetailsModalState extends State<_TripDetailsModal> {
  late TripModel _trip;
  bool _showChat = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'COMPLETED':
        return 'Complete';
      case 'CANCELLED':
        return 'Cancel';
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return 'Progress';
      case 'REQUESTED':
        return 'Schedule';
      default:
        return s;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'COMPLETED':
        return const Color(0xFFDCFCE7);
      case 'CANCELLED':
        return const Color(0xFFFEE2E2);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFFDBEAFE);
      case 'REQUESTED':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusFg(String s) {
    switch (s) {
      case 'COMPLETED':
        return const Color(0xFF16A34A);
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFF2563EB);
      case 'REQUESTED':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBorder(String s) {
    switch (s) {
      case 'COMPLETED':
        return const Color(0xFFBBF7D0);
      case 'CANCELLED':
        return const Color(0xFFFECACA);
      case 'IN_PROGRESS':
      case 'ACCEPTED':
        return const Color(0xFFBFDBFE);
      case 'REQUESTED':
        return const Color(0xFFFED7AA);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _rideTypeEmoji(TripModel t) {
    if (t.isDelivery) {
      if (t.deliveryType == 'EXPRESS') return '⚡';
      return '📦';
    }
    return '🚗';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tripDay = DateTime(dt.year, dt.month, dt.day);

      final hour =
          dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final time = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';

      if (tripDay == today) return 'Today, $time';
      if (tripDay == yesterday) return 'Yesterday, $time';

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, $time';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'R';
  }

  // ── Actions ─────────────────────────────────────────────────

  Future<void> _callRider() async {
    final phone = _trip.recipientPhone;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _openChat() {
    setState(() => _showChat = true);
  }

  void _closeChatModal() {
    setState(() => _showChat = false);
  }

  Future<void> _handleUpdateAction(String action) async {
    final actionLabel = {
      'complete': 'complete',
      'cancel': 'cancel',
      'start': 'start',
      'reschedule': 'reschedule',
    }[action] ?? action;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmActionDialog(action: actionLabel),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);

    try {
      Map<String, dynamic> data;
      switch (action) {
        case 'complete':
          data = await apiService.completeTrip(_trip.id, _trip.distanceKm ?? 0, _trip.fareAmount ?? 0);
          break;
        case 'cancel':
          data = await apiService.cancelTrip(_trip.id);
          break;
        case 'start':
          data = await apiService.startTrip(_trip.id);
          break;
        default:
          return;
      }
      if (mounted) {
        setState(() {
          _trip = TripModel.fromJson(data);
          _loading = false;
        });
        widget.onStatusUpdated();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$e'),
              backgroundColor: const Color(0xFFDC2626)),
        );
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showChat) {
      return _buildChatSheet();
    }
    return _buildDetailsSheet();
  }

  // ── Details sheet ───────────────────────────────────────────

  Widget _buildDetailsSheet() {
    final riderLabel = _trip.recipientName ?? 'Rider #${_trip.riderId}';
    final initials = _initials(riderLabel);
    final dateStr = _formatDate(_trip.requestedAt);
    final isComplete = _trip.status == 'COMPLETED';
    final isCancelled = _trip.status == 'CANCELLED';
    final isProgress =
        _trip.status == 'IN_PROGRESS' || _trip.status == 'ACCEPTED';
    final isScheduled = _trip.status == 'REQUESTED';
    final hasPhone =
        _trip.recipientPhone != null && _trip.recipientPhone!.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Gradient header ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trip Details',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Trip ID: ${_trip.id}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFFBFDBFE))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Rider info card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF2563EB)
                                  ],
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
                            const SizedBox(width: 16),
                            // Name + date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(riderLabel,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827)),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(_rideTypeEmoji(_trip),
                                          style:
                                              const TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 14, color: Color(0xFF6B7280)),
                                      const SizedBox(width: 4),
                                      Text(dateStr,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Cost + status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _trip.fareAmount != null
                                      ? '\$${_trip.fareAmount!.toStringAsFixed(2)}'
                                      : '\$0.00',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A)),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusBg(_trip.status),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: _statusBorder(_trip.status),
                                        width: 2),
                                  ),
                                  child: Text(_statusLabel(_trip.status),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _statusFg(_trip.status))),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Contact actions
                        if (!isCancelled && hasPhone) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    label: 'Call Rider',
                                    icon: Icons.phone,
                                    bg: const Color(0xFF2563EB),
                                    onTap: _callRider,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _actionButton(
                                    label: 'Message',
                                    icon: Icons.chat_bubble,
                                    bg: const Color(0xFF16A34A),
                                    onTap: _openChat,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Rider note ──
                  if (_trip.packageDescription != null &&
                      _trip.packageDescription!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEFCE8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFDE68A), width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description,
                              size: 20, color: Color(0xFFCA8A04)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rider Note',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF713F12))),
                                const SizedBox(height: 4),
                                Text(_trip.packageDescription!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF854D0E))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Trip route ──
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE5E7EB), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.navigation,
                                size: 20, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Text('Trip Route',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Pickup
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBEAFE),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PICKUP LOCATION',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9CA3AF),
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text(
                                        _trip.pickupAddress ??
                                            'Pickup location',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827))),
                                    if (_trip.startedAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                            _formatTime(_trip.startedAt),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF9CA3AF))),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Dotted line
                        Padding(
                          padding: const EdgeInsets.only(left: 19),
                          child: CustomPaint(
                            size: const Size(2, 24),
                            painter: _DashedLinePainter(),
                          ),
                        ),

                        // Dropoff
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.location_on,
                                    size: 20, color: Color(0xFFDC2626)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('DROPOFF LOCATION',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9CA3AF),
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text(
                                        _trip.dropoffAddress ??
                                            'Dropoff location',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827))),
                                    if (_trip.completedAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                            _formatTime(_trip.completedAt),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF9CA3AF))),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Trip stats (distance / duration)
                        if (_trip.distanceKm != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: Row(
                              children: [
                                if (_trip.distanceKm != null)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.navigation,
                                                  size: 14,
                                                  color: Color(0xFF6B7280)),
                                              SizedBox(width: 6),
                                              Text('DISTANCE',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Color(0xFF6B7280))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${_trip.distanceKm!.toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF111827))),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_trip.distanceKm != null &&
                                    _trip.startedAt != null &&
                                    _trip.completedAt != null)
                                  const SizedBox(width: 12),
                                if (_trip.startedAt != null &&
                                    _trip.completedAt != null)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.access_time,
                                                  size: 14,
                                                  color: Color(0xFF6B7280)),
                                              SizedBox(width: 6),
                                              Text('DURATION',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Color(0xFF6B7280))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Builder(builder: (_) {
                                            try {
                                              final start = DateTime.parse(
                                                  _trip.startedAt!);
                                              final end = DateTime.parse(
                                                  _trip.completedAt!);
                                              final mins = end
                                                  .difference(start)
                                                  .inMinutes;
                                              return Text('$mins mins',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF111827)));
                                            } catch (_) {
                                              return const Text('--',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF111827)));
                                            }
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Fare breakdown ──
                  if (_trip.fareAmount != null && _trip.fareAmount! > 0)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 20, color: Color(0xFF16A34A)),
                              SizedBox(width: 8),
                              Text('Fare Breakdown',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _fareRow('Base Fare',
                              '\$${(_trip.fareAmount! * 0.55).toStringAsFixed(2)}'),
                          _fareDivider(),
                          _fareRow('Distance Charge',
                              '\$${(_trip.fareAmount! * 0.27).toStringAsFixed(2)}'),
                          _fareDivider(),
                          _fareRow('Time Charge',
                              '\$${(_trip.fareAmount! * 0.18).toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Color(0xFFD1D5DB), width: 2)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Earned',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827))),
                                Text(
                                    '\$${_trip.fareAmount!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Payment method ──
                  if (isComplete)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.credit_card,
                                  size: 20, color: Color(0xFF7C3AED)),
                              SizedBox(width: 8),
                              Text('Payment Method',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Credit Card',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7C3AED))),
                          ),
                        ],
                      ),
                    ),

                  // ── Rider rating ──
                  if (isComplete)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEFCE8), Color(0xFFFFF7ED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFDE68A), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.star,
                                  size: 20, color: Color(0xFFEAB308)),
                              SizedBox(width: 8),
                              Text("Rider's Rating",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.star,
                                    size: 28,
                                    color: i < 5
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD1D5DB),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              const Text('5.0',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827))),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Footer actions ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border:
                  Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: _buildFooterActions(
                isComplete, isCancelled, isProgress, isScheduled),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(
      bool isComplete, bool isCancelled, bool isProgress, bool isScheduled) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isProgress) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _footerButton(
                  label: 'Complete Trip',
                  icon: Icons.check,
                  bg: const Color(0xFF16A34A),
                  onTap: () => _handleUpdateAction('complete'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _footerButton(
                  label: 'Cancel Trip',
                  icon: Icons.close,
                  bg: const Color(0xFFDC2626),
                  onTap: () => _handleUpdateAction('cancel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _footerButton(
              label: 'Close',
              bg: Colors.white,
              fg: const Color(0xFF374151),
              border: const Color(0xFFD1D5DB),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    if (isScheduled) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _footerButton(
                  label: 'Start Trip',
                  icon: Icons.navigation,
                  bg: const Color(0xFF2563EB),
                  onTap: () => _handleUpdateAction('start'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _footerButton(
                  label: 'Cancel Trip',
                  icon: Icons.close,
                  bg: const Color(0xFFDC2626),
                  onTap: () => _handleUpdateAction('cancel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _footerButton(
              label: 'Close',
              bg: Colors.white,
              fg: const Color(0xFF374151),
              border: const Color(0xFFD1D5DB),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    if (isComplete) {
      return Row(
        children: [
          Expanded(
            child: _footerButton(
              label: 'Suggest Again',
              icon: Icons.refresh,
              bg: const Color(0xFF2563EB),
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _footerButton(
              label: 'Close',
              bg: Colors.white,
              fg: const Color(0xFF374151),
              border: const Color(0xFFD1D5DB),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    // Cancelled
    return SizedBox(
      width: double.infinity,
      child: _footerButton(
        label: 'Close',
        bg: Colors.white,
        fg: const Color(0xFF374151),
        border: const Color(0xFFD1D5DB),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _footerButton({
    required String label,
    IconData? icon,
    required Color bg,
    Color fg = Colors.white,
    Color? border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border != null
              ? Border.all(color: border, width: 2)
              : null,
          boxShadow: border == null
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 20, color: fg),
            if (icon != null) const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _fareRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _fareDivider() {
    return const Divider(height: 1, color: Color(0xFFF3F4F6));
  }

  // ── Chat sheet ──────────────────────────────────────────────

  Widget _buildChatSheet() {
    final riderLabel = _trip.recipientName ?? 'Rider #${_trip.riderId}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat with $riderLabel',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Trip ID: ${_trip.id}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFFBFDBFE))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _closeChatModal,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Chat widget
          Expanded(
            child: TripChatWidget(
              tripId: _trip.id,
              mySenderId: widget.driver.id as int,
              mySenderName: (widget.driver.name as String?) ?? 'Driver',
              mySenderRole: 'DRIVER',
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Confirm action dialog (matches React update modal)
// ===========================================================================

class _ConfirmActionDialog extends StatelessWidget {
  final String action;

  const _ConfirmActionDialog({required this.action});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Confirm Action',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF374151)),
                    children: [
                      const TextSpan(text: 'Are you sure you want to '),
                      TextSpan(
                          text: action,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' this trip?'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('Confirm',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
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
    );
  }
}

// ===========================================================================
// Dashed line painter (for route visualization)
// ===========================================================================

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
