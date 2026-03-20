class Trip {
  final int id;
  final String riderName;
  final String date;
  final String time;
  final String pickup;
  final String dropoff;
  final String fare;
  final TripStatus status;
  final String rideType;
  final String? notes;

  Trip({
    required this.id,
    required this.riderName,
    required this.date,
    required this.time,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.status,
    required this.rideType,
    this.notes,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      riderName: json['riderName'],
      date: json['date'],
      time: json['time'],
      pickup: json['pickup'],
      dropoff: json['dropoff'],
      fare: json['fare'],
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${json['status']}',
      ),
      rideType: json['rideType'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderName': riderName,
      'date': date,
      'time': time,
      'pickup': pickup,
      'dropoff': dropoff,
      'fare': fare,
      'status': status.toString().split('.').last,
      'rideType': rideType,
      'notes': notes,
    };
  }
}

enum TripStatus {
  complete,
  cancelled,
  inProgress,
  scheduled,
}

class TripMockData {
  static List<Trip> getAllTrips() {
    return [
      Trip(
        id: 1,
        riderName: 'Sarah Johnson',
        date: 'Feb 8, 2026',
        time: '2:30 PM',
        pickup: '123 Main St, Downtown',
        dropoff: '456 Oak Ave, Westside',
        fare: '\$18.50',
        status: TripStatus.complete,
        rideType: 'Standard',
        notes: 'Please use back entrance',
      ),
      Trip(
        id: 2,
        riderName: 'Michael Chen',
        date: 'Feb 8, 2026',
        time: '1:15 PM',
        pickup: '789 Pine Rd, Northgate',
        dropoff: '321 Elm St, Southside',
        fare: '\$24.00',
        status: TripStatus.complete,
        rideType: 'Premium',
      ),
      Trip(
        id: 3,
        riderName: 'Emma Davis',
        date: 'Feb 8, 2026',
        time: '12:45 PM',
        pickup: '555 Market St, Central',
        dropoff: '888 Broadway, Eastside',
        fare: '\$15.75',
        status: TripStatus.cancelled,
        rideType: 'Standard',
        notes: 'Rider cancelled - waited 10 min',
      ),
      Trip(
        id: 4,
        riderName: 'James Wilson',
        date: 'Feb 7, 2026',
        time: '6:00 PM',
        pickup: '222 River St, Riverside',
        dropoff: '777 Hill Ave, Highland',
        fare: '\$32.50',
        status: TripStatus.complete,
        rideType: 'XL',
        notes: 'Airport pickup',
      ),
      Trip(
        id: 5,
        riderName: 'Lisa Anderson',
        date: 'Feb 7, 2026',
        time: '4:30 PM',
        pickup: '333 Lake Dr, Lakeside',
        dropoff: '999 Park Blvd, Parkview',
        fare: '\$19.25',
        status: TripStatus.complete,
        rideType: 'Standard',
      ),
      Trip(
        id: 6,
        riderName: 'David Martinez',
        date: 'Feb 9, 2026',
        time: '10:00 AM',
        pickup: '444 Coast Rd, Beachside',
        dropoff: '666 Valley St, Valley',
        fare: '\$28.00',
        status: TripStatus.scheduled,
        rideType: 'Premium',
        notes: 'Scheduled for tomorrow morning',
      ),
    ];
  }
}
