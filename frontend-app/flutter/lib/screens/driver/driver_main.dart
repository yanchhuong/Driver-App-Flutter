import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/realtime_service.dart';
import '../../widgets/trip_request_sheet.dart';
import 'rides_page.dart';
import 'trip_page.dart';
import 'driver_profile_page.dart';
import 'driver_settings_page.dart';
import 'active_trip_page.dart';

enum DriverTab { rides, trip, profile }

final driverTabProvider = StateProvider<DriverTab>((ref) => DriverTab.rides);

class DriverMain extends ConsumerStatefulWidget {
  final VoidCallback onLogout;
  const DriverMain({super.key, required this.onLogout});

  @override
  ConsumerState<DriverMain> createState() => _DriverMainState();
}

class _DriverMainState extends ConsumerState<DriverMain> {
  // Queued trip requests that have not been shown yet.
  final List<TripModel> _pendingQueue = [];
  // Trips currently removed (accepted by someone else or cancelled).
  final Set<int> _removedIds = {};
  // Whether the accept/reject sheet is already visible.
  bool _sheetVisible = false;
  // Notification badge count
  int _notifCount = 0;

  // Panel visibility
  bool _showNotificationsPanel = false;
  bool _showChatPanel = false;

  // Chat input controller
  final TextEditingController _chatMessageCtrl = TextEditingController();

  // Driver notifications static data
  final List<Map<String, dynamic>> _driverNotifications = [
    {
      'title': 'Trip Completed',
      'message': 'Trip to Oak Avenue completed. You earned \$18.50',
      'time': '10 min ago',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': true,
    },
    {
      'title': 'New Ride Request',
      'message': 'Pickup at 123 Main Street - 2.5 miles away',
      'time': '30 min ago',
      'icon': Icons.directions_car,
      'iconColor': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
      'unread': true,
    },
    {
      'title': 'New Delivery Request',
      'message': 'Package pickup from Restaurant - \$42.00',
      'time': '1 hour ago',
      'icon': Icons.inventory_2,
      'iconColor': const Color(0xFF9333EA),
      'bgColor': const Color(0xFFFAF5FF),
      'unread': false,
    },
    {
      'title': 'Payment Received',
      'message': 'Weekly earnings of \$542.50 deposited to your account',
      'time': '2 hours ago',
      'icon': Icons.attach_money,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': false,
    },
    {
      'title': 'Ride Cancelled',
      'message': 'Passenger cancelled the ride to Airport',
      'time': '3 hours ago',
      'icon': Icons.warning,
      'iconColor': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFEF2F2),
      'unread': false,
    },
    {
      'title': 'Bonus Earned!',
      'message': 'You completed 10 rides today. Bonus: \$25.00',
      'time': 'Yesterday',
      'icon': Icons.attach_money,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startRealtime();
  }

  @override
  void dispose() {
    _chatMessageCtrl.dispose();
    RealtimeService.instance.removeListeners();
    RealtimeService.instance.disconnect();
    super.dispose();
  }

  void _startRealtime() {
    final rt = RealtimeService.instance;
    rt.onTripRequested(_onIncomingTrip);
    rt.onTripRemoved(_onTripRemoved);
    rt.connect();
  }

  void _onIncomingTrip(TripModel trip) {
    if (!mounted || _removedIds.contains(trip.id)) return;
    setState(() {
      _pendingQueue.add(trip);
      _notifCount++;
    });
    _tryShowSheet();
  }

  void _onTripRemoved(int tripId) {
    _removedIds.add(tripId);
    _pendingQueue.removeWhere((t) => t.id == tripId);
    if (mounted) setState(() { if (_notifCount > 0) _notifCount--; });
  }

