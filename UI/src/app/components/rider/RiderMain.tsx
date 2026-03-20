import { useState } from 'react';
import { Home, History, DollarSign, User, Bell, Settings, Package, Car, CheckCircle2, AlertCircle, X, MapPin, MessageCircle, Send, ArrowLeft } from 'lucide-react';
import { HomePage } from './HomePage';
import { HistoryPage } from './HistoryPage';
import { SettlePage } from './SettlePage';
import { RiderProfilePage } from './RiderProfilePage';
import { ActiveRidePage } from './ActiveRidePage';

interface RiderMainProps {
  onLogout?: () => void;
}

type RiderTab = 'home' | 'history' | 'settle' | 'profile';

export function RiderMain({ onLogout }: RiderMainProps) {
  const [activeTab, setActiveTab] = useState<RiderTab>('home');
  const [showActiveRide, setShowActiveRide] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [chatMessage, setChatMessage] = useState('');
  const [selectedContact, setSelectedContact] = useState<string | null>(null);

  // Chat contacts data
  const chatContacts = [
    {
      id: 'contact-1',
      name: 'John Smith',
      avatar: 'JS',
      lastMessage: 'Hello, how are you?',
      time: '2 min ago',
      unread: true
    },
    {
      id: 'contact-2',
      name: 'Emily Johnson',
      avatar: 'EJ',
      lastMessage: 'Your package is on the way!',
      time: '15 min ago',
      unread: true
    },
    {
      id: 'contact-3',
      name: 'Michael Brown',
      avatar: 'MB',
      lastMessage: 'Thank you for the ride!',
      time: '1 hour ago',
      unread: false
    },
    {
      id: 'contact-4',
      name: 'Sarah Davis',
      avatar: 'SD',
      lastMessage: 'See you tomorrow',
      time: '2 hours ago',
      unread: false
    }
  ];

  // Chat messages for each contact
  const chatMessages: Record<string, Array<{id: string, sender: 'me' | 'them', text: string, time: string}>> = {
    'contact-1': [
      { id: 'msg-1', sender: 'them', text: 'Hi! I\'m on my way to pick you up.', time: '10:30 AM' },
      { id: 'msg-2', sender: 'me', text: 'Great! I\'ll be ready in 2 minutes.', time: '10:31 AM' },
      { id: 'msg-3', sender: 'them', text: 'Perfect! I\'m driving a blue Toyota Camry.', time: '10:32 AM' },
      { id: 'msg-4', sender: 'them', text: 'Hello, how are you?', time: '10:35 AM' }
    ],
    'contact-2': [
      { id: 'msg-1', sender: 'them', text: 'I have your package!', time: '9:15 AM' },
      { id: 'msg-2', sender: 'me', text: 'Awesome! How far are you?', time: '9:16 AM' },
      { id: 'msg-3', sender: 'them', text: 'About 5 minutes away', time: '9:17 AM' },
      { id: 'msg-4', sender: 'them', text: 'Your package is on the way!', time: '9:20 AM' }
    ],
    'contact-3': [
      { id: 'msg-1', sender: 'them', text: 'Thanks for choosing our service!', time: 'Yesterday' },
      { id: 'msg-2', sender: 'me', text: 'The ride was excellent!', time: 'Yesterday' },
      { id: 'msg-3', sender: 'them', text: 'Thank you for the ride!', time: 'Yesterday' }
    ],
    'contact-4': [
      { id: 'msg-1', sender: 'me', text: 'Can we schedule a ride for tomorrow?', time: 'Yesterday' },
      { id: 'msg-2', sender: 'them', text: 'Sure! What time?', time: 'Yesterday' },
      { id: 'msg-3', sender: 'me', text: '8:00 AM please', time: 'Yesterday' },
      { id: 'msg-4', sender: 'them', text: 'See you tomorrow', time: 'Yesterday' }
    ]
  };

  const handleContactClick = (contactId: string) => {
    setSelectedContact(contactId);
  };

  const handleBackToContacts = () => {
    setSelectedContact(null);
  };

  const handleSendMessage = () => {
    if (chatMessage.trim()) {
      // In a real app, this would send the message to the backend
      console.log('Sending message:', chatMessage);
      setChatMessage('');
    }
  };

  // Notification data
  const notifications = [
    {
      id: 'notif-1',
      type: 'ride_completed',
      title: 'Ride Completed',
      message: 'Your ride to Oak Avenue has been completed. Total fare: $18.50',
      time: '5 min ago',
      icon: CheckCircle2,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: true
    },
    {
      id: 'notif-2',
      type: 'driver_arrived',
      title: 'Driver Arrived',
      message: 'John Smith has arrived at your pickup location',
      time: '1 hour ago',
      icon: Car,
      iconColor: 'text-blue-600',
      bgColor: 'bg-blue-50',
      unread: true
    },
    {
      id: 'notif-3',
      type: 'delivery_assigned',
      title: 'Delivery Driver Assigned',
      message: 'Emily Johnson is on the way to pick up your package',
      time: '2 hours ago',
      icon: Package,
      iconColor: 'text-purple-600',
      bgColor: 'bg-purple-50',
      unread: false
    },
    {
      id: 'notif-4',
      type: 'ride_started',
      title: 'Ride Started',
      message: 'Your ride to Central Market has started',
      time: '3 hours ago',
      icon: MapPin,
      iconColor: 'text-blue-600',
      bgColor: 'bg-blue-50',
      unread: false
    },
    {
      id: 'notif-5',
      type: 'delivery_completed',
      title: 'Delivery Completed',
      message: 'Your package has been delivered to 456 Oak Avenue',
      time: '5 hours ago',
      icon: CheckCircle2,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: false
    },
    {
      id: 'notif-6',
      type: 'payment_success',
      title: 'Payment Successful',
      message: 'Payment of $42.00 processed successfully',
      time: 'Yesterday',
      icon: DollarSign,
      iconColor: 'text-green-600',
      bgColor: 'bg-green-50',
      unread: false
    },
    {
      id: 'notif-7',
      type: 'ride_cancelled',
      title: 'Ride Cancelled',
      message: 'Your scheduled ride has been cancelled',
      time: '2 days ago',
      icon: AlertCircle,
      iconColor: 'text-red-600',
      bgColor: 'bg-red-50',
      unread: false
    }
  ];

  const unreadCount = notifications.filter(n => n.unread).length;

  const tabs = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'history', label: 'History', icon: History },
    { id: 'settle', label: 'Settle', icon: DollarSign },
    { id: 'profile', label: 'Profile', icon: User }
  ];

  const renderContent = () => {
    if (showActiveRide) {
      return <ActiveRidePage onClose={() => setShowActiveRide(false)} />;
    }

    switch (activeTab) {
      case 'home':
        return <HomePage onRideStarted={() => setShowActiveRide(true)} />;
      case 'history':
        return <HistoryPage />;
      case 'settle':
        return <SettlePage />;
      case 'profile':
        return <RiderProfilePage onLogout={onLogout} />;
      default:
        return <HomePage onRideStarted={() => setShowActiveRide(true)} />;
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
      {!showActiveRide && (
        <div className="bg-white border-t border-gray-200 px-2 py-2 safe-area-pb flex-shrink-0">
          <div className="flex items-center justify-around max-w-md mx-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as RiderTab)}
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
      )}

      {/* Notifications Modal */}
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

      {/* Settings Modal */}
      {showSettings && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/30 z-40 animate-fadeIn"
            onClick={() => setShowSettings(false)}
          ></div>
          
          {/* Settings Panel - Half Screen Floating */}
          <div className="fixed top-16 right-4 w-80 max-h-[50vh] bg-white shadow-2xl z-50 flex flex-col animate-slideInRight rounded-2xl overflow-hidden">
            {/* Settings Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 flex-shrink-0">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-white">Settings</h3>
                <button
                  onClick={() => setShowSettings(false)}
                  className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Settings Content - Scrollable */}
            <div className="flex-1 overflow-y-auto">
              {/* Settings List */}
              <div className="p-3 space-y-2">
                <div className="flex gap-2 p-2.5 rounded-lg transition-all hover:shadow-sm cursor-pointer bg-gray-50 border border-gray-100">
                  <div className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center flex-shrink-0">
                    <Settings className="w-4 h-4 text-gray-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-0.5">
                      <p className="font-semibold text-gray-900 text-xs">General Settings</p>
                    </div>
                    <p className="text-xs text-gray-600 line-clamp-2">Manage your account settings and preferences.</p>
                  </div>
                </div>
                <div className="flex gap-2 p-2.5 rounded-lg transition-all hover:shadow-sm cursor-pointer bg-gray-50 border border-gray-100">
                  <div className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center flex-shrink-0">
                    <Bell className="w-4 h-4 text-gray-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-0.5">
                      <p className="font-semibold text-gray-900 text-xs">Notification Settings</p>
                    </div>
                    <p className="text-xs text-gray-600 line-clamp-2">Configure how you receive notifications.</p>
                  </div>
                </div>
                <div className="flex gap-2 p-2.5 rounded-lg transition-all hover:shadow-sm cursor-pointer bg-gray-50 border border-gray-100">
                  <div className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center flex-shrink-0">
                    <User className="w-4 h-4 text-gray-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-0.5">
                      <p className="font-semibold text-gray-900 text-xs">Profile Settings</p>
                    </div>
                    <p className="text-xs text-gray-600 line-clamp-2">Update your profile information.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </>
      )}

      {/* Chat Modal */}
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
                {selectedContact ? (
                  <>
                    <div className="flex items-center gap-3">
                      <button
                        onClick={handleBackToContacts}
                        className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                      >
                        <ArrowLeft className="w-4 h-4" />
                      </button>
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
                          <User className="w-4 h-4 text-white" />
                        </div>
                        <div>
                          <p className="font-semibold text-white text-sm">{chatContacts.find(c => c.id === selectedContact)?.name}</p>
                          <p className="text-xs text-white/70">{chatContacts.find(c => c.id === selectedContact)?.time}</p>
                        </div>
                      </div>
                    </div>
                    <button
                      onClick={() => setShowChat(false)}
                      className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </>
                ) : (
                  <>
                    <h3 className="text-lg font-bold text-white">Chat</h3>
                    <button
                      onClick={() => setShowChat(false)}
                      className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </>
                )}
              </div>
            </div>

            {/* Chat Content - Scrollable */}
            <div className="flex-1 overflow-y-auto">
              {/* Chat List */}
              <div className="p-3 space-y-2">
                {selectedContact ? (
                  <div className="space-y-2">
                    {chatMessages[selectedContact]?.map(msg => (
                      <div
                        key={msg.id}
                        className={`flex ${msg.sender === 'me' ? 'justify-end' : 'justify-start'} mb-2`}
                      >
                        <div
                          className={`p-2 rounded-lg max-w-[75%] ${msg.sender === 'me' ? 'bg-blue-500 text-white' : 'bg-gray-50 text-gray-900'}`}
                        >
                          <p className="text-xs">{msg.text}</p>
                          <p className={`text-xs mt-0.5 ${msg.sender === 'me' ? 'text-white/70' : 'text-gray-400'}`}>{msg.time}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  chatContacts.map(contact => (
                    <div
                      key={contact.id}
                      className={`flex gap-2 p-2.5 rounded-lg transition-all hover:shadow-sm cursor-pointer bg-gray-50 border border-gray-100 ${
                        contact.unread ? 'bg-blue-50 border border-blue-100' : ''
                      }`}
                      onClick={() => handleContactClick(contact.id)}
                    >
                      <div className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center flex-shrink-0">
                        <User className="w-4 h-4 text-gray-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2 mb-0.5">
                          <p className="font-semibold text-gray-900 text-xs">{contact.name}</p>
                          {contact.unread && (
                            <div className="w-1.5 h-1.5 bg-blue-600 rounded-full flex-shrink-0 mt-1"></div>
                          )}
                        </div>
                        <p className="text-xs text-gray-600 line-clamp-2">{contact.lastMessage}</p>
                        <p className="text-xs text-gray-400 mt-0.5">{contact.time}</p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Chat Footer */}
            <div className="border-t border-gray-200 p-3 flex-shrink-0">
              <div className="flex items-center">
                <input
                  type="text"
                  value={chatMessage}
                  onChange={(e) => setChatMessage(e.target.value)}
                  className="w-full text-sm px-3 py-2 bg-gray-50 border border-gray-300 rounded-lg transition-colors focus:outline-none focus:border-blue-500"
                  placeholder="Type a message..."
                />
                <button
                  onClick={handleSendMessage}
                  className="ml-2 text-sm px-3 py-2 text-blue-600 font-semibold hover:bg-blue-50 rounded-lg transition-colors"
                >
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}