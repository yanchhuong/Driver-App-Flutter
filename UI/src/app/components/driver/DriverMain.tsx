import { useState } from 'react';
import { MapPin, Navigation, User, Bell, Settings, X, Package, Car, CheckCircle2, AlertCircle, DollarSign, MessageCircle, Send } from 'lucide-react';
import { RidesPage } from './RidesPage';
import { TripPage } from './TripPage';
import { DriverProfilePage } from './DriverProfilePage';

interface DriverMainProps {
  onLogout?: () => void;
}

type DriverTab = 'rides' | 'trip' | 'profile';

export function DriverMain({ onLogout }: DriverMainProps) {
  const [activeTab, setActiveTab] = useState<DriverTab>('rides');
  const [showNotifications, setShowNotifications] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [chatMessage, setChatMessage] = useState('');
  const [currentRider, setCurrentRider] = useState({ name: 'Sarah Johnson', id: 'TRIP-12345' });

  // Sample chat messages
  const chatMessages = [
    { id: 1, sender: 'rider', text: 'Hi! I\'m waiting at the main entrance.', time: '2:30 PM' },
    { id: 2, sender: 'driver', text: 'Great! I\'m 2 minutes away.', time: '2:31 PM' },
    { id: 3, sender: 'rider', text: 'Perfect, I can see you on the map.', time: '2:32 PM' },
    { id: 4, sender: 'driver', text: 'I\'m pulling up now. Blue Toyota.', time: '2:33 PM' },
    { id: 5, sender: 'rider', text: 'Got it, coming out now!', time: '2:33 PM' }
  ];

  // Notification data for driver
  const notifications = [
    {
      id: 'notif-1',
      type: 'ride_completed',
      title: 'Trip Completed',
      message: 'Trip to Oak Avenue completed. You earned $18.50',
      time: '10 min ago',
      icon: CheckCircle2,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: true
    },
    {
      id: 'notif-2',
      type: 'new_ride_request',
      title: 'New Ride Request',
      message: 'Pickup at 123 Main Street - 2.5 miles away',
      time: '30 min ago',
      icon: Car,
      iconColor: 'text-blue-600',
      bgColor: 'bg-blue-50',
      unread: true
    },
    {
      id: 'notif-3',
      type: 'delivery_request',
      title: 'New Delivery Request',
      message: 'Package pickup from Restaurant - $42.00',
      time: '1 hour ago',
      icon: Package,
      iconColor: 'text-purple-600',
      bgColor: 'bg-purple-50',
      unread: false
    },
    {
      id: 'notif-4',
      type: 'payment_received',
      title: 'Payment Received',
      message: 'Weekly earnings of $542.50 deposited to your account',
      time: '2 hours ago',
      icon: DollarSign,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: false
    },
    {
      id: 'notif-5',
      type: 'ride_cancelled',
      title: 'Ride Cancelled',
      message: 'Passenger cancelled the ride to Airport',
      time: '3 hours ago',
      icon: AlertCircle,
      iconColor: 'text-red-600',
      bgColor: 'bg-red-50',
      unread: false
    },
    {
      id: 'notif-6',
      type: 'bonus_earned',
      title: 'Bonus Earned!',
      message: 'You completed 10 rides today. Bonus: $25.00',
      time: 'Yesterday',
      icon: DollarSign,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: false
    }
  ];

  const unreadCount = notifications.filter(n => n.unread).length;

  const tabs = [
    { id: 'rides', label: 'Rides', icon: MapPin },
    { id: 'trip', label: 'Trip', icon: Navigation },
    { id: 'profile', label: 'Profile', icon: User }
  ];

  const renderContent = () => {
    switch (activeTab) {
      case 'rides':
        return <RidesPage />;
      case 'trip':
        return <TripPage />;
      case 'profile':
        return <DriverProfilePage onLogout={onLogout} />;
      default:
        return <RidesPage />;
    }
  };

  return (
    <div className="h-screen bg-gray-50 flex flex-col overflow-hidden">
      {/* Top Bar */}
      <div className="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between flex-shrink-0 z-20">
        <div className="flex items-center gap-3">
          <h1 className="text-lg font-bold text-gray-900">DriveApp</h1>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={() => setShowChat(true)}
            className="relative p-2 hover:bg-gray-100 rounded-full transition-colors active:scale-95"
          >
            <MessageCircle className="w-5 h-5 text-gray-700" />
          </button>
          <button 
            onClick={() => setShowNotifications(true)}
            className="relative p-2 hover:bg-gray-100 rounded-full transition-colors active:scale-95"
          >
            <Bell className="w-5 h-5 text-gray-700" />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            )}
          </button>
        </div>
      </div>

      {/* Main Content - Scrollable */}
      <div className="flex-1 overflow-y-auto">
        {renderContent()}
      </div>

      {/* Bottom Navigation */}
      <div className="bg-white border-t border-gray-200 px-2 py-2 safe-area-pb flex-shrink-0">
        <div className="flex items-center justify-around max-w-md mx-auto">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as DriverTab)}
                className={`flex flex-col items-center justify-center gap-1 py-2 px-4 rounded-lg transition-all active:scale-95 ${
                  isActive
                    ? 'text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <Icon className={`w-5 h-5 ${isActive ? 'stroke-[2.5]' : ''}`} />
                <span className={`text-xs ${isActive ? 'font-semibold' : 'font-medium'}`}>
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Notifications Panel */}
      {showNotifications && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/30 z-40 animate-fadeIn"
            onClick={() => setShowNotifications(false)}
          ></div>
          
          {/* Notifications Panel - Half Screen Floating */}
          <div className="fixed top-16 right-4 w-80 max-h-[50vh] bg-white shadow-2xl z-50 flex flex-col animate-slideInRight rounded-2xl overflow-hidden">
            {/* Notifications Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 flex-shrink-0">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-white">Notifications</h3>
                <button
                  onClick={() => setShowNotifications(false)}
                  className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
              {unreadCount > 0 && (
                <p className="text-xs text-blue-100 mt-1">{unreadCount} unread</p>
              )}
            </div>

            {/* Notifications Content - Scrollable */}
            <div className="flex-1 overflow-y-auto">
              {/* Notifications List */}
              <div className="p-3 space-y-2">
                {notifications.map((notif) => {
                  const Icon = notif.icon;
                  return (
                    <div
                      key={notif.id}
                      className={`flex gap-2 p-2.5 rounded-lg transition-all hover:shadow-sm cursor-pointer ${
                        notif.unread ? 'bg-blue-50 border border-blue-100' : 'bg-gray-50 border border-gray-100'
                      }`}
                    >
                      <div className={`w-8 h-8 rounded-full ${notif.bgColor} flex items-center justify-center flex-shrink-0`}>
                        <Icon className={`w-4 h-4 ${notif.iconColor}`} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2 mb-0.5">
                          <p className="font-semibold text-gray-900 text-xs">{notif.title}</p>
                          {notif.unread && (
                            <div className="w-1.5 h-1.5 bg-blue-600 rounded-full flex-shrink-0 mt-1"></div>
                          )}
                        </div>
                        <p className="text-xs text-gray-600 line-clamp-2">{notif.message}</p>
                        <p className="text-xs text-gray-400 mt-0.5">{notif.time}</p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Notifications Footer */}
            <div className="border-t border-gray-200 p-3 flex-shrink-0">
              <button 
                onClick={() => setShowNotifications(false)}
                className="w-full text-sm px-3 py-2 text-blue-600 font-semibold hover:bg-blue-50 rounded-lg transition-colors"
              >
                Mark All as Read
              </button>
            </div>
          </div>
        </>
      )}

      {/* Chat Panel */}
      {showChat && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/30 z-40 animate-fadeIn"
            onClick={() => setShowChat(false)}
          ></div>
          
          {/* Chat Panel - Half Screen Floating */}
          <div className="fixed top-16 right-4 w-80 max-h-[50vh] bg-white shadow-2xl z-50 flex flex-col animate-slideInRight rounded-2xl overflow-hidden">
            {/* Chat Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 flex-shrink-0">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-bold text-white">Chat with {currentRider.name}</h3>
                  <p className="text-xs text-blue-100">Trip ID: {currentRider.id}</p>
                </div>
                <button
                  onClick={() => setShowChat(false)}
                  className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Chat Content - Scrollable */}
            <div className="flex-1 overflow-y-auto">
              {/* Chat List */}
              <div className="p-3 space-y-2">
                {chatMessages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`flex flex-col ${msg.sender === 'driver' ? 'items-end' : 'items-start'}`}
                  >
                    <div className={`max-w-[75%] rounded-lg p-3 ${
                      msg.sender === 'driver' 
                        ? 'bg-blue-600 text-white' 
                        : 'bg-gray-200 text-gray-900'
                    }`}>
                      <p className="text-sm">{msg.text}</p>
                    </div>
                    <p className="text-xs text-gray-400 mt-1 px-1">{msg.time}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Chat Footer */}
            <div className="border-t border-gray-200 p-3 flex-shrink-0">
              <div className="flex items-center">
                <input
                  type="text"
                  value={chatMessage}
                  onChange={(e) => setChatMessage(e.target.value)}
                  className="flex-1 px-3 py-2 text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Type a message..."
                />
                <button
                  className="p-2 hover:bg-gray-100 rounded-full transition-colors active:scale-95"
                >
                  <Send className="w-5 h-5 text-gray-700" />
                </button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}