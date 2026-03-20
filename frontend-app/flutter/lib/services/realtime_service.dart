import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../config/pusher_config.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';

/// Manages a real-time connection to Pusher Channels.
/// Delivers incoming trip-request events to registered listeners.
/// Falls back to 5-second polling when Pusher is not yet configured.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  final _pusher = PusherChannelsFlutter.getInstance();

  // Listeners for incoming trip requests
  final List<void Function(TripModel)> _onTripRequested = [];
  // Listeners for trips removed from queue (accepted / cancelled by someone else)
  final List<void Function(int tripId)> _onTripRemoved = [];

  bool _connected = false;
  bool _usePusher = false;

  // Polling fallback
  Timer? _pollTimer;
  final Set<int> _seenTripIds = {};

  // ── Lifecycle ──────────────────────────────────────────────

  Future<void> connect() async {
    _usePusher = kPusherChannelsKey != 'YOUR_APP_KEY';
    _seenTripIds.clear(); // reset on each connect so fresh trips are visible

    // Always start polling — guarantees drivers see trips within 5 s even if
    // Pusher is unavailable or the backend hasn't sent an event yet.
    _startPolling();

    if (_usePusher) {
      // Also try Pusher for instant (sub-second) delivery.
      // Don't await — let it connect in the background.
      _connectPusher();
    } else {
      debugPrint('[Realtime] Pusher Channels not configured — polling only');
    }
  }

  void disconnect() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (_connected) {
      _pusher.disconnect();
      _connected = false;
    }
  }

  // ── Listener registration ─────────────────────────────────

  void onTripRequested(void Function(TripModel) cb) => _onTripRequested.add(cb);
  void onTripRemoved(void Function(int) cb) => _onTripRemoved.add(cb);

  void removeListeners() {
    _onTripRequested.clear();
    _onTripRemoved.clear();
  }

  // ── Pusher Channels ───────────────────────────────────────

  Future<void> _connectPusher() async {
    try {
      await _pusher.init(
        apiKey: kPusherChannelsKey,
        cluster: kPusherChannelsCluster,
        onConnectionStateChange: (current, previous) {
          debugPrint('[Realtime] Pusher state: $previous → $current');
          _connected = current == 'CONNECTED';
        },
        onError: (message, code, error) {
          debugPrint('[Realtime] Pusher error ($code): $message');
        },
      );

      await _pusher.subscribe(
        channelName: kDriversChannel,
        onEvent: _handlePusherEvent,
      );

      await _pusher.connect();
      debugPrint('[Realtime] Pusher Channels connected → $kDriversChannel');
    } catch (e) {
      debugPrint('[Realtime] Pusher connect failed: $e (polling already running)');
    }
  }

  void _handlePusherEvent(PusherEvent event) {
    try {
      final data = jsonDecode(event.data ?? '{}') as Map<String, dynamic>;

      if (event.eventName == kEventTripRequest) {
        final trip = TripModel.fromJson(data);
        for (final cb in _onTripRequested) { cb(trip); }
      } else if (event.eventName == kEventTripAccepted ||
          event.eventName == kEventTripCancelled) {
        final id = data['id'] as int?;
        if (id != null) {
          for (final cb in _onTripRemoved) { cb(id); }
        }
      }
    } catch (e) {
      debugPrint('[Realtime] Event parse error: $e');
    }
  }

  // ── Polling fallback ──────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    _poll(); // immediate first check
  }

  Future<void> _poll() async {
    try {
      final list = await apiService.getTrips(status: 'REQUESTED');
      final trips = list.map((j) => TripModel.fromJson(j)).toList();

      for (final trip in trips) {
        if (!_seenTripIds.contains(trip.id)) {
          _seenTripIds.add(trip.id);
          for (final cb in _onTripRequested) { cb(trip); }
        }
      }

      // Clean up stale seen ids that are no longer REQUESTED
      final activeIds = trips.map((t) => t.id).toSet();
      final removed = _seenTripIds.difference(activeIds);
      for (final id in removed) {
        _seenTripIds.remove(id);
        for (final cb in _onTripRemoved) { cb(id); }
      }
    } catch (e) {
      debugPrint('[Realtime] Poll error: $e');
    }
  }

  /// Called externally when driver rejects a trip — prevents re-showing it.
  void markRejected(int tripId) => _seenTripIds.add(tripId);

  // ── Rider channel (trip-accepted-rider) ───────────────────

  /// Subscribe a rider to their personal channel so they are notified
  /// the moment a driver accepts their trip.
  Future<void> subscribeRiderChannel(
      int riderId, void Function(int tripId) onAccepted) async {
    if (!_usePusher) return; // rider falls back to polling in TripWaitingDialog
    try {
      await _pusher.subscribe(
        channelName: 'rider-$riderId',
        onEvent: (event) {
          if (event.eventName == 'trip-accepted-rider') {
            try {
              final data =
                  jsonDecode(event.data ?? '{}') as Map<String, dynamic>;
              final tripId = data['tripId'] as int?;
              if (tripId != null) onAccepted(tripId);
            } catch (_) {}
          }
        },
      );
      debugPrint('[Realtime] subscribed rider-$riderId');
    } catch (e) {
      debugPrint('[Realtime] rider channel failed: $e');
    }
  }

  Future<void> unsubscribeRiderChannel(int riderId) async {
    if (!_usePusher) return;
    try {
      await _pusher.unsubscribe(channelName: 'rider-$riderId');
    } catch (_) {}
  }

  // ── Chat channel (new-message) ────────────────────────────

  /// Subscribe to real-time chat messages for a specific trip.
  Future<void> subscribeChatChannel(
      int tripId, void Function(Map<String, dynamic>) onMessage) async {
    if (!_usePusher) return;
    try {
      await _pusher.subscribe(
        channelName: 'trip-$tripId',
        onEvent: (event) {
          if (event.eventName == 'new-message') {
            try {
              final data =
                  jsonDecode(event.data ?? '{}') as Map<String, dynamic>;
              onMessage(data);
            } catch (_) {}
          }
        },
      );
      debugPrint('[Realtime] subscribed trip-$tripId chat');
    } catch (e) {
      debugPrint('[Realtime] chat channel failed: $e');
    }
  }

  Future<void> unsubscribeChatChannel(int tripId) async {
    if (!_usePusher) return;
    try {
      await _pusher.unsubscribe(channelName: 'trip-$tripId');
    } catch (_) {}
  }
}
