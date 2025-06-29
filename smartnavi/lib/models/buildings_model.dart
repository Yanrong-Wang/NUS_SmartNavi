class Building {
  final String buildingCode;
  final String buildingName;
  final double latitude;
  final double longitude;

  Building({
    required this.buildingCode,
    required this.buildingName,
    required this.latitude,
    required this.longitude,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      buildingCode: json['buildingCode'] as String,
      buildingName: json['buildingName'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}