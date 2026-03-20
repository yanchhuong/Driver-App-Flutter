class DriverModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final String? vehicleType;
  final String? vehiclePlate;
  final String status; // ONLINE | OFFLINE | ON_TRIP
  final double? currentLatitude;
  final double? currentLongitude;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    this.vehicleType,
    this.vehiclePlate,
    required this.status,
    this.currentLatitude,
    this.currentLongitude,
  });

  bool get isOnline => status == 'ONLINE';
  bool get isOnTrip => status == 'ON_TRIP';

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'] ?? '',
        licenseNumber: j['licenseNumber'] ?? '',
        vehicleType: j['vehicleType'],
        vehiclePlate: j['vehiclePlate'],
        status: j['status'] ?? 'OFFLINE',
        currentLatitude: j['currentLatitude']?.toDouble(),
        currentLongitude: j['currentLongitude']?.toDouble(),
      );

  DriverModel copyWith({String? status}) => DriverModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        licenseNumber: licenseNumber,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        status: status ?? this.status,
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
      );
}
