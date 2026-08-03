import '../domain/models/spiritual_habit.dart';

class AiCoachInsight {
  final String title;
  final String message;
  final String hadithReference;

  AiCoachInsight({
    required this.title,
    required this.message,
    required this.hadithReference,
  });
}

class AiHabitCoachService {
  static final AiHabitCoachService _instance = AiHabitCoachService._internal();
  factory AiHabitCoachService() => _instance;
  AiHabitCoachService._internal();

  AiCoachInsight generateInsight(SpiritualHabitLog log) {
    if (log.prayedTahajjud) {
      return AiCoachInsight(
        title: 'Spiritual Exaltation: Tahajjud Accomplished!',
        message: 'MashaAllah! Standing in the night prayer is the mark of the righteous. Your dedication to seeking Allah\'s closeness during quiet hours brings light to your heart.',
        hadithReference: 'Prophet (ﷺ) said: "Hold fast to the night prayer, for it was the custom of the righteous before you." (Tirmidhi 3549)',
      );
    } else if (log.isFastingToday) {
      return AiCoachInsight(
        title: 'Barakah of Voluntary Fasting',
        message: 'Alhamdulillah for your voluntary fast today! Fasting cleanses the body and elevates your spiritual awareness. Keep your speech pure and remember Allah abundant in Dhikr.',
        hadithReference: 'Prophet (ﷺ) said: "Fasting is a shield against the Fire." (Sahih Muslim 1151)',
      );
    } else if (log.quranPagesRead >= 10) {
      return AiCoachInsight(
        title: 'Vibrant Quran Connection',
        message: 'SubhanAllah! You have read ${log.quranPagesRead} pages of Quran today. Every letter recited rewards you tenfold. May the Quran intercede for you on the Day of Judgment.',
        hadithReference: 'Prophet (ﷺ) said: "Recite the Quran, for it will come as an intercessor for its companions on the Day of Resurrection." (Sahih Muslim 804)',
      );
    } else {
      return AiCoachInsight(
        title: 'Consistent Daily Remembrance',
        message: 'Consistency in the 5 daily prayers and regular Dhikr is the most beloved deed to Allah. Keep building your daily momentum step by step.',
        hadithReference: 'Prophet (ﷺ) said: "The most beloved of deeds to Allah are those that are most consistent, even if they are small." (Sahih al-Bukhari 6465)',
      );
    }
  }
}
