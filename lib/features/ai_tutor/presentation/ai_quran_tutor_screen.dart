import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/recitation_analysis.dart';
import '../services/arabic_speech_recognition_service.dart';

class AiQuranTutorScreen extends StatefulWidget {
  const AiQuranTutorScreen({Key? key}) : super(key: key);

  @override
  State<AiQuranTutorScreen> createState() => _AiQuranTutorScreenState();
}

class _AiQuranTutorScreenState extends State<AiQuranTutorScreen> {
  final ArabicSpeechRecognitionService _service = ArabicSpeechRecognitionService();

  String _selectedSurah = 'Surah Al-Ikhlas';
  int _selectedVerse = 1;
  String _selectedArabicText = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
  String _selectedAccent = 'Classical Arabic (Hafs an Asim)';

  bool _isRecording = false;
  bool _isAnalyzing = false;
  RecitationAnalysis? _analysisResult;

  final Map<String, List<Map<String, dynamic>>> _surahData = {
    'Surah Al-Fatiha': [
      {'verse': 1, 'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
      {'verse': 2, 'text': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
      {'verse': 3, 'text': 'الرَّحْمَٰنِ الرَّحِيمِ'},
    ],
    'Surah Al-Ikhlas': [
      {'verse': 1, 'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
      {'verse': 2, 'text': 'اللَّهُ الصَّمَدُ'},
      {'verse': 3, 'text': 'لَمْ يَلِدْ وَلَمْ يُولَدْ'},
      {'verse': 4, 'text': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'},
    ],
    'Surah Al-Falaq': [
      {'verse': 1, 'text': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'},
      {'verse': 2, 'text': 'مِن شَرِّ مَا خَلَقَ'},
    ],
  };

  void _startRecitationRecording() {
    setState(() {
      _isRecording = true;
      _analysisResult = null;
    });

    // Simulate 3 seconds of voice recording
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      final result = await _service.analyzeRecitation(
        surahName: _selectedSurah,
        verseNumber: _selectedVerse,
        arabicText: _selectedArabicText,
        selectedAccent: _selectedAccent,
      );

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Quran Tutor'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Recite into your microphone. AI recognizes Arabic accents and detects Tajweed, Ghunnah, Qalqalah, and Madd mistakes.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Surah & Verse Selector
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: _selectedSurah,
                            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.gold : AppColors.lightPrimary,
                            ),
                            items: _surahData.keys.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSurah = val;
                                  _selectedVerse = 1;
                                  _selectedArabicText = _surahData[val]![0]['text'];
                                });
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Verse $_selectedVerse',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.gold : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Arabic Scripture Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedArabicText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontFamily: 'Amiri',
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Accent Dropdown
                      Row(
                        children: [
                          const Icon(Icons.translate, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          const Text('Accent Mode: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedAccent,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              items: _service.supportedAccents.map((acc) {
                                return DropdownMenuItem(value: acc, child: Text(acc, overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedAccent = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mic Button & Recording Visualizer
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: (_isRecording || _isAnalyzing) ? null : _startRecitationRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording 
                                ? AppColors.error 
                                : (_isAnalyzing ? AppColors.gold : (isDark ? AppColors.gold : AppColors.lightPrimary)),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? AppColors.error : AppColors.gold).withValues(alpha: 0.4),
                                blurRadius: _isRecording ? 20 : 10,
                                spreadRadius: _isRecording ? 4 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : (_isAnalyzing ? Icons.sync : Icons.mic),
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        _isRecording 
                            ? 'Listening to Recitation... Speak now' 
                            : (_isAnalyzing 
                                ? 'AI Analyzing Tajweed & Pronunciation...' 
                                : 'Tap Mic to Start Reciting'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isRecording ? AppColors.error : (isDark ? AppColors.gold : AppColors.lightPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Analysis Results Display
                if (_analysisResult != null) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recitation Score',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_analysisResult!.accuracyScore.toInt()}% ACCURACY',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          _analysisResult!.overallFeedback,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Detected Tajweed Corrections:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),

                        ..._analysisResult!.mistakes.map((m) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        m.typeName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange),
                                      ),
                                      Text(
                                        m.phrase,
                                        style: const TextStyle(fontSize: 16, fontFamily: 'Amiri', fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(m.explanation, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.gold),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Fix: ${m.correctionGuide}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
