import { MapPin, Clock, Star, Filter, ChevronRight, RotateCcw, FileText, X, User, DollarSign, Calendar, Navigation, Phone, MessageCircle, AlertCircle, CreditCard, Send, Check } from 'lucide-react';
import { useState } from 'react';

type RideStatus = 'Complete' | 'Cancel' | 'Progress' | 'Schedule';
type RideType = 'Express' | 'Ride' | 'Delivery';

interface ChatMessage {
  id: number;
  sender: 'driver' | 'rider';
  text: string;
  time: string;
}

interface TripHistoryItem {
  id: string;
  riderName: string;
  note: string;
  date: string;
  status: RideStatus;
  rideType: RideType;
  cost: string;
  pickup: string;
  dropoff: string;
  rating?: number;
  distance?: string;
  duration?: string;
  riderPhone?: string;
  paymentMethod?: string;
  fareBreakdown?: {
    baseFare: string;
    distance: string;
    time: string;
    surge?: string;
    tip?: string;
    total: string;
  };
  startTime?: string;
  endTime?: string;
}

export function TripPage() {
  const [filterStatus, setFilterStatus] = useState<'all' | RideStatus>('all');
  const [selectedTrip, setSelectedTrip] = useState<TripHistoryItem | null>(null);
  const [showChat, setShowChat] = useState(false);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([
    { id: 1, sender: 'rider', text: 'Hi! I\'m waiting at the main entrance.', time: '2:25 PM' },
    { id: 2, sender: 'driver', text: 'Great! I\'m 2 minutes away.', time: '2:26 PM' },
    { id: 3, sender: 'rider', text: 'Perfect, see you soon!', time: '2:26 PM' }
  ]);
  const [messageInput, setMessageInput] = useState('');
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [updateAction, setUpdateAction] = useState<'complete' | 'cancel' | 'start' | 'reschedule' | null>(null);
  const [tripHistory, setTripHistory] = useState<TripHistoryItem[]>([
    {
      id: 'TRIP-12345',
      riderName: 'Sarah Johnson',
      note: 'Please wait at main entrance',
      date: 'Today, 2:30 PM',
      status: 'Complete',
      rideType: 'Ride',
      cost: '$18.50',
      pickup: '123 Main St, Downtown',
      dropoff: '456 Oak Ave, Westside',
      rating: 5,
      distance: '5.2 miles',
      duration: '15 mins',
      riderPhone: '555-1234',
      paymentMethod: 'Credit Card',
      fareBreakdown: {
        baseFare: '$10.00',
        distance: '$5.00',
        time: '$3.50',
        total: '$18.50'
      },
      startTime: '14:15:00',
      endTime: '14:30:00'
    },
    {
      id: 'TRIP-12344',
      riderName: 'Michael Chen',
      note: 'Airport pickup - Terminal 2',
      date: 'Today, 10:15 AM',
      status: 'Complete',
      rideType: 'Express',
      cost: '$42.00',
      pickup: 'International Airport',
      dropoff: '789 Business Park',
      rating: 4,
      distance: '10.5 miles',
      duration: '30 mins',
      riderPhone: '555-5678',
      paymentMethod: 'Cash',
      fareBreakdown: {
        baseFare: '$15.00',
        distance: '$15.00',
        time: '$12.00',
        total: '$42.00'
      },
      startTime: '10:00:00',
      endTime: '10:30:00'
    },
    {
      id: 'TRIP-12343',
      riderName: 'Emily Davis',
      note: 'Food delivery to apartment 5B',
      date: 'Yesterday, 8:45 PM',
      status: 'Complete',
      rideType: 'Delivery',
      cost: '$8.25',
      pickup: 'Downtown Restaurant',
      dropoff: '321 Elm St Apt 5B',
      rating: 5,
      distance: '2.3 miles',
      duration: '10 mins',
      riderPhone: '555-8765',
      paymentMethod: 'Credit Card',
      fareBreakdown: {
        baseFare: '$5.00',
        distance: '$2.00',
        time: '$1.25',
        total: '$8.25'
      },
      startTime: '20:35:00',
      endTime: '20:45:00'
    },
    {
      id: 'TRIP-12342',
      riderName: 'James Wilson',
      note: 'Going to meeting, need to hurry',
      date: 'Yesterday, 3:20 PM',
      status: 'Cancel',
      rideType: 'Express',
      cost: '$0.00',
      pickup: '555 Market St',
      dropoff: '888 Corporate Center',
    },
    {
      id: 'TRIP-12341',
      riderName: 'Lisa Anderson',
      note: '',
      date: 'Jan 14, 9:00 AM',
      status: 'Progress',
      rideType: 'Ride',
      cost: '$24.00',
      pickup: 'Current location',
      dropoff: '999 Shopping Mall',
    },
    {
      id: 'TRIP-12340',
      riderName: 'Robert Brown',
      note: 'Scheduled pickup for tomorrow morning',
      date: 'Jan 17, 7:00 AM',
      status: 'Schedule',
      rideType: 'Ride',
      cost: '$32.00',
      pickup: '147 Residential St',
      dropoff: 'City Airport',
    }
  ]);

  const getStatusColor = (status: RideStatus) => {
    switch (status) {
      case 'Complete': return 'bg-green-100 text-green-700 border-green-200';
      case 'Cancel': return 'bg-red-100 text-red-700 border-red-200';
      case 'Progress': return 'bg-blue-100 text-blue-700 border-blue-200';
      case 'Schedule': return 'bg-orange-100 text-orange-700 border-orange-200';
      default: return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  };

  const getRideTypeIcon = (type: RideType) => {
    switch (type) {
      case 'Express': return '⚡';
      case 'Ride': return '🚗';
      case 'Delivery': return '📦';
      default: return '🚗';
    }
  };

  const filteredTrips = filterStatus === 'all' 
    ? tripHistory 
    : tripHistory.filter(trip => trip.status === filterStatus);

  const handleRideAgain = (trip: TripHistoryItem) => {
    console.log('Ride again for:', trip);
    // Logic to create a new ride with same pickup/dropoff
  };

  const handleTripClick = (trip: TripHistoryItem) => {
    setSelectedTrip(trip);
  };

  const handleTripClose = () => {
    setSelectedTrip(null);
  };

  const handleChatOpen = () => {
    setShowChat(true);
  };

  const handleChatClose = () => {
    setShowChat(false);
  };

  const handleSendMessage = () => {
    if (messageInput.trim()) {
      const newMessage: ChatMessage = {
        id: chatMessages.length + 1,
        sender: 'driver',
        text: messageInput,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
      setChatMessages([...chatMessages, newMessage])
      setMessageInput('');
    }
  };

  const handleCallRider = () => {
    if (selectedTrip?.riderPhone) {
      window.location.href = `tel:${selectedTrip.riderPhone}`;
    }
  };

  const handleMessageRider = () => {
    handleChatOpen();
  };

  const handleUpdateAction = (action: 'complete' | 'cancel' | 'start' | 'reschedule') => {
    setUpdateAction(action);
    setShowUpdateModal(true);
  };

  const handleUpdateConfirm = () => {
    if (selectedTrip && updateAction) {
      const updatedTrip = { ...selectedTrip };
      switch (updateAction) {
        case 'complete':
          updatedTrip.status = 'Complete';
          break;
        case 'cancel':
          updatedTrip.status = 'Cancel';
          break;
        case 'start':
          updatedTrip.status = 'Progress';
          break;
        case 'reschedule':
          updatedTrip.status = 'Schedule';
          break;
      }
      setTripHistory(prevHistory => prevHistory.map(trip => trip.id === updatedTrip.id ? updatedTrip : trip));
      handleTripClose();
    }
    setShowUpdateModal(false);
  };

  const handleUpdateCancel = () => {
    setShowUpdateModal(false);
  };

  return (
    <div className="p-4">
      {/* Header with Filter */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-xl font-bold text-gray-900">Trip History</h2>
          <button className="p-2 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
            <Filter className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Status Filter Tabs */}
        <div className="flex gap-2 overflow-x-auto pb-2">
          <button
            onClick={() => setFilterStatus('all')}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
              filterStatus === 'all'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            All
          </button>
          <button
            onClick={() => setFilterStatus('Complete')}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
              filterStatus === 'Complete'
                ? 'bg-green-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            Complete
          </button>
          <button
            onClick={() => setFilterStatus('Progress')}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
              filterStatus === 'Progress'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            In Progress
          </button>
          <button
            onClick={() => setFilterStatus('Schedule')}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
              filterStatus === 'Schedule'
                ? 'bg-orange-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            Scheduled
          </button>
          <button
            onClick={() => setFilterStatus('Cancel')}
            className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${
              filterStatus === 'Cancel'
                ? 'bg-red-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            Cancelled
          </button>
        </div>
      </div>

      {/* Trip List */}
      <div className="space-y-3">
        {filteredTrips.map((trip) => (
          <div
            key={trip.id}
            className="bg-white rounded-xl border border-gray-200 overflow-hidden hover:shadow-md transition-all"
          >
            {/* Trip Header */}
            <div className="p-4">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3 flex-1">
                  <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold">
                    {trip.riderName.charAt(0)}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-semibold text-gray-900">{trip.riderName}</h3>
                      <span className="text-lg">{getRideTypeIcon(trip.rideType)}</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs">
                      <Clock className="w-3 h-3 text-gray-400" />
                      <span className="text-gray-600">{trip.date}</span>
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-lg font-bold text-gray-900">{trip.cost}</div>
                  <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium border ${getStatusColor(trip.status)}`}>
                    {trip.status}
                  </span>
                </div>
              </div>

              {/* Note */}
              {trip.note && (
                <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-2 mb-3">
                  <div className="flex items-start gap-2">
                    <FileText className="w-3.5 h-3.5 text-yellow-600 mt-0.5 flex-shrink-0" />
                    <p className="text-xs text-yellow-800">{trip.note}</p>
                  </div>
                </div>
              )}

              {/* Route */}
              <div className="space-y-2 mb-3">
                <div className="flex items-start gap-2">
                  <div className="w-2 h-2 rounded-full bg-blue-600 mt-1.5 flex-shrink-0"></div>
                  <div className="flex-1">
                    <div className="text-xs text-gray-500">Pickup</div>
                    <div className="text-sm font-medium text-gray-900">{trip.pickup}</div>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <MapPin className="w-2 h-2 text-red-600 mt-1.5 flex-shrink-0" />
                  <div className="flex-1">
                    <div className="text-xs text-gray-500">Dropoff</div>
                    <div className="text-sm font-medium text-gray-900">{trip.dropoff}</div>
                  </div>
                </div>
              </div>

              {/* Rating for completed trips */}
              {trip.status === 'Complete' && trip.rating && (
                <div className="flex items-center gap-1 mb-3">
                  <span className="text-xs text-gray-600">Rider Rating:</span>
                  {[...Array(5)].map((_, i) => (
                    <Star
                      key={i}
                      className={`w-3.5 h-3.5 ${
                        i < trip.rating!
                          ? 'fill-yellow-400 text-yellow-400'
                          : 'text-gray-300'
                      }`}
                    />
                  ))}
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex gap-2 pt-3 border-t border-gray-100">
                {trip.status === 'Complete' && (
                  <button
                    onClick={() => handleRideAgain(trip)}
                    className="flex-1 bg-blue-600 text-white py-2.5 rounded-lg font-medium text-sm hover:bg-blue-700 active:bg-blue-800 transition-colors flex items-center justify-center gap-2"
                  >
                    <RotateCcw className="w-4 h-4" />
                    Ride Again
                  </button>
                )}
                <button
                  onClick={() => handleTripClick(trip)}
                  className="flex-1 bg-gray-100 text-gray-700 py-2.5 rounded-lg font-medium text-sm hover:bg-gray-200 active:bg-gray-300 transition-colors flex items-center justify-center gap-2"
                >
                  View Details
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Load More */}
      {filteredTrips.length > 0 && (
        <button className="w-full mt-4 py-3 text-blue-600 font-medium hover:text-blue-700 active:text-blue-800 transition-colors">
          Load More Trips
        </button>
      )}

      {/* Empty State */}
      {filteredTrips.length === 0 && (
        <div className="text-center py-12">
          <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
            <FileText className="w-8 h-8 text-gray-400" />
          </div>
          <h3 className="font-semibold text-gray-900 mb-1">No trips found</h3>
          <p className="text-sm text-gray-600">No trips match the selected filter</p>
        </div>
      )}

      {/* Trip Details Modal */}
      {selectedTrip && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
            onClick={handleTripClose}
          ></div>
          
          {/* Modal */}
          <div className="fixed inset-4 md:inset-x-auto md:left-1/2 md:-translate-x-1/2 md:top-1/2 md:-translate-y-1/2 md:max-w-2xl md:w-full bg-white rounded-2xl shadow-2xl z-50 animate-slideUp flex flex-col max-h-[90vh]">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-5 rounded-t-2xl flex-shrink-0">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-white mb-1">Trip Details</h3>
                  <p className="text-blue-100 text-sm">Trip ID: {selectedTrip.id}</p>
                </div>
                <button
                  onClick={handleTripClose}
                  className="text-white/90 hover:text-white p-2 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
            </div>

            {/* Modal Content - Scrollable */}
            <div className="flex-1 overflow-y-auto p-5">
              {/* Rider Info Card */}
              <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-4 mb-4 border border-gray-200">
                <div className="flex items-center gap-4 mb-3">
                  <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white font-bold text-xl">
                    {selectedTrip.riderName.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="text-lg font-bold text-gray-900">{selectedTrip.riderName}</h3>
                      <span className="text-xl">{getRideTypeIcon(selectedTrip.rideType)}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Clock className="w-4 h-4" />
                      <span>{selectedTrip.date}</span>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-2xl font-bold text-green-600 mb-1">{selectedTrip.cost}</div>
                    <span className={`inline-block px-3 py-1 rounded-full text-xs font-bold border-2 ${getStatusColor(selectedTrip.status)}`}>
                      {selectedTrip.status}
                    </span>
                  </div>
                </div>

                {/* Rider Contact Actions */}
                {selectedTrip.status !== 'Cancel' && selectedTrip.riderPhone && (
                  <div className="flex gap-2 pt-3 border-t border-gray-200">
                    <button
                      onClick={handleCallRider}
                      className="flex-1 bg-blue-600 text-white py-2.5 rounded-lg font-semibold text-sm hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
                    >
                      <Phone className="w-4 h-4" />
                      Call Rider
                    </button>
                    <button
                      onClick={handleMessageRider}
                      className="flex-1 bg-green-600 text-white py-2.5 rounded-lg font-semibold text-sm hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                    >
                      <MessageCircle className="w-4 h-4" />
                      Message
                    </button>
                  </div>
                )}
              </div>

              {/* Rider Note */}
              {selectedTrip.note && (
                <div className="bg-yellow-50 border-2 border-yellow-200 rounded-xl p-4 mb-4">
                  <div className="flex items-start gap-3">
                    <FileText className="w-5 h-5 text-yellow-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <h4 className="font-bold text-yellow-900 mb-1">Rider Note</h4>
                      <p className="text-sm text-yellow-800">{selectedTrip.note}</p>
                    </div>
                  </div>
                </div>
              )}

              {/* Trip Route */}
              <div className="bg-white rounded-xl p-4 mb-4 border-2 border-gray-200">
                <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <Navigation className="w-5 h-5 text-blue-600" />
                  Trip Route
                </h4>
                <div className="space-y-4">
                  {/* Pickup */}
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
                      <div className="w-3 h-3 rounded-full bg-blue-600"></div>
                    </div>
                    <div className="flex-1 pt-1">
                      <div className="text-xs font-semibold text-gray-500 uppercase mb-1">Pickup Location</div>
                      <div className="font-semibold text-gray-900">{selectedTrip.pickup}</div>
                      {selectedTrip.startTime && (
                        <div className="text-xs text-gray-500 mt-1">{selectedTrip.startTime}</div>
                      )}
                    </div>
                  </div>

                  {/* Dotted Line */}
                  <div className="ml-5 border-l-2 border-dashed border-gray-300 h-6"></div>

                  {/* Dropoff */}
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
                      <MapPin className="w-5 h-5 text-red-600" />
                    </div>
                    <div className="flex-1 pt-1">
                      <div className="text-xs font-semibold text-gray-500 uppercase mb-1">Dropoff Location</div>
                      <div className="font-semibold text-gray-900">{selectedTrip.dropoff}</div>
                      {selectedTrip.endTime && (
                        <div className="text-xs text-gray-500 mt-1">{selectedTrip.endTime}</div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Trip Stats */}
                {(selectedTrip.distance || selectedTrip.duration) && (
                  <div className="grid grid-cols-2 gap-3 mt-4 pt-4 border-t border-gray-200">
                    {selectedTrip.distance && (
                      <div className="bg-gray-50 rounded-lg p-3">
                        <div className="flex items-center gap-2 text-gray-600 mb-1">
                          <Navigation className="w-4 h-4" />
                          <span className="text-xs font-semibold uppercase">Distance</span>
                        </div>
                        <div className="text-lg font-bold text-gray-900">{selectedTrip.distance}</div>
                      </div>
                    )}
                    {selectedTrip.duration && (
                      <div className="bg-gray-50 rounded-lg p-3">
                        <div className="flex items-center gap-2 text-gray-600 mb-1">
                          <Clock className="w-4 h-4" />
                          <span className="text-xs font-semibold uppercase">Duration</span>
                        </div>
                        <div className="text-lg font-bold text-gray-900">{selectedTrip.duration}</div>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Fare Breakdown */}
              {selectedTrip.fareBreakdown && (
                <div className="bg-white rounded-xl p-4 mb-4 border-2 border-gray-200">
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <DollarSign className="w-5 h-5 text-green-600" />
                    Fare Breakdown
                  </h4>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between py-2">
                      <span className="text-gray-600">Base Fare</span>
                      <span className="font-semibold text-gray-900">{selectedTrip.fareBreakdown.baseFare}</span>
                    </div>
                    <div className="flex items-center justify-between py-2 border-t border-gray-100">
                      <span className="text-gray-600">Distance Charge</span>
                      <span className="font-semibold text-gray-900">{selectedTrip.fareBreakdown.distance}</span>
                    </div>
                    <div className="flex items-center justify-between py-2 border-t border-gray-100">
                      <span className="text-gray-600">Time Charge</span>
                      <span className="font-semibold text-gray-900">{selectedTrip.fareBreakdown.time}</span>
                    </div>
                    {selectedTrip.fareBreakdown.surge && (
                      <div className="flex items-center justify-between py-2 border-t border-gray-100">
                        <span className="text-orange-600 font-semibold flex items-center gap-1">
                          <AlertCircle className="w-4 h-4" />
                          Surge Pricing
                        </span>
                        <span className="font-semibold text-orange-600">{selectedTrip.fareBreakdown.surge}</span>
                      </div>
                    )}
                    {selectedTrip.fareBreakdown.tip && (
                      <div className="flex items-center justify-between py-2 border-t border-gray-100">
                        <span className="text-blue-600 font-semibold">Tip</span>
                        <span className="font-semibold text-blue-600">{selectedTrip.fareBreakdown.tip}</span>
                      </div>
                    )}
                    <div className="flex items-center justify-between py-3 border-t-2 border-gray-300">
                      <span className="text-lg font-bold text-gray-900">Total Earned</span>
                      <span className="text-2xl font-bold text-green-600">{selectedTrip.fareBreakdown.total}</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Payment Method */}
              {selectedTrip.paymentMethod && (
                <div className="bg-white rounded-xl p-4 mb-4 border-2 border-gray-200">
                  <h4 className="font-bold text-gray-900 mb-2 flex items-center gap-2">
                    <CreditCard className="w-5 h-5 text-purple-600" />
                    Payment Method
                  </h4>
                  <div className="flex items-center gap-2">
                    <div className="bg-purple-100 px-3 py-1.5 rounded-full">
                      <span className="text-sm font-semibold text-purple-700">{selectedTrip.paymentMethod}</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Rider Rating */}
              {selectedTrip.status === 'Complete' && selectedTrip.rating && (
                <div className="bg-gradient-to-r from-yellow-50 to-orange-50 rounded-xl p-4 border-2 border-yellow-200">
                  <h4 className="font-bold text-gray-900 mb-3 flex items-center gap-2">
                    <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                    Rider's Rating
                  </h4>
                  <div className="flex items-center gap-2">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`w-7 h-7 ${
                          i < selectedTrip.rating!
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-300'
                        }`}
                      />
                    ))}
                    <span className="text-2xl font-bold text-gray-900 ml-2">{selectedTrip.rating}.0</span>
                  </div>
                </div>
              )}
            </div>

            {/* Modal Footer */}
            <div className="p-5 border-t border-gray-200 flex-shrink-0 bg-gray-50 rounded-b-2xl">
              {/* Progress Trip Actions */}
              {selectedTrip.status === 'Progress' && (
                <div className="space-y-3">
                  <div className="flex gap-3">
                    <button
                      onClick={() => handleUpdateAction('complete')}
                      className="flex-1 bg-green-600 text-white py-3.5 rounded-xl font-bold hover:bg-green-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                    >
                      <Check className="w-5 h-5" />
                      Complete Trip
                    </button>
                    <button
                      onClick={() => handleUpdateAction('cancel')}
                      className="flex-1 bg-red-600 text-white py-3.5 rounded-xl font-bold hover:bg-red-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                    >
                      <X className="w-5 h-5" />
                      Cancel Trip
                    </button>
                  </div>
                  <button
                    onClick={handleTripClose}
                    className="w-full bg-white text-gray-700 py-3.5 rounded-xl font-bold border-2 border-gray-300 hover:bg-gray-50 transition-colors"
                  >
                    Close
                  </button>
                </div>
              )}

              {/* Schedule Trip Actions */}
              {selectedTrip.status === 'Schedule' && (
                <div className="space-y-3">
                  <div className="flex gap-3">
                    <button
                      onClick={() => handleUpdateAction('start')}
                      className="flex-1 bg-blue-600 text-white py-3.5 rounded-xl font-bold hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                    >
                      <Navigation className="w-5 h-5" />
                      Start Trip
                    </button>
                    <button
                      onClick={() => handleUpdateAction('cancel')}
                      className="flex-1 bg-red-600 text-white py-3.5 rounded-xl font-bold hover:bg-red-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                    >
                      <X className="w-5 h-5" />
                      Cancel Trip
                    </button>
                  </div>
                  <button
                    onClick={handleTripClose}
                    className="w-full bg-white text-gray-700 py-3.5 rounded-xl font-bold border-2 border-gray-300 hover:bg-gray-50 transition-colors"
                  >
                    Close
                  </button>
                </div>
              )}

              {/* Complete Trip Actions */}
              {selectedTrip.status === 'Complete' && (
                <div className="flex gap-3">
                  <button
                    onClick={() => {
                      handleRideAgain(selectedTrip);
                      handleTripClose();
                    }}
                    className="flex-1 bg-blue-600 text-white py-3.5 rounded-xl font-bold hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                  >
                    <RotateCcw className="w-5 h-5" />
                    Suggest Again
                  </button>
                  <button
                    onClick={handleTripClose}
                    className="flex-1 bg-white text-gray-700 py-3.5 rounded-xl font-bold border-2 border-gray-300 hover:bg-gray-50 transition-colors"
                  >
                    Close
                  </button>
                </div>
              )}

              {/* Cancelled Trip Actions */}
              {selectedTrip.status === 'Cancel' && (
                <button
                  onClick={handleTripClose}
                  className="w-full bg-white text-gray-700 py-3.5 rounded-xl font-bold border-2 border-gray-300 hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
              )}
            </div>
          </div>
        </>
      )}

      {/* Chat Modal */}
      {showChat && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
            onClick={handleChatClose}
          ></div>
          
          {/* Modal */}
          <div className="fixed inset-4 md:inset-x-auto md:left-1/2 md:-translate-x-1/2 md:top-1/2 md:-translate-y-1/2 md:max-w-2xl md:w-full bg-white rounded-2xl shadow-2xl z-50 animate-slideUp flex flex-col max-h-[90vh]">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-5 rounded-t-2xl flex-shrink-0">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-white mb-1">Chat with {selectedTrip?.riderName}</h3>
                  <p className="text-blue-100 text-sm">Trip ID: {selectedTrip?.id}</p>
                </div>
                <button
                  onClick={handleChatClose}
                  className="text-white/90 hover:text-white p-2 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
            </div>

            {/* Modal Content - Scrollable */}
            <div className="flex-1 overflow-y-auto p-5 bg-gray-50">
              {/* Chat Messages */}
              <div className="space-y-3">
                {chatMessages.map(msg => (
                  <div
                    key={msg.id}
                    className={`flex ${msg.sender === 'driver' ? 'justify-end' : 'justify-start'}`}
                  >
                    <div
                      className={`max-w-[75%] ${
                        msg.sender === 'driver'
                          ? 'bg-blue-600 text-white'
                          : 'bg-white text-gray-900 border border-gray-200'
                      } p-3 rounded-2xl shadow-sm`}
                    >
                      <p className="text-sm leading-relaxed">{msg.text}</p>
                      <p className={`text-xs mt-1 ${msg.sender === 'driver' ? 'text-blue-100' : 'text-gray-500'}`}>
                        {msg.time}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Modal Footer */}
            <div className="p-5 border-t border-gray-200 flex-shrink-0 bg-white rounded-b-2xl">
              <div className="flex gap-3">
                <input
                  type="text"
                  value={messageInput}
                  onChange={(e) => setMessageInput(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                  placeholder="Type a message..."
                  className="flex-1 px-4 py-3 rounded-xl border-2 border-gray-300 focus:outline-none focus:border-blue-500 transition-colors"
                />
                <button
                  onClick={handleSendMessage}
                  className="px-5 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 shadow-lg"
                >
                  <Send className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>
        </>
      )}

      {/* Update Modal */}
      {showUpdateModal && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/50 z-50 animate-fadeIn"
            onClick={handleUpdateCancel}
          ></div>
          
          {/* Modal */}
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-sm mx-auto bg-white rounded-2xl shadow-2xl z-50 animate-slideUp">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 rounded-t-2xl">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-white">Confirm Action</h3>
                <button
                  onClick={handleUpdateCancel}
                  className="text-white/90 hover:text-white p-1.5 hover:bg-white/10 rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Modal Content */}
            <div className="p-5">
              <p className="text-center text-gray-700 mb-6">
                Are you sure you want to <span className="font-bold">{updateAction}</span> this trip?
              </p>
              <div className="flex gap-3">
                <button
                  onClick={handleUpdateCancel}
                  className="flex-1 bg-gray-100 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleUpdateConfirm}
                  className="flex-1 bg-blue-600 text-white py-3 rounded-xl font-semibold hover:bg-blue-700 transition-colors shadow-lg"
                >
                  Confirm
                </button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}