import { useState } from 'react';
import { 
  ChevronLeft, 
  User, 
  Bell, 
  Shield, 
  Globe, 
  Car,
  Wallet,
  CreditCard,
  Database,
  HelpCircle,
  FileText,
  Info,
  ChevronRight,
  Check,
  Lock,
  Trash2,
  Download,
  Clock,
  Navigation,
  MapPin,
  Volume2
} from 'lucide-react';

interface DriverSettingsPageProps {
  onBack: () => void;
}

export function DriverSettingsPage({ onBack }: DriverSettingsPageProps) {
  const [activeSection, setActiveSection] = useState<string | null>(null);
  
  // Driver Account Settings
  const [accountData, setAccountData] = useState({
    name: 'John Driver',
    email: 'john.driver@example.com',
    phone: '+1 (555) 987-6543',
    dateOfBirth: '1988-03-20',
    address: '123 Main St, City, State 12345',
    emergencyContact: '+1 (555) 111-2222',
    emergencyName: 'Jane Driver'
  });

  // Vehicle Information
  const [vehicleData, setVehicleData] = useState({
    make: 'Toyota',
    model: 'Camry',
    year: '2022',
    color: 'Silver',
    plate: 'ABC-1234',
    vin: '1HGBH41JXMN109186',
    seatingCapacity: '4'
  });

  // Documents
  const [documents, setDocuments] = useState({
    driversLicense: { uploaded: true, expiry: '2027-03-15', verified: true },
    insurance: { uploaded: true, expiry: '2026-12-31', verified: true },
    vehicleRegistration: { uploaded: true, expiry: '2026-06-30', verified: true },
    background: { uploaded: true, expiry: '2026-01-15', verified: true }
  });

  // Notification Settings
  const [notifications, setNotifications] = useState({
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    rideRequests: true,
    riderMessages: true,
    earningsReports: true,
    promotions: false,
    maintenanceReminders: true
  });

  // Working Preferences
  const [workingPrefs, setWorkingPrefs] = useState({
    maxDistance: '20',
    preferredAreas: [] as string[],
    acceptPool: true,
    acceptDelivery: false,
    acceptPets: true,
    autoAccept: false
  });

  // Navigation Preferences
  const [navPrefs, setNavPrefs] = useState({
    voiceGuidance: true,
    avoidTolls: false,
    avoidHighways: false,
    navigationApp: 'builtin'
  });

  const sections = [
    { 
      id: 'account', 
      icon: User, 
      label: 'Account Settings', 
      subtitle: 'Personal information',
      color: 'text-blue-600',
      bg: 'bg-blue-50'
    },
    { 
      id: 'vehicle', 
      icon: Car, 
      label: 'Vehicle Information', 
      subtitle: 'Your car details',
      color: 'text-purple-600',
      bg: 'bg-purple-50'
    },
    { 
      id: 'documents', 
      icon: FileText, 
      label: 'Documents', 
      subtitle: 'License, insurance & permits',
      color: 'text-orange-600',
      bg: 'bg-orange-50'
    },
    { 
      id: 'earnings', 
      icon: Wallet, 
      label: 'Earnings & Payouts', 
      subtitle: 'Payment preferences',
      color: 'text-green-600',
      bg: 'bg-green-50'
    },
    { 
      id: 'working', 
      icon: Clock, 
      label: 'Working Preferences', 
      subtitle: 'Trip acceptance settings',
      color: 'text-blue-600',
      bg: 'bg-blue-50'
    },
    { 
      id: 'navigation', 
      icon: Navigation, 
      label: 'Navigation', 
      subtitle: 'Route preferences',
      color: 'text-indigo-600',
      bg: 'bg-indigo-50'
    },
    { 
      id: 'notifications', 
      icon: Bell, 
      label: 'Notifications', 
      subtitle: 'Alert preferences',
      color: 'text-green-600',
      bg: 'bg-green-50'
    },
    { 
      id: 'security', 
      icon: Lock, 
      label: 'Security', 
      subtitle: 'Password & authentication',
      color: 'text-red-600',
      bg: 'bg-red-50'
    },
    { 
      id: 'help', 
      icon: HelpCircle, 
      label: 'Help & Support', 
      subtitle: 'Get assistance',
      color: 'text-blue-600',
      bg: 'bg-blue-50'
    },
    { 
      id: 'legal', 
      icon: FileText, 
      label: 'Legal', 
      subtitle: 'Terms & policies',
      color: 'text-gray-600',
      bg: 'bg-gray-50'
    },
    { 
      id: 'about', 
      icon: Info, 
      label: 'About', 
      subtitle: 'App info',
      color: 'text-gray-600',
      bg: 'bg-gray-50'
    }
  ];

  // Render main settings list
  if (!activeSection) {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={onBack}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <div>
              <h1 className="text-xl font-bold text-gray-900">Settings</h1>
              <p className="text-sm text-gray-600">Manage your preferences</p>
            </div>
          </div>
        </div>

        <div className="p-4 space-y-2">
          {sections.map((section) => (
            <button
              key={section.id}
              onClick={() => setActiveSection(section.id)}
              className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all active:scale-[0.99] flex items-center gap-3"
            >
              <div className={`${section.bg} p-2.5 rounded-lg`}>
                <section.icon className={`w-5 h-5 ${section.color}`} />
              </div>
              <div className="flex-1 text-left">
                <div className="font-semibold text-gray-900">{section.label}</div>
                <div className="text-xs text-gray-500">{section.subtitle}</div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          ))}
        </div>
      </div>
    );
  }

  // Account Settings Detail
  if (activeSection === 'account') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={() => setActiveSection(null)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <h1 className="text-xl font-bold text-gray-900">Account Settings</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Profile Photo */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Profile Photo</label>
            <div className="flex items-center gap-4">
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center">
                <User className="w-10 h-10 text-blue-600" />
              </div>
              <div className="flex-1">
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium text-sm hover:bg-blue-700 mb-2">
                  Upload Photo
                </button>
                <p className="text-xs text-gray-500">JPG or PNG. Max 5MB.</p>
              </div>
            </div>
          </div>

          {/* Personal Information */}
          <div className="bg-white rounded-xl p-4 border border-gray-200 space-y-4">
            <h3 className="font-semibold text-gray-900">Personal Information</h3>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                type="text"
                value={accountData.name}
                onChange={(e) => setAccountData({ ...accountData, name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                type="email"
                value={accountData.email}
                onChange={(e) => setAccountData({ ...accountData, email: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
              <input
                type="tel"
                value={accountData.phone}
                onChange={(e) => setAccountData({ ...accountData, phone: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Date of Birth</label>
              <input
                type="date"
                value={accountData.dateOfBirth}
                onChange={(e) => setAccountData({ ...accountData, dateOfBirth: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
              <textarea
                value={accountData.address}
                onChange={(e) => setAccountData({ ...accountData, address: e.target.value })}
                rows={2}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <button className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700">
              Save Changes
            </button>
          </div>

          {/* Emergency Contact */}
          <div className="bg-white rounded-xl p-4 border border-gray-200 space-y-4">
            <h3 className="font-semibold text-gray-900">Emergency Contact</h3>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Contact Name</label>
              <input
                type="text"
                value={accountData.emergencyName}
                onChange={(e) => setAccountData({ ...accountData, emergencyName: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
              <input
                type="tel"
                value={accountData.emergencyContact}
                onChange={(e) => setAccountData({ ...accountData, emergencyContact: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <button className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700">
              Update Emergency Contact
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Vehicle Information Detail
  if (activeSection === 'vehicle') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={() => setActiveSection(null)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <h1 className="text-xl font-bold text-gray-900">Vehicle Information</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Vehicle Photo */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Vehicle Photo</label>
            <div className="bg-gray-100 rounded-xl h-48 flex items-center justify-center mb-3">
              <Car className="w-16 h-16 text-gray-400" />
            </div>
            <button className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg font-medium text-sm hover:bg-blue-700">
              Upload Vehicle Photo
            </button>
          </div>

          {/* Vehicle Details */}
          <div className="bg-white rounded-xl p-4 border border-gray-200 space-y-4">
            <h3 className="font-semibold text-gray-900">Vehicle Details</h3>
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Make</label>
                <input
                  type="text"
                  value={vehicleData.make}
                  onChange={(e) => setVehicleData({ ...vehicleData, make: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Model</label>
                <input
                  type="text"
                  value={vehicleData.model}
                  onChange={(e) => setVehicleData({ ...vehicleData, model: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Year</label>
                <input
                  type="text"
                  value={vehicleData.year}
                  onChange={(e) => setVehicleData({ ...vehicleData, year: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Color</label>
                <input
                  type="text"
                  value={vehicleData.color}
                  onChange={(e) => setVehicleData({ ...vehicleData, color: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">License Plate</label>
              <input
                type="text"
                value={vehicleData.plate}
                onChange={(e) => setVehicleData({ ...vehicleData, plate: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">VIN</label>
              <input
                type="text"
                value={vehicleData.vin}
                onChange={(e) => setVehicleData({ ...vehicleData, vin: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Seating Capacity</label>
              <select
                value={vehicleData.seatingCapacity}
                onChange={(e) => setVehicleData({ ...vehicleData, seatingCapacity: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="2">2 passengers</option>
                <option value="4">4 passengers</option>
                <option value="6">6 passengers</option>
                <option value="8">8 passengers</option>
              </select>
            </div>

            <button className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700">
              Update Vehicle Info
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Documents Detail
  if (activeSection === 'documents') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={() => setActiveSection(null)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <h1 className="text-xl font-bold text-gray-900">Documents</h1>
          </div>
        </div>

        <div className="p-4 space-y-3">
          {/* Driver's License */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <FileText className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <div className="font-semibold text-gray-900">Driver's License</div>
                  <div className="text-xs text-gray-600">Expires: {documents.driversLicense.expiry}</div>
                </div>
              </div>
              {documents.driversLicense.verified && (
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1">
                  <Check className="w-3 h-3" />
                  Verified
                </span>
              )}
            </div>
            <div className="flex gap-2">
              <button className="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg font-medium text-sm hover:bg-gray-200">
                View
              </button>
              <button className="flex-1 bg-blue-600 text-white py-2 rounded-lg font-medium text-sm hover:bg-blue-700">
                Update
              </button>
            </div>
          </div>

          {/* Insurance */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                  <Shield className="w-5 h-5 text-purple-600" />
                </div>
                <div>
                  <div className="font-semibold text-gray-900">Insurance</div>
                  <div className="text-xs text-gray-600">Expires: {documents.insurance.expiry}</div>
                </div>
              </div>
              {documents.insurance.verified && (
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1">
                  <Check className="w-3 h-3" />
                  Verified
                </span>
              )}
            </div>
            <div className="flex gap-2">
              <button className="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg font-medium text-sm hover:bg-gray-200">
                View
              </button>
              <button className="flex-1 bg-blue-600 text-white py-2 rounded-lg font-medium text-sm hover:bg-blue-700">
                Update
              </button>
            </div>
          </div>

          {/* Vehicle Registration */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                  <Car className="w-5 h-5 text-green-600" />
                </div>
                <div>
                  <div className="font-semibold text-gray-900">Vehicle Registration</div>
                  <div className="text-xs text-gray-600">Expires: {documents.vehicleRegistration.expiry}</div>
                </div>
              </div>
              {documents.vehicleRegistration.verified && (
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1">
                  <Check className="w-3 h-3" />
                  Verified
                </span>
              )}
            </div>
            <div className="flex gap-2">
              <button className="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg font-medium text-sm hover:bg-gray-200">
                View
              </button>
              <button className="flex-1 bg-blue-600 text-white py-2 rounded-lg font-medium text-sm hover:bg-blue-700">
                Update
              </button>
            </div>
          </div>

          {/* Background Check */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                  <Shield className="w-5 h-5 text-orange-600" />
                </div>
                <div>
                  <div className="font-semibold text-gray-900">Background Check</div>
                  <div className="text-xs text-gray-600">Valid until: {documents.background.expiry}</div>
                </div>
              </div>
              {documents.background.verified && (
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold flex items-center gap-1">
                  <Check className="w-3 h-3" />
                  Verified
                </span>
              )}
            </div>
            <button className="w-full bg-gray-100 text-gray-700 py-2 rounded-lg font-medium text-sm hover:bg-gray-200">
              View Report
            </button>
          </div>

          {/* Renewal Reminder */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <h3 className="font-semibold text-blue-900 mb-2">Document Reminders</h3>
            <p className="text-sm text-blue-700">We'll notify you 30 days before any document expires.</p>
          </div>
        </div>
      </div>
    );
  }

  // Working Preferences Detail
  if (activeSection === 'working') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={() => setActiveSection(null)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <h1 className="text-xl font-bold text-gray-900">Working Preferences</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Trip Acceptance */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Trip Acceptance</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Maximum Distance (miles)</label>
                <input
                  type="number"
                  value={workingPrefs.maxDistance}
                  onChange={(e) => setWorkingPrefs({ ...workingPrefs, maxDistance: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <p className="text-xs text-gray-500 mt-1">Maximum distance you're willing to travel to pick up riders</p>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Auto-Accept Trips</div>
                  <div className="text-sm text-gray-600">Automatically accept nearby ride requests</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={workingPrefs.autoAccept}
                    onChange={(e) => setWorkingPrefs({ ...workingPrefs, autoAccept: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
            </div>
          </div>

          {/* Service Types */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Service Types</h3>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Pool Rides</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={workingPrefs.acceptPool}
                    onChange={(e) => setWorkingPrefs({ ...workingPrefs, acceptPool: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Delivery Requests</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={workingPrefs.acceptDelivery}
                    onChange={(e) => setWorkingPrefs({ ...workingPrefs, acceptDelivery: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Allow Pets</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={workingPrefs.acceptPets}
                    onChange={(e) => setWorkingPrefs({ ...workingPrefs, acceptPets: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
            </div>
          </div>

          {/* Preferred Areas */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-3">Preferred Areas</h3>
            <p className="text-sm text-gray-600 mb-3">Set areas where you prefer to receive trip requests</p>
            <button className="w-full bg-blue-600 text-white py-2.5 rounded-lg font-medium text-sm hover:bg-blue-700">
              Manage Preferred Areas
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Navigation Preferences Detail
  if (activeSection === 'navigation') {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="p-4 flex items-center gap-3">
            <button
              onClick={() => setActiveSection(null)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-6 h-6 text-gray-700" />
            </button>
            <h1 className="text-xl font-bold text-gray-900">Navigation</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Navigation App */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Navigation App</label>
            <select
              value={navPrefs.navigationApp}
              onChange={(e) => setNavPrefs({ ...navPrefs, navigationApp: e.target.value })}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="builtin">Built-in Navigation</option>
              <option value="google">Google Maps</option>
              <option value="waze">Waze</option>
              <option value="apple">Apple Maps</option>
            </select>
          </div>

          {/* Route Preferences */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Route Preferences</h3>
            
            <div className="space-y-4">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Voice Guidance</div>
                  <div className="text-sm text-gray-600">Turn-by-turn voice instructions</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={navPrefs.voiceGuidance}
                    onChange={(e) => setNavPrefs({ ...navPrefs, voiceGuidance: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Avoid Tolls</div>
                  <div className="text-sm text-gray-600">Prefer toll-free routes</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={navPrefs.avoidTolls}
                    onChange={(e) => setNavPrefs({ ...navPrefs, avoidTolls: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Avoid Highways</div>
                  <div className="text-sm text-gray-600">Use local roads when possible</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={navPrefs.avoidHighways}
                    onChange={(e) => setNavPrefs({ ...navPrefs, avoidHighways: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Notifications remain the same as rider version...
  // For brevity, returning to main menu for other sections
  return (
    <div className="h-full bg-gray-50 flex items-center justify-center p-4">
      <div className="text-center">
        <p className="text-gray-600 mb-4">Section: {activeSection}</p>
        <button
          onClick={() => setActiveSection(null)}
          className="bg-blue-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-blue-700"
        >
          Back to Settings
        </button>
      </div>
    </div>
  );
}
