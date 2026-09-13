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

  MosqueState({
    required this.mosques,
    this.isLoading = false,
    this.currentCity = 'Locating...',
    this.userLat,
    this.userLon,
    this.errorMessage,
  });

  MosqueState copyWith({
    List<MosqueLocation>? mosques,
    bool? isLoading,
    String? currentCity,
    double? userLat,
    double? userLon,
    String? errorMessage,
  }) {
    return MosqueState(
      mosques: mosques ?? this.mosques,
      isLoading: isLoading ?? this.isLoading,
      currentCity: currentCity ?? this.currentCity,
      userLat: userLat ?? this.userLat,
      userLon: userLon ?? this.userLon,
      errorMessage: errorMessage,
    );
  }
}

class MosqueNotifier extends StateNotifier<MosqueState> {
  final HiveService _hiveService = HiveService();
  final MosqueApiService _apiService = MosqueApiService();
  static const String _mosqueKey = 'real_mosques_cache_v3';

  MosqueNotifier() : super(MosqueState(mosques: [])) {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // 1. Load cached real mosques first if available
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _mosqueKey);
    final cachedCity = _hiveService.getValue<String>(HiveService.settingsBox, 'last_mosque_city');

    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(
        mosques: cached.map((e) => MosqueLocation.fromMap(e as Map)).toList(),
        currentCity: cachedCity ?? 'Nearby',
      );
    }

    // 2. Fetch live data from API
    await loadNearbyMosques();
  }

  /// Automatically detects user coordinates & fetches live mosques
  Future<void> loadNearbyMosques() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loc = await _apiService.detectUserLocation();
      final lat = loc?.lat ?? 33.6099;
      final lon = loc?.lon ?? 73.0301;
      final city = loc != null ? '${loc.city}, ${loc.country}' : 'Rawalpindi, Pakistan';

      final realMosques = await _apiService.fetchNearbyMosques(lat, lon);

      if (realMosques.isNotEmpty) {
        state = state.copyWith(
          mosques: realMosques,
          isLoading: false,
          currentCity: city,
          userLat: lat,
          userLon: lon,
        );
        _saveToCache(realMosques, city);
      } else {
        // Fallback search by city name
        final fallback = await _apiService.searchMosques(loc?.city ?? 'Rawalpindi', userLat: lat, userLon: lon);
        state = state.copyWith(
          mosques: fallback,
          isLoading: false,
          currentCity: city,
          userLat: lat,
          userLon: lon,
        );
        if (fallback.isNotEmpty) _saveToCache(fallback, city);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to fetch mosques. Please check your internet connection.',
      );
    }
  }

  /// Search mosques in any city or query globally
  Future<void> searchMosques(String query) async {
    if (query.trim().isEmpty) {
      await loadNearbyMosques();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await _apiService.searchMosques(
        query,
        userLat: state.userLat,
        userLon: state.userLon,
      );

      state = state.copyWith(
        mosques: results,
        isLoading: false,
        currentCity: query.trim(),
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
