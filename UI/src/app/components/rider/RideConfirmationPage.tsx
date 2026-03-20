import { useState } from 'react';
import { MapPin, ChevronLeft, Wallet, Ticket, Menu, FileText, Navigation, X } from 'lucide-react';
import { createRideRequest } from '../../utils/rideStateManager';
import { RideMap } from './RideMap';

interface RideConfirmationPageProps {
  pickupLocation: string;
  dropoffLocation: string;
  selectedService: string;
  estimatedPrice: string;
  estimatedTime: string;
  onBack: () => void;
  onConfirm: () => void;
}

export function RideConfirmationPage({
  pickupLocation,
  dropoffLocation,
  selectedService,
  estimatedPrice,
  estimatedTime,
  onBack,
  onConfirm
}: RideConfirmationPageProps) {
  const [paymentMethod, setPaymentMethod] = useState('cash');
  const [rideType, setRideType] = useState<'ride' | 'delivery'>('ride');
  const [deliverySpeed, setDeliverySpeed] = useState<'normal' | 'express'>('normal');
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showCouponModal, setShowCouponModal] = useState(false);
  const [showOptionsModal, setShowOptionsModal] = useState(false);
  const [showNoteModal, setShowNoteModal] = useState(false);

  const handleConfirmClick = () => {
    // Create the ride request in the shared state
    const rideRequest = createRideRequest({
      riderId: 'rider-123',
      riderName: 'Current User',
      pickup: pickupLocation,
      dropoff: dropoffLocation,
      rideType: rideType === 'delivery' ? `delivery-${deliverySpeed}` : rideType,
      serviceType: selectedService,
      estimatedPrice: estimatedPrice,
      estimatedTime: estimatedTime,
      distance: '5.2 km',
      paymentMethod: paymentMethod
    });

    console.log('Ride request created:', rideRequest);
    
    // Call the original onConfirm to navigate to active ride page
    onConfirm();
  };

  const serviceNames: Record<string, string> = {
    economy: 'Economy',
    standard: 'Standard',
    premium: 'Premium',
    xl: 'XL'
  };

  const getServiceSeats = (service: string): string => {
    const seats: Record<string, string> = {
      economy: '4 seats',
      standard: '4 seats', 
      premium: '4 seats',
      xl: '6 seats'
    };
    return seats[service] || '4 seats';
  };

  return (
    <div className="h-full flex flex-col relative overflow-hidden">
      {/* Map Section - Top Half */}
      <div className="relative h-[55vh] flex-shrink-0 z-10">
        <RideMap
          pickupLocation={pickupLocation}
          dropoffLocation={dropoffLocation}
          estimatedTime={estimatedTime}
        />

        {/* Back Button - Top Left */}
        <button
          onClick={onBack}
          className="absolute top-4 left-4 z-20 w-11 h-11 bg-white rounded-full shadow-xl flex items-center justify-center hover:bg-gray-50 active:bg-gray-100 transition-all border-2 border-gray-200"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900 stroke-[2.5]" />
        </button>

        {/* Close Button - Top Right */}
        <button
          onClick={onBack}
          className="absolute top-4 right-4 z-20 w-11 h-11 bg-white rounded-full shadow-xl flex items-center justify-center hover:bg-gray-50 active:bg-gray-100 transition-all border-2 border-gray-200"
        >
          <X className="w-5 h-5 text-gray-900 stroke-[2.5]" />
        </button>

        {/* Location Badge - Top Center */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-20 bg-white rounded-full px-4 py-2 shadow-lg">
          <p className="font-semibold text-gray-900 text-sm">My Location</p>
        </div>
      </div>

      {/* Bottom Sheet - Bottom Half */}
      <div className="flex-1 bg-white rounded-t-3xl shadow-2xl relative z-20 overflow-y-auto">
        {/* Pull Handle */}
        <div className="pt-3 pb-2">
          <div className="w-12 h-1.5 bg-gray-300 rounded-full mx-auto"></div>
        </div>

        <div className="px-5 pb-6">
          {/* Where to? Section */}
          <div className="mb-4">
            <div className="flex items-center gap-2 mb-3">
              <MapPin className="w-5 h-5 text-orange-600" />
              <span className="font-semibold text-gray-900">Where to?</span>
            </div>
            
            {/* Selected Ride Type */}
            <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl border border-gray-200">
              <div className="w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                {serviceNames[selectedService]?.charAt(0)}
              </div>
              <div className="flex-1">
                <div className="font-semibold text-gray-900">{serviceNames[selectedService]} ({getServiceSeats(selectedService)})</div>
                <div className="text-xs text-gray-600">{dropoffLocation}</div>
              </div>
              <div className="text-right">
                <div className="font-bold text-orange-600 text-lg">{estimatedPrice}</div>
                <div className="text-xs text-gray-600">{estimatedTime}</div>
              </div>
            </div>
          </div>

          {/* Action Buttons Row */}
          <div className="grid grid-cols-4 gap-3 mb-4">
            {/* Cash Button */}
            <button 
              onClick={() => setShowPaymentModal(true)}
              className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50 active:bg-gray-100 transition-colors"
            >
              <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                paymentMethod === 'cash' ? 'bg-green-100' : 'bg-gray-100'
              }`}>
                <Wallet className={`w-6 h-6 ${paymentMethod === 'cash' ? 'text-green-600' : 'text-gray-600'}`} />
              </div>
              <span className="text-xs font-medium text-gray-700">Cash</span>
            </button>

            {/* Coupon Button */}
            <button 
              onClick={() => setShowCouponModal(true)}
              className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50 active:bg-gray-100 transition-colors"
            >
              <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                <Ticket className="w-6 h-6 text-gray-600" />
              </div>
              <span className="text-xs font-medium text-gray-700">Coupon</span>
            </button>

            {/* Option Button */}
            <button 
              onClick={() => setShowOptionsModal(true)}
              className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50 active:bg-gray-100 transition-colors"
            >
              <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                <Menu className="w-6 h-6 text-gray-600" />
              </div>
              <span className="text-xs font-medium text-gray-700">Option</span>
            </button>

            {/* Note Button */}
            <button 
              onClick={() => setShowNoteModal(true)}
              className="flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-gray-50 active:bg-gray-100 transition-colors"
            >
              <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                <FileText className="w-6 h-6 text-gray-600" />
              </div>
              <span className="text-xs font-medium text-gray-700">Note</span>
            </button>
          </div>

          {/* Confirm Booking Button */}
          <div className="flex gap-3">
            <button
              onClick={onBack}
              className="flex-1 bg-blue-100 text-blue-700 py-4 rounded-xl font-bold text-lg hover:bg-blue-200 active:bg-blue-300 transition-all shadow-lg border-2 border-blue-200"
            >
              Cancel
            </button>
            <button
              onClick={handleConfirmClick}
              className="flex-1 bg-blue-600 text-white py-4 rounded-xl font-bold text-lg hover:bg-blue-700 active:bg-blue-800 transition-all shadow-lg"
            >
              Confirm Booking
            </button>
          </div>
        </div>
      </div>

      {/* Payment Method Modal */}
      {showPaymentModal && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 z-[100]"
            onClick={() => setShowPaymentModal(false)}
          ></div>
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-[101] p-6">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Select Payment Method</h3>
            <div className="space-y-2 mb-6">
              <button
                onClick={() => {
                  setPaymentMethod('cash');
                  setShowPaymentModal(false);
                }}
                className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 transition-all ${
                  paymentMethod === 'cash'
                    ? 'border-green-600 bg-green-50'
                    : 'border-gray-200 hover:bg-gray-50'
                }`}
              >
                <Wallet className="w-6 h-6 text-green-600" />
                <span className="flex-1 text-left font-semibold text-gray-900">Cash</span>
                {paymentMethod === 'cash' && (
                  <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  </div>
                )}
              </button>
              <button
                onClick={() => {
                  setPaymentMethod('card');
                  setShowPaymentModal(false);
                }}
                className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 transition-all ${
                  paymentMethod === 'card'
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:bg-gray-50'
                }`}
              >
                <Wallet className="w-6 h-6 text-blue-600" />
                <span className="flex-1 text-left font-semibold text-gray-900">Card</span>
                {paymentMethod === 'card' && (
                  <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  </div>
                )}
              </button>
            </div>
            <button
              onClick={() => setShowPaymentModal(false)}
              className="w-full bg-gray-200 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-300 transition-colors"
            >
              Cancel
            </button>
          </div>
        </>
      )}

      {/* Coupon Modal */}
      {showCouponModal && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 z-[100]"
            onClick={() => setShowCouponModal(false)}
          ></div>
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-[101] p-6">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Apply Coupon</h3>
            <input
              type="text"
              placeholder="Enter coupon code"
              className="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-orange-600 focus:ring-2 focus:ring-orange-200 outline-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => setShowCouponModal(false)}
                className="flex-1 bg-gray-200 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-300 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => setShowCouponModal(false)}
                className="flex-1 bg-orange-600 text-white py-3 rounded-xl font-semibold hover:bg-orange-700 transition-colors"
              >
                Apply
              </button>
            </div>
          </div>
        </>
      )}

      {/* Options Modal */}
      {showOptionsModal && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 z-[100]"
            onClick={() => setShowOptionsModal(false)}
          ></div>
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-[101] p-6 max-h-[80vh] overflow-y-auto">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Select Ride Type</h3>
            
            {/* Ride Type Selection */}
            <div className="space-y-3 mb-4">
              <button
                onClick={() => setRideType('ride')}
                className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 transition-all ${
                  rideType === 'ride'
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:bg-gray-50'
                }`}
              >
                <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                  rideType === 'ride' ? 'bg-blue-600' : 'bg-gray-100'
                }`}>
                  <svg className={`w-6 h-6 ${rideType === 'ride' ? 'text-white' : 'text-gray-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                  </svg>
                </div>
                <div className="flex-1 text-left">
                  <div className="font-semibold text-gray-900">Ride</div>
                  <div className="text-xs text-gray-600">Standard ride service</div>
                </div>
                {rideType === 'ride' && (
                  <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  </div>
                )}
              </button>

              <button
                onClick={() => setRideType('delivery')}
                className={`w-full flex items-center gap-3 p-4 rounded-xl border-2 transition-all ${
                  rideType === 'delivery'
                    ? 'border-orange-600 bg-orange-50'
                    : 'border-gray-200 hover:bg-gray-50'
                }`}
              >
                <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                  rideType === 'delivery' ? 'bg-orange-600' : 'bg-gray-100'
                }`}>
                  <svg className={`w-6 h-6 ${rideType === 'delivery' ? 'text-white' : 'text-gray-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                  </svg>
                </div>
                <div className="flex-1 text-left">
                  <div className="font-semibold text-gray-900">Delivery</div>
                  <div className="text-xs text-gray-600">Package delivery service</div>
                </div>
                {rideType === 'delivery' && (
                  <div className="w-6 h-6 bg-orange-600 rounded-full flex items-center justify-center">
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  </div>
                )}
              </button>
            </div>

            {/* Delivery Speed Options - Shows only when Delivery is selected */}
            {rideType === 'delivery' && (
              <div className="pt-4 border-t border-gray-200 mb-4">
                <h4 className="text-sm font-semibold text-gray-700 mb-3">Delivery Speed</h4>
                <div className="space-y-2">
                  <button
                    onClick={() => setDeliverySpeed('normal')}
                    className={`w-full flex items-center gap-3 p-3 rounded-xl border-2 transition-all ${
                      deliverySpeed === 'normal'
                        ? 'border-orange-600 bg-orange-50'
                        : 'border-gray-200 hover:bg-gray-50'
                    }`}
                  >
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                      deliverySpeed === 'normal' ? 'bg-orange-600' : 'bg-gray-100'
                    }`}>
                      <svg className={`w-5 h-5 ${deliverySpeed === 'normal' ? 'text-white' : 'text-gray-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                      </svg>
                    </div>
                    <div className="flex-1 text-left">
                      <div className="font-semibold text-gray-900">Normal</div>
                      <div className="text-xs text-gray-600">Standard delivery time</div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-bold text-gray-900">{estimatedTime}</div>
                    </div>
                    {deliverySpeed === 'normal' && (
                      <div className="w-5 h-5 rounded-full bg-orange-600 flex items-center justify-center">
                        <div className="w-2 h-2 bg-white rounded-full"></div>
                      </div>
                    )}
                  </button>
                  
                  <button
                    onClick={() => setDeliverySpeed('express')}
                    className={`w-full flex items-center gap-3 p-3 rounded-xl border-2 transition-all ${
                      deliverySpeed === 'express'
                        ? 'border-purple-600 bg-purple-50'
                        : 'border-gray-200 hover:bg-gray-50'
                    }`}
                  >
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                      deliverySpeed === 'express' ? 'bg-purple-600' : 'bg-gray-100'
                    }`}>
                      <svg className={`w-5 h-5 ${deliverySpeed === 'express' ? 'text-white' : 'text-gray-600'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                    </div>
                    <div className="flex-1 text-left">
                      <div className="font-semibold text-gray-900 flex items-center gap-2">
                        Express
                        <span className="text-xs px-2 py-0.5 bg-purple-100 text-purple-700 rounded-full font-medium">Fast</span>
                      </div>
                      <div className="text-xs text-gray-600">Priority fast delivery</div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-bold text-purple-600">~6 min</div>
                    </div>
                    {deliverySpeed === 'express' && (
                      <div className="w-5 h-5 rounded-full bg-purple-600 flex items-center justify-center">
                        <div className="w-2 h-2 bg-white rounded-full"></div>
                      </div>
                    )}
                  </button>
                </div>
              </div>
            )}

            <button
              onClick={() => setShowOptionsModal(false)}
              className="w-full bg-orange-600 text-white py-3 rounded-xl font-semibold hover:bg-orange-700 transition-colors"
            >
              Done
            </button>
          </div>
        </>
      )}

      {/* Note Modal */}
      {showNoteModal && (
        <>
          <div 
            className="fixed inset-0 bg-black/50 z-[100]"
            onClick={() => setShowNoteModal(false)}
          ></div>
          <div className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md mx-auto bg-white rounded-2xl shadow-2xl z-[101] p-6">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Add Note for Driver</h3>
            <textarea
              placeholder="Add instructions for your driver..."
              className="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-orange-600 focus:ring-2 focus:ring-orange-200 outline-none mb-4 h-32 resize-none"
            />
            <div className="flex gap-3">
              <button
                onClick={() => setShowNoteModal(false)}
                className="flex-1 bg-gray-200 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-300 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => setShowNoteModal(false)}
                className="flex-1 bg-orange-600 text-white py-3 rounded-xl font-semibold hover:bg-orange-700 transition-colors"
              >
                Save
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}