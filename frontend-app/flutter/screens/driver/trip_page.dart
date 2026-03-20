import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

enum TripFilter { all, completed, inProgress, cancelled }

final tripFilterProvider = StateProvider<TripFilter>((ref) => TripFilter.all);

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
        case TripFilter.cancelled:
          return t.status == 'CANCELLED';
        default:
          return true;
      }
    }).toList();
  }

  double _totalEarnings(List<TripModel> trips) {
    return trips
        .where((t) => t.status == 'COMPLETED' && t.fareAmount != null)
        .fold(0.0, (sum, t) => sum + t.fareAmount!);
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;
    if (driver == null) return const SizedBox();

    final tripState = ref.watch(driverTripProvider(driver.id));
    final filter = ref.watch(tripFilterProvider);
    final filtered = _filter(tripState.trips, filter);

    return Column(
      children: [
        // Stats
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Trips',
                    '${tripState.trips.length}', Icons.navigation,
                    const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Earnings',
                    '\$${_totalEarnings(tripState.trips).toStringAsFixed(2)}',
                    Icons.attach_money, const Color(0xFF10B981)),
              ),
            ],
          ),
        ),
        // Filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', TripFilter.all, filter),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', TripFilter.completed, filter),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', TripFilter.inProgress, filter),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled', TripFilter.cancelled, filter),
              ],
            ),
          ),
        ),
        // List
        Expanded(
          child: tripState.loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) =>
                            _buildTripCard(ctx, filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, TripFilter filter, TripFilter active) {
    final isActive = filter == active;
    return GestureDetector(
      onTap: () => ref.read(tripFilterProvider.notifier).state = filter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            )),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF2563EB),
                    child: Text('R',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Text('Rider #${trip.riderId}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827))),
                ],
              ),
              _buildStatusBadge(trip.status),
            ],
          ),
          const SizedBox(height: 12),
          // Date
          if (trip.requestedAt != null)
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  trip.requestedAt!.length > 10
                      ? trip.requestedAt!.substring(0, 10)
                      : trip.requestedAt!,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Route
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 24, color: const Color(0xFFD1D5DB)),
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFFDC2626), shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.pickupAddress ?? 'Pickup location',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151))),
                    const SizedBox(height: 20),
                    Text(trip.dropoffAddress ?? 'Dropoff location',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.isDelivery
                      ? 'Delivery${trip.deliveryType != null ? ' · ${trip.deliveryType}' : ''}'
                      : 'Ride',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB)),
                ),
              ),
              if (trip.fareAmount != null)
                Text(
                  '\$${trip.fareAmount!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case 'COMPLETED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Completed';
        break;
      case 'CANCELLED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      case 'IN_PROGRESS':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFF59E0B);
        label = 'In Progress';
        break;
      case 'ACCEPTED':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF6366F1);
        label = 'Accepted';
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        label = 'Requested';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.navigation, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No trips yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Your trip history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
