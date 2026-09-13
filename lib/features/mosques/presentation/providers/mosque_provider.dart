import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/mosque_location.dart';
import '../../services/mosque_api_service.dart';

class MosqueState {
  final List<MosqueLocation> mosques;
  final bool isLoading;
  final String currentCity;
  final double? userLat;
  final double? userLon;
  final String? errorMessage;
  final String? googleApiKey;
  final String activeSource; // 'Google Places' or 'OpenStreetMap'

  MosqueState({
    required this.mosques,
    this.isLoading = false,
    this.currentCity = 'Locating...',
    this.userLat,
    this.userLon,
    this.errorMessage,
    this.googleApiKey,
    this.activeSource = 'OpenStreetMap',
  });

  bool get hasGoogleApiKey => googleApiKey != null && googleApiKey!.trim().isNotEmpty;

  MosqueState copyWith({
    List<MosqueLocation>? mosques,
    bool? isLoading,
    String? currentCity,
    double? userLat,
    double? userLon,
    String? errorMessage,
    String? googleApiKey,
    String? activeSource,
  }) {
    return MosqueState(
      mosques: mosques ?? this.mosques,
      isLoading: isLoading ?? this.isLoading,
      currentCity: currentCity ?? this.currentCity,
      userLat: userLat ?? this.userLat,
      userLon: userLon ?? this.userLon,
      errorMessage: errorMessage,
      googleApiKey: googleApiKey ?? this.googleApiKey,
      activeSource: activeSource ?? this.activeSource,
    );
  }
}

class MosqueNotifier extends StateNotifier<MosqueState> {
  final HiveService _hiveService = HiveService();
  final MosqueApiService _apiService = MosqueApiService();
  static const String _mosqueKey = 'real_mosques_cache_v4';
  static const String _googleKeySetting = 'google_places_api_key';

  MosqueNotifier() : super(MosqueState(mosques: [])) {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // 1. Read stored Google API key if any
    final savedKey = _hiveService.getValue<String>(HiveService.settingsBox, _googleKeySetting);
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      state = state.copyWith(googleApiKey: savedKey.trim(), activeSource: 'Google Places');
    }

    // 2. Load cached mosques
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _mosqueKey);
    final cachedCity = _hiveService.getValue<String>(HiveService.settingsBox, 'last_mosque_city');

    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(
        mosques: cached.map((e) => MosqueLocation.fromMap(e as Map)).toList(),
        currentCity: cachedCity ?? 'Nearby',
      );
    }

    // 3. Fetch live data
    await loadNearbyMosques();
  }

  /// Save or remove Google Places API Key
  Future<void> setGoogleApiKey(String key) async {
    final trimmed = key.trim();
    await _hiveService.setValue<String>(HiveService.settingsBox, _googleKeySetting, trimmed);
    state = state.copyWith(
      googleApiKey: trimmed.isEmpty ? null : trimmed,
      activeSource: trimmed.isEmpty ? 'OpenStreetMap' : 'Google Places',
    );
    await loadNearbyMosques();
  }

  /// Automatically detects user coordinates & fetches live mosques
  Future<void> loadNearbyMosques() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loc = await _apiService.detectUserLocation();
      final lat = loc?.lat ?? 33.6844;
      final lon = loc?.lon ?? 73.0479;
      final city = loc?.city ?? 'Islamabad';

      List<MosqueLocation> realMosques = [];
      String usedSource = 'OpenStreetMap';

      // 1. If Google API key is configured, use Google Places API
      if (state.hasGoogleApiKey) {
        realMosques = await _apiService.fetchGoogleNearbyMosques(lat, lon, state.googleApiKey!);
        if (realMosques.isNotEmpty) {
          usedSource = 'Google Places';
        }
      }

      // 2. If no Google key or Google returned zero results, use Overpass / OSM
      if (realMosques.isEmpty) {
        realMosques = await _apiService.fetchNearbyMosques(lat, lon);
        usedSource = 'OpenStreetMap';
      }

      // 3. Fallback search by city if still empty
      if (realMosques.isEmpty) {
        realMosques = await _apiService.searchMosques(city, userLat: lat, userLon: lon);
      }

      state = state.copyWith(
        mosques: realMosques,
        isLoading: false,
        currentCity: city,
        userLat: lat,
        userLon: lon,
        activeSource: usedSource,
      );

      if (realMosques.isNotEmpty) {
        _saveToCache(realMosques, city);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to fetch mosques. Please check your internet connection.',
      );
    }
  }

  /// Search mosques in any city, sector or query
  Future<void> searchMosques(String query) async {
    if (query.trim().isEmpty) {
      await loadNearbyMosques();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      List<MosqueLocation> results = [];
      String usedSource = 'OpenStreetMap';

      if (state.hasGoogleApiKey) {
        results = await _apiService.searchGoogleMosques(
          query,
          state.googleApiKey!,
          userLat: state.userLat,
          userLon: state.userLon,
        );
        if (results.isNotEmpty) {
          usedSource = 'Google Places';
        }
      }

      if (results.isEmpty) {
        results = await _apiService.searchMosques(
          query,
          userLat: state.userLat,
          userLon: state.userLon,
        );
        usedSource = 'OpenStreetMap';
      }

      state = state.copyWith(
        mosques: results,
        isLoading: false,
        currentCity: query.trim(),
        activeSource: usedSource,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error searching for mosques in $query.',
      );
    }
  }

  Future<void> _saveToCache(List<MosqueLocation> list, String city) async {
    final mapped = list.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _mosqueKey, mapped);
    await _hiveService.setValue<String>(HiveService.settingsBox, 'last_mosque_city', city);
  }
}

final mosqueNotifierProvider = StateNotifierProvider<MosqueNotifier, MosqueState>((ref) {
  return MosqueNotifier();
});
