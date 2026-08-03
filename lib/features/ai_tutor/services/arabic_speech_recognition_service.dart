import 'dart:async';
import 'dart:math';
import '../domain/models/recitation_analysis.dart';

class ArabicSpeechRecognitionService {
  static final ArabicSpeechRecognitionService _instance = ArabicSpeechRecognitionService._internal();
  factory ArabicSpeechRecognitionService() => _instance;
  ArabicSpeechRecognitionService._internal();

  final List<String> supportedAccents = [
    'Classical Arabic (Hafs an Asim)',
    'North African Accent (Warsh an Nafi)',
    'South Asian Accent',
    'Levantine / Middle Eastern Accent',
    'Western Non-Native Accent',
  ];

  Future<RecitationAnalysis> analyzeRecitation({
    required String surahName,
    required int verseNumber,
    required String arabicText,
    required String selectedAccent,
  }) async {
    // Simulate speech-to-text processing delay
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final score = 88.0 + random.nextInt(10); // 88% to 97%

    List<TajweedMistake> simulatedMistakes = [];

    if (verseNumber == 1) {
      simulatedMistakes.add(
        TajweedMistake(
          type: TajweedMistakeType.ghunnah,
          phrase: 'مِن رَّبِّهِمْ',
          explanation: 'Insufficient 2-count nasalization (Ghunnah) duration on Noon Saakin before Ra.',
          correctionGuide: 'Hold the nasal sound for 2 full counts in the nasal cavity before moving to the Ra.',
        ),
      );
    } else {
      simulatedMistakes.add(
        TajweedMistake(
          type: TajweedMistakeType.qalqalah,
          phrase: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          explanation: 'The letter Dal (د) at the end of Ahad requires a distinct Qalqalah bouncing sound when pausing.',
          correctionGuide: 'Release the breath with a light echoing bounce on the letter Dal (د).',
        ),
      );
      simulatedMistakes.add(
        TajweedMistake(
          type: TajweedMistakeType.madd,
          phrase: 'السَّمَاءِ',
          explanation: 'Madd Muttasil (Connected Elongation) was recited for 2 counts instead of 4-5 counts.',
          correctionGuide: 'Elongate the Alif sound for 4 to 5 counts before pronouncing the Hamzah.',
        ),
      );
    }

    return RecitationAnalysis(
      surahName: surahName,
      verseNumber: verseNumber,
      originalArabicText: arabicText,
      accuracyScore: score,
      accentDetected: selectedAccent,
      mistakes: simulatedMistakes,
      overallFeedback: 'MashaAllah, excellent effort! Your rhythm and fluency are strong. Focus on holding the Ghunnah nasal duration for 2 counts to perfect your Tajweed.',
    );
  }
}
