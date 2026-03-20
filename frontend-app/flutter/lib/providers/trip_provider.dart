import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';

// ─── Trip list state ──────────────────────────────────────────

class TripListState {
  final List<TripModel> trips;
  final bool loading;
  final String? error;

  const TripListState({
    this.trips = const [],
    this.loading = false,
    this.error,
  });

  TripListState copyWith({
    List<TripModel>? trips,
    bool? loading,
    String? error,
  }) =>
      TripListState(
        trips: trips ?? this.trips,
        loading: loading ?? this.loading,
        error: error,
      );
}

// ─── Rider trips notifier ─────────────────────────────────────

class RiderTripNotifier extends StateNotifier<TripListState> {
  final int riderId;
  RiderTripNotifier(this.riderId) : super(const TripListState());

  Future<void> load({String? tripType}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await apiService.getRiderTrips(riderId, tripType: tripType);
      state = state.copyWith(
        trips: list.map((j) => TripModel.fromJson(j)).toList(),
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<TripModel?> requestTrip(Map<String, dynamic> data) async {
    try {
      final json = await apiService.requestTrip(data);
      final trip = TripModel.fromJson(json);
      state = state.copyWith(trips: [trip, ...state.trips]);
      return trip;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> cancelTrip(int tripId) async {
    try {
      final json = await apiService.cancelTrip(tripId);
      final updated = TripModel.fromJson(json);
      state = state.copyWith(
        trips: state.trips.map((t) => t.id == tripId ? updated : t).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final riderTripProvider = StateNotifierProvider.family<RiderTripNotifier,
    TripListState, int>(
  (_, riderId) => RiderTripNotifier(riderId),
);

// ─── Driver trips notifier ────────────────────────────────────

class DriverTripNotifier extends StateNotifier<TripListState> {
  final int driverId;
  DriverTripNotifier(this.driverId) : super(const TripListState());

  Future<void> loadRequested() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await apiService.getTrips(status: 'REQUESTED');
      state = state.copyWith(
        trips: list.map((j) => TripModel.fromJson(j)).toList(),
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMyTrips() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await apiService.getTrips(driverId: driverId);
      state = state.copyWith(
        trips: list.map((j) => TripModel.fromJson(j)).toList(),
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<TripModel?> acceptTrip(int tripId) async {
    try {
      final json = await apiService.acceptTrip(tripId, driverId);
      final updated = TripModel.fromJson(json);
      state = state.copyWith(
        trips: state.trips.where((t) => t.id != tripId).toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> startTrip(int tripId) async {
    try {
      await apiService.startTrip(tripId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeTrip(int tripId, double km, double fare) async {
    try {
      await apiService.completeTrip(tripId, km, fare);
      await loadMyTrips();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final driverTripProvider = StateNotifierProvider.family<DriverTripNotifier,
    TripListState, int>(
  (_, driverId) => DriverTripNotifier(driverId),
);
