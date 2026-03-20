import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'settle_page.dart';
import 'rider_profile_page.dart';

enum RiderTab { home, history, settle, profile }

final riderTabProvider = StateProvider<RiderTab>((ref) => RiderTab.home);

class RiderMain extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const RiderMain({super.key, required this.onLogout});

  @override
  ConsumerState<RiderMain> createState() => _RiderMainState();
}

class _RiderMainState extends ConsumerState<RiderMain> {
  bool _showNotifications = false;
  bool _showChat = false;
  String? _selectedContact;
  final TextEditingController _chatMessageCtrl = TextEditingController();

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Ride Completed',
      'message': 'Your ride to Oak Avenue has been completed. Total fare: \$18.50',
      'time': '5 min ago',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': true,
    },
    {
      'title': 'Driver Arrived',
      'message': 'John Smith has arrived at your pickup location',
      'time': '1 hour ago',
      'icon': Icons.directions_car,
      'iconColor': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
      'unread': true,
    },
    {
      'title': 'Delivery Driver Assigned',
      'message': 'Emily Johnson is on the way to pick up your package',
      'time': '2 hours ago',
      'icon': Icons.inventory_2,
      'iconColor': const Color(0xFF9333EA),
      'bgColor': const Color(0xFFFAF5FF),
      'unread': false,
    },
    {
      'title': 'Ride Started',
      'message': 'Your ride to Central Market has started',
      'time': '3 hours ago',
      'icon': Icons.location_on,
      'iconColor': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
      'unread': false,
    },
    {
      'title': 'Delivery Completed',
      'message': 'Your package has been delivered to 456 Oak Avenue',
      'time': '5 hours ago',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': false,
    },
    {
      'title': 'Payment Successful',
      'message': 'Payment of \$42.00 processed successfully',
      'time': 'Yesterday',
      'icon': Icons.attach_money,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'unread': false,
    },
    {
      'title': 'Ride Cancelled',
      'message': 'Your scheduled ride has been cancelled',
      'time': '2 days ago',
      'icon': Icons.warning,
      'iconColor': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFEF2F2),
      'unread': false,
    },
  ];

  final List<Map<String, dynamic>> _chatContacts = [
    {
      'id': 'contact-1',
      'name': 'John Smith',
      'lastMessage': 'Hello, how are you?',
      'time': '2 min ago',
      'unread': true,
    },
    {
      'id': 'contact-2',
      'name': 'Emily Johnson',
      'lastMessage': 'Your package is on the way!',
      'time': '15 min ago',
      'unread': true,
    },
    {
      'id': 'contact-3',
      'name': 'Michael Brown',
      'lastMessage': 'Thank you for the ride!',
      'time': '1 hour ago',
      'unread': false,
    },
    {
      'id': 'contact-4',
      'name': 'Sarah Davis',
      'lastMessage': 'See you tomorrow',
      'time': '2 hours ago',
      'unread': false,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    'contact-1': [
      {'sender': 'them', 'text': "Hi! I'm on my way to pick you up."},
      {'sender': 'me', 'text': "Great! I'll be ready in 5 minutes."},
      {'sender': 'them', 'text': 'Perfect! I\'m driving a blue Toyota Camry.'},
      {'sender': 'them', 'text': 'Hello, how are you?'},
    ],
    'contact-2': [
      {'sender': 'them', 'text': 'I have your package!'},
      {'sender': 'me', 'text': 'Awesome! How far are you?'},
      {'sender': 'them', 'text': 'About 5 minutes away'},
      {'sender': 'them', 'text': 'Your package is on the way!'},
    ],
    'contact-3': [
      {'sender': 'them', 'text': 'Thanks for choosing our service!'},
      {'sender': 'me', 'text': 'The ride was excellent!'},
      {'sender': 'them', 'text': 'Thank you for the ride!'},
    ],
    'contact-4': [
      {'sender': 'me', 'text': 'Can we schedule a ride for tomorrow?'},
      {'sender': 'them', 'text': 'Sure! What time?'},
      {'sender': 'me', 'text': '8:00 AM please'},
      {'sender': 'them', 'text': 'See you tomorrow'},
    ],
  };

  int get _unreadCount =>
      _notifications.where((n) => n['unread'] == true).length;

  @override
  void dispose() {
    _chatMessageCtrl.dispose();
    super.dispose();
  }

  void _closeAllPanels() {
    setState(() {
      _showNotifications = false;
      _showChat = false;
      _selectedContact = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(riderTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'DriveApp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showChat = !_showChat;
                _showNotifications = false;
              });
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF374151)),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showNotifications = !_showNotifications;
                    _showChat = false;
                  });
                },
                icon: const Icon(Icons.notifications, color: Color(0xFF374151)),
              ),
              if (_unreadCount > 0)
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
        ],
      ),
      body: Stack(
        children: [
          _buildContent(activeTab),
          if (_showNotifications || _showChat)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeAllPanels,
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
          if (_showNotifications) _buildNotificationsPanel(context),
          if (_showChat) _buildChatPanel(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, activeTab),
    );
  }

  Widget _buildContent(RiderTab tab) {
    switch (tab) {
      case RiderTab.home:
        return const HomePage();
      case RiderTab.history:
        return const HistoryPage();
      case RiderTab.settle:
        return const SettlePage();
      case RiderTab.profile:
        return RiderProfilePage(onLogout: widget.onLogout);
    }
  }

  Widget _buildNotificationsPanel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 320,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
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
                      onTap: _closeAllPanels,
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              // Notification list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isUnread = notification['unread'] == true;
                    return Container(
                      color: isUnread
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notification['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              notification['icon'] as IconData,
                              color: notification['iconColor'] as Color,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification['title'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isUnread
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: const Color(0xFF111827),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      notification['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notification['message'] as String,
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
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Footer
              InkWell(
                onTap: () {
                  setState(() {
                    for (final n in _notifications) {
                      n['unread'] = false;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
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
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 320,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (_selectedContact != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedContact = null;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.arrow_back,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        Text(
                          _selectedContact != null
                              ? (_chatContacts.firstWhere((c) =>
                                  c['id'] == _selectedContact)['name'] as String)
                              : 'Chat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _closeAllPanels,
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: _selectedContact == null
                    ? _buildContactList()
                    : _buildMessageThread(),
              ),
              // Footer
              if (_selectedContact != null) _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _chatContacts.length,
      itemBuilder: (context, index) {
        final contact = _chatContacts[index];
        final isUnread = contact['unread'] == true;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedContact = contact['id'] as String;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isUnread
                  ? const Color(0xFFEFF6FF)
                  : Colors.transparent,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    (contact['name'] as String)[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            contact['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            contact['time'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact['lastMessage'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                          fontWeight: isUnread
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageThread() {
    final messages = _chatMessages[_selectedContact] ?? [];
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message['sender'] == 'me';
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 12),
              ),
            ),
            child: Text(
              message['text'] as String,
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatMessageCtrl,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final text = _chatMessageCtrl.text.trim();
              if (text.isEmpty || _selectedContact == null) return;
              setState(() {
                _chatMessages[_selectedContact!]!.add({
                  'sender': 'me',
                  'text': text,
                });
                _chatMessageCtrl.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, RiderTab activeTab) {
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
                'Home',
                Icons.home,
                RiderTab.home,
                activeTab == RiderTab.home,
              ),
              _buildNavItem(
                context,
                'History',
                Icons.history,
                RiderTab.history,
                activeTab == RiderTab.history,
              ),
              _buildNavItem(
                context,
                'Settle',
                Icons.account_balance_wallet,
                RiderTab.settle,
                activeTab == RiderTab.settle,
              ),
              _buildNavItem(
                context,
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
                color: isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
