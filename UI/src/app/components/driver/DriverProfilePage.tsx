import { User, Star, Wallet, Car, Shield, LogOut, ChevronRight, CreditCard, FileText, HelpCircle, Edit2, Check, X, Plus, Trash2, ArrowLeft, DollarSign, Calendar, TrendingUp, Award, Users, Clock } from 'lucide-react';
import { useState } from 'react';
import { DriverSettingsPage } from './DriverSettingsPage';

interface DriverProfilePageProps {
  onLogout?: () => void;
}

type ProfileSection = 'main' | 'vehicles' | 'earnings' | 'ratings' | 'documents' | 'payment-methods' | 'safety' | 'help';

export function DriverProfilePage({ onLogout }: DriverProfilePageProps) {
  const [showSettings, setShowSettings] = useState(false);
  const [activeSection, setActiveSection] = useState<ProfileSection>('main');
  const [showProfileModal, setShowProfileModal] = useState(false);
  
  const [driverProfile, setDriverProfile] = useState({
    name: 'John Driver',
    email: 'john.driver@example.com',
    phone: '+1 (555) 987-6543',
    rating: 4.8,
    totalTrips: 1248,
    memberSince: 'Jan 2024',
    weeklyEarnings: '$1,245.50',
    totalEarnings: '$42,680.00'
  });

  const [editForm, setEditForm] = useState({ ...driverProfile });

  // Vehicles Data
  const [vehicles, setVehicles] = useState([
    { id: 1, model: 'Toyota Camry 2022', plate: 'ABC-1234', color: 'Silver', year: '2022', isActive: true },
    { id: 2, model: 'Honda Accord 2023', plate: 'XYZ-5678', color: 'Black', year: '2023', isActive: false }
  ]);

  const [showVehicleModal, setShowVehicleModal] = useState(false);
  const [editingVehicleId, setEditingVehicleId] = useState<number | null>(null);
  const [vehicleForm, setVehicleForm] = useState({
    model: '',
    plate: '',
    color: '',
    year: ''
  });

  // Earnings Data
  const [earningsHistory, setEarningsHistory] = useState([
    { id: 1, week: 'Mar 10 - Mar 16, 2026', amount: '$1,245.50', trips: 52, hours: 38, status: 'Paid' },
    { id: 2, week: 'Mar 3 - Mar 9, 2026', amount: '$1,180.00', trips: 48, hours: 35, status: 'Paid' },
    { id: 3, week: 'Feb 24 - Mar 2, 2026', amount: '$1,320.75', trips: 55, hours: 42, status: 'Paid' },
    { id: 4, week: 'Feb 17 - Feb 23, 2026', amount: '$985.25', trips: 42, hours: 28, status: 'Paid' }
  ]);

  // Ratings & Reviews Data
  const [ratingsData, setRatingsData] = useState([
    { id: 1, rider: 'Sarah Johnson', rating: 5, comment: 'Excellent driver! Very professional and friendly.', date: 'Mar 18, 2026' },
    { id: 2, rider: 'Mike Davis', rating: 5, comment: 'Great ride, smooth driving. Highly recommend!', date: 'Mar 17, 2026' },
    { id: 3, rider: 'Emily Chen', rating: 4, comment: 'Good service, arrived on time.', date: 'Mar 16, 2026' },
    { id: 4, rider: 'Alex Brown', rating: 5, comment: 'Best driver I\'ve had! Clean car and great conversation.', date: 'Mar 15, 2026' }
  ]);

  // Documents Data
  const [documents, setDocuments] = useState([
    { id: 1, type: 'Driver License', number: 'DL-123456', expiry: 'Dec 31, 2026', status: 'Verified', color: 'text-green-600', bg: 'bg-green-50' },
    { id: 2, type: 'Vehicle Registration', number: 'VR-789012', expiry: 'Jun 30, 2026', status: 'Verified', color: 'text-green-600', bg: 'bg-green-50' },
    { id: 3, type: 'Insurance Certificate', number: 'IC-345678', expiry: 'Sep 15, 2026', status: 'Verified', color: 'text-green-600', bg: 'bg-green-50' },
    { id: 4, type: 'Background Check', number: 'BC-901234', expiry: 'Mar 1, 2027', status: 'Verified', color: 'text-green-600', bg: 'bg-green-50' }
  ]);

  // Payment/Payout Methods Data
  const [payoutMethods, setPayoutMethods] = useState([
    { id: 1, type: 'Bank Account', name: 'Chase Bank', last4: '4567', isDefault: true },
    { id: 2, type: 'PayPal', name: 'john.driver@example.com', last4: '', isDefault: false }
  ]);

  const [showPayoutModal, setShowPayoutModal] = useState(false);
  const [editingPayoutId, setEditingPayoutId] = useState<number | null>(null);
  const [payoutForm, setPayoutForm] = useState({
    type: 'Bank Account',
    accountNumber: '',
    routingNumber: '',
    accountName: '',
    bankName: ''
  });

  // Profile Edit Handlers
  const handleEditProfile = () => {
    setEditForm({ ...driverProfile });
    setShowProfileModal(true);
  };

  const handleSaveProfile = () => {
    setDriverProfile(editForm);
    setShowProfileModal(false);
  };

  // Vehicle Handlers
  const handleAddVehicle = () => {
    setEditingVehicleId(null);
    setVehicleForm({
      model: '',
      plate: '',
      color: '',
      year: ''
    });
    setShowVehicleModal(true);
  };

  const handleEditVehicle = (vehicle: any) => {
    setEditingVehicleId(vehicle.id);
    setVehicleForm({
      model: vehicle.model,
      plate: vehicle.plate,
      color: vehicle.color,
      year: vehicle.year
    });
    setShowVehicleModal(true);
  };

  const handleSaveVehicle = () => {
    if (editingVehicleId) {
      setVehicles(vehicles.map(v => 
        v.id === editingVehicleId 
          ? { ...v, ...vehicleForm }
          : v
      ));
    } else {
      const newVehicle = {
        id: Math.max(...vehicles.map(v => v.id)) + 1,
        ...vehicleForm,
        isActive: false
      };
      setVehicles([...vehicles, newVehicle]);
    }
    setShowVehicleModal(false);
  };

  const handleDeleteVehicle = (id: number) => {
    setVehicles(vehicles.filter(v => v.id !== id));
  };

  const handleSetActiveVehicle = (id: number) => {
    setVehicles(vehicles.map(v => ({
      ...v,
      isActive: v.id === id
    })));
  };

  // Payout Method Handlers
  const handleAddPayout = () => {
    setEditingPayoutId(null);
    setPayoutForm({
      type: 'Bank Account',
      accountNumber: '',
      routingNumber: '',
      accountName: '',
      bankName: ''
    });
    setShowPayoutModal(true);
  };

  const handleEditPayout = (method: any) => {
    setEditingPayoutId(method.id);
    setPayoutForm({
      type: method.type,
      accountNumber: '****' + method.last4,
      routingNumber: '',
      accountName: method.name,
      bankName: method.name
    });
    setShowPayoutModal(true);
  };

  const handleSavePayout = () => {
    if (editingPayoutId) {
      setPayoutMethods(payoutMethods.map(m =>
        m.id === editingPayoutId
          ? { ...m, type: payoutForm.type, name: payoutForm.bankName || payoutForm.accountName, last4: payoutForm.accountNumber.slice(-4) }
          : m
      ));
    } else {
      const newPayout = {
        id: Math.max(...payoutMethods.map(m => m.id)) + 1,
        type: payoutForm.type,
        name: payoutForm.bankName || payoutForm.accountName,
        last4: payoutForm.accountNumber.slice(-4),
        isDefault: false
      };
      setPayoutMethods([...payoutMethods, newPayout]);
    }
    setShowPayoutModal(false);
  };

  const handleDeletePayout = (id: number) => {
    setPayoutMethods(payoutMethods.filter(m => m.id !== id));
  };

  const handleSetDefaultPayout = (id: number) => {
    setPayoutMethods(payoutMethods.map(m => ({
      ...m,
      isDefault: m.id === id
    })));
  };

  const menuItems = [
    { id: 'vehicles', icon: Car, label: 'My Vehicles', subtitle: 'Manage your vehicles', color: 'text-blue-600', bg: 'bg-blue-50' },
    { id: 'earnings', icon: Wallet, label: 'Earnings', subtitle: 'View earnings history', color: 'text-green-600', bg: 'bg-green-50' },
    { id: 'ratings', icon: Star, label: 'Ratings & Reviews', subtitle: 'See what riders say', color: 'text-yellow-600', bg: 'bg-yellow-50' },
    { id: 'documents', icon: FileText, label: 'Documents', subtitle: 'Licenses & permits', color: 'text-gray-600', bg: 'bg-gray-50' },
    { id: 'payment-methods', icon: CreditCard, label: 'Payout Methods', subtitle: 'Manage payouts', color: 'text-purple-600', bg: 'bg-purple-50' },
    { id: 'safety', icon: Shield, label: 'Safety & Insurance', subtitle: 'Coverage information', color: 'text-orange-600', bg: 'bg-orange-50' },
    { id: 'help', icon: HelpCircle, label: 'Help & Support', subtitle: 'Get assistance', color: 'text-blue-600', bg: 'bg-blue-50' }
  ];

  // Show settings page if requested
  if (showSettings) {
    return <DriverSettingsPage onBack={() => setShowSettings(false)} />;
  }

  // Vehicles Section
  if (activeSection === 'vehicles') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">My Vehicles</h2>
        </div>
        <div className="p-4 space-y-3">
          <button onClick={handleAddVehicle} className="w-full bg-blue-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-blue-700 transition-colors">
            <Plus className="w-5 h-5" />
            Add New Vehicle
          </button>
          {vehicles.map((vehicle) => (
            <div key={vehicle.id} className={`bg-white rounded-xl p-4 border-2 hover:shadow-md transition-all ${vehicle.isActive ? 'border-blue-400 bg-blue-50' : 'border-gray-200'}`}>
              <div className="flex items-start gap-3">
                <div className={`${vehicle.isActive ? 'bg-blue-100' : 'bg-gray-100'} p-3 rounded-lg`}>
                  <Car className={`w-6 h-6 ${vehicle.isActive ? 'text-blue-600' : 'text-gray-600'}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-bold text-gray-900">{vehicle.model}</h3>
                    {vehicle.isActive && (
                      <span className="bg-blue-600 text-white text-xs font-bold px-2 py-0.5 rounded-full">Active</span>
                    )}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-gray-600 mb-1">
                    <span className="bg-gray-200 px-2 py-0.5 rounded font-mono text-xs">{vehicle.plate}</span>
                    <span>•</span>
                    <span>{vehicle.color}</span>
                    <span>•</span>
                    <span>{vehicle.year}</span>
                  </div>
                </div>
                <div className="flex gap-1">
                  {!vehicle.isActive && (
                    <button 
                      onClick={() => handleSetActiveVehicle(vehicle.id)}
                      className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
                      title="Set as active"
                    >
                      <Check className="w-5 h-5" />
                    </button>
                  )}
                  <button 
                    onClick={() => handleEditVehicle(vehicle)}
                    className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
                    title="Edit vehicle"
                  >
                    <Edit2 className="w-5 h-5" />
                  </button>
                  {!vehicle.isActive && (
                    <button 
                      onClick={() => handleDeleteVehicle(vehicle.id)}
                      className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600"
                      title="Delete vehicle"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Vehicle Modal */}
        {showVehicleModal && (
          <>
            <div 
              className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
              onClick={() => setShowVehicleModal(false)}
            ></div>
            
            <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 rounded-t-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold text-white">
                    {editingVehicleId ? 'Edit Vehicle' : 'Add New Vehicle'}
                  </h3>
                  <button
                    onClick={() => setShowVehicleModal(false)}
                    className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>

              <div className="p-5 space-y-4 max-h-[60vh] overflow-y-auto">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Vehicle Model</label>
                  <input
                    type="text"
                    placeholder="Toyota Camry 2022"
                    value={vehicleForm.model}
                    onChange={(e) => setVehicleForm({ ...vehicleForm, model: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">License Plate</label>
                  <input
                    type="text"
                    placeholder="ABC-1234"
                    value={vehicleForm.plate}
                    onChange={(e) => setVehicleForm({ ...vehicleForm, plate: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Color</label>
                    <input
                      type="text"
                      placeholder="Silver"
                      value={vehicleForm.color}
                      onChange={(e) => setVehicleForm({ ...vehicleForm, color: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Year</label>
                    <input
                      type="text"
                      placeholder="2022"
                      value={vehicleForm.year}
                      onChange={(e) => setVehicleForm({ ...vehicleForm, year: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                </div>
              </div>

              <div className="p-5 border-t border-gray-200 flex gap-3">
                <button
                  onClick={() => setShowVehicleModal(false)}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveVehicle}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-white bg-blue-600 hover:bg-blue-700 transition-colors"
                >
                  {editingVehicleId ? 'Update' : 'Add Vehicle'}
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    );
  }

  // Earnings Section
  if (activeSection === 'earnings') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Earnings</h2>
        </div>

        {/* Earnings Summary */}
        <div className="p-4">
          <div className="bg-gradient-to-r from-green-600 to-green-700 rounded-2xl p-6 text-white mb-4 shadow-lg">
            <h3 className="text-sm text-green-100 mb-2">Total Lifetime Earnings</h3>
            <p className="text-4xl font-bold mb-4">{driverProfile.totalEarnings}</p>
            <div className="grid grid-cols-2 gap-4 pt-4 border-t border-green-500">
              <div>
                <p className="text-green-100 text-xs mb-1">This Week</p>
                <p className="text-xl font-bold">{driverProfile.weeklyEarnings}</p>
              </div>
              <div>
                <p className="text-green-100 text-xs mb-1">Total Trips</p>
                <p className="text-xl font-bold">{driverProfile.totalTrips}</p>
              </div>
            </div>
          </div>

          {/* Earnings History */}
          <div className="space-y-3">
            <h3 className="font-bold text-gray-900 mb-3">Earnings History</h3>
            {earningsHistory.map((earning) => (
              <div key={earning.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <Calendar className="w-5 h-5 text-gray-500" />
                    <span className="text-sm font-semibold text-gray-700">{earning.week}</span>
                  </div>
                  <span className="text-lg font-bold text-green-600">{earning.amount}</span>
                </div>
                <div className="flex items-center gap-4 text-xs text-gray-600">
                  <span>{earning.trips} trips</span>
                  <span>•</span>
                  <span>{earning.hours} hours</span>
                  <span>•</span>
                  <span className="bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-semibold">{earning.status}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // Ratings & Reviews Section
  if (activeSection === 'ratings') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Ratings & Reviews</h2>
        </div>

        <div className="p-4">
          {/* Rating Summary */}
          <div className="bg-gradient-to-r from-yellow-400 to-yellow-500 rounded-2xl p-6 text-white mb-4 shadow-lg">
            <div className="flex items-center justify-center gap-3 mb-2">
              <Star className="w-12 h-12 fill-white" />
              <span className="text-5xl font-bold">{driverProfile.rating}</span>
            </div>
            <p className="text-center text-yellow-100 text-sm">Based on {driverProfile.totalTrips} trips</p>
          </div>

          {/* Reviews List */}
          <div className="space-y-3">
            <h3 className="font-bold text-gray-900 mb-3">Recent Reviews</h3>
            {ratingsData.map((review) => (
              <div key={review.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
                <div className="flex items-start gap-3 mb-2">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white font-bold text-sm">
                    {review.rider.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <h4 className="font-bold text-gray-900">{review.rider}</h4>
                      <div className="flex items-center gap-1">
                        <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                        <span className="text-sm font-bold text-gray-900">{review.rating}</span>
                      </div>
                    </div>
                    <p className="text-sm text-gray-600 mb-1">{review.comment}</p>
                    <p className="text-xs text-gray-400">{review.date}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // Documents Section
  if (activeSection === 'documents') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center gap-3 z-10">
          <button
            onClick={() => setActiveSection('main')}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <h2 className="text-lg font-bold text-gray-900">Documents</h2>
        </div>
        <div className="p-4 space-y-3">
          {documents.map((doc) => (
            <div key={doc.id} className="bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all">
              <div className="flex items-start gap-3">
                <div className={`${doc.bg} p-3 rounded-lg`}>
                  <FileText className={`w-6 h-6 ${doc.color}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-gray-900 mb-1">{doc.type}</h3>
                  <p className="text-sm text-gray-600 mb-1">ID: {doc.number}</p>
                  <div className="flex items-center gap-2">
                    <p className="text-xs text-gray-500">Expires: {doc.expiry}</p>
                    <span className={`${doc.bg} ${doc.color} text-xs font-bold px-2 py-0.5 rounded-full`}>{doc.status}</span>
                  </div>
                </div>
                <button className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600">
                  <Edit2 className="w-5 h-5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  // Payout Methods Section
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
          <h2 className="text-lg font-bold text-gray-900">Payout Methods</h2>
        </div>
        <div className="p-4 space-y-3">
          <button 
            onClick={handleAddPayout}
            className="w-full bg-purple-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-purple-700 transition-colors"
          >
            <Plus className="w-5 h-5" />
            Add Payout Method
          </button>
          {payoutMethods.map((method) => (
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
                  <p className="text-sm text-gray-600">{method.name}</p>
                  {method.last4 && (
                    <p className="text-xs text-gray-500">•••• {method.last4}</p>
                  )}
                </div>
                <div className="flex gap-1">
                  {!method.isDefault && (
                    <button 
                      onClick={() => handleSetDefaultPayout(method.id)}
                      className="p-2 hover:bg-purple-50 rounded-lg transition-colors text-purple-600"
                      title="Set as default"
                    >
                      <Check className="w-5 h-5" />
                    </button>
                  )}
                  <button 
                    onClick={() => handleEditPayout(method)}
                    className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
                    title="Edit method"
                  >
                    <Edit2 className="w-5 h-5" />
                  </button>
                  {!method.isDefault && (
                    <button 
                      onClick={() => handleDeletePayout(method.id)}
                      className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600"
                      title="Delete method"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Payout Modal */}
        {showPayoutModal && (
          <>
            <div 
              className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
              onClick={() => setShowPayoutModal(false)}
            ></div>
            
            <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
              <div className="bg-gradient-to-r from-purple-600 to-purple-700 p-4 rounded-t-2xl">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-bold text-white">
                    {editingPayoutId ? 'Edit Payout Method' : 'Add Payout Method'}
                  </h3>
                  <button
                    onClick={() => setShowPayoutModal(false)}
                    className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>

              <div className="p-5 space-y-4 max-h-[60vh] overflow-y-auto">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">Account Type</label>
                  <select
                    value={payoutForm.type}
                    onChange={(e) => setPayoutForm({ ...payoutForm, type: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  >
                    <option value="Bank Account">Bank Account</option>
                    <option value="PayPal">PayPal</option>
                    <option value="Venmo">Venmo</option>
                  </select>
                </div>

                {payoutForm.type === 'Bank Account' ? (
                  <>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Bank Name</label>
                      <input
                        type="text"
                        placeholder="Chase Bank"
                        value={payoutForm.bankName}
                        onChange={(e) => setPayoutForm({ ...payoutForm, bankName: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Account Name</label>
                      <input
                        type="text"
                        placeholder="John Driver"
                        value={payoutForm.accountName}
                        onChange={(e) => setPayoutForm({ ...payoutForm, accountName: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Account Number</label>
                      <input
                        type="text"
                        placeholder="1234567890"
                        value={payoutForm.accountNumber}
                        onChange={(e) => setPayoutForm({ ...payoutForm, accountNumber: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">Routing Number</label>
                      <input
                        type="text"
                        placeholder="123456789"
                        value={payoutForm.routingNumber}
                        onChange={(e) => setPayoutForm({ ...payoutForm, routingNumber: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      />
                    </div>
                  </>
                ) : (
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                    <input
                      type="email"
                      placeholder="john.driver@example.com"
                      value={payoutForm.accountName}
                      onChange={(e) => setPayoutForm({ ...payoutForm, accountName: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    />
                  </div>
                )}
              </div>

              <div className="p-5 border-t border-gray-200 flex gap-3">
                <button
                  onClick={() => setShowPayoutModal(false)}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSavePayout}
                  className="flex-1 px-4 py-3 rounded-xl font-semibold text-white bg-purple-600 hover:bg-purple-700 transition-colors"
                >
                  {editingPayoutId ? 'Update' : 'Add Method'}
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    );
  }

  // Safety & Insurance Section
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
          <h2 className="text-lg font-bold text-gray-900">Safety & Insurance</h2>
        </div>
        <div className="p-4 space-y-4">
          <div className="bg-white rounded-xl p-5 border border-gray-200">
            <div className="flex items-start gap-3 mb-4">
              <div className="bg-orange-50 p-3 rounded-lg">
                <Shield className="w-6 h-6 text-orange-600" />
              </div>
              <div>
                <h3 className="font-bold text-gray-900 mb-1">Insurance Coverage</h3>
                <p className="text-sm text-gray-600">You are covered by our comprehensive insurance policy while driving.</p>
              </div>
            </div>
            <div className="space-y-2 bg-gray-50 rounded-lg p-3">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Liability Coverage</span>
                <span className="font-semibold text-gray-900">$1,000,000</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Collision Coverage</span>
                <span className="font-semibold text-gray-900">$50,000</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Uninsured Motorist</span>
                <span className="font-semibold text-gray-900">$1,000,000</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl p-5 border border-gray-200">
            <h3 className="font-bold text-gray-900 mb-3">Safety Features</h3>
            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center">
                  <Check className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900 text-sm">24/7 Support</p>
                  <p className="text-xs text-gray-600">Emergency assistance available anytime</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center">
                  <Check className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900 text-sm">Incident Report</p>
                  <p className="text-xs text-gray-600">Report any safety concerns instantly</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-50 rounded-full flex items-center justify-center">
                  <Check className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p className="font-semibold text-gray-900 text-sm">GPS Tracking</p>
                  <p className="text-xs text-gray-600">All trips are tracked for your safety</p>
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
        <div className="p-4 space-y-3">
          <div className="bg-white rounded-xl p-5 border border-gray-200">
            <h3 className="font-bold text-gray-900 mb-3">Contact Support</h3>
            <div className="space-y-3">
              <button className="w-full flex items-center gap-3 p-3 rounded-lg bg-blue-50 hover:bg-blue-100 transition-colors">
                <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center">
                  <HelpCircle className="w-5 h-5 text-white" />
                </div>
                <div className="flex-1 text-left">
                  <p className="font-semibold text-gray-900 text-sm">Live Chat</p>
                  <p className="text-xs text-gray-600">Chat with our support team</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
              <button className="w-full flex items-center gap-3 p-3 rounded-lg bg-green-50 hover:bg-green-100 transition-colors">
                <div className="w-10 h-10 bg-green-600 rounded-full flex items-center justify-center">
                  <Users className="w-5 h-5 text-white" />
                </div>
                <div className="flex-1 text-left">
                  <p className="font-semibold text-gray-900 text-sm">Call Support</p>
                  <p className="text-xs text-gray-600">1-800-DRIVEAPP (24/7)</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
            </div>
          </div>

          <div className="bg-white rounded-xl p-5 border border-gray-200">
            <h3 className="font-bold text-gray-900 mb-3">FAQs</h3>
            <div className="space-y-2">
              {[
                'How do I update my vehicle information?',
                'When will I receive my earnings?',
                'How do I report an incident?',
                'What insurance coverage do I have?'
              ].map((faq, index) => (
                <button key={index} className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-between">
                  <span className="text-sm text-gray-700">{faq}</span>
                  <ChevronRight className="w-4 h-4 text-gray-400" />
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Main Profile View
  return (
    <div className="min-h-full bg-gray-50">
      <div className="p-4 space-y-4">
        {/* Profile Header Card */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-6 text-white shadow-lg">
          <div className="flex items-start gap-4 mb-4">
            <div className="w-20 h-20 bg-white rounded-full flex items-center justify-center flex-shrink-0">
              <User className="w-10 h-10 text-blue-600" />
            </div>
            <div className="flex-1 min-w-0">
              <h2 className="text-2xl font-bold mb-1">{driverProfile.name}</h2>
              <p className="text-blue-100 text-sm mb-0.5">{driverProfile.email}</p>
              <p className="text-blue-100 text-sm mb-1">{driverProfile.phone}</p>
              <p className="text-blue-200 text-xs">Member since {driverProfile.memberSince}</p>
            </div>
            <div className="flex-shrink-0">
              <button
                onClick={handleEditProfile}
                className="p-2 bg-white/20 hover:bg-white/30 rounded-lg transition-colors"
              >
                <Edit2 className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-3 gap-3 pt-4 border-t border-white/20">
            <div className="text-center">
              <div className="flex items-center justify-center gap-1 mb-1">
                <Star className="w-4 h-4 text-yellow-300 fill-yellow-300" />
                <span className="text-xl font-bold">{driverProfile.rating}</span>
              </div>
              <p className="text-blue-100 text-xs">Rating</p>
            </div>
            <div className="text-center">
              <p className="text-xl font-bold mb-1">{driverProfile.totalTrips}</p>
              <p className="text-blue-100 text-xs">Trips</p>
            </div>
            <div className="text-center">
              <p className="text-xl font-bold mb-1">{driverProfile.weeklyEarnings}</p>
              <p className="text-blue-100 text-xs">This Week</p>
            </div>
          </div>
        </div>

        {/* Active Vehicle Card */}
        {vehicles.find(v => v.isActive) && (
          <div className="bg-white rounded-xl p-4 border border-gray-200 shadow-sm">
            <div className="flex items-start gap-3">
              <div className="bg-blue-50 p-3 rounded-lg">
                <Car className="w-6 h-6 text-blue-600" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-bold text-gray-900 mb-1">Active Vehicle</h3>
                <p className="text-sm text-gray-700 mb-0.5">{vehicles.find(v => v.isActive)?.model}</p>
                <div className="flex items-center gap-2 text-xs text-gray-600">
                  <span className="bg-gray-100 px-2 py-1 rounded font-mono">{vehicles.find(v => v.isActive)?.plate}</span>
                  <span>•</span>
                  <span>{vehicles.find(v => v.isActive)?.color}</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Menu Items */}
        <div className="space-y-3">
          {menuItems.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => setActiveSection(item.id as ProfileSection)}
                className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md hover:border-gray-300 transition-all active:scale-[0.98] flex items-center gap-3"
              >
                <div className={`${item.bg} p-3 rounded-lg`}>
                  <Icon className={`w-6 h-6 ${item.color}`} />
                </div>
                <div className="flex-1 text-left min-w-0">
                  <h3 className="font-bold text-gray-900">{item.label}</h3>
                  <p className="text-sm text-gray-600">{item.subtitle}</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400 flex-shrink-0" />
              </button>
            );
          })}
        </div>

        {/* Logout Button */}
        <button
          onClick={onLogout}
          className="w-full bg-red-50 text-red-600 py-4 rounded-xl font-bold border-2 border-red-200 hover:bg-red-100 hover:border-red-300 active:bg-red-200 transition-all flex items-center justify-center gap-2"
        >
          <LogOut className="w-5 h-5" />
          Logout
        </button>

        {/* App Version */}
        <div className="text-center py-4 text-xs text-gray-500">
          DriveApp Driver v2.4.1
        </div>
      </div>

      {/* Profile Edit Modal */}
      {showProfileModal && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
            onClick={() => setShowProfileModal(false)}
          ></div>
          
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 rounded-t-2xl">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-white">Edit Profile</h3>
                <button
                  onClick={() => setShowProfileModal(false)}
                  className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            <div className="p-5 space-y-4 max-h-[60vh] overflow-y-auto">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
                <input
                  type="text"
                  value={editForm.name}
                  onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                <input
                  type="email"
                  value={editForm.email}
                  onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Phone Number</label>
                <input
                  type="tel"
                  value={editForm.phone}
                  onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>

            <div className="p-5 border-t border-gray-200 flex gap-3">
              <button
                onClick={() => setShowProfileModal(false)}
                className="flex-1 px-4 py-3 rounded-xl font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleSaveProfile}
                className="flex-1 px-4 py-3 rounded-xl font-semibold text-white bg-blue-600 hover:bg-blue-700 transition-colors"
              >
                Save Changes
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
