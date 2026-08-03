import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String settingsBox = 'settings_box';
  static const String prayerBox = 'prayer_box';
  static const String quranBox = 'quran_box';
  static const String bookmarksBox = 'bookmarks_box';

  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(dir.path);
      } else {
        await Hive.initFlutter();
      }

      // Open boxes
      await Hive.openBox(settingsBox);
      await Hive.openBox(prayerBox);
      await Hive.openBox(quranBox);
      await Hive.openBox(bookmarksBox);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive Initialization Error: $e');
    }
  }

  // Generic methods to read/write
  T? getValue<T>(String boxName, String key, {T? defaultValue}) {
    try {
      final box = Hive.box(boxName);
      return box.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      debugPrint('Hive getValue Error in $boxName ($key): $e');
      return defaultValue;
    }
  }

  Future<void> setValue<T>(String boxName, String key, T value) async {
    try {
      final box = Hive.box(boxName);
      await box.put(key, value);
    } catch (e) {
      debugPrint('Hive setValue Error in $boxName ($key): $e');
    }
  }

  Future<void> deleteValue(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      await box.delete(key);
    } catch (e) {
      debugPrint('Hive deleteValue Error in $boxName ($key): $e');
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.clear();
    } catch (e) {
      debugPrint('Hive clearBox Error in $boxName: $e');
    }
  }
}
