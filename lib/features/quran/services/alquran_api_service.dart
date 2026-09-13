import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/hive_service.dart';

class AlQuranApiService {
  static final AlQuranApiService _instance = AlQuranApiService._internal();
  factory AlQuranApiService() => _instance;
  AlQuranApiService._internal();

  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  final HiveService _hiveService = HiveService();

  // In-memory caches for fast switching
  final Map<int, Map<String, dynamic>> _pageCache = {};
  final Map<int, List<Map<String, dynamic>>> _surahCache = {};

  /// Fetch full authentic Quran Page (1-604) with Uthmani script and translations
  Future<Map<String, dynamic>> getPageData(int pageNumber) async {
    // 1. Check in-memory cache
    if (_pageCache.containsKey(pageNumber)) {
      return _pageCache[pageNumber]!;
    }

    // 2. Check persistent Hive cache
    final cachedHive = _hiveService.getValue<Map>(
      HiveService.quranBox,
      'mushaf_page_$pageNumber',
    );
    if (cachedHive != null) {
      final parsed = Map<String, dynamic>.from(cachedHive);
      _pageCache[pageNumber] = parsed;
      return parsed;
    }

    // 3. Fetch live authentic data from AlQuran Cloud API
    try {
      final uthmaniUri = Uri.parse('$_baseUrl/page/$pageNumber/quran-uthmani');
      final englishUri = Uri.parse('$_baseUrl/page/$pageNumber/en.sahih');
      final urduUri = Uri.parse('$_baseUrl/page/$pageNumber/ur.jalandhry');

      final responses = await Future.wait([
        http.get(uthmaniUri).timeout(const Duration(seconds: 12)),
        http.get(englishUri).timeout(const Duration(seconds: 12)),
        http.get(urduUri).timeout(const Duration(seconds: 12)),
      ]);

      if (responses[0].statusCode == 200) {
        final uthmaniDecoded = json.decode(responses[0].body);
        final englishDecoded = responses[1].statusCode == 200 ? json.decode(responses[1].body) : null;
        final urduDecoded = responses[2].statusCode == 200 ? json.decode(responses[2].body) : null;

        final uthmaniData = uthmaniDecoded['data'];
        final List uthmaniAyahs = uthmaniData['ayahs'] ?? [];
        final List englishAyahs = englishDecoded?['data']?['ayahs'] ?? [];
        final List urduAyahs = urduDecoded?['data']?['ayahs'] ?? [];

        final List<Map<String, dynamic>> parsedAyahs = [];

        for (int i = 0; i < uthmaniAyahs.length; i++) {
          final uAyah = uthmaniAyahs[i];
          final enText = (i < englishAyahs.length) ? (englishAyahs[i]['text'] ?? '') : '';
          final urText = (i < urduAyahs.length) ? (urduAyahs[i]['text'] ?? '') : '';

          parsedAyahs.add({
            'number': uAyah['number'],
            'numberInSurah': uAyah['numberInSurah'],
            'text': uAyah['text'],
            'englishText': enText,
            'urduText': urText,
            'juz': uAyah['juz'],
            'page': uAyah['page'],
            'surah': uAyah['surah'],
            'audioUrl': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${uAyah['number']}.mp3',
          });
        }

        final result = {
          'pageNumber': pageNumber,
          'ayahs': parsedAyahs,
          'juz': parsedAyahs.isNotEmpty ? parsedAyahs.first['juz'] : 1,
          'surahNameEnglish': parsedAyahs.isNotEmpty ? (parsedAyahs.first['surah']['englishName'] ?? '') : '',
          'surahNameArabic': parsedAyahs.isNotEmpty ? (parsedAyahs.first['surah']['name'] ?? '') : '',
        };

        _pageCache[pageNumber] = result;
        await _hiveService.setValue<Map>(HiveService.quranBox, 'mushaf_page_$pageNumber', result);
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching authentic Quran page $pageNumber: $e');
    }

    return {};
  }

  /// Fetch full authentic Surah (1-114) with all verses, English, and Urdu translations
  Future<List<Map<String, dynamic>>> getSurahData(int surahNumber) async {
    // 1. Check in-memory cache
    if (_surahCache.containsKey(surahNumber)) {
      return _surahCache[surahNumber]!;
    }

    // 2. Check persistent Hive cache
    final cachedHive = _hiveService.getValue<List>(
      HiveService.quranBox,
      'surah_full_$surahNumber',
    );
    if (cachedHive != null) {
      final parsed = cachedHive.map((e) => Map<String, dynamic>.from(e)).toList();
      _surahCache[surahNumber] = parsed;
      return parsed;
    }

    // 3. Fetch authentic Surah multi-edition from AlQuran Cloud API
    try {
      final url = Uri.parse('$_baseUrl/surah/$surahNumber/editions/quran-uthmani,en.sahih,ur.jalandhry');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] is List) {
          final List editions = decoded['data'];
          final uthmaniEdition = editions.firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani', orElse: () => editions[0]);
          final englishEdition = editions.firstWhere((e) => e['edition']['identifier'] == 'en.sahih', orElse: () => null);
          final urduEdition = editions.firstWhere((e) => e['edition']['identifier'] == 'ur.jalandhry', orElse: () => null);

          final List uthmaniAyahs = uthmaniEdition['ayahs'] ?? [];
          final List englishAyahs = englishEdition?['ayahs'] ?? [];
          final List urduAyahs = urduEdition?['ayahs'] ?? [];

          final List<Map<String, dynamic>> parsedAyahs = [];

          for (int i = 0; i < uthmaniAyahs.length; i++) {
            final uAyah = uthmaniAyahs[i];
            final enText = (i < englishAyahs.length) ? (englishAyahs[i]['text'] ?? '') : '';
            final urText = (i < urduAyahs.length) ? (urduAyahs[i]['text'] ?? '') : '';

            parsedAyahs.add({
              'number': uAyah['number'],
              'numberInSurah': uAyah['numberInSurah'],
              'text': uAyah['text'],
              'englishText': enText,
              'urduText': urText,
              'juz': uAyah['juz'],
              'page': uAyah['page'],
              'audioUrl': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${uAyah['number']}.mp3',
            });
          }

          _surahCache[surahNumber] = parsedAyahs;
          await _hiveService.setValue<List>(HiveService.quranBox, 'surah_full_$surahNumber', parsedAyahs);
          return parsedAyahs;
        }
      }
    } catch (e) {
      debugPrint('Error fetching authentic Surah $surahNumber: $e');
    }

    return [];
  }
}
