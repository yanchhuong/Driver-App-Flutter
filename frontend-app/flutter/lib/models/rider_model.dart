class RiderModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final double rating;

  RiderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rating,
  });

  factory RiderModel.fromJson(Map<String, dynamic> j) => RiderModel(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'] ?? '',
        rating: (j['rating'] ?? 5.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}
