class SpiritualHabitLog {
  final int completedPrayersCount; // 0 to 5
  final bool prayedTahajjud;
  final int quranPagesRead;
  final int dhikrCount;
  final bool isFastingToday;
  final int streakDays;

  SpiritualHabitLog({
    this.completedPrayersCount = 5,
    this.prayedTahajjud = false,
    this.quranPagesRead = 4,
    this.dhikrCount = 100,
    this.isFastingToday = false,
    this.streakDays = 7,
  });

  Map<String, dynamic> toMap() => {
        'completedPrayersCount': completedPrayersCount,
        'prayedTahajjud': prayedTahajjud,
        'quranPagesRead': quranPagesRead,
        'dhikrCount': dhikrCount,
        'isFastingToday': isFastingToday,
        'streakDays': streakDays,
      };

  factory SpiritualHabitLog.fromMap(Map<dynamic, dynamic> map) => SpiritualHabitLog(
        completedPrayersCount: map['completedPrayersCount'] ?? 5,
        prayedTahajjud: map['prayedTahajjud'] ?? false,
        quranPagesRead: map['quranPagesRead'] ?? 4,
        dhikrCount: map['dhikrCount'] ?? 100,
        isFastingToday: map['isFastingToday'] ?? false,
        streakDays: map['streakDays'] ?? 7,
      );

  SpiritualHabitLog copyWith({
    int? completedPrayersCount,
    bool? prayedTahajjud,
    int? quranPagesRead,
    int? dhikrCount,
    bool? isFastingToday,
    int? streakDays,
  }) {
    return SpiritualHabitLog(
      completedPrayersCount: completedPrayersCount ?? this.completedPrayersCount,
      prayedTahajjud: prayedTahajjud ?? this.prayedTahajjud,
      quranPagesRead: quranPagesRead ?? this.quranPagesRead,
      dhikrCount: dhikrCount ?? this.dhikrCount,
      isFastingToday: isFastingToday ?? this.isFastingToday,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
