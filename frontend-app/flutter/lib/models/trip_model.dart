class TripModel {
  final int id;
  final int riderId;
  final int? driverId;
  final String tripType;       // RIDE | DELIVERY
  final String? deliveryType;  // EXPRESS | NORMAL
  final String? packageDescription;
  final String? recipientName;
  final String? recipientPhone;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? pickupAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String? dropoffAddress;
  final String status; // REQUESTED|ACCEPTED|IN_PROGRESS|COMPLETED|CANCELLED
  final String? requestedAt;
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final double? fareAmount;
  final double? distanceKm;

  TripModel({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.tripType,
    this.deliveryType,
    this.packageDescription,
    this.recipientName,
    this.recipientPhone,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.dropoffAddress,
    required this.status,
    this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.fareAmount,
    this.distanceKm,
  });

  bool get isDelivery => tripType == 'DELIVERY';
  bool get isActive =>
      status == 'REQUESTED' || status == 'ACCEPTED' || status == 'IN_PROGRESS';

  factory TripModel.fromJson(Map<String, dynamic> j) => TripModel(
        id: j['id'],
        riderId: j['rider']?['id'] ?? j['riderId'] ?? 0,
        driverId: j['driver']?['id'] ?? j['driverId'],
        tripType: j['tripType'] ?? 'RIDE',
        deliveryType: j['deliveryType'],
        packageDescription: j['packageDescription'],
        recipientName: j['recipientName'],
        recipientPhone: j['recipientPhone'],
        pickupLatitude: j['pickupLatitude']?.toDouble(),
        pickupLongitude: j['pickupLongitude']?.toDouble(),
        pickupAddress: j['pickupAddress'],
        dropoffLatitude: j['dropoffLatitude']?.toDouble(),
        dropoffLongitude: j['dropoffLongitude']?.toDouble(),
        dropoffAddress: j['dropoffAddress'],
        status: j['status'] ?? 'REQUESTED',
        requestedAt: j['requestedAt'],
        acceptedAt: j['acceptedAt'],
        arrivedAt: j['arrivedAt'],
        startedAt: j['startedAt'],
        completedAt: j['completedAt'],
        fareAmount: j['fareAmount']?.toDouble(),
        distanceKm: j['distanceKm']?.toDouble(),
      );
}
