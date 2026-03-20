# Real-Time Ride Synchronization Guide

## Overview

The app now has a real-time synchronization system that allows riders and drivers to see updates automatically without manual refresh. This is implemented using localStorage and browser events to simulate real-time communication.

## How It Works

### Architecture

The system uses three key mechanisms for synchronization:

1. **localStorage** - Shared data storage accessible across tabs
2. **Custom Events** - For same-tab communication between components
3. **Storage Events** - For cross-tab communication
4. **Polling** - As a fallback mechanism (every 2 seconds)

### State Manager (`/src/app/utils/rideStateManager.ts`)

This utility manages all ride state and provides functions for:

- Creating ride requests
- Updating ride status
- Accepting/canceling rides
- Subscribing to real-time updates
- Querying rides by status, rider, or driver

### Flow

#### 1. Rider Requests a Ride

**Component:** `RideConfirmationPage.tsx`

```
User clicks "Confirm Ride Request"
  ↓
createRideRequest() called
  ↓
Ride saved to localStorage with status "requested"
  ↓
Events dispatched to notify all listeners
  ↓
Navigate to ActiveRidePage (shows "Finding Driver")
```

#### 2. Driver Sees New Ride Request

**Component:** `RidesPage.tsx`

```
Component mounts
  ↓
Subscribe to ride updates (event listener + polling)
  ↓
getRidesByStatus('requested') fetches available rides
  ↓
Rides displayed in list/map view
  ↓
Auto-updates when new rides appear
```

#### 3. Driver Accepts Ride

**Component:** `RidesPage.tsx`

```
Driver clicks "Accept Ride"
  ↓
acceptRide() called with driver info
  ↓
Ride status updated to "accepted" in localStorage
  ↓
Driver info (name, phone, car details) added to ride
  ↓
Events dispatched to notify all listeners
  ↓
Ride removed from driver's available list
```

#### 4. Rider Sees Driver Accepted

**Component:** `ActiveRidePage.tsx`

```
Component tracking the ride
  ↓
Subscribe to ride updates (event listener + polling)
  ↓
Receives update that ride status changed to "accepted"
  ↓
UI switches from "Finding Driver" to driver details
  ↓
Shows driver name, phone, car info, etc.
```

## Key Functions

### Creating a Ride

```typescript
const rideRequest = createRideRequest({
  riderId: 'rider-123',
  riderName: 'Current User',
  pickup: 'Current Location',
  dropoff: '123 Main St',
  rideType: 'ride',
  serviceType: 'standard',
  estimatedPrice: '$18.50',
  estimatedTime: '12 min',
  distance: '5.2 km',
  paymentMethod: 'card'
});
```

### Subscribing to Updates

```typescript
// Subscribe to all ride updates
const unsubscribe = subscribeToRideUpdates((rides) => {
  console.log('Rides updated:', rides);
  // Update your component state
});

// Subscribe to a specific ride
const unsubscribe = subscribeToRide(rideId, (ride) => {
  console.log('Ride updated:', ride);
  // Update your component state
});

// Don't forget to unsubscribe on cleanup
return () => unsubscribe();
```

### Accepting a Ride

```typescript
const updatedRide = acceptRide(rideId, {
  driverId: 'driver-456',
  driverName: 'John Driver',
  driverPhone: '+1 (555) 123-4567',
  driverRating: 4.9,
  carModel: 'Toyota Camry',
  carPlate: 'ABC 1234',
  carColor: 'Black'
});
```

## Event System

### Custom Event (Same Tab)

When ride data changes, a custom event is dispatched:

```typescript
window.dispatchEvent(new CustomEvent('ride_update', { 
  detail: { rides } 
}));
```

Components listen with:

```typescript
window.addEventListener('ride_update', handleUpdate);
```

### Storage Event (Cross Tab)

When localStorage changes in one tab, other tabs receive a storage event:

```typescript
window.addEventListener('storage', (event) => {
  if (event.key === 'rideshare_rides') {
    // Update rides
  }
});
```

### Polling Fallback

Every 2 seconds, components poll for updates as a fallback:

```typescript
const pollInterval = setInterval(() => {
  const rides = getRidesByStatus('requested');
  setAvailableRides(rides);
}, 2000);
```

## Testing the Real-Time Sync

### Single Tab Testing

1. Open the app as a rider
2. Request a ride
3. Switch to driver view (or open DevTools and manually call acceptRide)
4. Watch the rider's view automatically update

### Multi-Tab Testing

1. Open two browser tabs
2. Log in as rider in Tab 1
3. Log in as driver in Tab 2
4. Request a ride in Tab 1
5. Watch Tab 2 automatically show the new ride request
6. Accept the ride in Tab 2
7. Watch Tab 1 automatically update with driver info

## Data Structure

### RideRequest Interface

```typescript
interface RideRequest {
  id: string;                    // Unique ride ID
  riderId: string;               // ID of the rider
  riderName: string;             // Name of the rider
  pickup: string;                // Pickup location
  dropoff: string;               // Dropoff location
  rideType: 'ride' | 'delivery' | 'express';
  serviceType: string;           // economy, standard, premium, xl
  estimatedPrice: string;        // e.g., "$18.50"
  estimatedTime: string;         // e.g., "12 min"
  distance: string;              // e.g., "5.2 km"
  paymentMethod: string;         // card, cash
  status: 'requested' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';
  timestamp: number;             // Unix timestamp
  
  // Filled when driver accepts
  driverId?: string;
  driverName?: string;
  driverPhone?: string;
  driverRating?: number;
  carModel?: string;
  carPlate?: string;
  carColor?: string;
}
```

## Troubleshooting

### Rides Not Appearing for Driver

- Check browser console for errors
- Verify localStorage is enabled
- Check that ride status is "requested"
- Try refreshing the page

### Rider Not Seeing Driver Acceptance

- Check browser console for the "Ride updated" log
- Verify the ride ID matches
- Check localStorage to see if ride was updated
- Try opening in a new tab to test cross-tab events

### General Issues

- Clear localStorage: `localStorage.clear()` in DevTools console
- Check that all event listeners are properly attached
- Verify polling is running (check console logs)
- Ensure components are properly subscribing/unsubscribing

## Performance Notes

- Polling interval is set to 2 seconds to balance responsiveness and performance
- Old rides (>24 hours) can be cleared with `clearOldRides()`
- localStorage has a 5-10MB limit across all data
- Consider using IndexedDB for production apps with many rides

## Future Improvements

For a production app, consider:

1. **Real Backend**: Replace localStorage with WebSocket or Server-Sent Events
2. **Push Notifications**: Notify users even when app is in background
3. **Geolocation**: Real-time driver location tracking
4. **Optimistic Updates**: Update UI immediately before server confirms
5. **Conflict Resolution**: Handle simultaneous updates from multiple sources
6. **Offline Support**: Queue actions when offline, sync when online
