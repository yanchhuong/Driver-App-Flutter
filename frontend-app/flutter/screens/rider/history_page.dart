import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
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

  double _totalSpent(List<TripModel> trips) {
    return trips
        .where((t) => t.status == 'COMPLETED' && t.fareAmount != null)
        .fold(0.0, (sum, t) => sum + t.fareAmount!);
  }

  @override
  Widget build(BuildContext context) {
    final rider = ref.watch(authProvider).rider;
    if (rider == null) return const SizedBox();

    final tripState = ref.watch(riderTripProvider(rider.id));
    final trips = tripState.trips;

    return Column(
      children: [
        // Header Stats
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ride History',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Rides', '${trips.length}',
                        Icons.navigation, const Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                        'Total Spent',
                        '\$${_totalSpent(trips).toStringAsFixed(2)}',
                        Icons.attach_money,
                        const Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Trip List
        Expanded(
          child: tripState.loading
              ? const Center(child: CircularProgressIndicator())
              : trips.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: trips.length,
                        itemBuilder: (ctx, i) =>
                            _buildTripCard(ctx, trips[i]),
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
        gradient: LinearGradient(colors: [
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ],
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
          // Header: date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                )
              else
                const SizedBox(),
              _buildStatusBadge(trip.status),
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
                  Container(
                      width: 2, height: 24, color: const Color(0xFFD1D5DB)),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 20),
                    Text(trip.dropoffAddress ?? 'Dropoff location',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151))),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trip.isDelivery
                          ? 'Delivery${trip.deliveryType != null ? ' · ${trip.deliveryType}' : ''}'
                          : 'Ride',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280)),
                    ),
                  ),
                  if (trip.fareAmount != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '\$${trip.fareAmount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ],
              ),
              IconButton(
                onPressed: () => _showTripDetails(context, trip),
                icon: const Icon(Icons.info_outline, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late Color bg, fg;
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
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No ride history yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Book your first ride to see your history',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _showTripDetails(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trip Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
            const SizedBox(height: 16),
            _buildDetailRow('Type', trip.isDelivery ? 'Delivery' : 'Ride'),
            _buildDetailRow('Status', trip.status),
            if (trip.requestedAt != null)
              _buildDetailRow('Date',
                  trip.requestedAt!.length > 10
                      ? trip.requestedAt!.substring(0, 10)
                      : trip.requestedAt!),
            _buildDetailRow(
                'Pickup', trip.pickupAddress ?? 'N/A'),
            _buildDetailRow(
                'Dropoff', trip.dropoffAddress ?? 'N/A'),
            if (trip.fareAmount != null)
              _buildDetailRow(
                  'Fare', '\$${trip.fareAmount!.toStringAsFixed(2)}'),
            if (trip.distanceKm != null)
              _buildDetailRow(
                  'Distance', '${trip.distanceKm!.toStringAsFixed(1)} km'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ),
        ],
      ),
    );
  }
}
