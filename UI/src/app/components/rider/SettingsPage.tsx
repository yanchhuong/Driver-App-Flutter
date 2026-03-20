import { useState } from 'react';
import { 
  ChevronLeft, 
  User, 
  Bell, 
  Shield, 
  Globe, 
  Moon, 
  Volume2, 
  MapPin,
  CreditCard,
  Database,
  HelpCircle,
  FileText,
  Info,
  ChevronRight,
  Check,
  Eye,
  EyeOff,
  Trash2,
  Download,
  Lock
} from 'lucide-react';

interface SettingsPageProps {
  onBack: () => void;
}

export function SettingsPage({ onBack }: SettingsPageProps) {
  const [activeSection, setActiveSection] = useState<string | null>(null);
  
  // Account Settings State
  const [accountData, setAccountData] = useState({
    name: 'Sarah Rider',
    email: 'sarah.rider@example.com',
    phone: '+1 (555) 123-4567',
    dateOfBirth: '1995-05-15',
    gender: 'female'
  });

  // Notification Settings State
  const [notifications, setNotifications] = useState({
    pushEnabled: true,
    emailEnabled: true,
    smsEnabled: false,
    rideUpdates: true,
    promotions: true,
    driverMessages: true,
    tripReminders: true,
    paymentReceipts: true
  });

  // Privacy Settings State
  const [privacy, setPrivacy] = useState({
    shareLocation: true,
    saveTripHistory: true,
    shareRating: true,
    allowDataCollection: true,
    personalizedAds: false
  });

  // App Preferences State
  const [preferences, setPreferences] = useState({
    language: 'en',
    theme: 'light',
    units: 'imperial',
    mapStyle: 'standard',
    autoConfirmPickup: false,
    voiceAssistant: true
  });

  // Security State
  const [security, setSecurity] = useState({
    twoFactorEnabled: false,
    biometricEnabled: false,
    showPassword: false
  });

  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [passwordForm, setPasswordForm] = useState({
    current: '',
    new: '',
    confirm: ''
  });

  const sections = [
    { 
      id: 'account', 
      icon: User, 
      label: 'Account Settings', 
      subtitle: 'Manage your personal information',
      color: 'text-blue-600',
      bg: 'bg-blue-50'
    },
    { 
      id: 'notifications', 
      icon: Bell, 
      label: 'Notifications', 
      subtitle: 'Control your alerts',
      color: 'text-green-600',
      bg: 'bg-green-50'
    },
    { 
      id: 'privacy', 
      icon: Shield, 
      label: 'Privacy & Data', 
      subtitle: 'Manage your privacy settings',
      color: 'text-purple-600',
      bg: 'bg-purple-50'
    },
    { 
      id: 'preferences', 
      icon: Globe, 
      label: 'App Preferences', 
      subtitle: 'Language, theme & more',
      color: 'text-orange-600',
      bg: 'bg-orange-50'
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
      id: 'data', 
      icon: Database, 
      label: 'Data & Storage', 
      subtitle: 'Manage app data',
      color: 'text-gray-600',
      bg: 'bg-gray-50'
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
      subtitle: 'App info & version',
      color: 'text-gray-600',
      bg: 'bg-gray-50'
    }
  ];

  const handlePasswordChange = () => {
    if (passwordForm.new !== passwordForm.confirm) {
      alert('New passwords do not match!');
      return;
    }
    if (passwordForm.new.length < 8) {
      alert('Password must be at least 8 characters!');
      return;
    }
    // Simulate password change
    alert('Password updated successfully!');
    setShowPasswordModal(false);
    setPasswordForm({ current: '', new: '', confirm: '' });
  };

  const handleDeleteAccount = () => {
    if (window.confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
      alert('Account deletion requested. You will receive a confirmation email.');
    }
  };

  const handleExportData = () => {
    alert('Your data export is being prepared. You will receive an email when it\'s ready.');
  };

  const handleClearCache = () => {
    if (window.confirm('Clear all cached data? This will log you out.')) {
      alert('Cache cleared successfully!');
    }
  };

  // Render main settings list
  if (!activeSection) {
    return (
      <div className="h-full bg-gray-50 overflow-y-auto">
        {/* Header */}
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

        {/* Settings List */}
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
                <p className="text-xs text-gray-500">JPG, PNG or GIF. Max 5MB.</p>
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
              <label className="block text-sm font-medium text-gray-700 mb-1">Gender</label>
              <select
                value={accountData.gender}
                onChange={(e) => setAccountData({ ...accountData, gender: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
                <option value="prefer-not-to-say">Prefer not to say</option>
              </select>
            </div>

            <button className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700">
              Save Changes
            </button>
          </div>

          {/* Danger Zone */}
          <div className="bg-red-50 border-2 border-red-200 rounded-xl p-4">
            <h3 className="font-semibold text-red-900 mb-2">Danger Zone</h3>
            <p className="text-sm text-red-700 mb-3">Once you delete your account, there is no going back.</p>
            <button
              onClick={handleDeleteAccount}
              className="w-full bg-red-600 text-white py-3 rounded-lg font-semibold hover:bg-red-700 flex items-center justify-center gap-2"
            >
              <Trash2 className="w-5 h-5" />
              Delete Account
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Notifications Settings Detail
  if (activeSection === 'notifications') {
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
            <h1 className="text-xl font-bold text-gray-900">Notifications</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Notification Channels */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Notification Channels</h3>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium text-gray-900">Push Notifications</div>
                  <div className="text-sm text-gray-600">Receive alerts on your device</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.pushEnabled}
                    onChange={(e) => setNotifications({ ...notifications, pushEnabled: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium text-gray-900">Email Notifications</div>
                  <div className="text-sm text-gray-600">Receive updates via email</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.emailEnabled}
                    onChange={(e) => setNotifications({ ...notifications, emailEnabled: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium text-gray-900">SMS Notifications</div>
                  <div className="text-sm text-gray-600">Receive text messages</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.smsEnabled}
                    onChange={(e) => setNotifications({ ...notifications, smsEnabled: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
            </div>
          </div>

          {/* Notification Types */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">What to Notify</h3>
            
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Ride Updates</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.rideUpdates}
                    onChange={(e) => setNotifications({ ...notifications, rideUpdates: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Promotions & Offers</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.promotions}
                    onChange={(e) => setNotifications({ ...notifications, promotions: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Driver Messages</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.driverMessages}
                    onChange={(e) => setNotifications({ ...notifications, driverMessages: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Trip Reminders</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.tripReminders}
                    onChange={(e) => setNotifications({ ...notifications, tripReminders: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-center justify-between">
                <div className="font-medium text-gray-900">Payment Receipts</div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={notifications.paymentReceipts}
                    onChange={(e) => setNotifications({ ...notifications, paymentReceipts: e.target.checked })}
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

  // Privacy Settings Detail
  if (activeSection === 'privacy') {
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
            <h1 className="text-xl font-bold text-gray-900">Privacy & Data</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Privacy Settings */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Privacy Controls</h3>
            
            <div className="space-y-4">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Share Location</div>
                  <div className="text-sm text-gray-600">Allow the app to access your location</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={privacy.shareLocation}
                    onChange={(e) => setPrivacy({ ...privacy, shareLocation: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Save Trip History</div>
                  <div className="text-sm text-gray-600">Keep a record of your trips</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={privacy.saveTripHistory}
                    onChange={(e) => setPrivacy({ ...privacy, saveTripHistory: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Share Rating with Drivers</div>
                  <div className="text-sm text-gray-600">Let drivers see your rating</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={privacy.shareRating}
                    onChange={(e) => setPrivacy({ ...privacy, shareRating: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Data Collection</div>
                  <div className="text-sm text-gray-600">Help improve our services</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={privacy.allowDataCollection}
                    onChange={(e) => setPrivacy({ ...privacy, allowDataCollection: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Personalized Ads</div>
                  <div className="text-sm text-gray-600">See relevant promotions</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={privacy.personalizedAds}
                    onChange={(e) => setPrivacy({ ...privacy, personalizedAds: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
            </div>
          </div>

          {/* Data Management */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Data Management</h3>
            
            <div className="space-y-3">
              <button
                onClick={handleExportData}
                className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <Download className="w-5 h-5 text-blue-600" />
                  <div className="text-left">
                    <div className="font-medium text-gray-900">Download My Data</div>
                    <div className="text-sm text-gray-600">Get a copy of your data</div>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>

              <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                <div className="flex items-center gap-3">
                  <FileText className="w-5 h-5 text-gray-600" />
                  <div className="text-left">
                    <div className="font-medium text-gray-900">Data Usage Report</div>
                    <div className="text-sm text-gray-600">See what data we collect</div>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // App Preferences Detail
  if (activeSection === 'preferences') {
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
            <h1 className="text-xl font-bold text-gray-900">App Preferences</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Language */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Language</label>
            <select
              value={preferences.language}
              onChange={(e) => setPreferences({ ...preferences, language: e.target.value })}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="en">English</option>
              <option value="es">Español</option>
              <option value="fr">Français</option>
              <option value="de">Deutsch</option>
              <option value="zh">中文</option>
              <option value="ja">日本語</option>
            </select>
          </div>

          {/* Theme */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Theme</label>
            <div className="grid grid-cols-3 gap-2">
              {['light', 'dark', 'auto'].map((theme) => (
                <button
                  key={theme}
                  onClick={() => setPreferences({ ...preferences, theme })}
                  className={`p-3 rounded-lg border-2 transition-all ${
                    preferences.theme === theme
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="text-center">
                    {theme === 'light' && <Sun className="w-6 h-6 mx-auto mb-1" />}
                    {theme === 'dark' && <Moon className="w-6 h-6 mx-auto mb-1" />}
                    {theme === 'auto' && <Globe className="w-6 h-6 mx-auto mb-1" />}
                    <div className="text-sm font-medium capitalize">{theme}</div>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Units */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Distance Units</label>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setPreferences({ ...preferences, units: 'imperial' })}
                className={`p-3 rounded-lg border-2 transition-all ${
                  preferences.units === 'imperial'
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <div className="font-medium">Miles</div>
                <div className="text-xs text-gray-600">Imperial</div>
              </button>
              <button
                onClick={() => setPreferences({ ...preferences, units: 'metric' })}
                className={`p-3 rounded-lg border-2 transition-all ${
                  preferences.units === 'metric'
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <div className="font-medium">Kilometers</div>
                <div className="text-xs text-gray-600">Metric</div>
              </button>
            </div>
          </div>

          {/* Map Style */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <label className="block text-sm font-semibold text-gray-900 mb-3">Map Style</label>
            <select
              value={preferences.mapStyle}
              onChange={(e) => setPreferences({ ...preferences, mapStyle: e.target.value })}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="standard">Standard</option>
              <option value="satellite">Satellite</option>
              <option value="terrain">Terrain</option>
              <option value="hybrid">Hybrid</option>
            </select>
          </div>

          {/* Other Preferences */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Other</h3>
            
            <div className="space-y-4">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Auto-confirm Pickup</div>
                  <div className="text-sm text-gray-600">Skip confirmation step</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={preferences.autoConfirmPickup}
                    onChange={(e) => setPreferences({ ...preferences, autoConfirmPickup: e.target.checked })}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div className="flex items-start justify-between gap-3">
                <div className="flex-1">
                  <div className="font-medium text-gray-900">Voice Assistant</div>
                  <div className="text-sm text-gray-600">Enable voice commands</div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={preferences.voiceAssistant}
                    onChange={(e) => setPreferences({ ...preferences, voiceAssistant: e.target.checked })}
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

  // Security Settings Detail
  if (activeSection === 'security') {
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
            <h1 className="text-xl font-bold text-gray-900">Security</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Password */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-3">Password</h3>
            <button
              onClick={() => setShowPasswordModal(true)}
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 flex items-center justify-center gap-2"
            >
              <Lock className="w-5 h-5" />
              Change Password
            </button>
          </div>

          {/* Two-Factor Authentication */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-start justify-between gap-3 mb-3">
              <div className="flex-1">
                <div className="font-semibold text-gray-900">Two-Factor Authentication</div>
                <div className="text-sm text-gray-600 mt-1">Add an extra layer of security</div>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={security.twoFactorEnabled}
                  onChange={(e) => setSecurity({ ...security, twoFactorEnabled: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
              </label>
            </div>
            {security.twoFactorEnabled && (
              <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                <div className="flex items-center gap-2 text-sm text-green-700">
                  <Check className="w-4 h-4" />
                  <span>Two-factor authentication is enabled</span>
                </div>
              </div>
            )}
          </div>

          {/* Biometric */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1">
                <div className="font-semibold text-gray-900">Biometric Login</div>
                <div className="text-sm text-gray-600 mt-1">Use fingerprint or face ID</div>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={security.biometricEnabled}
                  onChange={(e) => setSecurity({ ...security, biometricEnabled: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
              </label>
            </div>
          </div>

          {/* Active Sessions */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-3">Active Sessions</h3>
            <div className="space-y-3">
              <div className="flex items-start justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                  <div className="font-medium text-gray-900">Current Device</div>
                  <div className="text-sm text-gray-600">Chrome on MacOS</div>
                  <div className="text-xs text-gray-500 mt-1">Last active: Now</div>
                </div>
                <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full">Active</span>
              </div>
            </div>
            <button className="w-full mt-3 text-red-600 font-medium py-2 hover:bg-red-50 rounded-lg transition-colors">
              Sign Out All Other Devices
            </button>
          </div>
        </div>

        {/* Password Change Modal */}
        {showPasswordModal && (
          <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-2xl w-full max-w-md p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">Change Password</h2>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
                  <input
                    type="password"
                    value={passwordForm.current}
                    onChange={(e) => setPasswordForm({ ...passwordForm, current: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                  <input
                    type="password"
                    value={passwordForm.new}
                    onChange={(e) => setPasswordForm({ ...passwordForm, new: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                  <p className="text-xs text-gray-500 mt-1">Minimum 8 characters</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                  <input
                    type="password"
                    value={passwordForm.confirm}
                    onChange={(e) => setPasswordForm({ ...passwordForm, confirm: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => setShowPasswordModal(false)}
                  className="flex-1 bg-gray-100 text-gray-700 py-3 rounded-lg font-semibold hover:bg-gray-200"
                >
                  Cancel
                </button>
                <button
                  onClick={handlePasswordChange}
                  className="flex-1 bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700"
                >
                  Update
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  // Data & Storage Detail
  if (activeSection === 'data') {
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
            <h1 className="text-xl font-bold text-gray-900">Data & Storage</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Storage Usage */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Storage Usage</h3>
            
            <div className="space-y-3">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-600">App Cache</span>
                  <span className="text-sm font-semibold text-gray-900">24.5 MB</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-600 h-2 rounded-full" style={{ width: '35%' }}></div>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-600">Trip History</span>
                  <span className="text-sm font-semibold text-gray-900">12.8 MB</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-green-600 h-2 rounded-full" style={{ width: '20%' }}></div>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-600">Downloaded Maps</span>
                  <span className="text-sm font-semibold text-gray-900">45.2 MB</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-purple-600 h-2 rounded-full" style={{ width: '65%' }}></div>
                </div>
              </div>
            </div>

            <div className="mt-4 pt-4 border-t border-gray-200">
              <div className="flex items-center justify-between">
                <span className="font-semibold text-gray-900">Total Storage</span>
                <span className="font-bold text-gray-900">82.5 MB</span>
              </div>
            </div>
          </div>

          {/* Cache Management */}
          <div className="bg-white rounded-xl p-4 border border-gray-200 space-y-3">
            <h3 className="font-semibold text-gray-900">Manage Data</h3>
            
            <button
              onClick={handleClearCache}
              className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <div className="flex items-center gap-3">
                <Trash2 className="w-5 h-5 text-orange-600" />
                <div className="text-left">
                  <div className="font-medium text-gray-900">Clear Cache</div>
                  <div className="text-sm text-gray-600">Free up 24.5 MB</div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <Database className="w-5 h-5 text-blue-600" />
                <div className="text-left">
                  <div className="font-medium text-gray-900">Offline Maps</div>
                  <div className="text-sm text-gray-600">Manage downloaded areas</div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <MapPin className="w-5 h-5 text-green-600" />
                <div className="text-left">
                  <div className="font-medium text-gray-900">Location History</div>
                  <div className="text-sm text-gray-600">View and delete history</div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          </div>

          {/* Auto-Download */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-4">Auto-Download</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Download Maps</label>
                <select className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                  <option value="never">Never</option>
                  <option value="wifi">Only on Wi-Fi</option>
                  <option value="always">Always</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Download Receipts</label>
                <select className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                  <option value="never">Never</option>
                  <option value="wifi">Only on Wi-Fi</option>
                  <option value="always">Always</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Help & Support Detail
  if (activeSection === 'help') {
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
            <h1 className="text-xl font-bold text-gray-900">Help & Support</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* Quick Actions */}
          <div className="bg-white rounded-xl p-4 border border-gray-200 space-y-3">
            <h3 className="font-semibold text-gray-900">Quick Actions</h3>
            
            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <HelpCircle className="w-5 h-5 text-blue-600" />
                <span className="font-medium text-gray-900">FAQs</span>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <MessageSquare className="w-5 h-5 text-green-600" />
                <span className="font-medium text-gray-900">Chat with Support</span>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <Phone className="w-5 h-5 text-orange-600" />
                <span className="font-medium text-gray-900">Call Support</span>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
              <div className="flex items-center gap-3">
                <Mail className="w-5 h-5 text-purple-600" />
                <span className="font-medium text-gray-900">Email Support</span>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          </div>

          {/* Popular Topics */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-3">Popular Topics</h3>
            
            <div className="space-y-2">
              {[
                'How to request a ride',
                'Payment methods',
                'Cancellation policy',
                'Safety features',
                'Promotional codes',
                'Lost items'
              ].map((topic, index) => (
                <button
                  key={index}
                  className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-between group"
                >
                  <span className="text-gray-700 group-hover:text-gray-900">{topic}</span>
                  <ChevronRight className="w-4 h-4 text-gray-400 group-hover:text-gray-600" />
                </button>
              ))}
            </div>
          </div>

          {/* Contact Info */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <h3 className="font-semibold text-blue-900 mb-2">Need Immediate Help?</h3>
            <p className="text-sm text-blue-700 mb-3">Our support team is available 24/7</p>
            <div className="space-y-2 text-sm">
              <div className="flex items-center gap-2 text-blue-900">
                <Phone className="w-4 h-4" />
                <span>+1 (800) 123-4567</span>
              </div>
              <div className="flex items-center gap-2 text-blue-900">
                <Mail className="w-4 h-4" />
                <span>support@driveapp.com</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Legal Detail
  if (activeSection === 'legal') {
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
            <h1 className="text-xl font-bold text-gray-900">Legal</h1>
          </div>
        </div>

        <div className="p-4 space-y-3">
          {[
            { title: 'Terms of Service', subtitle: 'Last updated: Jan 15, 2026' },
            { title: 'Privacy Policy', subtitle: 'Last updated: Jan 15, 2026' },
            { title: 'Cookie Policy', subtitle: 'Last updated: Dec 10, 2025' },
            { title: 'Community Guidelines', subtitle: 'Last updated: Nov 5, 2025' },
            { title: 'Licenses', subtitle: 'Open source licenses' }
          ].map((item, index) => (
            <button
              key={index}
              className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all flex items-center justify-between"
            >
              <div className="text-left">
                <div className="font-semibold text-gray-900">{item.title}</div>
                <div className="text-xs text-gray-500">{item.subtitle}</div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          ))}
        </div>
      </div>
    );
  }

  // About Detail
  if (activeSection === 'about') {
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
            <h1 className="text-xl font-bold text-gray-900">About</h1>
          </div>
        </div>

        <div className="p-4 space-y-4">
          {/* App Info */}
          <div className="bg-white rounded-xl p-6 border border-gray-200 text-center">
            <div className="w-20 h-20 bg-blue-600 rounded-3xl flex items-center justify-center mx-auto mb-4">
              <Car className="w-10 h-10 text-white" />
            </div>
            <h2 className="text-2xl font-bold text-gray-900 mb-1">DriveApp</h2>
            <p className="text-gray-600 mb-4">Your reliable ride-sharing companion</p>
            <div className="inline-block bg-gray-100 px-4 py-2 rounded-full">
              <span className="text-sm font-semibold text-gray-700">Version 2.4.1</span>
            </div>
          </div>

          {/* Info Items */}
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            <button className="w-full p-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
              <span className="font-medium text-gray-900">What's New</span>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
            <button className="w-full p-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
              <span className="font-medium text-gray-900">Rate Us</span>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
            <button className="w-full p-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
              <span className="font-medium text-gray-900">Share App</span>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          </div>

          {/* Credits */}
          <div className="bg-white rounded-xl p-4 border border-gray-200">
            <h3 className="font-semibold text-gray-900 mb-3">Credits</h3>
            <p className="text-sm text-gray-600 leading-relaxed">
              Made with ❤️ by the DriveApp Team
              <br />
              <br />
              © 2026 DriveApp Inc. All rights reserved.
            </p>
          </div>

          {/* Social Links */}
          <div className="flex justify-center gap-4 pt-2">
            <button className="w-12 h-12 bg-white border border-gray-200 rounded-full flex items-center justify-center hover:bg-gray-50 transition-colors">
              <span className="text-xl">𝕏</span>
            </button>
            <button className="w-12 h-12 bg-white border border-gray-200 rounded-full flex items-center justify-center hover:bg-gray-50 transition-colors">
              <span className="text-xl">f</span>
            </button>
            <button className="w-12 h-12 bg-white border border-gray-200 rounded-full flex items-center justify-center hover:bg-gray-50 transition-colors">
              <span className="text-xl">in</span>
            </button>
          </div>
        </div>
      </div>
    );
  }

  return null;
}

// Missing imports at the top
import { MessageSquare, Phone, Mail, Car, Sun } from 'lucide-react';
