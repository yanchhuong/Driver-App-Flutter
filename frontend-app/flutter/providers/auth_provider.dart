import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rider_model.dart';
import '../models/driver_model.dart';
import '../services/api_service.dart';

// ─── Auth State ───────────────────────────────────────────────

enum AuthRole { none, rider, driver }

class AuthState {
  final AuthRole role;
  final RiderModel? rider;
  final DriverModel? driver;
  final bool loading;
  final String? error;

  const AuthState({
    this.role = AuthRole.none,
    this.rider,
    this.driver,
    this.loading = false,
    this.error,
  });

  bool get isLoggedIn => role != AuthRole.none;

  AuthState copyWith({
    AuthRole? role,
    RiderModel? rider,
    DriverModel? driver,
    bool? loading,
    String? error,
  }) =>
      AuthState(
        role: role ?? this.role,
        rider: rider ?? this.rider,
        driver: driver ?? this.driver,
        loading: loading ?? this.loading,
        error: error,
      );
}

// ─── Auth Notifier ────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login as rider — find by email, auto-register if not found
  Future<void> loginAsRider(String name, String email, String phone) async {
    state = state.copyWith(loading: true, error: null);
    try {
      var data = await apiService.findRiderByEmail(email);
      data ??= await apiService.registerRider({
        'name': name,
        'email': email,
        'phone': phone,
      });
      final rider = RiderModel.fromJson(data);
      await _persist('rider', rider.id);
      state = state.copyWith(role: AuthRole.rider, rider: rider, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Login as driver — find by email, auto-register if not found
  Future<void> loginAsDriver(
      String name, String email, String phone, String license) async {
    state = state.copyWith(loading: true, error: null);
    try {
      var data = await apiService.findDriverByEmail(email);
      data ??= await apiService.registerDriver({
        'name': name,
        'email': email,
        'phone': phone,
        'licenseNumber': license,
      });
      final driver = DriverModel.fromJson(data);
      await _persist('driver', driver.id);
      state = state.copyWith(role: AuthRole.driver, driver: driver, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Restore session from SharedPreferences
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('auth_role');
    final id = prefs.getInt('auth_id');
    if (role == null || id == null) return;
    try {
      if (role == 'rider') {
        final data = await apiService.getRider(id);
        state = state.copyWith(role: AuthRole.rider, rider: RiderModel.fromJson(data));
      } else if (role == 'driver') {
        final data = await apiService.getDriver(id);
        state = state.copyWith(role: AuthRole.driver, driver: DriverModel.fromJson(data));
      }
    } catch (_) {
      await _clearPersist();
    }
  }

  Future<void> logout() async {
    await _clearPersist();
    state = const AuthState();
  }

  Future<void> _persist(String role, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_role', role);
    await prefs.setInt('auth_id', id);
  }

  Future<void> _clearPersist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    await prefs.remove('auth_id');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
