import { MapPin, Clock, DollarSign, Navigation2, Map, List, X } from 'lucide-react';
import { useState, useEffect } from 'react';
import { 
  getRidesByStatus, 
  acceptRide, 
  subscribeToRideUpdates,
  type RideRequest 
} from '../../utils/rideStateManager';

interface Ride {
  id: number;
  pickup: string;
  dropoff: string;
  distance: string;
  estimatedTime: string;
  fare: string;
  surgeMultiplier: number | null;
  riderLocation: { lat: number; lng: number };
}

export function RidesPage() {
  const [selectedRide, setSelectedRide] = useState<RideRequest | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [availableRides, setAvailableRides] = useState<RideRequest[]>([]);

  // Load available rides on mount and subscribe to updates
  useEffect(() => {
    // Load initial rides
    const loadRides = () => {
      const requestedRides = getRidesByStatus('requested');
      setAvailableRides(requestedRides);
    };

    loadRides();

    // Subscribe to real-time updates
    const unsubscribe = subscribeToRideUpdates((allRides) => {
      const requestedRides = allRides.filter(ride => ride.status === 'requested');
      setAvailableRides(requestedRides);
    });

    // Poll every 2 seconds as fallback
    const pollInterval = setInterval(loadRides, 2000);

    return () => {
      unsubscribe();
      clearInterval(pollInterval);
    };
  }, []);

  const handleAcceptRide = () => {
    if (!selectedRide) return;

    // Accept the ride with driver information
    const updatedRide = acceptRide(selectedRide.id, {
      driverId: 'driver-456',
      driverName: 'John Driver',
      driverPhone: '+1 (555) 123-4567',
      driverRating: 4.9,
      carModel: 'Toyota Camry',
      carPlate: 'ABC 1234',
      carColor: 'Black'
    });

    if (updatedRide) {
      console.log('Ride accepted:', updatedRide);
      // Close the modal
      setSelectedRide(null);
      // Show success feedback
      alert('Ride accepted! The rider has been notified.');
    }
  };

  return (
    <div className="h-full relative">
      {/* Status Card */}
      <div className="p-4">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-5 text-white shadow-lg">
          <div className="flex items-center justify-between mb-3">
            <div>
              <h2 className="text-lg font-bold">You're Online</h2>
              <p className="text-blue-100 text-sm">Ready to accept rides</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" className="sr-only peer" defaultChecked />
              <div className="w-14 h-7 bg-blue-400 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-0.5 after:left-[4px] after:bg-white after:rounded-full after:h-6 after:w-6 after:transition-all"></div>
            </label>
          </div>
          
          <div className="grid grid-cols-3 gap-3 pt-3 border-t border-blue-500">
            <div>
              <div className="text-xl font-bold">12</div>
              <div className="text-blue-200 text-xs">Today's Rides</div>
            </div>
            <div>
              <div className="text-xl font-bold">$245</div>
              <div className="text-blue-200 text-xs">Today's Earnings</div>
            </div>
            <div>
              <div className="text-xl font-bold">4.8★</div>
              <div className="text-blue-200 text-xs">Your Rating</div>
            </div>
          </div>
        </div>
      </div>

      {/* View Toggle */}
      <div className="px-4 mb-3">
        <div className="flex gap-2">
          <button
            onClick={() => setViewMode('list')}
            className={`flex-1 py-2.5 px-4 rounded-lg font-medium text-sm transition-colors flex items-center justify-center gap-2 ${
              viewMode === 'list'
                ? 'bg-blue-600 text-white'
                : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
            }`}
          >
            <List className="w-4 h-4" />
            List View
          </button>
          <button
            onClick={() => setViewMode('map')}
            className={`flex-1 py-2.5 px-4 rounded-lg font-medium text-sm transition-colors flex items-center justify-center gap-2 ${
              viewMode === 'map'
                ? 'bg-blue-600 text-white'
                : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
            }`}
          >
            <Map className="w-4 h-4" />
            Map View
          </button>
        </div>
      </div>

      {/* Map View */}
      {viewMode === 'map' && (
        <div className="px-4">
          <div className="bg-gradient-to-br from-blue-50 to-green-50 rounded-2xl h-96 relative overflow-hidden border border-gray-200">
            {/* Mock Map with Rider Markers */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="text-center">
                <Map className="w-12 h-12 text-blue-600 mx-auto mb-2" />
                <p className="text-gray-700 font-medium">Map View</p>
                <p className="text-sm text-gray-600">Showing {availableRides.length} nearby riders</p>
              </div>
            </div>

            {/* Rider Location Markers */}
            {availableRides.map((ride, index) => (
              <button
                key={ride.id}
                onClick={() => setSelectedRide(ride)}
                className={`absolute w-10 h-10 bg-blue-600 rounded-full border-4 border-white shadow-lg flex items-center justify-center text-white font-bold hover:scale-110 transition-transform ${
                  selectedRide?.id === ride.id ? 'ring-4 ring-blue-300' : ''
                }`}
                style={{
                  top: `${20 + index * 25}%`,
                  left: `${30 + index * 20}%`,
                }}
              >
                {index + 1}
              </button>
            ))}

            {/* Legend */}
            <div className="absolute bottom-4 left-4 bg-white rounded-lg p-3 shadow-lg">
              <div className="flex items-center gap-2 text-xs">
                <div className="w-3 h-3 bg-blue-600 rounded-full"></div>
                <span className="text-gray-700">Rider requesting ride</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Available Rides List */}
      {viewMode === 'list' && (
        <div className="px-4">
          <h3 className="text-lg font-bold text-gray-900 mb-3">
            Available Rides {availableRides.length > 0 && `(${availableRides.length})`}
          </h3>
          {availableRides.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-xl border border-gray-200">
              <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-3">
                <Navigation2 className="w-8 h-8 text-gray-400" />
              </div>
              <h3 className="font-semibold text-gray-900 mb-1">No available rides</h3>
              <p className="text-sm text-gray-600">New ride requests will appear here</p>
            </div>
          ) : (
            <div className="space-y-3">
              {availableRides.map((ride, index) => (
                <button
                  key={ride.id}
                  onClick={() => setSelectedRide(ride)}
                  className={`w-full bg-white rounded-xl p-4 border-2 transition-all ${
                    selectedRide?.id === ride.id
                      ? 'border-blue-600 shadow-lg'
                      : 'border-gray-200 hover:shadow-md'
                  }`}
                >
                  {/* Locations */}
                  <div className="space-y-2 mb-3">
                    <div className="flex items-start gap-2">
                      <div className="w-3 h-3 rounded-full bg-blue-600 mt-1"></div>
                      <div className="flex-1 text-left">
                        <div className="text-xs text-gray-500 mb-0.5">Pickup</div>
                        <div className="text-sm font-medium text-gray-900">{ride.pickup}</div>
                      </div>
                    </div>
                    <div className="flex items-start gap-2">
                      <MapPin className="w-3 h-3 text-red-600 mt-1" />
                      <div className="flex-1 text-left">
                        <div className="text-xs text-gray-500 mb-0.5">Dropoff</div>
                        <div className="text-sm font-medium text-gray-900">{ride.dropoff}</div>
                      </div>
                    </div>
                  </div>

                  {/* Ride Details */}
                  <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                    <div className="flex items-center gap-4 text-xs text-gray-600">
                      <div className="flex items-center gap-1">
                        <Navigation2 className="w-3.5 h-3.5" />
                        {ride.distance}
                      </div>
                      <div className="flex items-center gap-1">
                        <Clock className="w-3.5 h-3.5" />
                        {ride.estimatedTime}
                      </div>
                    </div>
                    <div className="text-lg font-bold text-green-600 flex items-center">
                      <DollarSign className="w-4 h-4" />
                      {ride.estimatedPrice.replace('$', '')}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Sliding Detail Card */}
      {selectedRide && (
        <div 
          className="fixed inset-0 bg-black/40 z-50 animate-fade-in"
          onClick={() => setSelectedRide(null)}
        >
          <div 
            className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl shadow-2xl p-5 animate-slide-up max-h-[85vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Handle Bar */}
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>

            {/* Close Button */}
            <button
              onClick={() => setSelectedRide(null)}
              className="absolute top-4 right-4 p-2 bg-gray-100 rounded-full hover:bg-gray-200 transition-colors"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>

            {/* Ride Details */}
            <div className="mb-4">
              <h3 className="text-xl font-bold text-gray-900 mb-2">Ride Request</h3>
              <p className="text-sm text-gray-600">From {selectedRide.riderName}</p>
            </div>

            {/* Mini Map */}
            <div className="bg-gradient-to-br from-blue-100 to-green-100 rounded-xl h-40 mb-4 flex items-center justify-center">
              <div className="text-center">
                <MapPin className="w-10 h-10 text-blue-600 mx-auto mb-2 animate-pulse" />
                <p className="text-sm font-medium text-gray-700">Rider's Location</p>
                <p className="text-xs text-gray-600">{selectedRide.estimatedTime} away</p>
              </div>
            </div>

            {/* Route Details */}
            <div className="space-y-3 mb-5">
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-3">
                <div className="flex items-start gap-3">
                  <div className="w-4 h-4 rounded-full bg-blue-600 mt-0.5"></div>
                  <div className="flex-1">
                    <div className="text-xs text-blue-600 font-medium mb-1">Pickup Location</div>
                    <div className="font-semibold text-gray-900">{selectedRide.pickup}</div>
                  </div>
                </div>
              </div>

              <div className="bg-red-50 border border-red-200 rounded-xl p-3">
                <div className="flex items-start gap-3">
                  <MapPin className="w-4 h-4 text-red-600 mt-0.5" />
                  <div className="flex-1">
                    <div className="text-xs text-red-600 font-medium mb-1">Dropoff Location</div>
                    <div className="font-semibold text-gray-900">{selectedRide.dropoff}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Trip Info */}
            <div className="bg-gradient-to-r from-green-50 to-green-100 border border-green-200 rounded-xl p-4 mb-5">
              <div className="grid grid-cols-3 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold text-green-700">{selectedRide.estimatedPrice}</div>
                  <div className="text-xs text-gray-600 mt-1">Total Fare</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-900">{selectedRide.distance}</div>
                  <div className="text-xs text-gray-600 mt-1">Distance</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-900">{selectedRide.estimatedTime}</div>
                  <div className="text-xs text-gray-600 mt-1">Est. Time</div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="space-y-3">
              <button 
                onClick={handleAcceptRide}
                className="w-full bg-blue-600 text-white py-4 rounded-xl font-semibold hover:bg-blue-700 active:bg-blue-800 transition-colors shadow-lg"
              >
                Accept Ride
              </button>
              <button 
                onClick={() => setSelectedRide(null)}
                className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-200 active:bg-gray-300 transition-colors"
              >
                Decline
              </button>
            </div>
          </div>
        </div>
      )}

      <style>{`
        @keyframes slide-up {
          from {
            transform: translateY(100%);
          }
          to {
            transform: translateY(0);
          }
        }

        @keyframes fade-in {
          from {
            opacity: 0;
          }
          to {
            opacity: 1;
          }
        }

        .animate-slide-up {
          animation: slide-up 0.3s ease-out;
        }

        .animate-fade-in {
          animation: fade-in 0.2s ease-out;
        }
      `}</style>
    </div>
  );
}