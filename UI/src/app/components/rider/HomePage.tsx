import { useState, useEffect } from 'react';
import { MapPin, Search, Clock, Star, ChevronDown, Navigation, Loader2, CheckCircle, User, TrendingUp, ArrowRight, Plus } from 'lucide-react';
import { RideConfirmationPage } from './RideConfirmationPage';

interface HomePageProps {
  onRideStarted?: () => void;
}

export function HomePage({ onRideStarted }: HomePageProps) {
  const [pickupLocation, setPickupLocation] = useState('Current Location');
  const [dropoffLocation, setDropoffLocation] = useState('');
  const [selectedService, setSelectedService] = useState('standard');
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [isFocused, setIsFocused] = useState(false);
  const [mapSearchQuery, setMapSearchQuery] = useState('');
  const [showMapSuggestions, setShowMapSuggestions] = useState(false);
  const [highlightMapPin, setHighlightMapPin] = useState(false);
  const [showPickupSuggestions, setShowPickupSuggestions] = useState(false);
  const [isPickupFocused, setIsPickupFocused] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [currentSlide, setCurrentSlide] = useState(0);
  const [showCompanyDetails, setShowCompanyDetails] = useState(false);
  const [selectedCompany, setSelectedCompany] = useState<number>(0);
  const [isPanelExpanded, setIsPanelExpanded] = useState(true);

  // Company slideshow data
  const companyCards = [
    {
      id: 1,
      logo: '🚗',
      name: 'DriveApp',
      tagline: 'Your trusted ride partner',
      description: 'Safe, reliable, and affordable rides anytime',
      gradient: 'from-blue-500 to-blue-600',
      fullProfile: {
        founded: '2018',
        headquarters: 'San Francisco, CA',
        employees: '10,000+',
        cities: '500+ cities worldwide',
        rides: '1 Billion+ completed rides',
        rating: '4.8/5.0',
        mission: 'To provide safe, reliable, and affordable transportation to everyone, everywhere.',
        achievements: [
          '🏆 Best Ride-Sharing App 2025',
          '⭐ 50M+ Happy Customers',
          '🌍 Operating in 80+ Countries',
          '💚 Carbon-Neutral by 2026'
        ],
        services: ['Economy Rides', 'Premium Rides', 'Food Delivery', 'Package Delivery']
      }
    },
    {
      id: 2,
      logo: '⭐',
      name: 'Premium Service',
      tagline: '5-star rated drivers',
      description: 'Experience luxury with our top-rated drivers',
      gradient: 'from-purple-500 to-purple-600',
      fullProfile: {
        founded: '2019',
        headquarters: 'New York, NY',
        employees: '5,000+',
        cities: '200+ cities worldwide',
        rides: '100M+ premium rides',
        rating: '4.9/5.0',
        mission: 'Redefining luxury transportation with exceptional service and top-tier vehicles.',
        achievements: [
          '👔 Certified Professional Drivers',
          '🚙 Luxury Fleet Only',
          '⭐ 99% Customer Satisfaction',
          '🎖️ Award-Winning Service'
        ],
        services: ['Executive Rides', 'Airport Service', 'Corporate Transportation', 'Special Events']
      }
    },
    {
      id: 3,
      logo: '💎',
      name: 'Best Prices',
      tagline: 'Save more on every ride',
      description: 'Competitive rates with exclusive deals',
      gradient: 'from-green-500 to-green-600',
      fullProfile: {
        founded: '2020',
        headquarters: 'Austin, TX',
        employees: '3,000+',
        cities: '300+ cities',
        rides: '250M+ budget-friendly rides',
        rating: '4.7/5.0',
        mission: 'Making transportation accessible and affordable for everyone without compromising quality.',
        achievements: [
          '💰 Lowest Prices Guaranteed',
          '🎁 Daily Promo Codes',
          '💳 Flexible Payment Options',
          '📱 User-Friendly App'
        ],
        services: ['Economy Rides', 'Shared Rides', 'Student Discounts', 'Senior Discounts']
      }
    },
    {
      id: 4,
      logo: '🎯',
      name: '24/7 Support',
      tagline: 'Always here for you',
      description: 'Round-the-clock customer assistance',
      gradient: 'from-orange-500 to-orange-600',
      fullProfile: {
        founded: '2017',
        headquarters: 'Seattle, WA',
        employees: '8,000+',
        cities: '400+ cities',
        rides: '500M+ rides with support',
        rating: '4.9/5.0',
        mission: 'Ensuring every customer feels valued and supported throughout their journey.',
        achievements: [
          '📞 24/7 Live Support',
          '⚡ 2-Minute Response Time',
          '🌐 Multilingual Support',
          '🛡️ Safety First Approach'
        ],
        services: ['Customer Support', 'Emergency Assistance', 'Lost & Found', 'Safety Monitoring']
      }
    }
  ];

  // Auto-slide effect
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % companyCards.length);
    }, 3000); // Change slide every 3 seconds

    return () => clearInterval(interval);
  }, [companyCards.length]);

  const handleNextClick = () => {
    setShowConfirmation(true);
  };

  const handleBackFromConfirmation = () => {
    setShowConfirmation(false);
  };

  const handleConfirmRide = () => {
    // Navigate to active ride page
    onRideStarted?.();
  };

  const rideOptions = [
    {
      id: 'economy',
      name: 'Economy',
      description: 'Affordable rides',
      price: '$12.50',
      time: '3 min',
      capacity: '4 seats',
      icon: '🚗'
    },
    {
      id: 'standard',
      name: 'Standard',
      description: 'Comfortable ride',
      price: '$18.50',
      time: '2 min',
      capacity: '4 seats',
      icon: '🚙'
    },
    {
      id: 'premium',
      name: 'Premium',
      description: 'Luxury experience',
      price: '$28.00',
      time: '5 min',
      capacity: '4 seats',
      icon: '✨'
    }
  ];

  // Get selected ride option details
  const selectedOption = rideOptions.find(opt => opt.id === selectedService) || rideOptions[1];

  const recentPlaces = [
    { name: 'Home', address: '123 Main St, Downtown', icon: '🏠' },
    { name: 'Work', address: '456 Business Ave, Corporate Center', icon: '💼' },
    { name: 'Airport', address: 'International Airport Terminal 1', icon: '✈️' }
  ];

  // Popular destinations and suggestions
  const popularDestinations = [
    { name: 'Shopping Mall', address: 'Central Plaza Mall, 5th Avenue', icon: '🛍️', category: 'Shopping' },
    { name: 'City Hospital', address: 'General Hospital, Medical District', icon: '🏥', category: 'Healthcare' },
    { name: 'Train Station', address: 'Central Station, Railway St', icon: '🚉', category: 'Transport' },
    { name: 'Downtown', address: 'Downtown Business District', icon: '🏢', category: 'Business' },
    { name: 'Beach', address: 'Sunset Beach, Coastal Road', icon: '🏖️', category: 'Leisure' },
    { name: 'Restaurant District', address: 'Food Street, Culinary Quarter', icon: '🍽️', category: 'Dining' },
    { name: 'University', address: 'State University Campus', icon: '🎓', category: 'Education' },
    { name: 'Stadium', address: 'City Sports Stadium', icon: '🏟️', category: 'Sports' },
  ];

  // Filter map search suggestions
  const filteredMapSuggestions = mapSearchQuery
    ? popularDestinations.filter(dest =>
        dest.name.toLowerCase().includes(mapSearchQuery.toLowerCase()) ||
        dest.address.toLowerCase().includes(mapSearchQuery.toLowerCase()) ||
        dest.category.toLowerCase().includes(mapSearchQuery.toLowerCase())
      )
    : popularDestinations;

  // Filter pickup location suggestions
  const filteredPickupSuggestions = pickupLocation && pickupLocation !== 'Current Location'
    ? popularDestinations.filter(dest =>
        dest.name.toLowerCase().includes(pickupLocation.toLowerCase()) ||
        dest.address.toLowerCase().includes(pickupLocation.toLowerCase()) ||
        dest.category.toLowerCase().includes(pickupLocation.toLowerCase())
      )
    : popularDestinations;

  // Filter dropoff location suggestions
  const filteredSuggestions = dropoffLocation
    ? popularDestinations.filter(dest =>
        dest.name.toLowerCase().includes(dropoffLocation.toLowerCase()) ||
        dest.address.toLowerCase().includes(dropoffLocation.toLowerCase()) ||
        dest.category.toLowerCase().includes(dropoffLocation.toLowerCase())
      )
    : popularDestinations;

  const handleSuggestionClick = (address: string) => {
    setDropoffLocation(address);
    setShowSuggestions(false);
    setIsFocused(false);
  };

  const handleMapSearchClick = (address: string, name: string) => {
    setDropoffLocation(address);
    setMapSearchQuery(name);
    setShowMapSuggestions(false);
  };

  const handlePickupSuggestionClick = (address: string) => {
    setPickupLocation(address);
    setShowPickupSuggestions(false);
    setIsPickupFocused(false);
  };

  const handleViewMapPin = () => {
    setHighlightMapPin(true);
    setTimeout(() => setHighlightMapPin(false), 3000);
  };

  const handleDropoffSuggestionClick = (location: string) => {
    setDropoffLocation(location);
    setShowDropoffSuggestions(false);
    setIsDropoffFocused(false);
    // Auto-expand panel when destination is selected
    if (!isPanelExpanded) {
      setIsPanelExpanded(true);
    }
  };

  return (
    <div className="h-full flex flex-col md:flex-row">
      {/* Map View - Hidden on mobile, shown on desktop */}
      <div className="hidden md:block md:w-1/2 bg-gradient-to-br from-blue-100 to-green-100 relative">
        {/* Map Search Bar - Top Right */}
        <div className="absolute top-6 right-6 left-6 z-30">
          <div className="relative max-w-md ml-auto">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 z-10" />
            <input
              type="text"
              value={mapSearchQuery}
              onChange={(e) => {
                setMapSearchQuery(e.target.value);
                setShowMapSuggestions(true);
              }}
              onFocus={() => setShowMapSuggestions(true)}
              onBlur={() => {
                setTimeout(() => setShowMapSuggestions(false), 200);
              }}
              placeholder="Search locations on map..."
              className="w-full pl-12 pr-4 py-3 bg-white/95 backdrop-blur-sm border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none shadow-lg text-sm"
            />
            
            {/* Map Search Suggestions Dropdown */}
            {showMapSuggestions && (
              <div className="absolute left-0 right-0 top-full mt-2 bg-white border border-gray-200 rounded-xl shadow-2xl max-h-96 overflow-y-auto">
                {/* Header */}
                <div className="px-4 py-2 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-gray-200 sticky top-0">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <MapPin className="w-4 h-4 text-blue-600" />
                      <span className="text-xs font-semibold text-blue-900">
                        {mapSearchQuery ? 'Search Results' : 'Explore Locations'}
                      </span>
                    </div>
                    {mapSearchQuery && (
                      <span className="text-xs text-gray-600">
                        {filteredMapSuggestions.length} found
                      </span>
                    )}
                  </div>
                </div>

                {/* Suggestions List */}
                {filteredMapSuggestions.length > 0 ? (
                  <div className="py-2">
                    {filteredMapSuggestions.map((dest, index) => (
                      <button
                        key={index}
                        onClick={() => handleMapSearchClick(dest.address, dest.name)}
                        className="w-full flex items-center gap-3 px-4 py-3 hover:bg-blue-50 active:bg-blue-100 transition-colors border-b border-gray-100 last:border-b-0"
                      >
                        <div className="text-2xl flex-shrink-0">{dest.icon}</div>
                        <div className="flex-1 text-left">
                          <div className="font-semibold text-gray-900 text-sm">{dest.name}</div>
                          <div className="text-xs text-gray-600">{dest.address}</div>
                        </div>
                        <div className="flex flex-col items-end gap-1">
                          <div className="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded-full font-medium">
                            {dest.category}
                          </div>
                          <div className="text-xs text-gray-500">Click to set</div>
                        </div>
                      </button>
                    ))}
                  </div>
                ) : (
                  <div className="px-4 py-8 text-center text-gray-500">
                    <Search className="w-10 h-10 mx-auto mb-3 text-gray-400" />
                    <p className="text-sm font-medium">No locations found</p>
                    <p className="text-xs text-gray-400 mt-1">Try different keywords</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <MapPin className="w-20 h-20 text-blue-600 mx-auto mb-3" />
            <p className="text-gray-700 font-medium text-lg">Live Map View</p>
            <p className="text-sm text-gray-600 mt-1">Track your ride in real-time</p>
          </div>
        </div>

        {/* Destination Marker */}
        {dropoffLocation && (
          <div className="absolute top-1/4 right-1/4">
            <div className={`relative ${highlightMapPin ? 'animate-ping' : 'animate-bounce'}`}>
              <MapPin className={`w-8 h-8 text-red-600 drop-shadow-lg transition-all duration-300 ${highlightMapPin ? 'scale-150' : 'scale-100'}`} />
              <div className={`absolute -top-10 left-1/2 -translate-x-1/2 bg-white px-3 py-1 rounded-lg shadow-md whitespace-nowrap text-xs font-medium transition-all ${highlightMapPin ? 'bg-blue-600 text-white scale-110' : ''}`}>
                {highlightMapPin ? '📍 Viewing Location' : 'Destination'}
              </div>
            </div>
            
            {/* Highlight Ring Effect */}
            {highlightMapPin && (
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                <div className="w-16 h-16 rounded-full bg-blue-500/30 animate-ping"></div>
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 rounded-full bg-blue-400/20 animate-pulse"></div>
              </div>
            )}
          </div>
        )}

        {/* Current Location Badge */}
        <div className="absolute top-6 left-6 bg-white rounded-full px-5 py-3 shadow-xl flex items-center gap-3">
          <div className="w-3 h-3 bg-blue-600 rounded-full animate-pulse"></div>
          <div>
            <p className="text-xs text-gray-600">Your Location</p>
            <p className="font-semibold text-gray-900">{pickupLocation}</p>
          </div>
        </div>

        {/* Route Info */}
        {dropoffLocation && (
          <div className="absolute bottom-6 left-6 right-6 bg-white rounded-2xl p-4 shadow-xl">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2">
                <Navigation className="w-5 h-5 text-blue-600" />
                <span className="font-semibold text-gray-900">Route Preview</span>
              </div>
              <span className="text-sm text-blue-600 font-semibold">5.2 km</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Clock className="w-4 h-4 text-gray-400" />
              <span className="text-gray-600">Estimated time: 12 minutes</span>
            </div>
          </div>
        )}
      </div>

      {/* Mobile Map - Shown on mobile only */}
      <div className="md:hidden bg-gradient-to-br from-blue-100 to-green-100 h-80 relative flex-shrink-0 overflow-hidden">
        <div className="absolute inset-0 flex items-center justify-center px-4">
          {/* Company Cards Slideshow */}
          <div className="w-full max-w-sm">
            {companyCards.map((card, index) => (
              <div
                key={card.id}
                className={`absolute inset-0 flex items-center justify-center px-4 transition-all duration-500 ease-in-out ${
                  index === currentSlide
                    ? 'opacity-100 translate-x-0'
                    : index < currentSlide
                    ? 'opacity-0 -translate-x-full'
                    : 'opacity-0 translate-x-full'
                }`}
              >
                <div className={`bg-gradient-to-br ${card.gradient} rounded-2xl shadow-2xl p-6 w-full max-w-sm transform transition-transform duration-300 hover:scale-105`}>
                  <div className="text-center text-white">
                    <div className="flex justify-center mb-4">
                      <div className="bg-white/95 backdrop-blur-sm rounded-full w-20 h-20 flex items-center justify-center shadow-lg border-4 border-white/50">
                        <div className="text-4xl">{card.logo}</div>
                      </div>
                    </div>
                    <h2 className="text-2xl font-bold mb-1">{card.name}</h2>
                    <p className="text-sm font-semibold text-white/90 mb-2">{card.tagline}</p>
                    <p className="text-xs text-white/80 mb-4">{card.description}</p>
                    <button
                      onClick={() => {
                        setSelectedCompany(index);
                        setShowCompanyDetails(true);
                      }}
                      className="bg-white/20 hover:bg-white/30 active:bg-white/40 backdrop-blur-sm px-4 py-2 rounded-lg text-white font-semibold text-sm transition-colors border border-white/30"
                    >
                      Show Details
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Slide Navigation Dots */}
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2">
            {companyCards.map((_, index) => (
              <button
                key={index}
                onClick={() => setCurrentSlide(index)}
                className={`transition-all duration-300 rounded-full ${
                  index === currentSlide
                    ? 'w-8 h-2 bg-white'
                    : 'w-2 h-2 bg-white/50 hover:bg-white/70'
                }`}
                aria-label={`Go to slide ${index + 1}`}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Booking Card - Scrollable on both mobile and desktop */}
      <div className={`flex-1 bg-white md:rounded-none rounded-t-3xl relative z-10 shadow-2xl md:shadow-none overflow-hidden md:w-1/2 transition-all duration-500 ease-out md:mt-0 ${
        isPanelExpanded ? '-mt-8' : 'mt-[calc(100vh-160px)]'
      }`}>
        {/* Pull Handle */}
        <div 
          onClick={() => setIsPanelExpanded(!isPanelExpanded)}
          className="sticky top-0 bg-white z-30 pt-3 pb-2 cursor-pointer hover:bg-gray-50 active:bg-gray-100 transition-colors md:hidden"
        >
          <div className="w-12 h-1.5 bg-gray-300 rounded-full mx-auto"></div>
          <div className="text-center mt-2">
            <ChevronDown className={`w-5 h-5 mx-auto text-gray-400 transition-transform duration-300 ${
              isPanelExpanded ? 'rotate-180' : ''
            }`} />
          </div>
        </div>

        {/* Scrollable Content */}
        <div className="flex flex-col" style={{ height: isPanelExpanded ? 'calc(100vh - 320px)' : '150px' }}>
          <div className="overflow-y-auto flex-1 p-5 pt-2">
        {/* Location Inputs */}
        <div className="space-y-3 mb-5">
          <div className="relative">
            <div className="absolute left-3 top-1/2 -translate-y-1/2 w-3 h-3 rounded-full bg-blue-600 z-10"></div>
            <input
              type="text"
              value={pickupLocation}
              onChange={(e) => {
                setPickupLocation(e.target.value);
                setShowPickupSuggestions(true);
              }}
              onFocus={() => {
                setIsPickupFocused(true);
                setShowPickupSuggestions(true);
              }}
              onBlur={() => {
                // Delay to allow click on suggestions
                setTimeout(() => {
                  setIsPickupFocused(false);
                  setShowPickupSuggestions(false);
                }, 200);
              }}
              placeholder="Pickup location"
              className="w-full pl-10 pr-10 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
            />
            <button className="absolute right-3 top-1/2 -translate-y-1/2 text-blue-600 z-10">
              <Search className="w-5 h-5" />
            </button>
            
            {/* Pickup Location Suggestions Dropdown */}
            {(isPickupFocused || showPickupSuggestions) && (
              <div className="absolute left-0 right-0 top-full mt-2 bg-white border border-gray-200 rounded-xl shadow-xl max-h-80 overflow-y-auto z-20">
                {/* Header */}
                <div className="px-4 py-2 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-gray-200">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Navigation className="w-4 h-4 text-blue-600" />
                      <span className="text-xs font-semibold text-blue-900">
                        {pickupLocation && pickupLocation !== 'Current Location' ? 'Search Results' : 'Pickup Locations'}
                      </span>
                    </div>
                    {pickupLocation && pickupLocation !== 'Current Location' && (
                      <span className="text-xs text-gray-600">
                        {filteredPickupSuggestions.length + 1} found
                      </span>
                    )}
                  </div>
                </div>

                {/* Current Location Option - Always First */}
                <div className="py-2 border-b-2 border-blue-100">
                  <button
                    onClick={() => handlePickupSuggestionClick('Current Location')}
                    className={`w-full flex items-center gap-3 px-4 py-3 transition-colors ${
                      pickupLocation === 'Current Location' 
                        ? 'bg-blue-50 border-l-4 border-l-blue-600' 
                        : 'hover:bg-blue-50 active:bg-blue-100'
                    }`}
                  >
                    <div className="relative flex-shrink-0">
                      <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                        <Navigation className="w-5 h-5 text-blue-600" />
                      </div>
                      {pickupLocation === 'Current Location' && (
                        <div className="absolute -top-1 -right-1 w-4 h-4 bg-blue-600 rounded-full flex items-center justify-center">
                          <CheckCircle className="w-3 h-3 text-white" />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 text-left">
                      <div className="font-semibold text-gray-900 flex items-center gap-2">
                        Current Location
                        {pickupLocation === 'Current Location' && (
                          <span className="text-xs px-2 py-0.5 bg-blue-600 text-white rounded-full">Active</span>
                        )}
                      </div>
                      <div className="text-xs text-gray-600">Use my current GPS location</div>
                    </div>
                    <div className="text-xs px-2 py-1 bg-green-100 text-green-700 rounded-full font-medium">
                      GPS
                    </div>
                  </button>
                </div>

                {/* Other Locations */}
                {filteredPickupSuggestions.length > 0 ? (
                  <div className="py-2">
                    {filteredPickupSuggestions.map((dest, index) => (
                      <button
                        key={index}
                        onClick={() => handlePickupSuggestionClick(dest.address)}
                        className="w-full flex items-center gap-3 px-4 py-3 hover:bg-blue-50 active:bg-blue-100 transition-colors border-b border-gray-100 last:border-b-0"
                      >
                        <div className="text-2xl flex-shrink-0">{dest.icon}</div>
                        <div className="flex-1 text-left">
                          <div className="font-semibold text-gray-900">{dest.name}</div>
                          <div className="text-xs text-gray-600">{dest.address}</div>
                        </div>
                        <div className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
                          {dest.category}
                        </div>
                      </button>
                    ))}
                  </div>
                ) : (
                  pickupLocation !== 'Current Location' && (
                    <div className="px-4 py-6 text-center text-gray-500">
                      <Search className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                      <p className="text-sm">No locations found</p>
                      <p className="text-xs text-gray-400 mt-1">Try a different search term</p>
                    </div>
                  )
                )}
              </div>
            )}
          </div>

          <div className="relative">
            <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-3 h-3 text-red-600 z-10" />
            <input
              type="text"
              value={dropoffLocation}
              onChange={(e) => {
                setDropoffLocation(e.target.value);
                setShowSuggestions(true);
              }}
              onFocus={() => {
                setIsFocused(true);
                setShowSuggestions(true);
              }}
              onBlur={() => {
                // Delay to allow click on suggestions
                setTimeout(() => {
                  setIsFocused(false);
                  setShowSuggestions(false);
                }, 200);
              }}
              placeholder="Where to?"
              className="w-full pl-10 pr-12 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
            />
            
            {/* View Map Pin Button */}
            {dropoffLocation && (
              <button
                onClick={handleViewMapPin}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-blue-600 hover:text-blue-700 active:text-blue-800 p-1 hover:bg-blue-50 rounded-lg transition-all z-10"
                title="View on map"
              >
                <MapPin className="w-5 h-5" />
              </button>
            )}
            
            {/* Autocomplete Suggestions Dropdown */}
            {(isFocused || showSuggestions) && (
              <div className="absolute left-0 right-0 top-full mt-2 bg-white border border-gray-200 rounded-xl shadow-xl max-h-80 overflow-y-auto z-20">
                {/* Popular Header */}
                {!dropoffLocation && (
                  <div className="px-4 py-2 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-gray-200">
                    <div className="flex items-center gap-2">
                      <TrendingUp className="w-4 h-4 text-blue-600" />
                      <span className="text-xs font-semibold text-blue-900">Popular Destinations</span>
                    </div>
                  </div>
                )}
                
                {/* Search Results Header */}
                {dropoffLocation && filteredSuggestions.length > 0 && (
                  <div className="px-4 py-2 bg-gray-50 border-b border-gray-200">
                    <span className="text-xs font-semibold text-gray-700">
                      {filteredSuggestions.length} result{filteredSuggestions.length !== 1 ? 's' : ''} found
                    </span>
                  </div>
                )}

                {/* Suggestions List */}
                {filteredSuggestions.length > 0 ? (
                  <div className="py-2">
                    {filteredSuggestions.map((dest, index) => (
                      <button
                        key={index}
                        onClick={() => handleDropoffSuggestionClick(dest.address)}
                        className="w-full flex items-center gap-3 px-4 py-3 hover:bg-blue-50 active:bg-blue-100 transition-colors border-b border-gray-100 last:border-b-0"
                      >
                        <div className="text-2xl flex-shrink-0">{dest.icon}</div>
                        <div className="flex-1 text-left">
                          <div className="font-semibold text-gray-900">{dest.name}</div>
                          <div className="text-xs text-gray-600">{dest.address}</div>
                        </div>
                        <div className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
                          {dest.category}
                        </div>
                      </button>
                    ))}
                  </div>
                ) : (
                  <div className="px-4 py-8 text-center text-gray-500">
                    <Search className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                    <p className="text-sm">No destinations found</p>
                    <p className="text-xs text-gray-400 mt-1">Try a different search term</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Recent Places */}
        {!dropoffLocation && (
          <div className="mb-5">
            <h3 className="text-sm font-semibold text-gray-700 mb-2">Recent Places</h3>
            <div className="space-y-2">
              {recentPlaces.map((place, index) => (
                <button
                  key={index}
                  onClick={() => setDropoffLocation(place.address)}
                  className="w-full flex items-center gap-3 p-3 bg-gray-50 rounded-xl hover:bg-gray-100 active:bg-gray-200 transition-colors"
                >
                  <div className="text-2xl">{place.icon}</div>
                  <div className="flex-1 text-left">
                    <div className="font-semibold text-gray-900">{place.name}</div>
                    <div className="text-xs text-gray-600">{place.address}</div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Ride Options */}
        {dropoffLocation && (
          <div className="mb-5">
            <h3 className="text-sm font-semibold text-gray-700 mb-3">Choose a ride</h3>
            <div className="space-y-2">
              {rideOptions.map((option) => (
                <button
                  key={option.id}
                  onClick={() => setSelectedService(option.id)}
                  className={`w-full p-4 rounded-xl border-2 transition-all ${
                    selectedService === option.id
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 bg-white hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="text-3xl">{option.icon}</div>
                    <div className="flex-1 text-left">
                      <div className="flex items-center gap-2">
                        <div className="font-semibold text-gray-900">{option.name}</div>
                        <div className="flex items-center gap-0.5 text-xs">
                          <Clock className="w-3 h-3 text-gray-400" />
                          <span className="text-gray-600">{option.time}</span>
                        </div>
                      </div>
                      <div className="text-xs text-gray-600">{option.description} • {option.capacity}</div>
                    </div>
                    <div className="text-right">
                      <div className="font-bold text-gray-900">{option.price}</div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}
        </div>

        {/* Fixed Button Footer */}
        {dropoffLocation && (
          <div className="border-t border-gray-200 bg-white p-5 flex-shrink-0">
            <button
              className="w-full bg-blue-600 text-white py-4 rounded-xl font-semibold hover:bg-blue-700 active:bg-blue-800 transition-colors shadow-lg flex items-center justify-center gap-2"
              onClick={handleNextClick}
            >
              <ArrowRight className="w-5 h-5" />
              Next
            </button>
            <button className="w-full mt-3 text-blue-600 font-medium py-3 hover:text-blue-700 active:text-blue-800 transition-colors flex items-center justify-center gap-2">
              <Clock className="w-5 h-5" />
              Schedule for later
            </button>
          </div>
        )}
        </div>
      </div>

      {/* Fixed Next Button - Shows when destination is selected */}
      {dropoffLocation && !showConfirmation && (
        <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 p-4 shadow-lg z-50">
          <button
            className="w-full bg-blue-600 text-white py-4 rounded-xl font-bold text-lg hover:bg-blue-700 active:bg-blue-800 transition-colors shadow-lg flex items-center justify-center gap-2"
            onClick={handleNextClick}
          >
            <ArrowRight className="w-5 h-5" />
            Next
          </button>
          <button className="w-full mt-2 text-blue-600 font-medium py-2 hover:text-blue-700 active:text-blue-800 transition-colors flex items-center justify-center gap-2 text-sm">
            <Clock className="w-4 h-4" />
            Schedule for later
          </button>
        </div>
      )}

      {/* Floating Expand Button - Shows when panel is collapsed */}
      {!isPanelExpanded && (
        <button
          onClick={() => setIsPanelExpanded(true)}
          className="fixed bottom-8 right-6 z-40 w-14 h-14 bg-blue-600 hover:bg-blue-700 active:bg-blue-800 text-white rounded-full shadow-2xl flex items-center justify-center transition-all duration-300 hover:scale-110 active:scale-95 md:hidden animate-bounce"
        >
          <Plus className="w-7 h-7" />
        </button>
      )}

      {/* Ride Confirmation Page */}
      {showConfirmation && (
        <div className="fixed inset-0 z-50 bg-white">
          <RideConfirmationPage
            pickupLocation={pickupLocation}
            dropoffLocation={dropoffLocation}
            selectedService={selectedService}
            estimatedPrice={selectedOption.price}
            estimatedTime="12 min"
            onBack={handleBackFromConfirmation}
            onConfirm={handleConfirmRide}
          />
        </div>
      )}

      {/* Company Details Modal */}
      {showCompanyDetails && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/60 z-50 animate-fadeIn"
            onClick={() => setShowCompanyDetails(false)}
          ></div>
          
          {/* Modal */}
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-lg mx-auto bg-white rounded-3xl shadow-2xl z-50 overflow-hidden animate-slideUp max-h-[85vh] flex flex-col">
            {/* Header with gradient */}
            <div className={`bg-gradient-to-br ${companyCards[selectedCompany].gradient} p-6 text-white`}>
              <div className="flex items-center justify-between mb-4">
                <div className="text-6xl">{companyCards[selectedCompany].logo}</div>
                <button
                  onClick={() => setShowCompanyDetails(false)}
                  className="w-8 h-8 bg-white/20 hover:bg-white/30 rounded-full flex items-center justify-center transition-colors"
                >
                  <span className="text-white text-xl">×</span>
                </button>
              </div>
              <h2 className="text-3xl font-bold mb-1">{companyCards[selectedCompany].name}</h2>
              <p className="text-white/90 text-sm">{companyCards[selectedCompany].tagline}</p>
            </div>

            {/* Scrollable Content */}
            <div className="flex-1 overflow-y-auto p-6 space-y-5">
              {/* Mission */}
              <div>
                <h3 className="font-bold text-gray-900 mb-2 flex items-center gap-2">
                  <span className="text-lg">🎯</span> Our Mission
                </h3>
                <p className="text-sm text-gray-700 leading-relaxed">
                  {companyCards[selectedCompany].fullProfile.mission}
                </p>
              </div>

              {/* Company Info Grid */}
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-blue-50 rounded-xl p-3">
                  <div className="text-xs text-blue-600 font-semibold mb-1">Founded</div>
                  <div className="font-bold text-gray-900">{companyCards[selectedCompany].fullProfile.founded}</div>
                </div>
                <div className="bg-purple-50 rounded-xl p-3">
                  <div className="text-xs text-purple-600 font-semibold mb-1">Rating</div>
                  <div className="font-bold text-gray-900 flex items-center gap-1">
                    <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                    {companyCards[selectedCompany].fullProfile.rating}
                  </div>
                </div>
                <div className="bg-green-50 rounded-xl p-3">
                  <div className="text-xs text-green-600 font-semibold mb-1">Employees</div>
                  <div className="font-bold text-gray-900">{companyCards[selectedCompany].fullProfile.employees}</div>
                </div>
                <div className="bg-orange-50 rounded-xl p-3">
                  <div className="text-xs text-orange-600 font-semibold mb-1">Coverage</div>
                  <div className="font-bold text-gray-900 text-xs">{companyCards[selectedCompany].fullProfile.cities}</div>
                </div>
              </div>

              {/* Key Stats */}
              <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-xs text-gray-600 mb-1">Total Rides</div>
                    <div className="font-bold text-gray-900 text-lg">{companyCards[selectedCompany].fullProfile.rides}</div>
                  </div>
                  <div className="text-4xl">🚗</div>
                </div>
              </div>

              {/* Headquarters */}
              <div className="bg-gray-50 rounded-xl p-4">
                <div className="flex items-center gap-2 mb-2">
                  <MapPin className="w-4 h-4 text-blue-600" />
                  <h3 className="font-bold text-gray-900">Headquarters</h3>
                </div>
                <p className="text-sm text-gray-700">{companyCards[selectedCompany].fullProfile.headquarters}</p>
              </div>

              {/* Achievements */}
              <div>
                <h3 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <span className="text-lg">🏆</span> Achievements
                </h3>
                <div className="grid grid-cols-1 gap-2">
                  {companyCards[selectedCompany].fullProfile.achievements.map((achievement, index) => (
                    <div key={index} className="flex items-center gap-2 bg-gray-50 rounded-lg p-3">
                      <div className="text-sm text-gray-700">{achievement}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Services */}
              <div>
                <h3 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <span className="text-lg">💼</span> Our Services
                </h3>
                <div className="flex flex-wrap gap-2">
                  {companyCards[selectedCompany].fullProfile.services.map((service, index) => (
                    <div 
                      key={index} 
                      className="px-3 py-2 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold"
                    >
                      {service}
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Footer Button */}
            <div className="p-4 border-t border-gray-200">
              <button
                onClick={() => setShowCompanyDetails(false)}
                className={`w-full bg-gradient-to-r ${companyCards[selectedCompany].gradient} text-white py-3 rounded-xl font-semibold hover:opacity-90 transition-opacity`}
              >
                Close
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}