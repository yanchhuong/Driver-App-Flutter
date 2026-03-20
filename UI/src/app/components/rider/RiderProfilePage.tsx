import { User, Star, MapPin, Heart, Gift, CreditCard, Shield, HelpCircle, LogOut, ChevronRight, Settings, Edit2, Check, X, Plus, Trash2, Home as HomeIcon, Briefcase, Clock, Phone, Mail, ArrowLeft } from 'lucide-react';
import { useState } from 'react';
import { SettingsPage } from './SettingsPage';

interface RiderProfilePageProps {
  onLogout?: () => void;
}

type ProfileSection = 'main' | 'saved-places' | 'favorite-drivers' | 'promotions' | 'payment-methods' | 'safety' | 'help';

export function RiderProfilePage({ onLogout }: RiderProfilePageProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [activeSection, setActiveSection] = useState<ProfileSection>('main');
  
  const [riderProfile, setRiderProfile] = useState({
    name: 'Sarah Rider',
    email: 'sarah.rider@example.com',
    phone: '+1 (555) 123-4567',
    rating: 4.9,
    totalTrips: 156,
    memberSince: 'Mar 2023',
    savedLocations: 3
  });

  const [editForm, setEditForm] = useState({ ...riderProfile });

  // Saved Places Data
  const [savedPlaces, setSavedPlaces] = useState([
    { id: 1, name: 'Home', address: '123 Main Street, Springfield, IL 62701', icon: HomeIcon, color: 'text-blue-600', bg: 'bg-blue-50' },
    { id: 2, name: 'Work', address: '456 Business Ave, Springfield, IL 62702', icon: Briefcase, color: 'text-purple-600', bg: 'bg-purple-50' },
    { id: 3, name: 'Mom\'s House', address: '789 Oak Drive, Springfield, IL 62703', icon: MapPin, color: 'text-green-600', bg: 'bg-green-50' }
  ]);

  // Favorite Drivers Data
  const [favoriteDrivers, setFavoriteDrivers] = useState([
    { id: 1, name: 'John Smith', rating: 4.9, trips: 45, photo: 'JS', carModel: 'Toyota Camry 2022' },
    { id: 2, name: 'Emily Johnson', rating: 5.0, trips: 32, photo: 'EJ', carModel: 'Honda Accord 2023' },
    { id: 3, name: 'Michael Brown', rating: 4.8, trips: 28, photo: 'MB', carModel: 'Tesla Model 3' }
  ]);

  // Promotions Data
  const [promotions, setPromotions] = useState([
    { id: 1, title: '20% Off Next Ride', code: 'RIDE20', expiry: 'Mar 31, 2026', discount: '20%', status: 'active' },
    { id: 2, title: 'Free Delivery', code: 'FREEDEL', expiry: 'Apr 15, 2026', discount: 'Free', status: 'active' },
    { id: 3, title: '$5 Off Weekend Rides', code: 'WEEKEND5', expiry: 'Mar 25, 2026', discount: '$5', status: 'active' }
  ]);

  // Payment Methods Data
  const [paymentMethods, setPaymentMethods] = useState([
    { id: 1, type: 'Visa', last4: '4242', expiry: '12/26', isDefault: true },
    { id: 2, type: 'Mastercard', last4: '8888', expiry: '08/27', isDefault: false },
    { id: 3, type: 'Cash', last4: '', expiry: '', isDefault: false }
  ]);

  // Payment Form State
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [editingPaymentId, setEditingPaymentId] = useState<number | null>(null);
  const [paymentForm, setPaymentForm] = useState({
    cardNumber: '',
    cardholderName: '',
    expiry: '',
    cvv: '',
    type: 'Visa'
  });

  // Place Form State
  const [showPlaceModal, setShowPlaceModal] = useState(false);
  const [editingPlaceId, setEditingPlaceId] = useState<number | null>(null);
  const [placeForm, setPlaceForm] = useState({
    name: '',
    address: '',
    iconType: 'home'
  });

  const handleSave = () => {
    setRiderProfile(editForm);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setEditForm({ ...riderProfile });
    setIsEditing(false);
  };

  // Payment Methods Handlers
  const handleAddPayment = () => {
    setEditingPaymentId(null);
    setPaymentForm({
      cardNumber: '',
      cardholderName: '',
      expiry: '',
      cvv: '',
      type: 'Visa'
    });
    setShowPaymentModal(true);
  };

  const handleEditPayment = (method: any) => {
    setEditingPaymentId(method.id);
    setPaymentForm({
      cardNumber: '•••• •••• •••• ' + method.last4,
      cardholderName: '',
      expiry: method.expiry,
      cvv: '',
      type: method.type
    });
    setShowPaymentModal(true);
  };

  const handleSavePayment = () => {
    if (editingPaymentId) {
      // Update existing payment
      setPaymentMethods(paymentMethods.map(method => 
        method.id === editingPaymentId 
          ? { ...method, type: paymentForm.type, last4: paymentForm.cardNumber.slice(-4), expiry: paymentForm.expiry }
          : method
      ));
    } else {
      // Add new payment
      const newPayment = {
        id: Math.max(...paymentMethods.map(m => m.id)) + 1,
        type: paymentForm.type,
        last4: paymentForm.cardNumber.replace(/\s/g, '').slice(-4),
        expiry: paymentForm.expiry,
        isDefault: false
      };
      setPaymentMethods([...paymentMethods, newPayment]);
    }
    setShowPaymentModal(false);
  };

  const handleDeletePayment = (id: number) => {
    setPaymentMethods(paymentMethods.filter(method => method.id !== id));
  };

  const handleSetDefaultPayment = (id: number) => {
    setPaymentMethods(paymentMethods.map(method => ({
      ...method,
      isDefault: method.id === id
    })));
  };

  const formatCardNumber = (value: string) => {
    const cleaned = value.replace(/\s/g, '');
    const match = cleaned.match(/.{1,4}/g);
    return match ? match.join(' ') : '';
  };

  const formatExpiry = (value: string) => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length >= 2) {
      return cleaned.slice(0, 2) + '/' + cleaned.slice(2, 4);
    }
    return cleaned;
  };

  // Saved Places Handlers
  const getIconByType = (iconType: string) => {
    const iconMap: Record<string, any> = {
      home: { icon: HomeIcon, color: 'text-blue-600', bg: 'bg-blue-50' },
      work: { icon: Briefcase, color: 'text-purple-600', bg: 'bg-purple-50' },
      location: { icon: MapPin, color: 'text-green-600', bg: 'bg-green-50' },
      heart: { icon: Heart, color: 'text-red-600', bg: 'bg-red-50' },
      star: { icon: Star, color: 'text-yellow-600', bg: 'bg-yellow-50' }
    };
    return iconMap[iconType] || iconMap.location;
  };

  const handleAddPlace = () => {
    setEditingPlaceId(null);
    setPlaceForm({
      name: '',
      address: '',
      iconType: 'home'
    });
    setShowPlaceModal(true);
  };

  const handleEditPlace = (place: any) => {
    setEditingPlaceId(place.id);
    // Determine iconType from the place
    let iconType = 'location';
    if (place.icon === HomeIcon) iconType = 'home';
    else if (place.icon === Briefcase) iconType = 'work';
    else if (place.icon === Heart) iconType = 'heart';
    else if (place.icon === Star) iconType = 'star';
    
    setPlaceForm({
      name: place.name,
      address: place.address,
      iconType: iconType
    });
    setShowPlaceModal(true);
  };

  const handleSavePlace = () => {
    const iconData = getIconByType(placeForm.iconType);
    
    if (editingPlaceId) {
      // Update existing place
      setSavedPlaces(savedPlaces.map(place =>
        place.id === editingPlaceId
          ? { ...place, name: placeForm.name, address: placeForm.address, icon: iconData.icon, color: iconData.color, bg: iconData.bg }
          : place
      ));
    } else {
      // Add new place
      const newPlace = {
        id: Math.max(...savedPlaces.map(p => p.id)) + 1,
        name: placeForm.name,
        address: placeForm.address,
        icon: iconData.icon,
        color: iconData.color,
        bg: iconData.bg
      };
      setSavedPlaces([...savedPlaces, newPlace]);
    }
    setShowPlaceModal(false);
  };

  const handleDeletePlace = (id: number) => {
    setSavedPlaces(savedPlaces.filter(place => place.id !== id));
  };

  const menuItems = [
    { id: 'saved-places', icon: MapPin, label: 'Saved Places', subtitle: 'Home, Work & more', color: 'text-blue-600', bg: 'bg-blue-50' },
    { id: 'favorite-drivers', icon: Heart, label: 'Favorite Drivers', subtitle: 'Your preferred drivers', color: 'text-red-600', bg: 'bg-red-50' },
    { id: 'promotions', icon: Gift, label: 'Promotions', subtitle: 'Deals & discounts', color: 'text-green-600', bg: 'bg-green-50' },
    { id: 'payment-methods', icon: CreditCard, label: 'Payment Methods', subtitle: 'Manage cards & wallet', color: 'text-purple-600', bg: 'bg-purple-50' },
    { id: 'safety', icon: Shield, label: 'Safety', subtitle: 'Emergency contacts', color: 'text-orange-600', bg: 'bg-orange-50' },
    { id: 'help', icon: HelpCircle, label: 'Help & Support', subtitle: 'Get assistance', color: 'text-blue-600', bg: 'bg-blue-50' }
  ];

  // Show settings page if requested
  if (showSettings) {
    return <SettingsPage onBack={() => setShowSettings(false)} />;
  }

  // Saved Places Section
  if (activeSection === 'saved-places') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Saved Places</h2>
        </div>
        <div className="p-4 space-y-3">
          <button onClick={handleAddPlace} className="w-full bg-blue-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-blue-700 transition-colors">
            <Plus className="w-5 h-5" />
            Add New Place
          </button>
          {savedPlaces.map((place) => {
            const Icon = place.icon;
            return (
              <div key={place.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
                <div className="flex items-start gap-3">
                  <div className={`${place.bg} p-3 rounded-lg`}>
                    <Icon className={`w-6 h-6 ${place.color}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-gray-900 mb-1">{place.name}</h3>
                    <p className="text-sm text-gray-600">{place.address}</p>
                  </div>
                  <div className="flex gap-1">
                    <button 
                      onClick={() => handleEditPlace(place)}
                      className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
                      title="Edit place"
                    >
                      <Edit2 className="w-5 h-5" />
                    </button>
                    <button 
                      onClick={() => handleDeletePlace(place.id)}
                      className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600"
                      title="Delete place"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Place Modal */}
        {showPlaceModal && (
          <>
            {/* Backdrop */}
            <div 
              className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
              onClick={() => setShowPlaceModal(false)}
            ></div>
            
            {/* Modal */}
            <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
              {/* Modal Header */}
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 rounded-t-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold text-white">
                    {editingPlaceId ? 'Edit Place' : 'Add New Place'}
                  </h3>
                  <button
                    onClick={() => setShowPlaceModal(false)}
                    className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Modal Content */}
              <div className="p-5 space-y-4 max-h-[60vh] overflow-y-auto">
                {/* Place Name */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Place Name</label>
                  <input
                    type="text"
                    placeholder="Home"
                    value={placeForm.name}
                    onChange={(e) => setPlaceForm({ ...placeForm, name: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Address */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Address</label>
                  <input
                    type="text"
                    placeholder="123 Main Street, Springfield, IL 62701"
                    value={placeForm.address}
                    onChange={(e) => setPlaceForm({ ...placeForm, address: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Icon Type */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Icon Type</label>
                  <select
                    value={placeForm.iconType}
                    onChange={(e) => setPlaceForm({ ...placeForm, iconType: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="home">Home</option>
                    <option value="work">Work</option>
                    <option value="location">Location</option>
                    <option value="heart">Heart</option>
                    <option value="star">Star</option>
                  </select>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-5 border-t border-gray-200 flex gap-3">
                <button
                  onClick={() => setShowPlaceModal(false)}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSavePlace}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-white bg-blue-600 hover:bg-blue-700 transition-colors"
                >
                  {editingPlaceId ? 'Update' : 'Add Place'}
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    );
  }

  // Favorite Drivers Section
  if (activeSection === 'favorite-drivers') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Favorite Drivers</h2>
        </div>
        <div className="p-4 space-y-3">
          {favoriteDrivers.map((driver) => (
            <div key={driver.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
              <div className="flex items-center gap-3">
                <div className="w-14 h-14 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white font-bold text-lg">
                  {driver.photo}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-bold text-gray-900">{driver.name}</h3>
                    <Heart className="w-4 h-4 text-red-500 fill-red-500" />
                  </div>
                  <div className="flex items-center gap-2 mb-1">
                    <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                    <span className="text-sm font-semibold text-gray-700">{driver.rating}</span>
                    <span className="text-sm text-gray-500">• {driver.trips} trips with you</span>
                  </div>
                  <p className="text-xs text-gray-600">{driver.carModel}</p>
                </div>
                <button className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600">
                  <Trash2 className="w-5 h-5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  // Promotions Section
  if (activeSection === 'promotions') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Promotions</h2>
        </div>
        <div className="p-4 space-y-3">
          <button className="w-full bg-green-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-green-700 transition-colors">
            <Plus className="w-5 h-5" />
            Add Promo Code
          </button>
          {promotions.map((promo) => (
            <div key={promo.id} className="bg-gradient-to-r from-green-50 to-green-100 rounded-xl p-4 border-2 border-green-200 hover:shadow-md transition-all">
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <Gift className="w-5 h-5 text-green-600" />
                    <h3 className="font-bold text-gray-900">{promo.title}</h3>
                  </div>
                  <div className="bg-white rounded-lg px-3 py-1.5 inline-block mb-2">
                    <code className="text-sm font-bold text-green-600">{promo.code}</code>
                  </div>
                </div>
                <div className="text-right">
                  <div className="bg-green-600 text-white text-xs font-bold px-2 py-1 rounded-full">{promo.discount}</div>
                </div>
              </div>
              <div className="flex items-center justify-between text-xs text-gray-600">
                <span>Expires: {promo.expiry}</span>
                <button className="text-blue-600 font-semibold hover:underline">Apply Now</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  // Payment Methods Section
  if (activeSection === 'payment-methods') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Payment Methods</h2>
        </div>
        <div className="p-4 space-y-3">
          <button 
            onClick={handleAddPayment}
            className="w-full bg-purple-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-purple-700 transition-colors"
          >
            <Plus className="w-5 h-5" />
            Add Payment Method
          </button>
          {paymentMethods.map((method) => (
            <div key={method.id} className={`bg-white rounded-xl p-4 border-2 hover:shadow-md transition-all ${method.isDefault ? 'border-purple-400 bg-purple-50' : 'border-gray-200'}`}>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center">
                  <CreditCard className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-bold text-gray-900">{method.type}</h3>
                    {method.isDefault && (
                      <span className="bg-purple-600 text-white text-xs font-bold px-2 py-0.5 rounded-full">Default</span>
                    )}
                  </div>
                  {method.last4 && (
                    <>
                      <p className="text-sm text-gray-600">•••• •••• •••• {method.last4}</p>
                      <p className="text-xs text-gray-500">Expires {method.expiry}</p>
                    </>
                  )}
                </div>
                <div className="flex gap-1">
                  {method.last4 && !method.isDefault && (
                    <button 
                      onClick={() => handleSetDefaultPayment(method.id)}
                      className="p-2 hover:bg-purple-50 rounded-lg transition-colors text-purple-600"
                      title="Set as default"
                    >
                      <Check className="w-5 h-5" />
                    </button>
                  )}
                  {method.last4 && (
                    <button 
                      onClick={() => handleEditPayment(method)}
                      className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
                      title="Edit payment"
                    >
                      <Edit2 className="w-5 h-5" />
                    </button>
                  )}
                  {!method.isDefault && (
                    <button 
                      onClick={() => handleDeletePayment(method.id)}
                      className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600"
                      title="Delete payment"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Payment Modal */}
        {showPaymentModal && (
          <>
            {/* Backdrop */}
            <div 
              className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
              onClick={() => setShowPaymentModal(false)}
            ></div>
            
            {/* Modal */}
            <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
              {/* Modal Header */}
              <div className="bg-gradient-to-r from-purple-600 to-purple-700 p-4 rounded-t-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold text-white">
                    {editingPaymentId ? 'Edit Payment Method' : 'Add Payment Method'}
                  </h3>
                  <button
                    onClick={() => setShowPaymentModal(false)}
                    className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Modal Content */}
              <div className="p-5 space-y-4 max-h-[60vh] overflow-y-auto">
                {/* Card Type */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Card Type</label>
                  <select
                    value={paymentForm.type}
                    onChange={(e) => setPaymentForm({ ...paymentForm, type: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  >
                    <option value="Visa">Visa</option>
                    <option value="Mastercard">Mastercard</option>
                    <option value="American Express">American Express</option>
                    <option value="Discover">Discover</option>
                  </select>
                </div>

                {/* Card Number */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Card Number</label>
                  <input
                    type="text"
                    placeholder="1234 5678 9012 3456"
                    value={paymentForm.cardNumber}
                    onChange={(e) => {
                      const formatted = formatCardNumber(e.target.value.replace(/\D/g, '').slice(0, 16));
                      setPaymentForm({ ...paymentForm, cardNumber: formatted });
                    }}
                    maxLength={19}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  />
                </div>

                {/* Cardholder Name */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Cardholder Name</label>
                  <input
                    type="text"
                    placeholder="John Doe"
                    value={paymentForm.cardholderName}
                    onChange={(e) => setPaymentForm({ ...paymentForm, cardholderName: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  />
                </div>

                {/* Expiry and CVV */}
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Expiry Date</label>
                    <input
                      type="text"
                      placeholder="MM/YY"
                      value={paymentForm.expiry}
                      onChange={(e) => {
                        const formatted = formatExpiry(e.target.value);
                        setPaymentForm({ ...paymentForm, expiry: formatted });
                      }}
                      maxLength={5}
                      className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">CVV</label>
                    <input
                      type="text"
                      placeholder="123"
                      value={paymentForm.cvv}
                      onChange={(e) => {
                        const cleaned = e.target.value.replace(/\D/g, '').slice(0, 4);
                        setPaymentForm({ ...paymentForm, cvv: cleaned });
                      }}
                      maxLength={4}
                      className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    />
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-5 border-t border-gray-200 flex gap-3">
                <button
                  onClick={() => setShowPaymentModal(false)}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSavePayment}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-white bg-purple-600 hover:bg-purple-700 transition-colors"
                >
                  {editingPaymentId ? 'Update' : 'Add Card'}
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    );
  }

  // Safety Section
  if (activeSection === 'safety') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Safety</h2>
        </div>
        <div className="p-4 space-y-4">
          {/* Emergency Contacts */}
          <div>
            <h3 className="text-sm font-bold text-gray-700 mb-3">Emergency Contacts</h3>
            <button className="w-full bg-orange-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-orange-700 transition-colors mb-3">
              <Plus className="w-5 h-5" />
              Add Emergency Contact
            </button>
            <div className="space-y-2">
              {emergencyContacts.map((contact) => (
                <div key={contact.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center">
                      <User className="w-6 h-6 text-orange-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="font-bold text-gray-900">{contact.name}</h4>
                      <p className="text-sm text-gray-600">{contact.relationship}</p>
                      <p className="text-sm text-gray-500">{contact.phone}</p>
                    </div>
                    <button className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600">
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Safety Features */}
          <div>
            <h3 className="text-sm font-bold text-gray-700 mb-3">Safety Features</h3>
            <div className="space-y-2">
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Shield className="w-5 h-5 text-orange-600" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Share Trip Status</h4>
                      <p className="text-xs text-gray-600">Share real-time location</p>
                    </div>
                  </div>
                  <button className="w-12 h-6 bg-orange-600 rounded-full relative">
                    <div className="w-5 h-5 bg-white rounded-full absolute right-0.5 top-0.5"></div>
                  </button>
                </div>
              </div>
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Phone className="w-5 h-5 text-orange-600" />
                    <div>
                      <h4 className="font-semibold text-gray-900">911 Assistance</h4>
                      <p className="text-xs text-gray-600">Quick access to emergency</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Help & Support Section
  if (activeSection === 'help') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Help & Support</h2>
        </div>
        <div className="p-4 space-y-4">
          {/* Contact Options */}
          <div>
            <h3 className="text-sm font-bold text-gray-700 mb-3">Contact Us</h3>
            <div className="space-y-2">
              <button className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all flex items-center gap-3">
                <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                  <Phone className="w-6 h-6 text-blue-600" />
                </div>
                <div className="flex-1 text-left">
                  <h4 className="font-semibold text-gray-900">Call Support</h4>
                  <p className="text-sm text-gray-600">1-800-RIDE-APP</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
              <button className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all flex items-center gap-3">
                <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                  <HelpCircle className="w-6 h-6 text-purple-600" />
                </div>
                <div className="flex-1 text-left">
                  <h4 className="font-semibold text-gray-900">FAQ</h4>
                  <p className="text-sm text-gray-600">Common questions & answers</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
            </div>
          </div>

          {/* FAQ */}
          <div>
            <h3 className="text-sm font-bold text-gray-700 mb-3">Frequently Asked</h3>
            <div className="space-y-2">
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <h4 className="font-semibold text-gray-900 mb-1">How do I cancel a ride?</h4>
                <p className="text-sm text-gray-600">You can cancel from the active ride screen within 2 minutes for free.</p>
              </div>
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <h4 className="font-semibold text-gray-900 mb-1">How do I get a refund?</h4>
                <p className="text-sm text-gray-600">Contact support within 48 hours of your trip for refund requests.</p>
              </div>
              <div className="bg-white rounded-xl p-4 border border-gray-200">
                <h4 className="font-semibold text-gray-900 mb-1">How do I update my payment?</h4>
                <p className="text-sm text-gray-600">Go to Payment Methods in your profile to add or remove cards.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Main Profile View
  return (
    <div className="p-4 pb-6">
      {/* Profile Header */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-5 text-white mb-5 shadow-lg">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4 flex-1">
            <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center">
              <User className="w-8 h-8 text-blue-600" />
            </div>
            <div className="flex-1">
              {isEditing ? (
                <div className="space-y-2">
                  <input
                    type="text"
                    value={editForm.name}
                    onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                    className="w-full px-2 py-1 rounded bg-white/20 border border-white/30 text-white placeholder-blue-200 text-lg font-bold"
                  />
                  <input
                    type="email"
                    value={editForm.email}
                    onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                    className="w-full px-2 py-1 rounded bg-white/20 border border-white/30 text-white placeholder-blue-200 text-sm"
                  />
                  <input
                    type="tel"
                    value={editForm.phone}
                    onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                    className="w-full px-2 py-1 rounded bg-white/20 border border-white/30 text-white placeholder-blue-200 text-sm"
                  />
                </div>
              ) : (
                <>
                  <h2 className="text-xl font-bold">{riderProfile.name}</h2>
                  <p className="text-blue-100 text-sm">{riderProfile.email}</p>
                  <p className="text-blue-100 text-sm">{riderProfile.phone}</p>
                  <p className="text-blue-200 text-xs mt-1">Member since {riderProfile.memberSince}</p>
                </>
              )}
            </div>
          </div>
          {isEditing ? (
            <div className="flex gap-2">
              <button
                onClick={handleSave}
                className="px-4 py-2 bg-green-500 rounded-lg hover:bg-green-600 transition-colors font-semibold text-sm"
              >
                Update
              </button>
              <button
                onClick={handleCancel}
                className="p-2 bg-red-500 rounded-lg hover:bg-red-600 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          ) : (
            <button
              onClick={() => setIsEditing(true)}
              className="p-2 bg-white/20 rounded-lg hover:bg-white/30 transition-colors"
            >
              <Edit2 className="w-5 h-5" />
            </button>
          )}
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-3 pt-4 border-t border-blue-500">
          <div className="text-center">
            <div className="flex items-center justify-center gap-1 mb-1">
              <Star className="w-4 h-4 text-yellow-300" />
              <div className="text-lg font-bold">{riderProfile.rating}</div>
            </div>
            <div className="text-blue-200 text-xs">Rating</div>
          </div>
          <div className="text-center">
            <div className="text-lg font-bold mb-1">{riderProfile.totalTrips}</div>
            <div className="text-blue-200 text-xs">Total Trips</div>
          </div>
          <div className="text-center">
            <div className="text-lg font-bold mb-1">{riderProfile.savedLocations}</div>
            <div className="text-blue-200 text-xs">Saved Places</div>
          </div>
        </div>
      </div>

      {/* Referral Banner */}
      <div className="bg-gradient-to-r from-green-400 to-green-500 rounded-xl p-4 mb-5 text-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Gift className="w-8 h-8" />
            <div>
              <h3 className="font-bold">Refer a Friend</h3>
              <p className="text-green-100 text-xs">Get $10 credit each</p>
            </div>
          </div>
          <button className="bg-white text-green-600 px-4 py-2 rounded-lg font-semibold text-sm hover:bg-green-50 active:bg-green-100 transition-colors">
            Share
          </button>
        </div>
      </div>

      {/* Menu Items */}
      <div className="space-y-2 mb-5">
        {menuItems.map((item, index) => (
          <button
            key={index}
            onClick={() => setActiveSection(item.id as ProfileSection)}
            className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all active:scale-[0.99] flex items-center gap-3"
          >
            <div className={`${item.bg} p-2.5 rounded-lg`}>
              <item.icon className={`w-5 h-5 ${item.color}`} />
            </div>
            <div className="flex-1 text-left">
              <div className="font-semibold text-gray-900">{item.label}</div>
              <div className="text-xs text-gray-500">{item.subtitle}</div>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </button>
        ))}
      </div>

      {/* Logout Button */}
      <button
        onClick={onLogout}
        className="w-full bg-red-50 text-red-600 py-4 rounded-xl font-semibold border border-red-200 hover:bg-red-100 active:bg-red-200 transition-colors flex items-center justify-center gap-2"
      >
        <LogOut className="w-5 h-5" />
        Logout
      </button>

      {/* App Version */}
      <div className="text-center mt-6 text-xs text-gray-500">
        DriveApp v2.4.1
      </div>
    </div>
  );
}