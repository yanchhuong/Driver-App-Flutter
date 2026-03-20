import { CreditCard, Wallet, Calendar, DollarSign, TrendingUp, Download, ChevronRight, Receipt, X, MapPin } from 'lucide-react';
import { useState, useEffect } from 'react';

export function SettlePage() {
  const [selectedTransaction, setSelectedTransaction] = useState<string | null>(null);
  const [isClosing, setIsClosing] = useState(false);

  const paymentMethods = [
    {
      id: 1,
      type: 'card',
      name: 'Visa ending in 4242',
      isDefault: true,
      icon: '💳'
    },
    {
      id: 2,
      type: 'card',
      name: 'Mastercard ending in 8888',
      isDefault: false,
      icon: '💳'
    },
    {
      id: 3,
      type: 'wallet',
      name: 'DriveApp Wallet',
      balance: '$25.00',
      icon: '👛'
    }
  ];

  const recentTransactions = [
    {
      id: 'TXN-001',
      date: 'Today, 2:30 PM',
      fullDate: 'Mar 19, 2026 2:30 PM',
      description: 'Settlement Batch #001',
      totalAmount: '$85.50',
      totalCOD: '$85.50',
      totalFee: '$11.00',
      details: 'COD payment pending confirmation',
      status: 'Progress',
      rides: [
        {
          rideId: 'DELIVERY-2456',
          pickup: '123 Main Street',
          dropoff: '456 Oak Avenue',
          cod: '$18.50',
          fee: '$2.50',
          description: 'Package Delivery'
        },
        {
          rideId: 'DELIVERY-2457',
          pickup: '789 Park Lane',
          dropoff: '321 Broadway',
          cod: '$32.00',
          fee: '$4.00',
          description: 'Food Delivery'
        },
        {
          rideId: 'DELIVERY-2458',
          pickup: '555 River Road',
          dropoff: '888 Market Street',
          cod: '$35.00',
          fee: '$4.50',
          description: 'Document Delivery'
        }
      ]
    },
    {
      id: 'TXN-002',
      date: 'Yesterday, 8:15 AM',
      fullDate: 'Mar 18, 2026 8:15 AM',
      description: 'Settlement Batch #002',
      totalAmount: '$109.00',
      totalCOD: '$109.00',
      totalFee: '$14.00',
      details: 'COD payment completed successfully',
      status: 'Settled',
      rides: [
        {
          rideId: 'DELIVERY-2455',
          pickup: '789 Park Lane Restaurant',
          dropoff: 'International Airport Terminal 2',
          cod: '$42.00',
          fee: '$5.00',
          description: 'Food Delivery'
        },
        {
          rideId: 'DELIVERY-2454',
          pickup: '123 Shop Center',
          dropoff: '456 Residential Complex',
          cod: '$28.00',
          fee: '$3.50',
          description: 'Parcel Delivery'
        },
        {
          rideId: 'DELIVERY-2453',
          pickup: '999 Beach Road',
          dropoff: '111 Hill Street',
          cod: '$39.00',
          fee: '$5.50',
          description: 'Package Delivery'
        }
      ]
    },
    {
      id: 'TXN-003',
      date: 'Jan 14, 6:45 PM',
      fullDate: 'Jan 14, 2026 6:45 PM',
      description: 'Settlement Batch #003',
      totalAmount: '$53.00',
      totalCOD: '$53.00',
      totalFee: '$7.00',
      details: 'COD payment completed successfully',
      status: 'Settled',
      rides: [
        {
          rideId: 'DELIVERY-2453',
          pickup: '321 Elm Street',
          dropoff: '654 Broadway Office',
          cod: '$25.00',
          fee: '$3.00',
          description: 'Document Delivery'
        },
        {
          rideId: 'DELIVERY-2452',
          pickup: '444 Main Avenue',
          dropoff: '777 Central Plaza',
          cod: '$28.00',
          fee: '$4.00',
          description: 'Food Delivery'
        }
      ]
    },
    {
      id: 'TXN-004',
      date: 'Jan 14, 3:20 PM',
      fullDate: 'Jan 14, 2026 3:20 PM',
      description: 'Settlement Batch #004',
      totalAmount: '$14.25',
      totalCOD: '$14.25',
      totalFee: '$1.75',
      details: 'COD payment processing',
      status: 'Progress',
      rides: [
        {
          rideId: 'DELIVERY-2450',
          pickup: '555 River Road Warehouse',
          dropoff: '888 Market Street Shop',
          cod: '$14.25',
          fee: '$1.75',
          description: 'Parcel Delivery'
        }
      ]
    }
  ];

  const spendingStats = {
    totalAll: '$261.75',
    totalReceived: '$261.75',
    totalFee: '$33.75'
  };

  useEffect(() => {
    if (isClosing) {
      const timer = setTimeout(() => {
        setSelectedTransaction(null);
        setIsClosing(false);
      }, 300);
      return () => clearTimeout(timer);
    }
  }, [isClosing]);

  return (
    <div className="p-4">
      {/* Spending Stats */}
      <div className="bg-white rounded-2xl p-5 border border-gray-200 mb-5">
        <div className="flex items-center gap-2 mb-4">
          <TrendingUp className="w-5 h-5 text-blue-600" />
          <h3 className="font-bold text-gray-900">Overview</h3>
        </div>
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center">
            <div className="text-xl font-bold text-gray-900">{spendingStats.totalAll}</div>
            <div className="text-xs text-gray-600 mt-1">Total All</div>
          </div>
          <div className="text-center">
            <div className="text-xl font-bold text-green-600">{spendingStats.totalReceived}</div>
            <div className="text-xs text-gray-600 mt-1">Total Received</div>
          </div>
          <div className="text-center">
            <div className="text-xl font-bold text-red-600">-{spendingStats.totalFee}</div>
            <div className="text-xs text-gray-600 mt-1">Total Fee (-)</div>
          </div>
        </div>
      </div>

      {/* Settle Transaction */}
      <div className="mb-5">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-bold text-gray-900">Settle Transaction</h3>
          <button className="text-blue-600 font-medium text-sm hover:text-blue-700 flex items-center gap-1">
            <Download className="w-4 h-4" />
            Export
          </button>
        </div>
        <div className="space-y-2">
          {recentTransactions.map((transaction) => (
            <button
              key={transaction.id}
              onClick={() => setSelectedTransaction(transaction.id)}
              className="w-full bg-white rounded-xl p-4 border border-gray-200 hover:shadow-md transition-all active:scale-[0.99]"
            >
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-lg bg-gray-50">
                    <Receipt className="w-5 h-5 text-gray-600" />
                  </div>
                  <div className="text-left">
                    <div className="font-semibold text-gray-900">{transaction.description}</div>
                    <div className="text-xs text-gray-600">{transaction.date}</div>
                    <div className="text-xs text-blue-600 font-medium mt-1">
                      {transaction.rides.length} {transaction.rides.length === 1 ? 'Ride' : 'Rides'} included
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-bold text-gray-900">
                    {transaction.totalAmount}
                  </div>
                  <span className={`text-xs font-medium px-2 py-1 rounded-full mt-1 inline-block ${
                    transaction.status === 'Settled' 
                      ? 'bg-green-100 text-green-700' 
                      : 'bg-orange-100 text-orange-700'
                  }`}>
                    {transaction.status}
                  </span>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Transaction Detail Modal */}
      {selectedTransaction && (
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
              <h3 className="font-bold text-lg text-gray-900">Transaction Details</h3>
              <button 
                onClick={() => setIsClosing(true)}
                className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            {(() => {
              const transaction = recentTransactions.find(t => t.id === selectedTransaction);
              if (!transaction) return null;

              return (
                <div className="p-4 space-y-4">
                  {/* Status Badge */}
                  <div className="flex justify-center">
                    <span className={`text-sm font-semibold px-4 py-2 rounded-full ${
                      transaction.status === 'Settled' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-orange-100 text-orange-700'
                    }`}>
                      {transaction.status}
                    </span>
                  </div>

                  {/* Transaction ID */}
                  <div className="bg-blue-50 rounded-xl p-4 text-center">
                    <div className="text-xs text-blue-600 font-medium mb-1">Transaction ID</div>
                    <div className="text-xl font-bold text-blue-700">{transaction.id}</div>
                    <div className="text-xs text-blue-600 font-medium mt-2">
                      {transaction.rides.length} {transaction.rides.length === 1 ? 'Ride' : 'Rides'} included
                    </div>
                  </div>

                  {/* All Rides in Settlement */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Rides in This Settlement</h4>
                    <div className="space-y-3">
                      {transaction.rides.map((ride, index) => (
                        <div key={ride.rideId} className="bg-gray-50 rounded-lg p-3">
                          <div className="flex items-center justify-between mb-2">
                            <div className="text-xs font-semibold text-blue-600">{ride.rideId}</div>
                            <div className="text-sm font-bold text-gray-900">{ride.cod}</div>
                          </div>
                          <div className="text-xs text-gray-600 mb-2">{ride.description}</div>
                          <div className="space-y-2">
                            <div className="flex gap-2 items-start">
                              <div className="w-2 h-2 rounded-full bg-green-500 mt-1 flex-shrink-0"></div>
                              <div className="text-xs text-gray-700 flex-1">{ride.pickup}</div>
                            </div>
                            <div className="flex gap-2 items-start">
                              <MapPin className="w-2 h-2 text-red-600 mt-1 flex-shrink-0" />
                              <div className="text-xs text-gray-700 flex-1">{ride.dropoff}</div>
                            </div>
                          </div>
                          <div className="flex justify-between items-center mt-2 pt-2 border-t border-gray-200">
                            <span className="text-xs text-gray-600">Service Fee</span>
                            <span className="text-xs font-medium text-gray-900">{ride.fee}</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Total Payment Breakdown */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-3">Total Payment Breakdown</h4>
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm text-gray-600">Receive Amount</span>
                        <span className="text-sm font-semibold text-green-600">{transaction.totalCOD}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm text-gray-600">Total Fee (-)</span>
                        <span className="text-sm font-semibold text-red-600">-{transaction.totalFee}</span>
                      </div>
                      <div className="border-t border-gray-200 pt-3 flex justify-between items-center">
                        <span className="text-sm font-semibold text-gray-900">Grand Total</span>
                        <span className="text-lg font-bold text-gray-900">{transaction.totalAmount}</span>
                      </div>
                    </div>
                  </div>

                  {/* Date & Time */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <Calendar className="w-4 h-4 text-gray-600" />
                      <h4 className="text-sm font-semibold text-gray-900">Settlement Date & Time</h4>
                    </div>
                    <p className="text-sm text-gray-700">{transaction.fullDate}</p>
                  </div>

                  {/* Additional Details */}
                  <div className="bg-white rounded-xl border border-gray-200 p-4">
                    <h4 className="text-sm font-semibold text-gray-900 mb-2">Details</h4>
                    <p className="text-sm text-gray-700">{transaction.details}</p>
                  </div>
                </div>
              );
            })()}
          </div>
        </div>
      )}
    </div>
  );
}