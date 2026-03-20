import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/driver/driver_main.dart';
import 'screens/rider/rider_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: DriveApp()));
}

class DriveApp extends StatelessWidget {
  const DriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    // Restore saved session on launch
    Future.microtask(() async {
      await ref.read(authProvider.notifier).restoreSession();
      if (mounted) setState(() => _restored = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_restored) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final auth = ref.watch(authProvider);

    if (auth.role == AuthRole.driver) {
      return DriverMain(onLogout: () => ref.read(authProvider.notifier).logout());
    }
    if (auth.role == AuthRole.rider) {
      return RiderMain(onLogout: () => ref.read(authProvider.notifier).logout());
    }

    // Not logged in — show landing or login
    return _LandingOrLogin();
  }
}

class _LandingOrLogin extends StatefulWidget {
  @override
  State<_LandingOrLogin> createState() => _LandingOrLoginState();
}

class _LandingOrLoginState extends State<_LandingOrLogin> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginPage(
        onBack: () => setState(() => _showLogin = false),
      );
    }
    return LandingPage(
      onGetStarted: () => setState(() => _showLogin = true),
      onSignIn: () => setState(() => _showLogin = true),
    );
  }
}
