# DriveApp Flutter - React to Flutter Conversion

This directory contains the Flutter conversion of the DriveApp ride-sharing application originally built in React.

## 🎯 Conversion Overview

### Completed Components ✅
1. **main.dart** - App entry point with Riverpod state management  
2. **screens/landing_page.dart** - Full landing page with hero section, features, and stats
3. **screens/login_page.dart** - Login page with driver/rider toggle and dual email/phone input
4. **screens/driver/driver_main.dart** - Driver dashboard with bottom navigation
5. **models/ride.dart** - Ride data model with mock data
6. **pubspec.yaml** - All required dependencies configured

### To Be Implemented 🔄
- `screens/driver/rides_page.dart` - Available rides with list/map view toggle
- `screens/driver/trip_page.dart` - Trip history with filtering
- `screens/driver/driver_profile_page.dart` - Editable driver profile
- `screens/rider/rider_main.dart` - Rider dashboard container
- `screens/rider/home_page.dart` - Ride booking interface
- `screens/rider/history_page.dart` - Ride history
- `screens/rider/settle_page.dart` - Payments and wallet
- `screens/rider/rider_profile_page.dart` - Editable rider profile

## 📦 Installation

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Dart 3.2.0 or higher

### Steps

1. **Create a new Flutter project:**
```bash
flutter create driveapp
cd driveapp
```

2. **Replace pubspec.yaml:**
Copy the `pubspec.yaml` from this directory to your project root

3. **Install dependencies:**
```bash
flutter pub get
```

4. **Copy source files:**
Copy all `.dart` files from this directory into your `lib/` folder:
```
cp -r flutter/screens lib/
cp -r flutter/models lib/
cp flutter/main.dart lib/
```

5. **Run the app:**
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry & navigation
├── screens/
│   ├── landing_page.dart          # Marketing landing page
│   ├── login_page.dart            # Auth with role toggle
│   ├── driver/
│   │   ├── driver_main.dart       # Driver container
│   │   ├── rides_page.dart        # Available rides (TODO)
│   │   ├── trip_page.dart         # Trip history (TODO)
│   │   └── driver_profile_page.dart # Profile (TODO)
│   └── rider/
│       ├── rider_main.dart        # Rider container (TODO)
│       ├── home_page.dart         # Booking (TODO)
│       ├── history_page.dart      # History (TODO)
│       ├── settle_page.dart       # Payments (TODO)
│       └── rider_profile_page.dart # Profile (TODO)
└── models/
    └── ride.dart                  # Data models
```

## 🎨 Key Conversion Patterns

### State Management
**React (useState):**
```javascript
const [activeTab, setActiveTab] = useState('rides');
setActiveTab('trip');
```

**Flutter (Riverpod):**
```dart
final activeTabProvider = StateProvider<DriverTab>((ref) => DriverTab.rides);

// Read value
final activeTab = ref.watch(activeTabProvider);

// Update value
ref.read(activeTabProvider.notifier).state = DriverTab.trip;
```

### Navigation
**React:**
```javascript
<button onClick={() => setCurrentPage('login')}>Sign In</button>
```

**Flutter:**
```dart
ElevatedButton(
  onPressed: () => ref.read(appPageProvider.notifier).state = AppPage.login,
  child: Text('Sign In'),
)
```

### Styling
**React (Tailwind CSS):**
```jsx
<div className="bg-blue-600 text-white p-4 rounded-lg shadow-lg">
```

**Flutter:**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFF2563EB),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white),
  ),
)
```

## 🎨 Design System

### Colors
```dart
// Primary
Color(0xFF2563EB)  // blue-600 - Primary actions
Color(0xFF1E40AF)  // blue-800 - Dark blue

// Grays
Color(0xFF111827)  // gray-900 - Headings
Color(0xFF374151)  // gray-700 - Body text
Color(0xFF6B7280)  // gray-500 - Secondary text
Color(0xFFF9FAFB)  // gray-50 - Background

// Accents
Color(0xFF16A34A)  // green-600 - Success
Color(0xFFDC2626)  // red-600 - Error
Color(0xFFF59E0B)  // amber-500 - Warning
Color(0xFF9333EA)  // purple-600 - Premium
```

