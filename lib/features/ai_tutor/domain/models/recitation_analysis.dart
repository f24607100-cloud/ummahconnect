enum TajweedMistakeType {
  ghunnah,
  qalqalah,
  madd,
  makhraj,
}

class TajweedMistake {
  final TajweedMistakeType type;
  final String phrase;
  final String explanation;
  final String correctionGuide;

  TajweedMistake({
    required this.type,
    required this.phrase,
    required this.explanation,
    required this.correctionGuide,
  });

  String get typeName {
    switch (type) {
      case TajweedMistakeType.ghunnah:
        return 'Ghunnah (Nasalization)';
      case TajweedMistakeType.qalqalah:
        return 'Qalqalah (Echo Sound)';
      case TajweedMistakeType.madd:
        return 'Madd (Elongation)';
      case TajweedMistakeType.makhraj:
        return 'Makhraj (Articulation Point)';
    }
  }
}

class RecitationAnalysis {
  final String surahName;
  final int verseNumber;
  final String originalArabicText;
  final double accuracyScore; // 0 to 100%
  final String accentDetected;
  final List<TajweedMistake> mistakes;
  final String overallFeedback;

  RecitationAnalysis({
    required this.surahName,
    required this.verseNumber,
    required this.originalArabicText,
    required this.accuracyScore,
    required this.accentDetected,
    required this.mistakes,
    required this.overallFeedback,
  });
}
