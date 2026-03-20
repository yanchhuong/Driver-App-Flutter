import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'rides_page.dart';
import 'trip_page.dart';
import 'driver_profile_page.dart';

enum DriverTab { rides, trip, profile }

final driverTabProvider = StateProvider<DriverTab>((ref) => DriverTab.rides);

class DriverMain extends ConsumerWidget {
  final VoidCallback onLogout;

  const DriverMain({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(driverTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          ref.watch(authProvider).driver?.name ?? 'DriveApp Driver',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Color(0xFF374151)),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Color(0xFF374151)),
          ),
        ],
      ),
      body: _buildContent(activeTab, ref),
      bottomNavigationBar: _buildBottomNav(context, ref, activeTab),
    );
  }

  Widget _buildContent(DriverTab tab, WidgetRef ref) {
    switch (tab) {
      case DriverTab.rides:
        return const RidesPage();
      case DriverTab.trip:
        return const TripPage();
      case DriverTab.profile:
        return DriverProfilePage(onLogout: onLogout);
    }
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref, DriverTab activeTab) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                ref,
                'Rides',
                Icons.location_on,
                DriverTab.rides,
                activeTab == DriverTab.rides,
              ),
              _buildNavItem(
                context,
                ref,
                'Trip',
                Icons.navigation,
                DriverTab.trip,
                activeTab == DriverTab.trip,
              ),
              _buildNavItem(
                context,
                ref,
                'Profile',
                Icons.person,
                DriverTab.profile,
                activeTab == DriverTab.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    DriverTab tab,
    bool isActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(driverTabProvider.notifier).state = tab,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
