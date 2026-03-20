import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'ride_confirmation_page.dart';

// ── Ride type enum & provider ──
enum _RideType { economy, standard, premium }

final _rideTypeProvider = StateProvider<_RideType>((_) => _RideType.standard);

// ── Data models ──

class _CompanyCard {
  final int id;
  final String logo;
  final String name;
  final String tagline;
  final String description;
  final List<Color> gradientColors;
  final _CompanyProfile fullProfile;

  const _CompanyCard({
    required this.id,
    required this.logo,
    required this.name,
    required this.tagline,
    required this.description,
    required this.gradientColors,
    required this.fullProfile,
  });
}

class _CompanyProfile {
  final String founded;
  final String headquarters;
  final String employees;
  final String cities;
  final String rides;
  final String rating;
  final String mission;
  final List<String> achievements;
  final List<String> services;

  const _CompanyProfile({
    required this.founded,
    required this.headquarters,
    required this.employees,
    required this.cities,
    required this.rides,
    required this.rating,
    required this.mission,
    required this.achievements,
    required this.services,
  });
}

class _RideOption {
  final _RideType id;
  final String name;
  final String description;
  final String price;
  final String time;
  final String capacity;
  final IconData icon;

  const _RideOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.time,
    required this.capacity,
    required this.icon,
  });
}

class _RecentPlace {
  final String name;
  final String address;
  final IconData icon;

  const _RecentPlace({
    required this.name,
    required this.address,
    required this.icon,
  });
}

class _PopularDestination {
  final String name;
  final String address;
  final IconData icon;
  final String category;

  const _PopularDestination({
    required this.name,
    required this.address,
    required this.icon,
    required this.category,
  });
}

// ── Constants ──

const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);

const _companyCards = <_CompanyCard>[
  _CompanyCard(
    id: 1,
    logo: '\u{1F697}', // 🚗
    name: 'DriveApp',
    tagline: 'Your trusted ride partner',
    description: 'Safe, reliable, and affordable rides anytime',
    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    fullProfile: _CompanyProfile(
      founded: '2018',
      headquarters: 'San Francisco, CA',
      employees: '10,000+',
      cities: '500+ cities worldwide',
      rides: '1 Billion+ completed rides',
      rating: '4.8/5.0',
      mission:
          'To provide safe, reliable, and affordable transportation to everyone, everywhere.',
      achievements: [
        'Best Ride-Sharing App 2025',
        '50M+ Happy Customers',
        'Operating in 80+ Countries',
        'Carbon-Neutral by 2026',
      ],
      services: [
        'Economy Rides',
        'Premium Rides',
        'Food Delivery',
        'Package Delivery',
      ],
    ),
  ),
  _CompanyCard(
    id: 2,
    logo: '\u{2B50}', // ⭐
    name: 'Premium Service',
    tagline: '5-star rated drivers',
    description: 'Experience luxury with our top-rated drivers',
    gradientColors: [Color(0xFFA855F7), Color(0xFF9333EA)],
    fullProfile: _CompanyProfile(
      founded: '2019',
      headquarters: 'New York, NY',
      employees: '5,000+',
      cities: '200+ cities worldwide',
      rides: '100M+ premium rides',
      rating: '4.9/5.0',
      mission:
          'Redefining luxury transportation with exceptional service and top-tier vehicles.',
      achievements: [
        'Certified Professional Drivers',
        'Luxury Fleet Only',
        '99% Customer Satisfaction',
        'Award-Winning Service',
      ],
      services: [
        'Executive Rides',
        'Airport Service',
        'Corporate Transportation',
        'Special Events',
      ],
    ),
  ),
  _CompanyCard(
    id: 3,
    logo: '\u{1F48E}', // 💎
    name: 'Best Prices',
    tagline: 'Save more on every ride',
    description: 'Competitive rates with exclusive deals',
    gradientColors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    fullProfile: _CompanyProfile(
      founded: '2020',
      headquarters: 'Austin, TX',
      employees: '3,000+',
      cities: '300+ cities',
      rides: '250M+ budget-friendly rides',
      rating: '4.7/5.0',
      mission:
          'Making transportation accessible and affordable for everyone without compromising quality.',
      achievements: [
        'Lowest Prices Guaranteed',
        'Daily Promo Codes',
        'Flexible Payment Options',
        'User-Friendly App',
      ],
      services: [
        'Economy Rides',
        'Shared Rides',
        'Student Discounts',
        'Senior Discounts',
      ],
    ),
  ),
  _CompanyCard(
    id: 4,
    logo: '\u{1F3AF}', // 🎯
    name: '24/7 Support',
    tagline: 'Always here for you',
    description: 'Round-the-clock customer assistance',
    gradientColors: [Color(0xFFF97316), Color(0xFFEA580C)],
    fullProfile: _CompanyProfile(
      founded: '2017',
      headquarters: 'Seattle, WA',
      employees: '8,000+',
      cities: '400+ cities',
      rides: '500M+ rides with support',
      rating: '4.9/5.0',
      mission:
          'Ensuring every customer feels valued and supported throughout their journey.',
      achievements: [
        '24/7 Live Support',
        '2-Minute Response Time',
        'Multilingual Support',
        'Safety First Approach',
      ],
      services: [
        'Customer Support',
        'Emergency Assistance',
        'Lost & Found',
        'Safety Monitoring',
      ],
    ),
  ),
];

