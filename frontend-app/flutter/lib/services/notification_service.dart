import 'package:flutter/foundation.dart';
import 'package:pusher_beams/pusher_beams.dart';

const _instanceId = '27751f6b-614f-4e1c-8c50-6513038395be';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  /// Call once on app start (skipped on web — Beams uses native SDKs).
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await PusherBeams.instance.start(_instanceId);
      _initialized = true;
      debugPrint('[Beams] initialized');
    } catch (e) {
      debugPrint('[Beams] init failed: $e');
    }
  }

  /// Subscribe rider to their personal interest channel.
  /// Call this immediately after a successful rider login.
  Future<void> subscribeRider(int riderId) async {
    if (!_initialized) return;
    try {
      await PusherBeams.instance.addDeviceInterest('rider-$riderId');
      debugPrint('[Beams] subscribed to rider-$riderId');
    } catch (e) {
      debugPrint('[Beams] subscribe rider failed: $e');
    }
  }

  /// Subscribe driver to the shared drivers interest channel.
  /// Call this immediately after a successful driver login.
  Future<void> subscribeDriver() async {
    if (!_initialized) return;
    try {
      await PusherBeams.instance.addDeviceInterest('drivers');
      debugPrint('[Beams] subscribed to drivers');
    } catch (e) {
      debugPrint('[Beams] subscribe driver failed: $e');
    }
  }

  /// Clear all interests on logout.
  Future<void> clearSubscriptions() async {
    if (!_initialized) return;
    try {
      await PusherBeams.instance.clearDeviceInterests();
      debugPrint('[Beams] cleared all interests');
    } catch (e) {
      debugPrint('[Beams] clear interests failed: $e');
    }
  }

  /// Return all currently active interests (for debug/display).
  Future<List<String>> getInterests() async {
    if (!_initialized) return [];
    try {
      final interests = await PusherBeams.instance.getDeviceInterests();
      return interests.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }
}
