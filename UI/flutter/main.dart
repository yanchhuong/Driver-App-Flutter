import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/driver/driver_main.dart';
import 'screens/rider/rider_main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: DriveApp()));
}

class DriveApp extends StatelessWidget {
  const DriveApp({Key? key}) : super(key: key);

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

// App navigation state
enum AppPage { landing, login, driverMain, riderMain }

final appPageProvider = StateProvider<AppPage>((ref) => AppPage.landing);

class AppNavigator extends ConsumerWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(appPageProvider);

    switch (currentPage) {
      case AppPage.login:
        return LoginPage(
          onBack: () => ref.read(appPageProvider.notifier).state = AppPage.landing,
          onLoginSuccess: (userType) {
            if (userType == UserType.driver) {
              ref.read(appPageProvider.notifier).state = AppPage.driverMain;
            } else {
              ref.read(appPageProvider.notifier).state = AppPage.riderMain;
            }
          },
        );
      case AppPage.driverMain:
        return DriverMain(
          onLogout: () => ref.read(appPageProvider.notifier).state = AppPage.landing,
        );
      case AppPage.riderMain:
        return RiderMain(
          onLogout: () => ref.read(appPageProvider.notifier).state = AppPage.landing,
        );
      case AppPage.landing:
      default:
        return LandingPage(
          onGetStarted: () => ref.read(appPageProvider.notifier).state = AppPage.login,
          onSignIn: () => ref.read(appPageProvider.notifier).state = AppPage.login,
        );
    }
  }
}

enum UserType { driver, rider }
