import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

enum RidesView { list, map }

final ridesViewProvider = StateProvider<RidesView>((ref) => RidesView.list);

class RidesPage extends ConsumerStatefulWidget {
  const RidesPage({super.key});

  @override
  ConsumerState<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends ConsumerState<RidesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final driverId = ref.read(authProvider).driver?.id;
    if (driverId == null) return;
    await ref.read(driverTripProvider(driverId).notifier).loadRequested();
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(authProvider).driver;
    if (driver == null) return const SizedBox();

    final tripState = ref.watch(driverTripProvider(driver.id));
    final view = ref.watch(ridesViewProvider);

    return Column(
      children: [
        // View Toggle
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildViewToggle(ref, 'List View', Icons.list,
                    RidesView.list, view == RidesView.list),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildViewToggle(ref, 'Map View', Icons.map,
                    RidesView.map, view == RidesView.map),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: tripState.loading
              ? const Center(child: CircularProgressIndicator())
              : tripState.error != null
                  ? _buildError(tripState.error!)
                  : view == RidesView.list
                      ? _buildListView(context, ref, tripState.trips, driver.id)
                      : _buildMapView(context, tripState.trips.length),
        ),
      ],
    );
  }

  Widget _buildViewToggle(
      WidgetRef ref, String label, IconData icon, RidesView view, bool isActive) {
    return GestureDetector(
      onTap: () => ref.read(ridesViewProvider.notifier).state = view,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18,
                color: isActive ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref,
      List<TripModel> trips, int driverId) {
    if (trips.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) =>
            _buildRideCard(context, ref, trips[index], driverId),
      ),
    );
  }

  Widget _buildRideCard(
      BuildContext context, WidgetRef ref, TripModel trip, int driverId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.isDelivery
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.isDelivery
                      ? 'Delivery${trip.deliveryType != null ? ' · ${trip.deliveryType}' : ''}'
                      : 'Ride',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trip.isDelivery
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Rider #${trip.riderId}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pickup
          _buildAddressRow(const Color(0xFF10B981), 'Pickup',
              trip.pickupAddress ?? 'Pickup location'),
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 4, bottom: 4),
            child: Container(width: 2, height: 16, color: const Color(0xFFD1D5DB)),
          ),
          // Dropoff
          _buildAddressRow(const Color(0xFFDC2626), 'Dropoff',
              trip.dropoffAddress ?? 'Dropoff location'),
          const SizedBox(height: 12),
          // Details row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (trip.distanceKm != null)
                  _buildInfoChip(Icons.straighten,
                      '${trip.distanceKm!.toStringAsFixed(1)} km'),
                const Spacer(),
                Text(
                  '\$${trip.fareAmount?.toStringAsFixed(2) ?? '—'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptTrip(context, ref, trip, driverId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptTrip(BuildContext context, WidgetRef ref,
      TripModel trip, int driverId) async {
    final accepted = await ref
        .read(driverTripProvider(driverId).notifier)
        .acceptTrip(trip.id);
    if (!context.mounted) return;
    if (accepted != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Trip Accepted!'),
            ],
          ),
          content: Text(
              'Head to: ${trip.pickupAddress ?? 'Pickup location'}\nRider #${trip.riderId}'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB)),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAddressRow(Color dot, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
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
              Text(address,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(text,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildMapView(BuildContext context, int count) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFE5E7EB),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Map View',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Showing $count available trips',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 8),
                Text('$count riders nearby',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No ride requests',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Pull down to refresh',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
