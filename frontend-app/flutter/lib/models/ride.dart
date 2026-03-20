class Ride {
  final int id;
  final String pickup;
  final String dropoff;
  final String distance;
  final String estimatedTime;
  final String fare;
  final double? surgeMultiplier;
  final RiderLocation riderLocation;

  Ride({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.distance,
    required this.estimatedTime,
    required this.fare,
    this.surgeMultiplier,
    required this.riderLocation,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      pickup: json['pickup'],
      dropoff: json['dropoff'],
      distance: json['distance'],
      estimatedTime: json['estimatedTime'],
      fare: json['fare'],
      surgeMultiplier: json['surgeMultiplier'],
      riderLocation: RiderLocation.fromJson(json['riderLocation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup': pickup,
      'dropoff': dropoff,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'fare': fare,
      'surgeMultiplier': surgeMultiplier,
      'riderLocation': riderLocation.toJson(),
    };
  }
}

class RiderLocation {
  final double lat;
  final double lng;

  RiderLocation({required this.lat, required this.lng});

  factory RiderLocation.fromJson(Map<String, dynamic> json) {
    return RiderLocation(
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

// Mock data
class RideMockData {
  static List<Ride> getAvailableRides() {
    return [
      Ride(
        id: 1,
        pickup: '123 Main St, Downtown',
        dropoff: '456 Oak Ave, Westside',
        distance: '5.2 mi',
        estimatedTime: '12 min',
        fare: '\$18.50',
        surgeMultiplier: null,
        riderLocation: RiderLocation(lat: 40.7128, lng: -74.0060),
      ),
      Ride(
        id: 2,
        pickup: '789 Pine Rd, Northgate',
        dropoff: '321 Elm St, Southside',
        distance: '3.8 mi',
        estimatedTime: '9 min',
        fare: '\$14.25',
        surgeMultiplier: 1.5,
        riderLocation: RiderLocation(lat: 40.7580, lng: -73.9855),
      ),
      Ride(
        id: 3,
        pickup: '555 Market St, Central',
        dropoff: '888 Broadway, Eastside',
        distance: '7.1 mi',
        estimatedTime: '18 min',
        fare: '\$24.00',
        surgeMultiplier: null,
        riderLocation: RiderLocation(lat: 40.7489, lng: -73.9680),
      ),
    ];
  }
}
