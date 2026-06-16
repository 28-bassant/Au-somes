class CenterModel {
  final String name;
  final String phone;

  final String address;
  final String locationName;
  final double latitude;
  final double longitude;

  final String facebookName;
  final String facebookLink;

  final String websiteName;
  final String websiteLink;

  final String image;

  CenterModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.facebookName,
    required this.facebookLink,
    required this.websiteName,
    required this.websiteLink,
    required this.image,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',

      address: json['address'] ?? '',
      locationName: json['locationName'] ?? json['address'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),

      facebookName: json['facebookName'] ?? '',
      facebookLink: json['facebookLink'] ?? '',

      websiteName: json['websiteName'] ?? '',
      websiteLink: json['websiteLink'] ?? '',

      image: json['image'] ?? '',
    );
  }
}
