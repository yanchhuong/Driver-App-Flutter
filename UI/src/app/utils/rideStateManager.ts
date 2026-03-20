// Mock real-time ride state management using localStorage and events

export interface RideRequest {
  id: string;
  riderId: string;
  riderName: string;
  pickup: string;
  dropoff: string;
  rideType: 'ride' | 'delivery' | 'express';
  serviceType: string;
  estimatedPrice: string;
  estimatedTime: string;
  distance: string;
  paymentMethod: string;
  status: 'requested' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';
  timestamp: number;
  driverId?: string;
  driverName?: string;
  driverPhone?: string;
  driverRating?: number;
  carModel?: string;
  carPlate?: string;
  carColor?: string;
}

const RIDES_KEY = 'rideshare_rides';
const RIDE_UPDATE_EVENT = 'ride_update';

// Generate a unique ID for rides
export function generateRideId(): string {
  return `RIDE-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

// Get all rides from localStorage
export function getAllRides(): RideRequest[] {
  try {
    const ridesJson = localStorage.getItem(RIDES_KEY);
    return ridesJson ? JSON.parse(ridesJson) : [];
  } catch (error) {
    console.error('Error reading rides:', error);
    return [];
  }
}

// Get a specific ride by ID
export function getRideById(rideId: string): RideRequest | null {
  const rides = getAllRides();
  return rides.find(ride => ride.id === rideId) || null;
}

// Get rides by status
export function getRidesByStatus(status: RideRequest['status']): RideRequest[] {
  const rides = getAllRides();
  return rides.filter(ride => ride.status === status);
}

// Get rides for a specific rider
export function getRidesForRider(riderId: string): RideRequest[] {
  const rides = getAllRides();
  return rides.filter(ride => ride.riderId === riderId);
}

// Get rides for a specific driver
export function getRidesForDriver(driverId: string): RideRequest[] {
  const rides = getAllRides();
  return rides.filter(ride => ride.driverId === driverId);
}

// Save rides to localStorage and dispatch event
function saveRides(rides: RideRequest[]): void {
  try {
    localStorage.setItem(RIDES_KEY, JSON.stringify(rides));
    
    // Dispatch custom event for same-tab updates
    window.dispatchEvent(new CustomEvent(RIDE_UPDATE_EVENT, { 
      detail: { rides } 
    }));
  } catch (error) {
    console.error('Error saving rides:', error);
  }
}

// Create a new ride request
export function createRideRequest(rideData: Omit<RideRequest, 'id' | 'status' | 'timestamp'>): RideRequest {
  const rides = getAllRides();
  
  const newRide: RideRequest = {
    ...rideData,
    id: generateRideId(),
    status: 'requested',
    timestamp: Date.now()
  };
  
  rides.push(newRide);
  saveRides(rides);
  
  return newRide;
}

// Update ride status
export function updateRideStatus(
  rideId: string, 
  status: RideRequest['status'],
  updates?: Partial<RideRequest>
): RideRequest | null {
  const rides = getAllRides();
  const rideIndex = rides.findIndex(ride => ride.id === rideId);
  
  if (rideIndex === -1) {
    return null;
  }
  
  rides[rideIndex] = {
    ...rides[rideIndex],
    status,
    ...updates
  };
  
  saveRides(rides);
  return rides[rideIndex];
}

// Accept a ride (driver action)
export function acceptRide(
  rideId: string,
  driverData: {
    driverId: string;
    driverName: string;
    driverPhone: string;
    driverRating: number;
    carModel: string;
    carPlate: string;
    carColor: string;
  }
): RideRequest | null {
  return updateRideStatus(rideId, 'accepted', driverData);
}

// Cancel a ride
export function cancelRide(rideId: string): RideRequest | null {
  return updateRideStatus(rideId, 'cancelled');
}

// Complete a ride
export function completeRide(rideId: string): RideRequest | null {
  return updateRideStatus(rideId, 'completed');
}

// Subscribe to ride updates
export function subscribeToRideUpdates(callback: (rides: RideRequest[]) => void): () => void {
  // Handler for custom events (same tab)
  const handleCustomEvent = (event: Event) => {
    const customEvent = event as CustomEvent;
    callback(customEvent.detail.rides);
  };
  
  // Handler for storage events (different tabs)
  const handleStorageEvent = (event: StorageEvent) => {
    if (event.key === RIDES_KEY) {
      callback(getAllRides());
    }
  };
  
  // Add both event listeners
  window.addEventListener(RIDE_UPDATE_EVENT, handleCustomEvent);
  window.addEventListener('storage', handleStorageEvent);
  
  // Return unsubscribe function
  return () => {
    window.removeEventListener(RIDE_UPDATE_EVENT, handleCustomEvent);
    window.removeEventListener('storage', handleStorageEvent);
  };
}

// Subscribe to a specific ride's updates
export function subscribeToRide(rideId: string, callback: (ride: RideRequest | null) => void): () => void {
  return subscribeToRideUpdates((rides) => {
    const ride = rides.find(r => r.id === rideId) || null;
    callback(ride);
  });
}

// Polling function for additional reliability
export function startPolling(callback: () => void, interval: number = 2000): () => void {
  const intervalId = setInterval(callback, interval);
  
  return () => {
    clearInterval(intervalId);
  };
}

// Clear old rides (optional utility)
export function clearOldRides(olderThanHours: number = 24): void {
  const rides = getAllRides();
  const cutoffTime = Date.now() - (olderThanHours * 60 * 60 * 1000);
  
  const recentRides = rides.filter(ride => 
    ride.timestamp > cutoffTime || 
    ride.status === 'in_progress' ||
    ride.status === 'accepted'
  );
  
  saveRides(recentRides);
}
