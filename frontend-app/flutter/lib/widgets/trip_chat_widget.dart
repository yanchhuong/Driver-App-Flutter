import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/realtime_service.dart';

class TripChatWidget extends StatefulWidget {
  final int tripId;
  final int mySenderId;
  final String mySenderName;
  final String mySenderRole; // 'RIDER' or 'DRIVER'

  const TripChatWidget({
    super.key,
    required this.tripId,
    required this.mySenderId,
    required this.mySenderName,
    required this.mySenderRole,
  });

  @override
  State<TripChatWidget> createState() => _TripChatWidgetState();
}

class _TripChatWidgetState extends State<TripChatWidget> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _sending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Subscribe to real-time chat via Pusher
    RealtimeService.instance.subscribeChatChannel(widget.tripId, (msg) {
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    });

    // Polling fallback (every 5s)
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollMessages());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _pollTimer?.cancel();
    RealtimeService.instance.unsubscribeChatChannel(widget.tripId);
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final list = await apiService.getMessages(widget.tripId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(list.cast<Map<String, dynamic>>());
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _pollMessages() async {
    try {
      final list = await apiService.getMessages(widget.tripId);
      if (!mounted) return;
      final fetched = list.cast<Map<String, dynamic>>();
      if (fetched.length != _messages.length) {
        setState(() {
          _messages.clear();
          _messages.addAll(fetched);
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _ctrl.clear();

    try {
      final msg = await apiService.sendMessage(widget.tripId, {
        'senderId': widget.mySenderId,
        'senderName': widget.mySenderName,
        'senderRole': widget.mySenderRole,
        'content': text,
      });
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) _ctrl.text = text; // restore on failure
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isMe(Map<String, dynamic> msg) {
    final role = msg['senderRole'] as String?;
    final id   = msg['senderId'];
    return role == widget.mySenderRole &&
        (id == widget.mySenderId || id.toString() == widget.mySenderId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text('In-Trip Chat',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Message list
          SizedBox(
            height: 240,
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _MessageBubble(
                      msg: _messages[i],
                      isMe: _isMe(_messages[i]),
                    ),
                  ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Input row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _sending
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send_rounded),
                        color: const Color(0xFF2563EB),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          shape: const CircleBorder(),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final content    = msg['content'] as String? ?? '';
    final senderName = msg['senderName'] as String? ?? '';
    final timestamp  = msg['timestamp'] as String?;

    String timeLabel = '';
    if (timestamp != null) {
      try {
        final dt = DateTime.parse(timestamp).toLocal();
        timeLabel =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  senderName,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280)),
                ),
              ),
            Text(
              content,
              style: TextStyle(
                  fontSize: 13,
                  color: isMe ? Colors.white : const Color(0xFF111827)),
            ),
            if (timeLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  timeLabel,
                  style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF9CA3AF)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
