import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'settle_page.dart';
import 'rider_profile_page.dart';

enum RiderTab { home, history, settle, profile }

final riderTabProvider = StateProvider<RiderTab>((ref) => RiderTab.home);

class RiderMain extends ConsumerWidget {
  final VoidCallback onLogout;

  const RiderMain({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(riderTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          ref.watch(authProvider).rider?.name ?? 'DriveApp',
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

  Widget _buildContent(RiderTab tab, WidgetRef ref) {
    switch (tab) {
      case RiderTab.home:
        return const HomePage();
      case RiderTab.history:
        return const HistoryPage();
      case RiderTab.settle:
        return const SettlePage();
      case RiderTab.profile:
        return RiderProfilePage(onLogout: onLogout);
    }
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref, RiderTab activeTab) {
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
                'Home',
                Icons.home,
                RiderTab.home,
                activeTab == RiderTab.home,
              ),
              _buildNavItem(
                context,
                ref,
                'History',
                Icons.history,
                RiderTab.history,
                activeTab == RiderTab.history,
              ),
              _buildNavItem(
                context,
                ref,
                'Settle',
                Icons.account_balance_wallet,
                RiderTab.settle,
                activeTab == RiderTab.settle,
              ),
              _buildNavItem(
                context,
                ref,
                'Profile',
                Icons.person,
                RiderTab.profile,
                activeTab == RiderTab.profile,
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
    RiderTab tab,
    bool isActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(riderTabProvider.notifier).state = tab,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