final _rideOptions = <_RideOption>[
  const _RideOption(
    id: _RideType.economy,
    name: 'Economy',
    description: 'Affordable rides',
    price: '\$12.50',
    time: '3 min',
    capacity: '4 seats',
    icon: Icons.directions_car_outlined,
  ),
  const _RideOption(
    id: _RideType.standard,
    name: 'Standard',
    description: 'Comfortable ride',
    price: '\$18.50',
    time: '2 min',
    capacity: '4 seats',
    icon: Icons.directions_car_filled,
  ),
  const _RideOption(
    id: _RideType.premium,
    name: 'Premium',
    description: 'Luxury experience',
    price: '\$28.00',
    time: '5 min',
    capacity: '4 seats',
    icon: Icons.auto_awesome,
  ),
];

final _recentPlaces = <_RecentPlace>[
  const _RecentPlace(name: 'Home', address: '123 Main St, Downtown', icon: Icons.home_outlined),
  const _RecentPlace(
      name: 'Work',
      address: '456 Business Ave, Corporate Center',
      icon: Icons.work_outline),
  const _RecentPlace(
      name: 'Airport',
      address: 'International Airport Terminal 1',
      icon: Icons.flight_outlined),
];

final _popularDestinations = <_PopularDestination>[
  const _PopularDestination(
      name: 'Shopping Mall',
      address: 'Central Plaza Mall, 5th Avenue',
      icon: Icons.shopping_bag_outlined,
      category: 'Shopping'),
  const _PopularDestination(
      name: 'City Hospital',
      address: 'General Hospital, Medical District',
      icon: Icons.local_hospital_outlined,
      category: 'Healthcare'),
  const _PopularDestination(
      name: 'Train Station',
      address: 'Central Station, Railway St',
      icon: Icons.train_outlined,
      category: 'Transport'),
  const _PopularDestination(
      name: 'Downtown',
      address: 'Downtown Business District',
      icon: Icons.business_outlined,
      category: 'Business'),
  const _PopularDestination(
      name: 'Beach',
      address: 'Sunset Beach, Coastal Road',
      icon: Icons.beach_access_outlined,
      category: 'Leisure'),
  const _PopularDestination(
      name: 'Restaurant District',
      address: 'Food Street, Culinary Quarter',
      icon: Icons.restaurant_outlined,
      category: 'Dining'),
  const _PopularDestination(
      name: 'University',
      address: 'State University Campus',
      icon: Icons.school_outlined,
      category: 'Education'),
  const _PopularDestination(
      name: 'Stadium',
      address: 'City Sports Stadium',
      icon: Icons.stadium_outlined,
      category: 'Sports'),
];