  void _tryShowSheet() {
    if (_sheetVisible || _pendingQueue.isEmpty) return;
    final trip = _pendingQueue.first;

    // Skip if this trip was already removed while queued
    if (_removedIds.contains(trip.id)) {
      _pendingQueue.removeAt(0);
      _tryShowSheet();
      return;
    }

    final driver = ref.read(authProvider).driver;
    if (driver == null) return;

    setState(() => _sheetVisible = true);

    TripRequestSheet.show(
      context,
      trip: trip,
      driverId: driver.id,
      onAccepted: (acceptedTrip) {
        _pendingQueue.remove(trip);
        _pendingQueue.clear();
        if (mounted) setState(() { _sheetVisible = false; _notifCount = 0; });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveTripPage(
              initialTrip: acceptedTrip,
              driverId: driver.id,
            ),
          ),
        );
      },
      onRejected: () {
        RealtimeService.instance.markRejected(trip.id);
        _pendingQueue.remove(trip);
        if (mounted) {
          setState(() {
            _sheetVisible = false;
            if (_notifCount > 0) _notifCount--;
          });
          // Show next in queue after short delay
          Future.delayed(const Duration(milliseconds: 400), _tryShowSheet);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(driverTabProvider);
    final isPanelOpen = _showNotificationsPanel || _showChatPanel;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'DriveApp Driver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Chat button
          IconButton(
            onPressed: () {
              setState(() {
                _showChatPanel = !_showChatPanel;
                if (_showChatPanel) _showNotificationsPanel = false;
              });
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF374151)),
          ),
          // Notification bell with live badge
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showNotificationsPanel = !_showNotificationsPanel;
                    if (_showNotificationsPanel) _showChatPanel = false;
                  });
                },
                icon: Icon(
                  Icons.notifications,
                  color: _notifCount > 0
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF374151),
                ),
              ),
              if (_notifCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_notifCount',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          Builder(builder: (ctx) => IconButton(
            onPressed: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => const DriverSettingsPage())),
            icon: const Icon(Icons.settings, color: Color(0xFF374151)),
          )),
        ],
      ),
      body: Stack(
        children: [
          _buildContent(activeTab),

          // Backdrop
          if (isPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showNotificationsPanel = false;
                    _showChatPanel = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

          // Notifications panel
          if (_showNotificationsPanel)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blue gradient header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _showNotificationsPanel = false),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                      // Notification list
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _driverNotifications.length,
                          itemBuilder: (context, index) {
                            final notif = _driverNotifications[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: (notif['unread'] as bool)
                                    ? const Color(0xFFF8FAFF)
                                    : Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade100),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: notif['bgColor'] as Color,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      notif['icon'] as IconData,
                                      color: notif['iconColor'] as Color,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif['title'] as String,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF111827),
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              notif['time'] as String,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          notif['message'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (notif['unread'] as bool)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(
                                          top: 4, left: 6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2563EB),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Mark All as Read footer
                      InkWell(
                        onTap: () {
                          setState(() {
                            for (final n in _driverNotifications) {
                              n['unread'] = false;
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Text(
                              'Mark All as Read',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Chat panel
          if (_showChatPanel)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blue gradient header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showChatPanel = false),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                      // Empty message list area
                      const Expanded(
                        child: Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      // Message input footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatMessageCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2563EB)),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_chatMessageCtrl.text.trim().isNotEmpty) {
                                  _chatMessageCtrl.clear();
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(activeTab),
    );
  }

  Widget _buildContent(DriverTab tab) {
    return switch (tab) {
      DriverTab.rides   => const RidesPage(),
      DriverTab.trip    => const TripPage(),
      DriverTab.profile => DriverProfilePage(onLogout: widget.onLogout),
    };
  }

  Widget _buildBottomNav(DriverTab activeTab) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem('Rides',   Icons.location_on, DriverTab.rides,   activeTab),
              _navItem('Trip',    Icons.navigation,  DriverTab.trip,    activeTab),
              _navItem('Profile', Icons.person,      DriverTab.profile, activeTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      String label, IconData icon, DriverTab tab, DriverTab activeTab) {
    final isActive = tab == activeTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(driverTabProvider.notifier).state = tab,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF6B7280),
                  size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF6B7280),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
