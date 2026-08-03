class MosqueLocation {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final String jummahTime;
  final Map<String, String> prayerTimes;
  final String imagePlaceholder;

  MosqueLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.jummahTime,
    required this.prayerTimes,
    required this.imagePlaceholder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distanceKm': distanceKm,
      'jummahTime': jummahTime,
      'prayerTimes': prayerTimes,
      'imagePlaceholder': imagePlaceholder,
    };
  }

  factory MosqueLocation.fromMap(Map<dynamic, dynamic> map) {
    final rawTimes = map['prayerTimes'] as Map? ?? {};
    return MosqueLocation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distanceKm: (map['distanceKm'] ?? 1.0).toDouble(),
      jummahTime: map['jummahTime'] ?? '12:30 PM',
      prayerTimes: Map<String, String>.from(rawTimes),
      imagePlaceholder: map['imagePlaceholder'] ?? 'mosque_1',
    );
  }
}
