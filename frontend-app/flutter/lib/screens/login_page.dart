import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

enum _UserType { rider, driver, manager }

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const LoginPage({super.key, required this.onBack});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  _UserType _userType = _UserType.rider;

  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  // Quick login state
  Map<String, dynamic>? _quickRider;
  Map<String, dynamic>? _quickDriver;
  bool _loadingQuick = true;
  bool _quickLoginLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuickUsers();
  }

  Future<void> _loadQuickUsers() async {
    try {
      final riders  = await apiService.getRiders();
      final drivers = await apiService.getDrivers();
      if (!mounted) return;
      setState(() {
        _quickRider  = riders.isNotEmpty  ? riders.first  as Map<String, dynamic> : null;
        _quickDriver = drivers.isNotEmpty ? drivers.first as Map<String, dynamic> : null;
        _loadingQuick = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingQuick = false);
    }
  }

  Future<void> _quickLogin(Map<String, dynamic> user, _UserType type) async {
    setState(() => _quickLoginLoading = true);
    final auth = ref.read(authProvider.notifier);
    try {
      if (type == _UserType.rider) {
        await auth.loginAsRider(
          user['name'] ?? '',
          user['email'] ?? '',
          user['phone'] ?? '',
        );
      } else {
        await auth.loginAsDriver(
          user['name'] ?? '',
          user['email'] ?? '',
          user['phone'] ?? '',
          user['licenseNumber'] ?? '',
        );
      }
    } finally {
      if (mounted) setState(() => _quickLoginLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider.notifier);
    if (_userType == _UserType.rider) {
      await auth.loginAsRider(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
      );
    } else if (_userType == _UserType.driver) {
      await auth.loginAsDriver(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _licenseCtrl.text.trim(),
      );
    } else {
      await auth.loginAsManager(_nameCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.loading || _quickLoginLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 24),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in or register to continue',
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quick Login ──────────────────────────────────
                _buildQuickLoginSection(isLoading),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or sign in manually',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),
                const SizedBox(height: 20),

                // Role toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _toggle('Rider', Icons.person, _UserType.rider)),
                      const SizedBox(width: 4),
                      Expanded(child: _toggle('Driver', Icons.directions_car, _UserType.driver)),
                      const SizedBox(width: 4),
                      Expanded(child: _toggle('Manager', Icons.admin_panel_settings, _UserType.manager)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (auth.error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFDC2626), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(auth.error!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFDC2626))),
                              ),
                            ],
                          ),
                        ),
                      _field('Full Name', Icons.person_outline, _nameCtrl,
                          hint: 'Your full name'),
                      const SizedBox(height: 14),
                      _field('Email', Icons.email_outlined, _emailCtrl,
                          hint: 'you@email.com',
                          keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _field('Phone', Icons.phone_outlined, _phoneCtrl,
                          hint: '+1 234 567 8900',
                          keyboard: TextInputType.phone),
                      if (_userType == _UserType.driver) ...[
                        const SizedBox(height: 14),
                        _field('License Number', Icons.badge_outlined,
                            _licenseCtrl,
                            hint: 'e.g. DL-123456'),
                      ],
                      if (_userType == _UserType.manager) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Color(0xFFF59E0B)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Manager access — can view and settle all payments.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  'Continue as ${_userType == _UserType.rider ? 'Rider' : _userType == _UserType.driver ? 'Driver' : 'Manager'}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'New users are registered automatically',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            const Text(
              'Quick Login',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151)),
            ),
            const Spacer(),
            if (_loadingQuick)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF2563EB)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (!_loadingQuick && _quickRider == null && _quickDriver == null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No users in database yet. Use the form below to register.',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              if (_quickRider != null)
                Expanded(
                  child: _buildQuickCard(
                    _quickRider!,
                    _UserType.rider,
                    const Color(0xFF2563EB),
                    Icons.person,
                    isLoading,
                  ),
                ),
              if (_quickRider != null && _quickDriver != null)
                const SizedBox(width: 12),
              if (_quickDriver != null)
                Expanded(
                  child: _buildQuickCard(
                    _quickDriver!,
                    _UserType.driver,
                    const Color(0xFF10B981),
                    Icons.directions_car,
                    isLoading,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickCard(
    Map<String, dynamic> user,
    _UserType type,
    Color color,
    IconData icon,
    bool isLoading,
  ) {
    final name  = (user['name'] ?? '') as String;
    final email = (user['email'] ?? '') as String;
    final label = type == _UserType.rider ? 'Rider' : 'Driver';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : label[0];

    return GestureDetector(
      onTap: isLoading ? null : () => _quickLogin(user, type),
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                name.isNotEmpty ? name : label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Email
              Text(
                email,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Login as $label',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, IconData icon, _UserType type) {
    final selected = _userType == type;
    return GestureDetector(
      onTap: () => setState(() => _userType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC2626))),
          ),
        ),
      ],
    );
  }
}
