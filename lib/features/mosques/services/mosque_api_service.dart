import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../domain/models/mosque_location.dart';

class UserLocationResult {
  final String city;
  final String country;
  final double lat;
  final double lon;
  final bool isGps;

  UserLocationResult({
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    this.isGps = false,
  });
}

class MosqueApiService {
  static final MosqueApiService _instance = MosqueApiService._internal();
  factory MosqueApiService() => _instance;
  MosqueApiService._internal();

  /// Automatically detect user's current city & coordinates
  /// Priority: 1. Device GPS (Geolocator) -> 2. IP Geolocation -> 3. Islamabad Default
  Future<UserLocationResult?> detectUserLocation() async {
    // 1. Try real device / browser GPS
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 6),
            ),
          );

          final reverseAddress = await reverseGeocode(position.latitude, position.longitude);

          return UserLocationResult(
            city: reverseAddress ?? 'Islamabad (Current GPS)',
            country: 'Pakistan',
            lat: position.latitude,
            lon: position.longitude,
            isGps: true,
          );
        }
      }
    } catch (e) {
      debugPrint('GPS detection skipped or failed: $e');
    }

    // 2. Fallback to IP geolocation
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return UserLocationResult(
            city: data['city'] ?? 'Islamabad',
            country: data['country'] ?? 'Pakistan',
            lat: (data['lat'] as num).toDouble(),
            lon: (data['lon'] as num).toDouble(),
            isGps: false,
          );
        }
      }
    } catch (e) {
      debugPrint('IP location detection error: $e');
    }

    return UserLocationResult(
      city: 'Islamabad',
      country: 'Pakistan',
      lat: 33.6844,
      lon: 73.0479,
      isGps: false,
    );
  }

  /// Reverse geocode coordinates to human-readable neighborhood/sector
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'UmmahConnectApp/1.0',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final suburb = address['suburb'] ??
              address['neighbourhood'] ??
              address['residential'] ??
              address['city_district'];
          final city = address['city'] ?? address['town'] ?? address['state'] ?? 'Islamabad';

          if (suburb != null && suburb.toString().isNotEmpty) {
            return '$suburb, $city';
          }
          return city.toString();
        }
      }
    } catch (_) {}
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

    return {
      'Fajr': '04:30 AM',
      'Dhuhr': '12:15 PM',
      'Asr': '03:45 PM',
      'Maghrib': '06:20 PM',
      'Isha': '07:45 PM',
    };
  }

  // =========================================================================
  // GOOGLE PLACES API ENGINE
  // =========================================================================

  /// Fetch nearby mosques via official Google Places Nearby Search API
  Future<List<MosqueLocation>> fetchGoogleNearbyMosques(
    double lat,
    double lon,
    String apiKey, {
    int radiusMeters = 7000,
  }) async {
    final List<MosqueLocation> mosques = [];
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lon'
        '&radius=$radiusMeters'
        '&type=mosque'
        '&key=$apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        final prayerTimes = await fetchPrayerTimes(lat, lon);

        for (var place in results) {
          final loc = place['geometry']?['location'];
          if (loc == null) continue;

          final placeLat = (loc['lat'] as num).toDouble();
          final placeLon = (loc['lng'] as num).toDouble();
          final name = place['name']?.toString() ?? 'Masjid';
          final vicinity = place['vicinity']?.toString() ?? place['formatted_address']?.toString() ?? 'Nearby';
          final dist = _calculateDistanceKm(lat, lon, placeLat, placeLon);
          final rating = (place['rating'] as num?)?.toDouble();
          final totalReviews = place['user_ratings_total'] as int?;

          mosques.add(
            MosqueLocation(
              id: place['place_id']?.toString() ?? 'g_${mosques.length}',
              name: name,
              address: vicinity,
              distanceKm: double.parse(dist.toStringAsFixed(1)),
              latitude: placeLat,
              longitude: placeLon,
              jummahTime: '12:45 PM (Khutbah) / 01:15 PM',
              prayerTimes: prayerTimes,
              imagePlaceholder: 'mosque_${(mosques.length % 5) + 1}',
              rating: rating,
              userRatingsTotal: totalReviews,
              source: 'Google Places',
            ),
          );
        }

        mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      }
    } catch (e) {
      debugPrint('Google Places Nearby API error: $e');
    }
    return mosques;
  }

  /// Search mosques via Google Places Text Search API
  Future<List<MosqueLocation>> searchGoogleMosques(
    String query,
    String apiKey, {
    double? userLat,
    double? userLon,
  }) async {
    final List<MosqueLocation> mosques = [];
    try {
      final sanitizedQuery = Uri.encodeComponent('mosques in $query');
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=$sanitizedQuery'
        '&key=$apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        Map<String, String>? timings;

        for (var place in results) {
          final loc = place['geometry']?['location'];
          if (loc == null) continue;

          final placeLat = (loc['lat'] as num).toDouble();
          final placeLon = (loc['lng'] as num).toDouble();
          final name = place['name']?.toString() ?? 'Masjid';
          final address = place['formatted_address']?.toString() ?? place['vicinity']?.toString() ?? query;

          double dist = 1.0;
          if (userLat != null && userLon != null) {
            dist = _calculateDistanceKm(userLat, userLon, placeLat, placeLon);
          }

          timings ??= await fetchPrayerTimes(placeLat, placeLon);

          final rating = (place['rating'] as num?)?.toDouble();
          final totalReviews = place['user_ratings_total'] as int?;

          mosques.add(
            MosqueLocation(
              id: place['place_id']?.toString() ?? 'g_${mosques.length}',
              name: name,
              address: address,
              distanceKm: double.parse(dist.toStringAsFixed(1)),
              latitude: placeLat,
              longitude: placeLon,
              jummahTime: '12:45 PM (Khutbah) / 01:15 PM',
              prayerTimes: timings,
              imagePlaceholder: 'mosque_${(mosques.length % 5) + 1}',
              rating: rating,
              userRatingsTotal: totalReviews,
              source: 'Google Places',
            ),
          );
        }

        if (userLat != null && userLon != null) {
          mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        }
      }
    } catch (e) {
      debugPrint('Google Places Text Search error: $e');
    }
    return mosques;
  }

  // =========================================================================
  // OPENSTREETMAP & OVERPASS ENGINE (FREE & BUILT-IN FALLBACK)
  // =========================================================================

  /// Fetch comprehensive local mosques using Overpass API
  /// Finds ALL mosques, Jamiat, and places of worship in the sector/radius
  Future<List<MosqueLocation>> fetchOverpassNearbyMosques(
    double lat,
    double lon, {
    int radiusMeters = 8000,
  }) async {
    final List<MosqueLocation> mosques = [];

    try {
      final query = '''
[out:json][timeout:20];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  node["amenity"="place_of_worship"](around:$radiusMeters,$lat,$lon);
  way["amenity"="place_of_worship"](around:$radiusMeters,$lat,$lon);
);
out center 45;
''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http
          .post(url, body: {'data': query})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List? ?? [];
        final timings = await fetchPrayerTimes(lat, lon);

        final Set<String> seenNames = {};

        for (var el in elements) {
          final tags = el['tags'] as Map<String, dynamic>? ?? {};
          final religion = (tags['religion']?.toString() ?? '').toLowerCase();

          // Exclude explicitly non-Islamic places of worship if marked
          if (religion.isNotEmpty &&
              religion != 'muslim' &&
              religion != 'islam' &&
              religion != 'none') {
            continue;
          }

          double itemLat = 0.0;
          double itemLon = 0.0;
          if (el['type'] == 'node') {
            itemLat = (el['lat'] as num?)?.toDouble() ?? 0.0;
            itemLon = (el['lon'] as num?)?.toDouble() ?? 0.0;
          } else if (el['center'] != null) {
            itemLat = (el['center']['lat'] as num?)?.toDouble() ?? 0.0;
            itemLon = (el['center']['lon'] as num?)?.toDouble() ?? 0.0;
          }

          if (itemLat == 0.0 || itemLon == 0.0) continue;

          String rawName = tags['name']?.toString() ??
              tags['name:en']?.toString() ??
              tags['name:ur']?.toString() ??
              '';

          if (rawName.isEmpty) {
            final street = tags['addr:street']?.toString() ?? tags['addr:suburb']?.toString();
            if (street != null && street.isNotEmpty) {
              rawName = 'Jamia Masjid ($street)';
            } else {
              rawName = 'Masjid';
            }
          }

          // Build clean address
          final addrParts = <String>[];
          if (tags['addr:street'] != null) addrParts.add(tags['addr:street'].toString());
          if (tags['addr:suburb'] != null) addrParts.add(tags['addr:suburb'].toString());
          if (tags['addr:city'] != null) addrParts.add(tags['addr:city'].toString());

          String address = addrParts.isNotEmpty
              ? addrParts.join(', ')
              : 'Mosque, Local Sector Area';

          final dist = _calculateDistanceKm(lat, lon, itemLat, itemLon);

          // Deduplicate identical names close to each other
          final dedupeKey = '${rawName.toLowerCase()}_${(itemLat * 100).round()}_${(itemLon * 100).round()}';
          if (seenNames.contains(dedupeKey)) continue;
          seenNames.add(dedupeKey);

          mosques.add(
            MosqueLocation(
              id: '${el['type']}_${el['id']}',
              name: rawName,
              address: address,
              distanceKm: double.parse(dist.toStringAsFixed(1)),
              latitude: itemLat,
              longitude: itemLon,
              jummahTime: '12:45 PM (Khutbah) / 01:15 PM',
              prayerTimes: timings,
              imagePlaceholder: 'mosque_${(mosques.length % 5) + 1}',
              source: 'OpenStreetMap',
            ),
          );
        }

        mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      }
    } catch (e) {
      debugPrint('Overpass API fetch error: $e');
    }

    return mosques;
  }

  /// Combined fetch: tries Overpass first, then Nominatim fallback
  Future<List<MosqueLocation>> fetchNearbyMosques(double lat, double lon) async {
    // 1. Try Overpass API for comprehensive neighborhood coverage
    final overpassResults = await fetchOverpassNearbyMosques(lat, lon);
    if (overpassResults.isNotEmpty) {
      return overpassResults;
    }

    // 2. Fallback to Nominatim multi-keyword query
    return _fetchNominatimNearby(lat, lon);
  }

  Future<List<MosqueLocation>> _fetchNominatimNearby(double lat, double lon) async {
    final List<MosqueLocation> mosques = [];
    try {
      final delta = 0.15; // ~16km
      final minLon = lon - delta;
      final maxLon = lon + delta;
      final minLat = lat - delta;
      final maxLat = lat + delta;

      final timings = await fetchPrayerTimes(lat, lon);
      final keywords = ['masjid', 'mosque'];

      for (var kw in keywords) {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$kw&viewbox=$minLon,$maxLat,$maxLon,$minLat&bounded=1&limit=25',
        );

        final response = await http.get(url, headers: {
          'User-Agent': 'UmmahConnectApp/1.0',
        }).timeout(const Duration(seconds: 8));

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

            if (!mosques.any((m) => m.id == item['place_id']?.toString())) {
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
                  source: 'OpenStreetMap',
                ),
              );
            }
          }
        }
      }

      mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } catch (e) {
      debugPrint('Nominatim nearby error: $e');
    }
    return mosques;
  }

  /// Search mosques in any city, sector or query globally
  Future<List<MosqueLocation>> searchMosques(
    String query, {
    double? userLat,
    double? userLon,
  }) async {
    final List<MosqueLocation> mosques = [];

    try {
      // 1. First geocode the query location to get center lat/lon
      final geocodeUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final geoResponse = await http.get(geocodeUrl, headers: {
        'User-Agent': 'UmmahConnectApp/1.0',
      }).timeout(const Duration(seconds: 6));

      if (geoResponse.statusCode == 200) {
        final List geoData = json.decode(geoResponse.body);
        if (geoData.isNotEmpty) {
          final targetLat = double.tryParse(geoData[0]['lat']?.toString() ?? '') ?? 0.0;
          final targetLon = double.tryParse(geoData[0]['lon']?.toString() ?? '') ?? 0.0;

          if (targetLat != 0.0 && targetLon != 0.0) {
            // Run Overpass around that geocoded sector/city center
            final sectorMosques = await fetchOverpassNearbyMosques(targetLat, targetLon, radiusMeters: 6000);
            if (sectorMosques.isNotEmpty) {
              if (userLat != null && userLon != null) {
                // Recompute distance from user's current location
                return sectorMosques.map((m) {
                  final d = _calculateDistanceKm(userLat, userLon, m.latitude, m.longitude);
                  return MosqueLocation(
                    id: m.id,
                    name: m.name,
                    address: m.address,
                    distanceKm: double.parse(d.toStringAsFixed(1)),
                    latitude: m.latitude,
                    longitude: m.longitude,
                    jummahTime: m.jummahTime,
                    prayerTimes: m.prayerTimes,
                    imagePlaceholder: m.imagePlaceholder,
                    source: m.source,
                  );
                }).toList()..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
              }
              return sectorMosques;
            }
          }
        }
      }

      // 2. Fallback Nominatim search with query
      final sanitizedQuery = Uri.encodeComponent('mosque $query');
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$sanitizedQuery&format=json&limit=25',
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
              source: 'OpenStreetMap',
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

  /// Haversine formula to compute distance in km
  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
