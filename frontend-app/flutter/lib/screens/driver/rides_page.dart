import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';

enum RidesView { list, map }

final ridesViewProvider = StateProvider<RidesView>((ref) => RidesView.list);

class RidesPage extends ConsumerStatefulWidget {
  const RidesPage({super.key});

  @override
  ConsumerState<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends ConsumerState<RidesPage>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  TripModel? _selectedTrip;
  bool _accepting = false;
  double _todayEarnings = 0.0;
  int _completedToday = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.microtask(_load);
    Future.microtask(_loadEarnings);
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _load();
      _loadEarnings();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final driverId = ref.read(authProvider).driver?.id;
    if (driverId == null) return;
    await ref.read(driverTripProvider(driverId).notifier).loadRequested();
  }

  Future<void> _loadEarnings() async {
    final driverId = ref.read(authProvider).driver?.id;
    if (driverId == null) return;
    try {
      final list = await apiService.getTrips(driverId: driverId, status: 'COMPLETED');
      final trips = list.map((j) => TripModel.fromJson(j as Map<String, dynamic>)).toList();
      final today = DateTime.now();
      final todayTrips = trips.where((t) {
        if (t.completedAt == null) return false;
        try {
          final d = DateTime.parse(t.completedAt!);
          return d.year == today.year && d.month == today.month && d.day == today.day;
        } catch (_) {
          return false;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _todayEarnings = todayTrips.fold(0.0, (s, t) => s + (t.fareAmount ?? 0));
          _completedToday = todayTrips.length;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleOnlineStatus(bool isOnline) async {
    final driver = ref.read(authProvider).driver;
    if (driver == null) return;
    final newStatus = isOnline ? 'ONLINE' : 'OFFLINE';
    try {
      await apiService.updateDriverStatus(driver.id, newStatus);
      ref
          .read(authProvider.notifier)
          .updateDriverProfile(
            driver.id,
            name: driver.name,
            email: driver.email,
            phone: driver.phone,
            licenseNumber: driver.licenseNumber,
          );
    } catch (_) {}
  }

  Future<void> _acceptTrip(TripModel trip, int driverId) async {
    setState(() => _accepting = true);
    try {
      final accepted = await ref
          .read(driverTripProvider(driverId).notifier)
          .acceptTrip(trip.id);
      if (!mounted) return;
      setState(() {
        _accepting = false;
        _selectedTrip = null;
      });
      if (accepted != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Trip accepted! Head to: ${trip.pickupAddress ?? 'Pickup location'}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final driver = authState.driver;
    if (driver == null) return const SizedBox();

    final tripState = ref.watch(driverTripProvider(driver.id));
    final view = ref.watch(ridesViewProvider);
    final isOnline = driver.status == 'ONLINE' || driver.status == 'ON_TRIP';

    return Stack(
      children: [
        Column(
          children: [
            // Status card
            _buildStatusCard(driver.name, isOnline, tripState.trips, driver.rating),
            // View toggle
            _buildViewToggle(view),
            // Content
            Expanded(
              child: tripState.loading && tripState.trips.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : tripState.error != null
                      ? _buildError(tripState.error!)
                      : view == RidesView.list
                          ? _buildListView(
                              tripState.trips, driver.id)
                          : _buildMapView(tripState.trips),
            ),
          ],
        ),

        // Detail sheet overlay
        if (_selectedTrip != null)
          _buildDetailSheet(_selectedTrip!, driver.id),
      ],
    );
  }

  // ── STATUS CARD ───────────────────────────────────────────────

  Widget _buildStatusCard(
      String driverName, bool isOnline, List<TripModel> trips, double rating) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? "You're Online" : "You're Offline",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ready to accept rides',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFFBFDBFE)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: _toggleOnlineStatus,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF10B981),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildStatItem("Today's Rides", '${trips.length}'),
                _buildStatDivider(),
                _buildStatItem("Today's Earnings", '\$${_todayEarnings.toStringAsFixed(2)}'),
                _buildStatDivider(),
                _buildStatItem('Your Rating', '${rating.toStringAsFixed(1)} ⭐'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFFBFDBFE))),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
        width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2));
  }

  // ── VIEW TOGGLE ───────────────────────────────────────────────

  Widget _buildViewToggle(RidesView current) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _viewTogglePill(
              'List View',
              Icons.list_rounded,
              RidesView.list,
              current == RidesView.list,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _viewTogglePill(
              'Map View',
              Icons.map_outlined,
              RidesView.map,
              current == RidesView.map,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewTogglePill(
      String label, IconData icon, RidesView view, bool active) {
    return GestureDetector(
      onTap: () => ref.read(ridesViewProvider.notifier).state = view,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                active ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 17,
                color: active ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        active ? Colors.white : const Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  // ── LIST VIEW ─────────────────────────────────────────────────

  Widget _buildListView(List<TripModel> trips, int driverId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Available Rides (${trips.length})',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
        ),
        Expanded(
          child: trips.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: trips.length,
                    itemBuilder: (_, i) =>
                        _buildRideCard(trips[i], driverId),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRideCard(TripModel trip, int driverId) {
    final isSelected = _selectedTrip?.id == trip.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTrip = trip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup row
              _buildAddressRow(
                const Color(0xFF2563EB),
                Icons.circle,
                'Pickup',
                trip.pickupAddress ?? 'Pickup location',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 3, bottom: 3),
                child: Container(
                    width: 2,
                    height: 14,
                    color: const Color(0xFFD1D5DB)),
              ),
              // Dropoff row
              _buildAddressRow(
                const Color(0xFFDC2626),
                Icons.location_on,
                'Dropoff',
                trip.dropoffAddress ?? 'Dropoff location',
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  if (trip.distanceKm != null) ...[
                    const Icon(Icons.navigation_outlined,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.access_time,
                      size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    trip.distanceKm != null
                        ? '${(trip.distanceKm! * 3).ceil()} min'
                        : '— min',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const Spacer(),
                  Text(
                    '\$${trip.fareAmount?.toStringAsFixed(2) ?? '—'}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(
      Color color, IconData icon, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 11, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280))),
              const SizedBox(height: 1),
              Text(address,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }

  // ── MAP VIEW ──────────────────────────────────────────────────

  Widget _buildMapView(List<TripModel> trips) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
            ),
          ),
        ),

        // Rider marker dots
        ...List.generate(trips.length, (i) {
          final offset = Offset(
            100.0 + (i * 80.0) % (MediaQuery.of(context).size.width - 160),
            120.0 + (i * 60.0) % 160,
          );
          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          );
        }),

        // Center label
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        color: Color(0xFF2563EB), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Map View',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${trips.length} rider${trips.length == 1 ? '' : 's'} nearby',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── DETAIL SHEET ──────────────────────────────────────────────

  Widget _buildDetailSheet(TripModel trip, int driverId) {
    final estTime = trip.distanceKm != null
        ? '${(trip.distanceKm! * 3).ceil()} min'
        : '—';

    return GestureDetector(
      onTap: () => setState(() => _selectedTrip = null),
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // prevent tap-through
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle + close
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTrip = null),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close,
                                  size: 17, color: Color(0xFF374151)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text('Ride Request',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        Text(
                          'From Rider #${trip.riderId}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 16),

                        // Mini map
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFDBEAFE),
                                Color(0xFFD1FAE5)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, child) => Transform.scale(
                                scale:
                                    1.0 + 0.08 * _pulseController.value,
                                child: child,
                              ),
                              child: const Icon(Icons.location_on,
                                  size: 36, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pickup
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 10, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  trip.pickupAddress ??
                                      'Pickup location',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1E40AF)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dropoff
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: Color(0xFFDC2626)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trip.dropoffAddress ??
                                      'Dropoff location',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF991B1B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _buildSheetStat(
                                '\$${trip.fareAmount?.toStringAsFixed(2) ?? '—'}',
                                'Fare',
                                const Color(0xFF10B981),
                              ),
                              _buildSheetStatDivider(),
                              _buildSheetStat(
                                trip.distanceKm != null
                                    ? '${trip.distanceKm!.toStringAsFixed(1)} km'
                                    : '—',
                                'Distance',
                                const Color(0xFF111827),
                              ),
                              _buildSheetStatDivider(),
                              _buildSheetStat(
                                  estTime, 'Est. Time', const Color(0xFF111827)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Accept button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _accepting
                                ? null
                                : () => _acceptTrip(trip, driverId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _accepting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Text('Accept Ride',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Decline button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _selectedTrip = null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              side: const BorderSide(
                                  color: Color(0xFFD1D5DB)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Decline',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetStat(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildSheetStatDivider() {
    return Container(
        width: 1, height: 28, color: const Color(0xFFE5E7EB));
  }

  // ── EMPTY / ERROR ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No available rides',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Pull down to refresh or wait for new requests',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFF2563EB)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
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
            const Icon(Icons.error_outline,
                size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB)),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
