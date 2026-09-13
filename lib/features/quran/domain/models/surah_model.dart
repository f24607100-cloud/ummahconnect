class Ayah {
  final int numberInSurah;
  final int globalAyahNumber;
  final String arabicText;
  final String englishTranslation;
  final String urduTranslation;
  final String transliteration;
  final int pageNumber;
  final int juzNumber;
  final String? audioUrl;

  Ayah({
    required this.numberInSurah,
    required this.globalAyahNumber,
    required this.arabicText,
    required this.englishTranslation,
    required this.urduTranslation,
    required this.transliteration,
    required this.pageNumber,
    required this.juzNumber,
    this.audioUrl,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      numberInSurah: map['numberInSurah'] ?? 1,
      globalAyahNumber: map['globalAyahNumber'] ?? 1,
      arabicText: map['arabicText'] ?? '',
      englishTranslation: map['englishTranslation'] ?? '',
      urduTranslation: map['urduTranslation'] ?? '',
      transliteration: map['transliteration'] ?? '',
      pageNumber: map['pageNumber'] ?? 1,
      juzNumber: map['juzNumber'] ?? 1,
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberInSurah': numberInSurah,
      'globalAyahNumber': globalAyahNumber,
      'arabicText': arabicText,
      'englishTranslation': englishTranslation,
      'urduTranslation': urduTranslation,
      'transliteration': transliteration,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'audioUrl': audioUrl,
    };
  }
}

class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String englishMeaning;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int versesCount;
  final int startPage;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.englishMeaning,
    required this.revelationType,
    required this.versesCount,
    required this.startPage,
    required this.ayahs,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['number'] ?? 1,
      nameArabic: map['nameArabic'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      englishMeaning: map['englishMeaning'] ?? '',
      revelationType: map['revelationType'] ?? 'Meccan',
      versesCount: map['versesCount'] ?? 7,
      startPage: map['startPage'] ?? 1,
      ayahs: (map['ayahs'] as List<dynamic>?)
              ?.map((e) => Ayah.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'englishMeaning': englishMeaning,
      'revelationType': revelationType,
      'versesCount': versesCount,
      'startPage': startPage,
      'ayahs': ayahs.map((a) => a.toMap()).toList(),
    };
  }
}
