import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/mosque_location.dart';

class UserLocationResult {
  final String city;
  final String country;
  final double lat;
  final double lon;

  UserLocationResult({
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
  });
}

class MosqueApiService {
  static final MosqueApiService _instance = MosqueApiService._internal();
  factory MosqueApiService() => _instance;
  MosqueApiService._internal();

  /// Automatically detect user's current city & coordinates
  Future<UserLocationResult?> detectUserLocation() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return UserLocationResult(
            city: data['city'] ?? 'Rawalpindi',
            country: data['country'] ?? 'Pakistan',
            lat: (data['lat'] as num).toDouble(),
            lon: (data['lon'] as num).toDouble(),
          );
        }
      }
    } catch (e) {
      debugPrint('Location detection error: $e');
    }
    return null;
  }

  /// Fetch real prayer times for the coordinates from AlAdhan API
  Future<Map<String, String>> fetchPrayerTimes(double lat, double lon) async {
    try {
      final url = Uri.parse('https://api.aladhan.com/v1/timings/today?latitude=$lat&longitude=$lon');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] != null) {
          final timings = decoded['data']['timings'];
          return {
            'Fajr': timings['Fajr'] ?? '04:30',
            'Dhuhr': timings['Dhuhr'] ?? '12:15',
            'Asr': timings['Asr'] ?? '15:45',
            'Maghrib': timings['Maghrib'] ?? '18:20',
            'Isha': timings['Isha'] ?? '19:45',
          };
        }
      }
    } catch (e) {
      debugPrint('Prayer times fetch error: $e');
    }

    // Default fallback prayer timings
    return {
      'Fajr': '04:30 AM',
      'Dhuhr': '12:15 PM',
      'Asr': '03:45 PM',
      'Maghrib': '06:20 PM',
      'Isha': '07:45 PM',
    };
  }

  /// Fetch real live nearby mosques from OpenStreetMap Nominatim around lat/lon
  Future<List<MosqueLocation>> fetchNearbyMosques(double lat, double lon) async {
    final List<MosqueLocation> mosques = [];

    try {
      // Calculate viewbox bounding box ~15km around user
      final deltaLat = 0.12;
      final deltaLon = 0.12;
      final minLon = lon - deltaLon;
      final maxLon = lon + deltaLon;
      final minLat = lat - deltaLat;
      final maxLat = lat + deltaLat;

      final timings = await fetchPrayerTimes(lat, lon);

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=mosque&viewbox=$minLon,$maxLat,$maxLon,$minLat&bounded=1&limit=25',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'UmmahConnectApp/1.0',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        for (var item in data) {
          final itemLat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final itemLon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          final rawName = item['name']?.toString() ?? '';
          final displayName = item['display_name']?.toString() ?? '';

          String mosqueName = rawName.isNotEmpty ? rawName : 'Masjid';
          if (mosqueName.toLowerCase() == 'masjid' || mosqueName.toLowerCase() == 'mosque') {
            final parts = displayName.split(',');
            if (parts.length > 1) {
              mosqueName = 'Masjid (${parts[1].trim()})';
            }
          }

          final dist = _calculateDistanceKm(lat, lon, itemLat, itemLon);

          mosques.add(
            MosqueLocation(
              id: item['place_id']?.toString() ?? 'm_${mosques.length}',
              name: mosqueName,
              address: displayName,
              distanceKm: double.parse(dist.toStringAsFixed(1)),
              latitude: itemLat,
              longitude: itemLon,
              jummahTime: '12:45 PM (Khutbah) / 01:15 PM',
              prayerTimes: timings,
              imagePlaceholder: 'mosque_${(mosques.length % 5) + 1}',
            ),
          );
        }

        // Sort by distance (nearest first)
        mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      }
    } catch (e) {
      debugPrint('Error fetching nearby mosques from OpenStreetMap: $e');
    }

    return mosques;
  }

  /// Search real mosques in any city or query globally
  Future<List<MosqueLocation>> searchMosques(String query, {double? userLat, double? userLon}) async {
    final List<MosqueLocation> mosques = [];

    try {
      final sanitizedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=mosque+$sanitizedQuery&format=json&limit=25',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'UmmahConnectApp/1.0',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        Map<String, String>? fetchedTimings;

        for (var item in data) {
          final itemLat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final itemLon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          final rawName = item['name']?.toString() ?? '';
          final displayName = item['display_name']?.toString() ?? '';

          String mosqueName = rawName.isNotEmpty ? rawName : 'Masjid';
          if (mosqueName.toLowerCase() == 'masjid' || mosqueName.toLowerCase() == 'mosque') {
            final parts = displayName.split(',');
            if (parts.length > 1) {
              mosqueName = 'Masjid (${parts[1].trim()})';
            }
          }

          double dist = 1.0;
          if (userLat != null && userLon != null && itemLat != 0.0 && itemLon != 0.0) {
            dist = _calculateDistanceKm(userLat, userLon, itemLat, itemLon);
          }

          fetchedTimings ??= await fetchPrayerTimes(itemLat, itemLon);

          mosques.add(
            MosqueLocation(
              id: item['place_id']?.toString() ?? 'm_${mosques.length}',
              name: mosqueName,
              address: displayName,
              distanceKm: double.parse(dist.toStringAsFixed(1)),
              latitude: itemLat,
              longitude: itemLon,
              jummahTime: '12:45 PM (Khutbah) / 01:15 PM',
              prayerTimes: fetchedTimings,
              imagePlaceholder: 'mosque_${(mosques.length % 5) + 1}',
            ),
          );
        }

        if (userLat != null && userLon != null) {
          mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        }
      }
    } catch (e) {
      debugPrint('Error searching mosques from OpenStreetMap: $e');
    }

    return mosques;
  }

  /// Haversine formula to compute great-circle distance between two points in km
  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