### Typography
- **Font Family:** Inter (via Google Fonts)
- **Heading:** FontWeight.bold (700)
- **Body:** FontWeight.normal (400)
- **Button:** FontWeight.w600 (600)

## 📱 Features

### Implemented ✅
- ✅ Landing page with hero section and driver benefits
- ✅ Login with driver/rider role toggle
- ✅ Dual email/phone input field
- ✅ Gradient backgrounds matching React design
- ✅ Bottom navigation for driver/rider
- ✅ Riverpod state management
- ✅ Mobile-optimized layouts

### To Implement 🔄
- 🔄 Available rides list with map view
- 🔄 Trip history with filtering (Complete, Cancelled, In Progress, Scheduled)
- 🔄 Editable driver/rider profiles
- 🔄 Ride booking interface
- 🔄 Payment and wallet management
- 🔄 Real-time location tracking
- 🔄 Push notifications
- 🔄 Backend integration (Firebase/Supabase)

## 🚀 Next Steps

### Phase 1: Complete Driver Interface
1. Create `rides_page.dart` with:
   - List view of available rides
   - Map view toggle
   - Ride detail bottom sheet
   - Accept/decline actions

2. Create `trip_page.dart` with:
   - Trip history cards
   - Status filtering (All, Complete, In Progress, etc.)
   - Ride Again functionality
   - Empty state

3. Create `driver_profile_page.dart` with:
   - Editable profile fields
   - Vehicle information
   - Statistics
   - Menu items

### Phase 2: Complete Rider Interface
1. Create `rider_main.dart` (similar to driver_main.dart)
2. Create `home_page.dart` with ride booking
3. Create `history_page.dart` with trip history
4. Create `settle_page.dart` with payments
5. Create `rider_profile_page.dart` with profile

### Phase 3: Backend Integration
1. Set up Firebase or Supabase
2. Implement authentication
3. Add real-time database
4. Implement push notifications
5. Add payment gateway

### Phase 4: Advanced Features
1. Google Maps integration
2. Real-time location tracking
3. In-app messaging
4. Rating system
5. Promo codes

## 📚 Dependencies

```yaml
flutter_riverpod: ^2.4.9   # State management (replaces React hooks)
google_fonts: ^6.1.0        # Typography (Inter font)
lucide_icons: ^0.1.0        # Icons (replaces lucide-react)
intl: ^0.18.1               # Date/number formatting
```

### Recommended Additional Dependencies
```yaml
# Navigation
go_router: ^12.0.0

# Maps
google_maps_flutter: ^2.5.0

# HTTP
dio: ^5.4.0

# Local Storage
shared_preferences: ^2.2.2
hive: ^2.2.3

# Image Caching
cached_network_image: ^3.3.0
```

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Widget Test Example
```dart
testWidgets('Landing page shows Get Started button', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: LandingPage(
        onGetStarted: () {},
        onSignIn: () {},
      )),
    ),
  );
  
  expect(find.text('Get Started'), findsOneWidget);
});
```

## 🐛 Debugging

### Common Issues

**1. "setState called after dispose"**
```dart
// Solution: Check if widget is mounted
if (mounted) {
  setState(() {
    // Update state
  });
}
```

**2. "RenderBox overflow"**
```dart
// Solution: Wrap in SingleChildScrollView or Expanded
SingleChildScrollView(
  child: Column(
    children: [/* widgets */],
  ),
)
```

**3. "Provider not found"**
```dart
// Solution: Ensure widget is wrapped in ProviderScope
runApp(
  ProviderScope(  // <- Important!
    child: DriveApp(),
  ),
);
```

## 📖 Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Riverpod Guide**: https://riverpod.dev
- **Material Design 3**: https://m3.material.io
- **React to Flutter Guide**: https://docs.flutter.dev/get-started/flutter-for/react-native-devs

## 🤝 Contributing

When continuing this conversion:
1. Follow the existing patterns (Riverpod for state, consistent styling)
2. Match the React design as closely as possible
3. Use the color constants from the design system
4. Add comments for complex logic
5. Test on both iOS and Android simulators

## 📄 License

This is a conversion of the DriveApp React application for demonstration purposes.

---

**Conversion Progress:** 40% Complete  
**Last Updated:** January 27, 2026  
**Flutter Version:** 3.16.0+  
**Dart Version:** 3.2.0+
