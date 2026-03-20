import 'dart:convert';
import 'package:http/http.dart' as http;

// Change to your machine's IP when testing on a real device.
// Android emulator: 10.0.2.2  |  iOS simulator / web: localhost
const String _baseUrl = 'http://localhost:8080/api';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> _get(String path) async {
    final res = await _client.get(Uri.parse('$_baseUrl$path'), headers: _headers);
    return _handle(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> _patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    final msg = _tryMessage(res.body);
    throw ApiException(res.statusCode, msg);
  }

  String _tryMessage(String body) {
    try {
      return jsonDecode(body)['message'] ?? body;
    } catch (_) {
      return body;
    }
  }

  // ─── RIDERS ────────────────────────────────────────────────

  Future<List<dynamic>> getRiders() => _get('/riders').then((v) => v as List);

  Future<Map<String, dynamic>> getRider(int id) =>
      _get('/riders/$id').then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> registerRider(Map<String, dynamic> data) =>
      _post('/riders', data).then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> updateRider(int id, Map<String, dynamic> data) =>
      _put('/riders/$id', data).then((v) => v as Map<String, dynamic>);

  Future<List<dynamic>> getRiderTrips(int riderId, {String? tripType}) {
    final query = tripType != null ? '?tripType=$tripType' : '';
    return _get('/riders/$riderId/trips$query').then((v) => v as List);
  }

  Future<List<dynamic>> getRiderPayments(int riderId) =>
      _get('/riders/$riderId/payments').then((v) => v as List);

  /// Lightweight login: find rider by email
  Future<Map<String, dynamic>?> findRiderByEmail(String email) async {
    final list = await getRiders();
    final match = list.cast<Map<String, dynamic>>().where((r) => r['email'] == email).toList();
    return match.isNotEmpty ? match.first : null;
  }

  // ─── DRIVERS ───────────────────────────────────────────────

  Future<List<dynamic>> getDrivers({String? status}) {
    final query = status != null ? '?status=$status' : '';
    return _get('/drivers$query').then((v) => v as List);
  }

  Future<Map<String, dynamic>> getDriver(int id) =>
      _get('/drivers/$id').then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> data) =>
      _post('/drivers', data).then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> updateDriver(int id, Map<String, dynamic> data) =>
      _put('/drivers/$id', data).then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> updateDriverStatus(int id, String status) =>
      _patch('/drivers/$id/status', {'status': status})
          .then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> updateDriverLocation(
          int id, double lat, double lng) =>
      _patch('/drivers/$id/location', {'latitude': lat, 'longitude': lng})
          .then((v) => v as Map<String, dynamic>);

  /// Lightweight login: find driver by email
  Future<Map<String, dynamic>?> findDriverByEmail(String email) async {
    final list = await getDrivers();
    final match = list.cast<Map<String, dynamic>>().where((d) => d['email'] == email).toList();
    return match.isNotEmpty ? match.first : null;
  }

  // ─── TRIPS ─────────────────────────────────────────────────

  Future<List<dynamic>> getTrips({String? status, String? tripType, int? driverId}) {
    final params = <String>[];
    if (status != null) params.add('status=$status');
    if (tripType != null) params.add('tripType=$tripType');
    if (driverId != null) params.add('driverId=$driverId');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return _get('/trips$query').then((v) => v as List);
  }

  Future<Map<String, dynamic>> getTrip(int id) =>
      _get('/trips/$id').then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> requestTrip(Map<String, dynamic> data) =>
      _post('/trips', data).then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> acceptTrip(int tripId, int driverId) =>
      _patch('/trips/$tripId/accept', {'driverId': driverId})
          .then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> startTrip(int tripId) =>
      _patch('/trips/$tripId/start', {}).then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> completeTrip(
          int tripId, double distanceKm, double fareAmount) =>
      _patch('/trips/$tripId/complete',
              {'distanceKm': distanceKm, 'fareAmount': fareAmount})
          .then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> arriveTrip(int tripId, int driverId) =>
      _patch('/trips/$tripId/arrive', {'driverId': driverId})
          .then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> cancelTrip(int tripId) =>
      _patch('/trips/$tripId/cancel', {}).then((v) => v as Map<String, dynamic>);

  Future<List<dynamic>> getTripActivities(int tripId) =>
      _get('/trips/$tripId/activities').then((v) => v as List);

  // ─── PAYMENTS ──────────────────────────────────────────────

  Future<List<dynamic>> getPayments({String? status}) {
    final query = status != null ? '?status=$status' : '';
    return _get('/payments$query').then((v) => v as List);
  }

  Future<Map<String, dynamic>> getPaymentByTrip(int tripId) =>
      _get('/payments/trip/$tripId').then((v) => v as Map<String, dynamic>);

  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> data) =>
      _post('/payments', data).then((v) => (v as Map).cast<String, dynamic>());

  Future<Map<String, dynamic>> confirmPayment(int id) =>
      _patch('/payments/$id/confirm', {}).then((v) => (v as Map).cast<String, dynamic>());

  // ─── TRIP CHAT ──────────────────────────────────────────────

  Future<List<dynamic>> getMessages(int tripId) =>
      _get('/trips/$tripId/messages').then((v) => v as List);

  Future<Map<String, dynamic>> sendMessage(int tripId, Map<String, dynamic> data) =>
      _post('/trips/$tripId/messages', data)
          .then((v) => (v as Map).cast<String, dynamic>());
}

// Singleton
final apiService = ApiService();
