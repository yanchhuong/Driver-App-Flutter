import { MapPin, Clock, Star, ChevronRight, Calendar, DollarSign, X, Package, Car, User, CheckCircle, XCircle, RefreshCw, AlertCircle } from 'lucide-react';
import { useState, useEffect } from 'react';

export function HistoryPage() {
  const [selectedTrip, setSelectedTrip] = useState<string | null>(null);
  const [isClosing, setIsClosing] = useState(false);
  const [statusFilter, setStatusFilter] = useState<string>('all');

  const tripHistory = [
    {
      id: 'TRIP-12345',
      type: 'Ride',
      date: 'Today, 2:30 PM',
      fullDate: 'Mar 19, 2026 2:30 PM',
      driver: {
        name: 'John Smith',
        rating: 4.9,
        phone: '+1 (555) 123-4567',
        vehicle: 'Toyota Camry',
        plate: 'ABC-1234'
      },
      pickup: '123 Main St, Downtown',
      dropoff: '456 Oak Ave, Westside',
      fare: '$18.50',
      baseFare: '$12.00',
      serviceFee: '$2.50',
      tax: '$1.50',
      tip: '$2.50',
      status: 'completed',
      distance: '5.2 mi',
      duration: '12 min',
      paymentMethod: 'Visa ••••4242'
    },
    {
      id: 'DELIVERY-12344',
      type: 'Delivery',
      date: 'Yesterday, 8:15 AM',
      fullDate: 'Mar 18, 2026 8:15 AM',
      driver: {
        name: 'Emily Johnson',
        rating: 5.0,
        phone: '+1 (555) 234-5678',
        vehicle: 'Honda Civic',
        plate: 'XYZ-5678'
      },
      pickup: '789 Pine Rd Restaurant',
      dropoff: 'International Airport Terminal 2',
      fare: '$42.00',
      baseFare: '$35.00',
      serviceFee: '$5.00',
      tax: '$2.00',
      tip: '$0.00',
      status: 'completed',
      distance: '18.5 mi',
      duration: '35 min',
      paymentMethod: 'Cash on Delivery'
    },
    {
      id: 'TRIP-12343',
      type: 'Ride',
      date: 'Jan 14, 6:45 PM',
      fullDate: 'Jan 14, 2026 6:45 PM',
      driver: {
        name: 'Michael Davis',
        rating: 4.8,
        phone: '+1 (555) 345-6789',
        vehicle: 'Nissan Altima',
        plate: 'DEF-9012'
      },
      pickup: '321 Elm St, Southside',
      dropoff: '555 Market St, Central',
      fare: '$14.25',
      baseFare: '$10.00',
      serviceFee: '$1.75',
      tax: '$1.00',
      tip: '$1.50',
      status: 'cancelled',
      distance: '3.8 mi',
      duration: '9 min',
      paymentMethod: 'Mastercard ••••8888',
      cancellationReason: 'Cancelled by rider'
    },
    {
      id: 'DELIVERY-12342',
      type: 'Delivery',
      date: 'Jan 13, 3:20 PM',
      fullDate: 'Jan 13, 2026 3:20 PM',
      driver: {
        name: 'Sarah Wilson',
        rating: 4.9,
        phone: '+1 (555) 456-7890',
        vehicle: 'Ford Focus',
        plate: 'GHI-3456'
      },
      pickup: '888 Broadway Warehouse',
      dropoff: '123 Main St Office',
      fare: '$24.00',
      baseFare: '$20.00',
      serviceFee: '$3.00',
      tax: '$1.00',
      tip: '$0.00',
      status: 'completed',
      distance: '7.1 mi',
      duration: '18 min',
      paymentMethod: 'Cash on Delivery'
    },
    {
      id: 'TRIP-12341',
      type: 'Ride',
      date: 'Jan 12, 11:30 AM',
      fullDate: 'Jan 12, 2026 11:30 AM',
      driver: {
        name: 'David Brown',
        rating: 4.7,
        phone: '+1 (555) 567-8901',
        vehicle: 'Hyundai Elantra',
        plate: 'JKL-7890'
      },
      pickup: '999 Beach Rd, Coastal Area',
      dropoff: '222 Hill St, Mountain View',
      fare: '$32.00',
      baseFare: '$28.00',
      serviceFee: '$3.00',
      tax: '$1.00',
      tip: '$0.00',
      status: 'refunded',
      distance: '12.3 mi',
      duration: '28 min',
      paymentMethod: 'Visa ••••4242',
      refundReason: 'Service issue - Full refund issued'
    },
    {
      id: 'DELIVERY-12340',
      type: 'Delivery',
      date: 'Jan 11, 5:00 PM',
      fullDate: 'Jan 11, 2026 5:00 PM',
      driver: {
        name: 'Lisa Anderson',
        rating: 4.6,
        phone: '+1 (555) 678-9012',
        vehicle: 'Toyota Prius',
        plate: 'MNO-2345'
      },
      pickup: '444 Shop Center Mall',
      dropoff: '777 Residential Complex',
      fare: '$19.75',
      baseFare: '$16.00',
      serviceFee: '$2.50',
      tax: '$1.25',
      tip: '$0.00',
      status: 'cancelled',
      distance: '6.5 mi',
      duration: '15 min',
      paymentMethod: 'Apple Pay',
      cancellationReason: 'Cancelled by driver'
    }
  ];

  const thisWeekStats = {
    totalTrips: 8,
    totalSpent: '$142.50',
    totalDistance: '45.3 mi'
  };

  useEffect(() => {
    if (isClosing) {
      const timer = setTimeout(() => {
        setSelectedTrip(null);
        setIsClosing(false);
      }, 300);
      return () => clearTimeout(timer);
    }
  }, [isClosing]);

  // Filter trips by status
  const filteredTrips = statusFilter === 'all' 
    ? tripHistory 
    : tripHistory.filter(trip => trip.status === statusFilter);

  // Helper function to get status badge styling
  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'completed':
        return {
          icon: CheckCircle,
          bgColor: 'bg-green-100',
          textColor: 'text-green-700',
          label: 'Completed'
        };
      case 'cancelled':
        return {
          icon: XCircle,
          bgColor: 'bg-red-100',
          textColor: 'text-red-700',
          label: 'Cancelled'
        };
      case 'refunded':
        return {
          icon: RefreshCw,
          bgColor: 'bg-blue-100',
          textColor: 'text-blue-700',
          label: 'Refunded'
        };
      default:
        return {
          icon: AlertCircle,
          bgColor: 'bg-gray-100',
          textColor: 'text-gray-700',
          label: status
        };
    }
  };

  return (
    <div className="p-4">
      {/* Stats Card */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-5 text-white mb-5 shadow-lg">
        <div className="flex items-center gap-2 mb-3">
          <Calendar className="w-5 h-5" />
          <h2 className="text-lg font-bold">This Week</h2>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <div>
            <div className="text-2xl font-bold">{thisWeekStats.totalTrips}</div>
            <div className="text-blue-200 text-xs">Trips</div>
          </div>
          <div>
            <div className="text-2xl font-bold">{thisWeekStats.totalSpent}</div>
            <div className="text-blue-200 text-xs">Spent</div>
          </div>
          <div>
            <div className="text-2xl font-bold">{thisWeekStats.totalDistance}</div>
            <div className="text-blue-200 text-xs">Distance</div>
          </div>
        </div>
      </div>

      {/* Filter Buttons */}
      <div className="flex gap-2 mb-4 overflow-x-auto pb-2">
        <button 
          onClick={() => setStatusFilter('all')}
          className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap flex items-center gap-1.5 transition-colors ${
            statusFilter === 'all'
              ? 'bg-blue-600 text-white'
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
          }`}
        >
          All Trips
          <span className="text-xs opacity-75">({tripHistory.length})</span>
        </button>
        <button 
          onClick={() => setStatusFilter('completed')}
          className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap flex items-center gap-1.5 transition-colors ${
            statusFilter === 'completed'
              ? 'bg-green-600 text-white'
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
          }`}
        >
          <CheckCircle className="w-3.5 h-3.5" />
          Completed
          <span className="text-xs opacity-75">({tripHistory.filter(t => t.status === 'completed').length})</span>
        </button>
        <button 
          onClick={() => setStatusFilter('cancelled')}
          className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap flex items-center gap-1.5 transition-colors ${
            statusFilter === 'cancelled'
              ? 'bg-red-600 text-white'
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
          }`}
        >
          <XCircle className="w-3.5 h-3.5" />
          Cancelled
          <span className="text-xs opacity-75">({tripHistory.filter(t => t.status === 'cancelled').length})</span>
        </button>
        <button 
          onClick={() => setStatusFilter('refunded')}
          className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap flex items-center gap-1.5 transition-colors ${
            statusFilter === 'refunded'
              ? 'bg-blue-600 text-white'
              : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
          }`}
        >
          <RefreshCw className="w-3.5 h-3.5" />
          Refunded
          <span className="text-xs opacity-75">({tripHistory.filter(t => t.status === 'refunded').length})</span>
        </button>
      </div>

      {/* Trip History List */}
      <div className="space-y-3">
        <h3 className="text-lg font-bold text-gray-900 mb-3">Recent Trips</h3>
        {filteredTrips.map((trip) => {
          const statusBadge = getStatusBadge(trip.status);
          const StatusIcon = statusBadge.icon;
          
          return (
          <button
            key={trip.id}
            className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all active:scale-[0.99]"
            onClick={() => setSelectedTrip(trip.id)}
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2 flex-wrap">
                <Clock className="w-4 h-4 text-gray-400" />
                <span className="text-sm text-gray-600">{trip.date}</span>
                <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                  trip.type === 'Delivery' 
                    ? 'bg-purple-100 text-purple-700' 
                    : 'bg-blue-100 text-blue-700'
                }`}>
                  {trip.type}
                </span>
                <span className={`text-xs font-medium px-2 py-1 rounded-full flex items-center gap-1 ${statusBadge.bgColor} ${statusBadge.textColor}`}>
                  <StatusIcon className="w-3 h-3" />
                  {statusBadge.label}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-lg font-bold text-gray-900">{trip.fare}</span>
                <ChevronRight className="w-4 h-4 text-gray-400" />
              </div>
            </div>

            {/* Route */}
            <div className="space-y-2 mb-3">
              <div className="flex items-start gap-2">
                <div className="w-3 h-3 rounded-full bg-blue-600 mt-1 flex-shrink-0"></div>
                <div className="flex-1 text-left">
                  <div className="text-sm font-medium text-gray-900">{trip.pickup}</div>
                </div>
              </div>
              <div className="flex items-start gap-2">
                <MapPin className="w-3 h-3 text-red-600 mt-1 flex-shrink-0" />
                <div className="flex-1 text-left">
                  <div className="text-sm font-medium text-gray-900">{trip.dropoff}</div>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className="flex items-center justify-between pt-3 border-t border-gray-100">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-xs font-bold">
                  {trip.driver.name.charAt(0)}
                </div>
                <div className="text-left">
                  <div className="text-sm font-medium text-gray-900">{trip.driver.name}</div>
                  <div className="flex items-center gap-1 text-xs text-gray-600">
                    <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                    <span>{trip.driver.rating}</span>
                  </div>
                </div>
              </div>
              <div className="text-right text-xs text-gray-600">
                {trip.distance} • {trip.duration}
              </div>
            </div>
          </button>
        );
        })}
      </div>

      {/* Load More */}
      <button className="w-full mt-4 py-3 text-blue-600 font-medium hover:text-blue-700 active:text-blue-800 transition-colors">
        Load More Trips
      </button>

      {/* Trip Details Modal */}
      {selectedTrip && (
        <div 
          className={`fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center transition-opacity duration-300 ${
            isClosing ? 'opacity-0' : 'opacity-100'
          }`}
          onClick={() => setIsClosing(true)}
        >
          <div 
            className={`bg-white rounded-t-3xl sm:rounded-3xl w-full sm:max-w-md max-h-[90vh] overflow-y-auto transition-transform duration-300 ease-out ${
              isClosing ? 'translate-y-full' : 'translate-y-0'
            }`}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex items-center justify-between">
              <h3 className="font-bold text-lg text-gray-900">Trip Details</h3>
              <button 
                onClick={() => setIsClosing(true)}
                className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            {(() => {
              const trip = tripHistory.find(t => t.id === selectedTrip);
              if (!trip) return null;

              return (
                <div className="p-4 space-y-4">
                  {/* Type Badge */}
                  <div className="flex justify-center">
                    <span className={`text-sm font-semibold px-4 py-2 rounded-full ${
                      trip.type === 'Delivery' 
                        ? 'bg-purple-100 text-purple-700' 
                        : 'bg-blue-100 text-blue-700'
                    }`}>
                      {trip.type}
                    </span>
                  </div>

                  {/* Trip ID Reference */}
                  <div className="bg-blue-50 rounded-xl p-4 text-center">
                    <div className="text-xs text-blue-600 font-medium mb-1">Trip ID</div>
                    <div className="text-xl font-bold text-blue-700">{trip.id}</div>
                  </div>

                  {/* Driver Information */}
                  <div className="bg-gray-50 rounded-xl p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Driver Information</h4>
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold text-lg">
                        {trip.driver.name.charAt(0)}
                      </div>
                      <div className="flex-1">
                        <div className="text-sm font-semibold text-gray-900">{trip.driver.name}</div>
                        <div className="flex items-center gap-1 text-xs text-gray-600">
                          <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                          <span>{trip.driver.rating}</span>
                        </div>
                      </div>
                    </div>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Phone</span>
                        <span className="font-medium text-gray-900">{trip.driver.phone}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Vehicle</span>
                        <span className="font-medium text-gray-900">{trip.driver.vehicle}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Plate</span>
                        <span className="font-medium text-gray-900">{trip.driver.plate}</span>
                      </div>
                    </div>
                  </div>

                  {/* Trip Route */}
                  <div className="bg-gray-50 rounded-xl p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Trip Route</h4>
                    <div className="space-y-3">
                      <div className="flex gap-3">
                        <div className="flex flex-col items-center">
                          <div className="w-3 h-3 rounded-full bg-green-500"></div>
                          <div className="w-0.5 h-8 bg-gray-300"></div>
                          <div className="w-3 h-3 rounded-full bg-red-500"></div>
                        </div>
                        <div className="flex-1 space-y-3">
                          <div>
                            <div className="text-xs text-gray-600">Pickup</div>
                            <div className="text-sm font-medium text-gray-900">{trip.pickup}</div>
                          </div>
                          <div>
                            <div className="text-xs text-gray-600">Drop-off</div>
                            <div className="text-sm font-medium text-gray-900">{trip.dropoff}</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Trip Stats */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Trip Statistics</h4>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <div className="text-xs text-gray-600">Distance</div>
                        <div className="text-sm font-semibold text-gray-900">{trip.distance}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-600">Duration</div>
                        <div className="text-sm font-semibold text-gray-900">{trip.duration}</div>
                      </div>
                    </div>
                  </div>

                  {/* Payment Breakdown */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Payment Breakdown</h4>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm text-gray-600">Base Fare</span>
                        <span className="text-sm font-semibold text-gray-900">{trip.baseFare}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm text-gray-600">Service Fee</span>
                        <span className="text-sm font-semibold text-gray-900">{trip.serviceFee}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm text-gray-600">Tax</span>
                        <span className="text-sm font-semibold text-gray-900">{trip.tax}</span>
                      </div>
                      {trip.tip !== '$0.00' && (
                        <div className="flex justify-between items-center">
                          <span className="text-sm text-gray-600">Tip</span>
                          <span className="text-sm font-semibold text-green-600">{trip.tip}</span>
                        </div>
                      )}
                      <div className="border-t border-gray-200 pt-3 flex justify-between items-center">
                        <span className="text-sm font-semibold text-gray-900">Total Fare</span>
                        <span className="text-lg font-bold text-gray-900">{trip.fare}</span>
                      </div>
                    </div>
                  </div>

                  {/* Payment Method */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <DollarSign className="w-4 h-4 text-gray-600" />
                      <h4 className="text-sm font-semibold text-gray-900">Payment Method</h4>
                    </div>
                    <p className="text-sm text-gray-700">{trip.paymentMethod}</p>
                  </div>

                  {/* Date & Time */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <Calendar className="w-4 h-4 text-gray-600" />
                      <h4 className="text-sm font-semibold text-gray-900">Date & Time</h4>
                    </div>
                    <p className="text-sm text-gray-700">{trip.fullDate}</p>
                  </div>

                  {/* Status and Reason */}
                  {trip.status === 'cancelled' && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4">
                      <div className="flex items-center gap-2 mb-2">
                        <XCircle className="w-4 h-4 text-red-600" />
                        <h4 className="text-sm font-semibold text-gray-900">Status</h4>
                      </div>
                      <p className="text-sm text-gray-700">Cancelled</p>
                      <p className="text-sm text-gray-500 mt-1">Reason: {trip.cancellationReason}</p>
                    </div>
                  )}
                  {trip.status === 'refunded' && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4">
                      <div className="flex items-center gap-2 mb-2">
                        <RefreshCw className="w-4 h-4 text-blue-600" />
                        <h4 className="text-sm font-semibold text-gray-900">Status</h4>
                      </div>
                      <p className="text-sm text-gray-700">Refunded</p>
                      <p className="text-sm text-gray-500 mt-1">Reason: {trip.refundReason}</p>
                    </div>
                  )}
                </div>
              );
            })()}
          </div>
        </div>
      )}
    </div>
  );
}