import 'dart:async';
import '../domain/models/learning_roadmap.dart';

class AiLearningRoadmapGenerator {
  static final AiLearningRoadmapGenerator _instance = AiLearningRoadmapGenerator._internal();
  factory AiLearningRoadmapGenerator() => _instance;
  AiLearningRoadmapGenerator._internal();

  Future<LearningRoadmap> generateRoadmap(String userPrompt) async {
    await Future.delayed(const Duration(seconds: 2));

    final id = 'roadmap_${DateTime.now().millisecondsSinceEpoch}';

    List<WeeklyModule> modules = [
      WeeklyModule(
        weekNumber: 1,
        title: 'Week 1: Foundations of Faith & Purification',
        summary: 'Understand the 6 Pillars of Iman, Tawheed, and how to perform Wudu & Taharah cleanly.',
        tasks: [
          LessonTask(
            id: 't_1_1',
            title: 'Study Shahada & the 6 Pillars of Iman',
            description: 'Learn the core Islamic beliefs in Allah, Angels, Books, Prophets, Day of Judgment, and Divine Decree.',
          ),
          LessonTask(
            id: 't_1_2',
            title: 'Master Wudu (Ablution) Step-by-Step',
            description: 'Practice the Sunnah steps of Wudu before prayer.',
          ),
          LessonTask(
            id: 't_1_3',
            title: 'Memorize Surah Al-Fatiha',
            description: 'Learn the translation and correct Tajweed pronunciation of The Opening chapter.',
          ),
        ],
      ),
      WeeklyModule(
        weekNumber: 2,
        title: 'Week 2: Prayer Mastery & Daily Adhkar',
        summary: 'Learn the movements of Salah, times of the 5 daily prayers, and essential morning/evening supplications.',
        tasks: [
          LessonTask(
            id: 't_2_1',
            title: 'Understand the 5 Daily Prayer Times & Rakat',
            description: 'Fajr (2), Dhuhr (4), Asr (4), Maghrib (3), Isha (4).',
          ),
          LessonTask(
            id: 't_2_2',
            title: 'Recite Tashahhud & Salawat in Salah',
            description: 'Memorize the words recited during the sitting position of prayer.',
          ),
          LessonTask(
            id: 't_2_3',
            title: 'Establish Morning & Evening Adhkar',
            description: 'Recite Ayat al-Kursi, Surah Al-Ikhlas, Al-Falaq, and An-Nas after Fajr and Maghrib.',
          ),
        ],
      ),
      WeeklyModule(
        weekNumber: 3,
        title: 'Week 3: Quranic Connection & Noble Character',
        summary: 'Develop a daily Quran reading habit and implement Islamic ethics (Akhlaq) in speech and daily life.',
        tasks: [
          LessonTask(
            id: 't_3_1',
            title: 'Read 2 Pages of Quran Daily with Translation',
            description: 'Focus on reflective contemplation (Tadabbur) of the meanings.',
          ),
          LessonTask(
            id: 't_3_2',
            title: 'Practice Truthfulness & Kindness to Parents',
            description: 'Reflect on Hadith regarding honoring parents and avoiding backbiting.',
          ),
          LessonTask(
            id: 't_3_3',
            title: 'Learn the Etiquettes of Supplication (Dua)',
            description: 'Praise Allah, send blessings on the Prophet (ﷺ), and make sincere personal prayers.',
          ),
        ],
      ),
    ];

    return LearningRoadmap(
      id: id,
      goalPrompt: userPrompt.trim(),
      createdAt: DateTime.now(),
      modules: modules,
    );
  }
}