// ══════════════════════════════════════════════════════════════════
// ██  HomePage
// ══════════════════════════════════════════════════════════════════

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _pickupCtrl = TextEditingController(text: 'Current Location');
  final _dropoffCtrl = TextEditingController();

  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();

  bool _showPickupSuggestions = false;
  bool _showDropoffSuggestions = false;

  // Company carousel
  late final PageController _carouselController;
  int _currentSlide = 0;
  Timer? _slideTimer;

  // Company details modal
  bool _showCompanyDetails = false;
  int _selectedCompanyIndex = 0;

  // Pickup autocomplete from API
  List<_PlaceSuggestion> _pickupApiSuggestions = [];
  bool _pickupLoading = false;
  Timer? _pickupDebounce;

  // Dropoff autocomplete from API
  List<_PlaceSuggestion> _dropoffApiSuggestions = [];
  bool _dropoffLoading = false;
  Timer? _dropoffDebounce;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _startAutoSlide();

    _pickupFocus.addListener(() {
      if (_pickupFocus.hasFocus) {
        setState(() => _showPickupSuggestions = true);
      }
    });
    _dropoffFocus.addListener(() {
      if (_dropoffFocus.hasFocus) {
        setState(() => _showDropoffSuggestions = true);
      }
    });

    _pickupCtrl.addListener(_onPickupChanged);
    _dropoffCtrl.addListener(_onDropoffChanged);
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _carouselController.dispose();
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    _pickupDebounce?.cancel();
    _dropoffDebounce?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _slideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentSlide + 1) % _companyCards.length;
      setState(() => _currentSlide = next);
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Pickup autocomplete ──
  void _onPickupChanged() {
    final query = _pickupCtrl.text.trim();
    if (query.length < 3 || query == 'Current Location') {
      setState(() {
        _pickupApiSuggestions = [];
      });
      return;
    }
    _pickupDebounce?.cancel();
    _pickupDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query, isPickup: true);
    });
  }

  // ── Dropoff autocomplete ──
  void _onDropoffChanged() {
    final query = _dropoffCtrl.text.trim();
    if (query.length < 3) {
      setState(() {
        _dropoffApiSuggestions = [];
      });
      return;
    }
    _dropoffDebounce?.cancel();
    _dropoffDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query, isPickup: false);
    });
  }

  Future<void> _fetchSuggestions(String query,
      {required bool isPickup}) async {
    if (!mounted) return;
    setState(() {
      if (isPickup) {
        _pickupLoading = true;
      } else {
        _dropoffLoading = true;
      }
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'DriverAndRiderApp/1.0',
      }).timeout(const Duration(seconds: 8));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final results = data
            .map((item) => _PlaceSuggestion(
                  displayName: item['display_name'] as String,
                  shortName: _buildShortName(item),
                  lat: double.tryParse(item['lat'].toString()) ?? 0.0,
                  lon: double.tryParse(item['lon'].toString()) ?? 0.0,
                ))
            .toList();
        setState(() {
          if (isPickup) {
            _pickupApiSuggestions = results;
          } else {
            _dropoffApiSuggestions = results;
          }
        });
      }
    } catch (_) {
      // silently ignore network errors
    } finally {
      if (mounted) {
        setState(() {
          if (isPickup) {
            _pickupLoading = false;
          } else {
            _dropoffLoading = false;
          }
        });
      }
    }
  }

  String _buildShortName(Map item) {
    final addr = item['address'] as Map?;
    if (addr == null) return item['display_name'] as String;
    final parts = <String>[];
    for (final key in [
      'road', 'suburb', 'city', 'town', 'village', 'county', 'country'
    ]) {
      final v = addr[key];
      if (v != null && v.toString().isNotEmpty) parts.add(v.toString());
      if (parts.length >= 3) break;
    }
    return parts.isNotEmpty
        ? parts.join(', ')
        : item['display_name'] as String;
  }

  // ── Filter popular destinations ──
  List<_PopularDestination> _filterDestinations(String query) {
    if (query.isEmpty || query == 'Current Location') {
      return _popularDestinations;
    }
    final q = query.toLowerCase();
    return _popularDestinations
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.address.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q))
        .toList();
  }

  void _selectPickup(String address) {
    _pickupCtrl.removeListener(_onPickupChanged);
    _pickupCtrl.text = address;
    _pickupCtrl.addListener(_onPickupChanged);
    setState(() {
      _showPickupSuggestions = false;
      _pickupApiSuggestions = [];
    });
    _pickupFocus.unfocus();
  }

  void _selectDropoff(String address) {
    _dropoffCtrl.removeListener(_onDropoffChanged);
    _dropoffCtrl.text = address;
    _dropoffCtrl.addListener(_onDropoffChanged);
    setState(() {
      _showDropoffSuggestions = false;
      _dropoffApiSuggestions = [];
    });
    _dropoffFocus.unfocus();
  }

  void _goToConfirmation() {
    if (_pickupCtrl.text.trim().isEmpty ||
        _dropoffCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup and dropoff locations')),
      );
      return;
    }

    final rideType = ref.read(_rideTypeProvider);
    final option = _rideOptions.firstWhere((o) => o.id == rideType);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideConfirmationPage(
          pickup: _pickupCtrl.text.trim(),
          dropoff: _dropoffCtrl.text.trim(),
          tripType: 'RIDE',
          fareAmount: double.tryParse(
              option.price.replaceAll('\$', '').replaceAll(',', '')),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final rideType = ref.watch(_rideTypeProvider);
    final hasDropoff = _dropoffCtrl.text.trim().isNotEmpty;

    return Stack(
      children: [
        // Main scrollable content
        CustomScrollView(
          slivers: [
            // ── Company carousel area ──
            SliverToBoxAdapter(child: _buildCarousel()),

            // ── Booking card ──
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pull handle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),

                            // ── Location inputs ──
                            _buildPickupField(),
                            const SizedBox(height: 12),
                            _buildDropoffField(),
                            const SizedBox(height: 16),

                            // ── Recent places (when no dropoff) ──
                            if (!hasDropoff) _buildRecentPlaces(),

                            // ── Ride options (when dropoff entered) ──
                            if (hasDropoff) _buildRideOptions(rideType),

                            // Bottom padding for fixed button
                            if (hasDropoff) const SizedBox(height: 140),
                            if (!hasDropoff) const SizedBox(height: 20),
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

        // ── Fixed bottom button bar ──
        if (hasDropoff) _buildBottomBar(),

        // ── Company details modal ──
        if (_showCompanyDetails) _buildCompanyDetailsModal(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  CAROUSEL
  // ══════════════════════════════════════════════════════════════

  Widget _buildCarousel() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDBEAFE), Color(0xFFDCFCE7)],
        ),
      ),
      child: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _carouselController,
            itemCount: _companyCards.length,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemBuilder: (context, index) {
              final card = _companyCards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                child: _buildCompanySlide(card, index),
              );
            },
          ),

          // Dots
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_companyCards.length, (i) {
                final active = i == _currentSlide;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentSlide = i);
                    _carouselController.animateToPage(i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySlide(_CompanyCard card, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: card.gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(card.logo,
                    style: const TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: 14),
            Text(card.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(card.tagline,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 6),
            Text(card.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 14),
            // Show Details button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCompanyIndex = index;
                  _showCompanyDetails = true;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3)),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Show Details',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  PICKUP FIELD
  // ══════════════════════════════════════════════════════════════

  Widget _buildPickupField() {
    final filteredPopular = _filterDestinations(_pickupCtrl.text);
    final showDropdown = _showPickupSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        TextField(
          controller: _pickupCtrl,
          focusNode: _pickupFocus,
          onTap: () => setState(() => _showPickupSuggestions = true),
          decoration: InputDecoration(
            hintText: 'Pickup location',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: _kBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: _pickupLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF9CA3AF)),
                    ),
                  )
                : IconButton(
                    icon: const Icon(LucideIcons.search,
                        size: 20, color: _kBlue),
                    onPressed: () {},
                  ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBlue, width: 2)),
          ),
        ),

        // Suggestions dropdown
        if (showDropdown)
          _buildPickupDropdown(filteredPopular),
      ],
    );
  }

  Widget _buildPickupDropdown(List<_PopularDestination> filteredPopular) {
    final isSearch = _pickupCtrl.text.isNotEmpty &&
        _pickupCtrl.text != 'Current Location';

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFE8EAF6)],
                ),
                border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.navigation,
                      size: 14, color: _kBlue),
                  const SizedBox(width: 8),
                  Text(
                    isSearch ? 'Search Results' : 'Pickup Locations',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F)),
                  ),
                  const Spacer(),
                  if (isSearch)
                    Text(
                      '${filteredPopular.length + 1 + _pickupApiSuggestions.length} found',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                ],
              ),
            ),

            // Current Location option
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Color(0xFFDBEAFE), width: 2)),
              ),
              child: Material(
                color: _pickupCtrl.text == 'Current Location'
                    ? const Color(0xFFEFF6FF)
                    : Colors.transparent,
                child: InkWell(
                  onTap: () => _selectPickup('Current Location'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Icon with optional check
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(LucideIcons.navigation,
                                  size: 20, color: _kBlue),
                            ),
                            if (_pickupCtrl.text == 'Current Location')
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: _kBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      LucideIcons.checkCircle,
                                      size: 10,
                                      color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Current Location',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827))),
                                  if (_pickupCtrl.text ==
                                      'Current Location') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _kBlue,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Text('Active',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text('Use my current GPS location',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('GPS',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _kGreen,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // API suggestions
            ..._pickupApiSuggestions.map((s) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectPickup(s.shortName),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(s.shortName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text(s.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            // Popular destinations
            ...filteredPopular.map((dest) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectPickup(dest.address),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFF3F4F6))),
                      ),
                      child: Row(
                        children: [
                          Icon(dest.icon,
                              size: 22, color: const Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(dest.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text(dest.address,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(dest.category,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280))),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            // No results
            if (filteredPopular.isEmpty &&
                _pickupApiSuggestions.isEmpty &&
                _pickupCtrl.text != 'Current Location')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(LucideIcons.search,
                        size: 32, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('No locations found',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    const Text('Try a different search term',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  DROPOFF FIELD
  // ══════════════════════════════════════════════════════════════

  Widget _buildDropoffField() {
    final filteredPopular = _filterDestinations(_dropoffCtrl.text);
    final showDropdown = _showDropoffSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _dropoffCtrl,
          focusNode: _dropoffFocus,
          onTap: () => setState(() => _showDropoffSuggestions = true),
          decoration: InputDecoration(
            hintText: 'Where to?',
            prefixIcon: const Icon(LucideIcons.mapPin,
                size: 16, color: _kRed),
            suffixIcon: _dropoffLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF9CA3AF)),
                    ),
                  )
                : (_dropoffCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.mapPin,
                            size: 20, color: _kBlue),
                        onPressed: () {},
                      )
                    : null),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBlue, width: 2)),
          ),
        ),
        if (showDropdown) _buildDropoffDropdown(filteredPopular),
      ],
    );
  }

  Widget _buildDropoffDropdown(List<_PopularDestination> filteredPopular) {
    final hasQuery = _dropoffCtrl.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            // Header
            if (!hasQuery)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFE8EAF6)],
                  ),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.trendingUp,
                        size: 14, color: _kBlue),
                    SizedBox(width: 8),
                    Text('Popular Destinations',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A5F))),
                  ],
                ),
              ),

            if (hasQuery &&
                (filteredPopular.isNotEmpty ||
                    _dropoffApiSuggestions.isNotEmpty))
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: const Color(0xFFF9FAFB),
                child: Text(
                  '${filteredPopular.length + _dropoffApiSuggestions.length} result${filteredPopular.length + _dropoffApiSuggestions.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)),
                ),
              ),

            // API suggestions
            ..._dropoffApiSuggestions.map((s) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectDropoff(s.shortName),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(s.shortName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text(s.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            // Popular / filtered destinations
            ...filteredPopular.map((dest) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectDropoff(dest.address),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFF3F4F6))),
                      ),
                      child: Row(
                        children: [
                          Icon(dest.icon,
                              size: 22, color: const Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(dest.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text(dest.address,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(dest.category,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280))),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            // No results
            if (filteredPopular.isEmpty &&
                _dropoffApiSuggestions.isEmpty &&
                hasQuery)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(LucideIcons.search,
                        size: 32, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('No destinations found',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    const Text('Try a different search term',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  RECENT PLACES
  // ══════════════════════════════════════════════════════════════

  Widget _buildRecentPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Places',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        ..._recentPlaces.map((place) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _selectDropoff(place.address);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(place.icon,
                            size: 24, color: const Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(place.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827))),
                              const SizedBox(height: 2),
                              Text(place.address,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  RIDE OPTIONS
  // ══════════════════════════════════════════════════════════════

  Widget _buildRideOptions(_RideType selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a ride',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 12),
        ..._rideOptions.map((option) {
          final isSelected = option.id == selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isSelected
                  ? const Color(0xFFEFF6FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    ref.read(_rideTypeProvider.notifier).state =
                        option.id,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _kBlue
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(option.icon,
                          size: 28,
                          color: isSelected
                              ? _kBlue
                              : const Color(0xFF6B7280)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(option.name,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color(0xFF111827))),
                                const SizedBox(width: 8),
                                Icon(LucideIcons.clock,
                                    size: 12,
                                    color: Colors.grey.shade400),
                                const SizedBox(width: 2),
                                Text(option.time,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            Color(0xFF6B7280))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                                '${option.description} \u2022 ${option.capacity}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Text(option.price,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827))),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  BOTTOM BAR (Next + Schedule)
  // ══════════════════════════════════════════════════════════════

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
              top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _goToConfirmation,
                icon: const Icon(LucideIcons.arrowRight,
                    size: 20, color: Colors.white),
                label: const Text('Next',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Schedule for later - placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Schedule feature coming soon')),
                );
              },
              icon: const Icon(LucideIcons.clock,
                  size: 18, color: _kBlue),
              label: const Text('Schedule for later',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kBlue)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ██  COMPANY DETAILS MODAL
  // ══════════════════════════════════════════════════════════════

  Widget _buildCompanyDetailsModal() {
    final company = _companyCards[_selectedCompanyIndex];
    final profile = company.fullProfile;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () => setState(() => _showCompanyDetails = false),
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),

          // Modal
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints(
                maxWidth: 480,
                maxHeight:
                    MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Gradient header ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: company.gradientColors,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(company.logo,
                                  style: const TextStyle(fontSize: 52)),
                              GestureDetector(
                                onTap: () => setState(
                                    () => _showCompanyDetails = false),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(company.name,
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(company.tagline,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white
                                      .withValues(alpha: 0.9))),
                        ],
                      ),
                    ),

                    // ── Scrollable content ──
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Mission
                            _sectionTitle('Our Mission'),
                            const SizedBox(height: 8),
                            Text(profile.mission,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    height: 1.5)),
                            const SizedBox(height: 20),

                            // Info grid
                            _buildInfoGrid(profile),
                            const SizedBox(height: 20),

                            // Key stats
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEFF6FF),
                                      Color(0xFFF3E8FF)
                                    ]),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Rides',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Color(
                                                  0xFF6B7280))),
                                      const SizedBox(height: 4),
                                      Text(profile.rides,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: Color(
                                                  0xFF111827))),
                                    ],
                                  ),
                                  const Text('\u{1F697}',
                                      style:
                                          TextStyle(fontSize: 36)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Headquarters
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.mapPin,
                                      size: 16, color: _kBlue),
                                  const SizedBox(width: 8),
                                  const Text('Headquarters',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: Color(
                                              0xFF111827))),
                                  const Spacer(),
                                  Text(profile.headquarters,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(
                                              0xFF374151))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Achievements
                            _sectionTitle('Achievements'),
                            const SizedBox(height: 12),
                            ...profile.achievements.map((a) =>
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFF9FAFB),
                                      borderRadius:
                                          BorderRadius.circular(
                                              10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            LucideIcons.award,
                                            size: 16,
                                            color: Color(
                                                0xFFF59E0B)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(a,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(
                                                      0xFF374151))),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 20),

                            // Services
                            _sectionTitle('Our Services'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.services
                                  .map((s) => Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                              0xFFDBEAFE),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(20),
                                        ),
                                        child: Text(s,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color: Color(
                                                    0xFF1D4ED8))),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Footer close button ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Color(0xFFE5E7EB))),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(
                              () => _showCompanyDetails = false),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            backgroundColor:
                                company.gradientColors.first,
                          ),
                          child: const Text('Close',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827)));
  }

  Widget _buildInfoGrid(_CompanyProfile profile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _infoTile(
                    'Founded', profile.founded, const Color(0xFFEFF6FF),
                    labelColor: _kBlue)),
            const SizedBox(width: 12),
            Expanded(
              child: _infoTileWithIcon(
                'Rating',
                profile.rating,
                const Color(0xFFF3E8FF),
                labelColor: const Color(0xFF9333EA),
                trailingIcon: const Icon(LucideIcons.star,
                    size: 14, color: Color(0xFFEAB308)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _infoTile('Employees', profile.employees,
                    const Color(0xFFDCFCE7),
                    labelColor: _kGreen)),
            const SizedBox(width: 12),
            Expanded(
                child: _infoTile(
                    'Coverage', profile.cities, const Color(0xFFFFF7ED),
                    labelColor: const Color(0xFFEA580C),
                    valueFontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, Color bg,
      {Color labelColor = _kBlue, double valueFontSize = 14}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _infoTileWithIcon(String label, String value, Color bg,
      {Color labelColor = _kBlue, Widget? trailingIcon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (trailingIcon != null) ...[
                trailingIcon,
                const SizedBox(width: 4),
              ],
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Place suggestion model (shared with autocomplete) ──

class _PlaceSuggestion {
  final String displayName;
  final String shortName;
  final double lat;
  final double lon;

  const _PlaceSuggestion({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lon,
  });
}
