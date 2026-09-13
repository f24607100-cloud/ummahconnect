class MosqueLocation {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final String jummahTime;
  final Map<String, String> prayerTimes;
  final String imagePlaceholder;

  MosqueLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.jummahTime,
    required this.prayerTimes,
    required this.imagePlaceholder,
  });

  String get googleMapsUrl {
    if (latitude != 0.0 && longitude != 0.0) {
      return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    }
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distanceKm': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
      'jummahTime': jummahTime,
      'prayerTimes': prayerTimes,
      'imagePlaceholder': imagePlaceholder,
    };
  }

  factory MosqueLocation.fromMap(Map<dynamic, dynamic> map) {
    final rawTimes = map['prayerTimes'] as Map? ?? {};
    return MosqueLocation(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distanceKm: (map['distanceKm'] is num) ? (map['distanceKm'] as num).toDouble() : 1.0,
      latitude: (map['latitude'] is num) ? (map['latitude'] as num).toDouble() : 0.0,
      longitude: (map['longitude'] is num) ? (map['longitude'] as num).toDouble() : 0.0,
      jummahTime: map['jummahTime'] ?? '12:45 PM',
      prayerTimes: Map<String, String>.from(rawTimes),
      imagePlaceholder: map['imagePlaceholder'] ?? 'mosque_1',
    );
  }
}
