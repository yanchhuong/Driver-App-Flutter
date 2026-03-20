import { Phone, MessageSquare, MapPin, Star, Navigation, Clock, X, Loader2, Send } from 'lucide-react';
import { useState, useEffect, useRef } from 'react';
import { 
  getRidesForRider, 
  subscribeToRide,
  type RideRequest 
} from '../../utils/rideStateManager';

interface ActiveRidePageProps {
  onClose: () => void;
}

interface Message {
  id: number;
  sender: 'rider' | 'driver';
  text: string;
  time: string;
}

export function ActiveRidePage({ onClose }: ActiveRidePageProps) {
  const [isSearching, setIsSearching] = useState(true);
  const [currentRide, setCurrentRide] = useState<RideRequest | null>(null);
  const [showMessageModal, setShowMessageModal] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      sender: 'driver',
      text: 'Hi! I\'m on my way to pick you up.',
      time: '2:30 PM'
    }
  ]);
  const [newMessage, setNewMessage] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Get the rider's most recent ride request
    const riderId = 'rider-123'; // In a real app, this would be the actual user ID
    const riderRides = getRidesForRider(riderId);
    
    // Get the most recent ride (last in array)
    const latestRide = riderRides[riderRides.length - 1];
    
    if (!latestRide) {
      console.error('No ride found for rider');
      return;
    }

    console.log('Tracking ride:', latestRide);

    // Check if ride is already accepted
    if (latestRide.status === 'accepted') {
      setCurrentRide(latestRide);
      setIsSearching(false);
    }

    // Subscribe to ride updates
    const unsubscribe = subscribeToRide(latestRide.id, (updatedRide) => {
      if (updatedRide) {
        console.log('Ride updated:', updatedRide);
        setCurrentRide(updatedRide);
        
        // If ride is accepted, stop searching
        if (updatedRide.status === 'accepted') {
          setIsSearching(false);
        }
      }
    });

    // Poll every 2 seconds as fallback
    const pollInterval = setInterval(() => {
      const rides = getRidesForRider(riderId);
      const ride = rides.find(r => r.id === latestRide.id);
      if (ride && ride.status === 'accepted') {
        setCurrentRide(ride);
        setIsSearching(false);
      }
    }, 2000);

    return () => {
      unsubscribe();
      clearInterval(pollInterval);
    };
  }, []);

  useEffect(() => {
    // Scroll to bottom when new messages arrive
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = () => {
    if (newMessage.trim()) {
      const now = new Date();
      const timeString = now.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit',
        hour12: true 
      });

      setMessages([...messages, {
        id: messages.length + 1,
        sender: 'rider',
        text: newMessage,
        time: timeString
      }]);
      setNewMessage('');

      // Simulate driver response after 2 seconds
      setTimeout(() => {
        setMessages(prev => [...prev, {
          id: prev.length + 1,
          sender: 'driver',
          text: 'Got it! See you soon.',
          time: new Date().toLocaleTimeString('en-US', { 
            hour: 'numeric', 
            minute: '2-digit',
            hour12: true 
          })
        }]);
      }, 2000);
    }
  };

  const handleCallDriver = () => {
    if (currentRide?.driverPhone) {
      // This will trigger the phone dialer
      window.location.href = `tel:${currentRide.driverPhone}`;
    }
  };

  const driverInfo = currentRide ? {
    name: currentRide.driverName || 'Driver',
    phone: currentRide.driverPhone || '+1 (555) 123-4567',
    rating: currentRide.driverRating || 4.9,
    carModel: currentRide.carModel || 'Toyota Camry',
    carPlate: currentRide.carPlate || 'ABC 1234',
    carColor: currentRide.carColor || 'Black',
    arrivalTime: '3 minutes'
  } : {
    name: 'Driver',
    phone: '+1 (555) 123-4567',
    rating: 4.9,
    carModel: 'Toyota Camry',
    carPlate: 'ABC 1234',
    carColor: 'Black',
    arrivalTime: '3 minutes'
  };

  const rideDetails = currentRide ? {
    pickup: currentRide.pickup,
    dropoff: currentRide.dropoff,
    estimatedFare: currentRide.estimatedPrice,
    distance: currentRide.distance
  } : {
    pickup: 'Current Location',
    dropoff: '123 Main St, Downtown',
    estimatedFare: '$18.50',
    distance: '5.2 km'
  };

  // Show "Finding Driver" view first
  if (isSearching) {
    return (
      <div className="h-full flex flex-col bg-white">
        {/* Map Area */}
        <div className="bg-gradient-to-br from-blue-100 to-green-100 h-96 relative">
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center">
              <div className="relative w-24 h-24 mx-auto mb-4">
                <div className="absolute inset-0 rounded-full bg-blue-200 animate-ping opacity-75"></div>
                <div className="absolute inset-0 rounded-full bg-blue-100"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <Loader2 className="w-12 h-12 text-blue-600 animate-spin" />
                </div>
              </div>
              <p className="text-gray-700 font-semibold text-lg">Finding Driver</p>
              <p className="text-sm text-gray-600 mt-1">Searching nearby drivers...</p>
            </div>
          </div>

          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-4 left-4 bg-white rounded-full p-2 shadow-lg hover:bg-gray-50 active:bg-gray-100 transition-colors"
          >
            <X className="w-5 h-5 text-gray-700" />
          </button>

          {/* Current Location Pin */}
          <div className="absolute bottom-20 left-1/2 -translate-x-1/2">
            <div className="relative">
              <div className="w-4 h-4 bg-blue-600 rounded-full border-4 border-white shadow-lg animate-pulse"></div>
            </div>
          </div>
        </div>

        {/* Searching Info Card */}
        <div className="flex-1 bg-white rounded-t-3xl -mt-8 relative z-10 shadow-2xl p-6 overflow-y-auto">
          {/* Drag Handle */}
          <div className="flex justify-center mb-6">
            <div className="w-12 h-1 bg-gray-300 rounded-full"></div>
          </div>

          {/* Loading Animation */}
          <div className="text-center mb-6">
            <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-blue-50 mb-4">
              <Loader2 className="w-10 h-10 text-blue-600 animate-spin" />
            </div>
            <h2 className="font-bold text-gray-900 mb-2">Finding Your Driver</h2>
            <p className="text-gray-600 text-sm">We're matching you with the best available driver nearby</p>
          </div>

          {/* Trip Preview */}
          <div className="bg-gray-50 rounded-2xl p-4 mb-4">
            <h3 className="font-semibold text-gray-900 mb-3 text-sm">Trip Details</h3>
            
            {/* Pickup */}
            <div className="flex gap-3 mb-3">
              <div className="flex flex-col items-center">
                <div className="w-3 h-3 rounded-full bg-green-500 mt-1"></div>
                <div className="w-0.5 h-8 bg-gray-300 my-1"></div>
              </div>
              <div className="flex-1">
                <div className="text-xs text-gray-600 mb-1">Pickup</div>
                <div className="font-medium text-gray-900">{rideDetails.pickup}</div>
              </div>
            </div>

            {/* Dropoff */}
            <div className="flex gap-3">
              <div className="flex flex-col items-center">
                <MapPin className="w-3 h-3 text-red-600 mt-1" />
              </div>
              <div className="flex-1">
                <div className="text-xs text-gray-600 mb-1">Dropoff</div>
                <div className="font-medium text-gray-900">{rideDetails.dropoff}</div>
              </div>
            </div>
          </div>

          {/* Estimated Fare */}
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-2xl p-4 mb-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Estimated Fare</span>
              <span className="font-bold text-blue-600 text-lg">{rideDetails.estimatedFare}</span>
            </div>
          </div>

          {/* Progress Dots */}
          <div className="flex items-center justify-center gap-2 mb-6">
            <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce"></div>
            <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
            <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
          </div>

          {/* Cancel Button */}
          <button
            onClick={onClose}
            className="w-full border-2 border-gray-200 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-50 active:bg-gray-100 transition-colors"
          >
            Cancel Request
          </button>
        </div>
      </div>
    );
  }

  // Show driver details after finding
  return (
    <div className="h-full flex flex-col bg-white">
      {/* Map Area */}
      <div className="bg-gradient-to-br from-blue-100 to-green-100 h-96 relative">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <MapPin className="w-16 h-16 text-blue-600 mx-auto mb-2 animate-bounce" />
            <p className="text-gray-700 font-medium">Live Tracking</p>
            <p className="text-sm text-gray-600">Driver is on the way</p>
          </div>
        </div>

        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 left-4 bg-white rounded-full p-2 shadow-lg hover:bg-gray-50 active:bg-gray-100 transition-colors"
        >
          <X className="w-5 h-5 text-gray-700" />
        </button>

        {/* ETA Badge */}
        <div className="absolute top-4 right-4 bg-white rounded-full px-4 py-2 shadow-lg">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-blue-600" />
            <span className="text-sm font-semibold text-gray-900">{driverInfo.arrivalTime}</span>
          </div>
        </div>

        {/* Current Location Pin */}
        <div className="absolute bottom-20 left-1/2 -translate-x-1/2">
          <div className="relative">
            <div className="w-4 h-4 bg-blue-600 rounded-full border-4 border-white shadow-lg animate-pulse"></div>
          </div>
        </div>
      </div>

      {/* Driver Info Card */}
      <div className="flex-1 bg-white rounded-t-3xl -mt-8 relative z-10 shadow-2xl p-5 overflow-y-auto">
        {/* Drag Handle */}
        <div className="flex justify-center mb-4">
          <div className="w-12 h-1 bg-gray-300 rounded-full"></div>
        </div>

        {/* Status */}
        <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 mb-4 flex items-center gap-2">
          <div className="w-2 h-2 bg-blue-600 rounded-full animate-pulse"></div>
          <span className="text-sm font-semibold text-blue-700">Driver is on the way</span>
        </div>

        {/* Driver Profile */}
        <div className="bg-gray-50 rounded-2xl p-4 mb-4">
          <div className="flex items-center gap-4 mb-3">
            <div className="w-16 h-16 rounded-full bg-blue-600 flex items-center justify-center text-white text-xl font-bold shadow-lg">
              {driverInfo.name.split(' ').map(n => n[0]).join('')}
            </div>
            <div className="flex-1">
              <h2 className="font-bold text-gray-900 mb-1">{driverInfo.name}</h2>
              <div className="flex items-center gap-1 mb-1">
                <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                <span className="text-sm font-semibold text-gray-700">{driverInfo.rating}</span>
                <span className="text-xs text-gray-500">(247 trips)</span>
              </div>
              <div className="text-sm text-gray-600">
                {driverInfo.carColor} {driverInfo.carModel} • {driverInfo.carPlate}
              </div>
            </div>
          </div>

          {/* Contact Buttons */}
          <div className="flex gap-2">
            <a
              href={`tel:${driverInfo.phone}`}
              className="flex-1 bg-blue-600 text-white py-3 rounded-xl font-semibold hover:bg-blue-700 active:bg-blue-800 transition-colors flex items-center justify-center gap-2 shadow-md"
            >
              <Phone className="w-5 h-5" />
              Call Driver
            </a>
            <button
              onClick={() => setShowMessageModal(true)}
              className="flex-1 bg-white border-2 border-gray-200 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-50 active:bg-gray-100 transition-colors flex items-center justify-center gap-2"
            >
              <MessageSquare className="w-5 h-5" />
              Message
            </button>
          </div>

          {/* Phone Number */}
          <div className="mt-3 pt-3 border-t border-gray-200">
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600">Phone:</span>
              <span className="font-semibold text-gray-900">{driverInfo.phone}</span>
            </div>
          </div>
        </div>

        {/* Trip Details */}
        <div className="mb-4">
          <h3 className="font-semibold text-gray-900 mb-3">Trip Details</h3>
          
          {/* Pickup */}
          <div className="flex gap-3 mb-3">
            <div className="flex flex-col items-center">
              <div className="w-3 h-3 rounded-full bg-green-500 mt-1"></div>
              <div className="w-0.5 h-8 bg-gray-300 my-1"></div>
            </div>
            <div className="flex-1 bg-gray-50 rounded-xl p-3">
              <div className="text-xs text-gray-600 mb-1">Pickup</div>
              <div className="font-semibold text-gray-900">{rideDetails.pickup}</div>
            </div>
          </div>

          {/* Dropoff */}
          <div className="flex gap-3">
            <div className="flex flex-col items-center">
              <MapPin className="w-3 h-3 text-red-600 mt-1" />
            </div>
            <div className="flex-1 bg-gray-50 rounded-xl p-3">
              <div className="text-xs text-gray-600 mb-1">Dropoff</div>
              <div className="font-semibold text-gray-900">{rideDetails.dropoff}</div>
            </div>
          </div>
        </div>

        {/* Fare Info */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-2xl p-4 mb-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Distance</span>
            <span className="font-semibold text-gray-900">{rideDetails.distance}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Estimated Fare</span>
            <span className="font-bold text-blue-600">{rideDetails.estimatedFare}</span>
          </div>
        </div>

        {/* Safety Features */}
        <div className="border-2 border-gray-200 rounded-xl p-4 mb-4">
          <h3 className="font-semibold text-gray-900 mb-2 text-sm">Safety</h3>
          <div className="space-y-2">
            <button className="w-full text-left py-2 text-sm text-gray-700 hover:text-gray-900 flex items-center justify-between">
              <span>Share trip status</span>
              <span className="text-blue-600">→</span>
            </button>
            <button className="w-full text-left py-2 text-sm text-red-600 hover:text-red-700 flex items-center justify-between">
              <span>Emergency SOS</span>
              <span>🚨</span>
            </button>
          </div>
        </div>

        {/* Cancel Button */}
        <button className="w-full border-2 border-red-200 text-red-600 py-3 rounded-xl font-semibold hover:bg-red-50 active:bg-red-100 transition-colors">
          Cancel Ride
        </button>
      </div>

      {/* Message Modal */}
      {showMessageModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl flex flex-col max-h-[80vh]">
            {/* Header */}
            <div className="flex justify-between items-center p-5 border-b border-gray-200">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold">
                  {driverInfo.name.split(' ').map(n => n[0]).join('')}
                </div>
                <div>
                  <h3 className="font-bold text-gray-900">{driverInfo.name}</h3>
                  <p className="text-xs text-green-600 flex items-center gap-1">
                    <span className="w-2 h-2 bg-green-600 rounded-full"></span>
                    Online
                  </p>
                </div>
              </div>
              <button
                onClick={() => setShowMessageModal(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-5 space-y-3 bg-gray-50">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex ${msg.sender === 'rider' ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-[75%] ${
                      msg.sender === 'rider'
                        ? 'bg-blue-600 text-white rounded-2xl rounded-tr-sm'
                        : 'bg-white text-gray-900 rounded-2xl rounded-tl-sm shadow-sm'
                    } px-4 py-2.5`}
                  >
                    <p className="text-sm leading-relaxed">{msg.text}</p>
                    <p className={`text-xs mt-1 ${
                      msg.sender === 'rider' ? 'text-blue-100' : 'text-gray-500'
                    }`}>
                      {msg.time}
                    </p>
                  </div>
                </div>
              ))}
              <div ref={messagesEndRef} />
            </div>

            {/* Quick Replies */}
            <div className="px-5 py-2 border-t border-gray-200 bg-white">
              <div className="flex gap-2 overflow-x-auto pb-2">
                <button
                  onClick={() => {
                    setNewMessage("I'm waiting at the main entrance");
                  }}
                  className="text-xs px-3 py-1.5 bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 transition-colors whitespace-nowrap"
                >
                  📍 At main entrance
                </button>
                <button
                  onClick={() => {
                    setNewMessage("I'll be there in 2 minutes");
                  }}
                  className="text-xs px-3 py-1.5 bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 transition-colors whitespace-nowrap"
                >
                  ⏰ 2 minutes
                </button>
                <button
                  onClick={() => {
                    setNewMessage("Thank you!");
                  }}
                  className="text-xs px-3 py-1.5 bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 transition-colors whitespace-nowrap"
                >
                  👍 Thank you
                </button>
              </div>
            </div>

            {/* Input */}
            <div className="p-4 border-t border-gray-200 bg-white rounded-b-3xl">
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      handleSendMessage();
                    }
                  }}
                  placeholder="Type a message..."
                  className="flex-1 px-4 py-3 bg-gray-100 border-0 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                />
                <button
                  onClick={handleSendMessage}
                  disabled={!newMessage.trim()}
                  className={`p-3 rounded-xl transition-all ${
                    newMessage.trim()
                      ? 'bg-blue-600 text-white hover:bg-blue-700 active:scale-95'
                      : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  }`}
                >
                  <Send className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}