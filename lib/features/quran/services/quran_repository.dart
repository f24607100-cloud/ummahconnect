import '../domain/models/surah_model.dart';

class QuranRepository {
  static final QuranRepository _instance = QuranRepository._internal();
  factory QuranRepository() => _instance;
  QuranRepository._internal();

  final List<Map<String, dynamic>> _surahsMetadata = [
    {'number': 1, 'nameArabic': 'الفاتحة', 'nameEnglish': 'Al-Fatihah', 'meaning': 'The Opening', 'type': 'Meccan', 'verses': 7, 'page': 1},
    {'number': 2, 'nameArabic': 'البقرة', 'nameEnglish': 'Al-Baqarah', 'meaning': 'The Cow', 'type': 'Medinan', 'verses': 286, 'page': 2},
    {'number': 3, 'nameArabic': 'آل عمران', 'nameEnglish': 'Ali \'Imran', 'meaning': 'Family of Imran', 'type': 'Medinan', 'verses': 200, 'page': 50},
    {'number': 4, 'nameArabic': 'النساء', 'nameEnglish': 'An-Nisa\'', 'meaning': 'The Women', 'type': 'Medinan', 'verses': 176, 'page': 77},
    {'number': 5, 'nameArabic': 'المائدة', 'nameEnglish': 'Al-Ma\'idah', 'meaning': 'The Table Spread', 'type': 'Medinan', 'verses': 120, 'page': 106},
    {'number': 6, 'nameArabic': 'الأنعام', 'nameEnglish': 'Al-An\'am', 'meaning': 'The Cattle', 'type': 'Meccan', 'verses': 165, 'page': 128},
    {'number': 7, 'nameArabic': 'الأعراف', 'nameEnglish': 'Al-A\'raf', 'meaning': 'The Heights', 'type': 'Meccan', 'verses': 206, 'page': 151},
    {'number': 8, 'nameArabic': 'الأنفال', 'nameEnglish': 'Al-Anfal', 'meaning': 'The Spoils of War', 'type': 'Medinan', 'verses': 75, 'page': 177},
    {'number': 9, 'nameArabic': 'التوبة', 'nameEnglish': 'At-Tawbah', 'meaning': 'The Repentance', 'type': 'Medinan', 'verses': 129, 'page': 187},
    {'number': 10, 'nameArabic': 'يونس', 'nameEnglish': 'Yunus', 'meaning': 'Jonah', 'type': 'Meccan', 'verses': 109, 'page': 208},
    {'number': 11, 'nameArabic': 'هود', 'nameEnglish': 'Hud', 'meaning': 'Hud', 'type': 'Meccan', 'verses': 123, 'page': 221},
    {'number': 12, 'nameArabic': 'يوسف', 'nameEnglish': 'Yusuf', 'meaning': 'Joseph', 'type': 'Meccan', 'verses': 111, 'page': 235},
    {'number': 13, 'nameArabic': 'الرعد', 'nameEnglish': 'Ar-Ra\'d', 'meaning': 'The Thunder', 'type': 'Medinan', 'verses': 43, 'page': 249},
    {'number': 14, 'nameArabic': 'إبراهيم', 'nameEnglish': 'Ibrahim', 'meaning': 'Abraham', 'type': 'Meccan', 'verses': 52, 'page': 255},
    {'number': 15, 'nameArabic': 'الحجر', 'nameEnglish': 'Al-Hijr', 'meaning': 'The Rocky Tract', 'type': 'Meccan', 'verses': 99, 'page': 262},
    {'number': 16, 'nameArabic': 'النحل', 'nameEnglish': 'An-Nahl', 'meaning': 'The Bee', 'type': 'Meccan', 'verses': 128, 'page': 267},
    {'number': 17, 'nameArabic': 'الإسراء', 'nameEnglish': 'Al-Isra\'', 'meaning': 'The Night Journey', 'type': 'Meccan', 'verses': 111, 'page': 282},
    {'number': 18, 'nameArabic': 'الكهف', 'nameEnglish': 'Al-Kahf', 'meaning': 'The Cave', 'type': 'Meccan', 'verses': 110, 'page': 293},
    {'number': 19, 'nameArabic': 'مريم', 'nameEnglish': 'Maryam', 'meaning': 'Mary', 'type': 'Meccan', 'verses': 98, 'page': 305},
    {'number': 20, 'nameArabic': 'طه', 'nameEnglish': 'Ta-Ha', 'meaning': 'Ta-Ha', 'type': 'Meccan', 'verses': 135, 'page': 312},
    {'number': 21, 'nameArabic': 'الأنبياء', 'nameEnglish': 'Al-Anbiya\'', 'meaning': 'The Prophets', 'type': 'Meccan', 'verses': 112, 'page': 322},
    {'number': 22, 'nameArabic': 'الحج', 'nameEnglish': 'Al-Hajj', 'meaning': 'The Pilgrimage', 'type': 'Medinan', 'verses': 78, 'page': 332},
    {'number': 23, 'nameArabic': 'المؤمنون', 'nameEnglish': 'Al-Mu\'minun', 'meaning': 'The Believers', 'type': 'Meccan', 'verses': 118, 'page': 342},
    {'number': 24, 'nameArabic': 'النور', 'nameEnglish': 'An-Nur', 'meaning': 'The Light', 'type': 'Medinan', 'verses': 64, 'page': 350},
    {'number': 25, 'nameArabic': 'الفرقان', 'nameEnglish': 'Al-Furqan', 'meaning': 'The Criterion', 'type': 'Meccan', 'verses': 77, 'page': 359},
    {'number': 26, 'nameArabic': 'الشعراء', 'nameEnglish': 'Ash-Shu\'ara\'', 'meaning': 'The Poets', 'type': 'Meccan', 'verses': 227, 'page': 367},
    {'number': 27, 'nameArabic': 'النمل', 'nameEnglish': 'An-Naml', 'meaning': 'The Ant', 'type': 'Meccan', 'verses': 93, 'page': 377},
    {'number': 28, 'nameArabic': 'القصص', 'nameEnglish': 'Al-Qasas', 'meaning': 'The Stories', 'type': 'Meccan', 'verses': 88, 'page': 385},
    {'number': 29, 'nameArabic': 'العنكبوت', 'nameEnglish': 'Al-\'Ankabut', 'meaning': 'The Spider', 'type': 'Meccan', 'verses': 69, 'page': 396},
    {'number': 30, 'nameArabic': 'الروم', 'nameEnglish': 'Ar-Rum', 'meaning': 'The Romans', 'type': 'Meccan', 'verses': 60, 'page': 404},
    {'number': 31, 'nameArabic': 'لقمان', 'nameEnglish': 'Luqman', 'meaning': 'Luqman', 'type': 'Meccan', 'verses': 34, 'page': 411},
    {'number': 32, 'nameArabic': 'السجدة', 'nameEnglish': 'As-Sajdah', 'meaning': 'The Prostration', 'type': 'Meccan', 'verses': 30, 'page': 415},
    {'number': 33, 'nameArabic': 'الأحزاب', 'nameEnglish': 'Al-Ahzab', 'meaning': 'The Combined Forces', 'type': 'Medinan', 'verses': 73, 'page': 418},
    {'number': 34, 'nameArabic': 'سبأ', 'nameEnglish': 'Saba\'', 'meaning': 'Sheba', 'type': 'Meccan', 'verses': 54, 'page': 428},
    {'number': 35, 'nameArabic': 'فاطر', 'nameEnglish': 'Fatir', 'meaning': 'Originator', 'type': 'Meccan', 'verses': 45, 'page': 434},
    {'number': 36, 'nameArabic': 'يس', 'nameEnglish': 'Yaseen', 'meaning': 'Ya-Sin', 'type': 'Meccan', 'verses': 83, 'page': 440},
    {'number': 37, 'nameArabic': 'الصافات', 'nameEnglish': 'As-Saffat', 'meaning': 'Those who set the Ranks', 'type': 'Meccan', 'verses': 182, 'page': 446},
    {'number': 38, 'nameArabic': 'ص', 'nameEnglish': 'Sad', 'meaning': 'Sad', 'type': 'Meccan', 'verses': 88, 'page': 453},
    {'number': 39, 'nameArabic': 'الزمر', 'nameEnglish': 'Az-Zumar', 'meaning': 'The Troops', 'type': 'Meccan', 'verses': 75, 'page': 458},
    {'number': 40, 'nameArabic': 'غافر', 'nameEnglish': 'Ghafir', 'meaning': 'The Forgiver', 'type': 'Meccan', 'verses': 85, 'page': 467},
    {'number': 41, 'nameArabic': 'فصلت', 'nameEnglish': 'Fussilat', 'meaning': 'Explained in Detail', 'type': 'Meccan', 'verses': 54, 'page': 477},
    {'number': 42, 'nameArabic': 'الشورى', 'nameEnglish': 'Ash-Shura', 'meaning': 'The Consultation', 'type': 'Meccan', 'verses': 53, 'page': 483},
    {'number': 43, 'nameArabic': 'الزخرف', 'nameEnglish': 'Az-Zukhruf', 'meaning': 'The Ornaments of Gold', 'type': 'Meccan', 'verses': 89, 'page': 489},
    {'number': 44, 'nameArabic': 'الدخان', 'nameEnglish': 'Ad-Dukhan', 'meaning': 'The Smoke', 'type': 'Meccan', 'verses': 59, 'page': 496},
    {'number': 45, 'nameArabic': 'الجاثية', 'nameEnglish': 'Al-Jathiyah', 'meaning': 'The Crouching', 'type': 'Meccan', 'verses': 37, 'page': 499},
    {'number': 46, 'nameArabic': 'الأحقاف', 'nameEnglish': 'Al-Ahqaf', 'meaning': 'The Wind-Curved Sandhills', 'type': 'Meccan', 'verses': 35, 'page': 502},
    {'number': 47, 'nameArabic': 'محمد', 'nameEnglish': 'Muhammad', 'meaning': 'Muhammad', 'type': 'Medinan', 'verses': 38, 'page': 507},
    {'number': 48, 'nameArabic': 'الفتح', 'nameEnglish': 'Al-Fath', 'meaning': 'The Victory', 'type': 'Medinan', 'verses': 29, 'page': 511},
    {'number': 49, 'nameArabic': 'الحجرات', 'nameEnglish': 'Al-Hujurat', 'meaning': 'The Dwellings', 'type': 'Medinan', 'verses': 18, 'page': 515},
    {'number': 50, 'nameArabic': 'ق', 'nameEnglish': 'Qaf', 'meaning': 'Qaf', 'type': 'Meccan', 'verses': 45, 'page': 518},
    {'number': 51, 'nameArabic': 'الذاريات', 'nameEnglish': 'Adh-Dhariyat', 'meaning': 'The Winnowing Winds', 'type': 'Meccan', 'verses': 60, 'page': 520},
    {'number': 52, 'nameArabic': 'الطور', 'nameEnglish': 'At-Tur', 'meaning': 'The Mount', 'type': 'Meccan', 'verses': 49, 'page': 523},
    {'number': 53, 'nameArabic': 'النجم', 'nameEnglish': 'An-Najm', 'meaning': 'The Star', 'type': 'Meccan', 'verses': 62, 'page': 526},
    {'number': 54, 'nameArabic': 'القمر', 'nameEnglish': 'Al-Qamar', 'meaning': 'The Moon', 'type': 'Meccan', 'verses': 55, 'page': 528},
    {'number': 55, 'nameArabic': 'الرحمن', 'nameEnglish': 'Ar-Rahman', 'meaning': 'The Beneficent', 'type': 'Medinan', 'verses': 78, 'page': 531},
    {'number': 56, 'nameArabic': 'الواقعة', 'nameEnglish': 'Al-Waqi\'ah', 'meaning': 'The Inevitable', 'type': 'Meccan', 'verses': 96, 'page': 534},
    {'number': 57, 'nameArabic': 'الحديد', 'nameEnglish': 'Al-Hadid', 'meaning': 'The Iron', 'type': 'Medinan', 'verses': 29, 'page': 537},
    {'number': 58, 'nameArabic': 'المجادلة', 'nameEnglish': 'Al-Mujadila', 'meaning': 'The Pleading Woman', 'type': 'Medinan', 'verses': 22, 'page': 542},
    {'number': 59, 'nameArabic': 'الحشر', 'nameEnglish': 'Al-Hashr', 'meaning': 'The Exile', 'type': 'Medinan', 'verses': 24, 'page': 545},
    {'number': 60, 'nameArabic': 'الممتحنة', 'nameEnglish': 'Al-Mumtahanah', 'meaning': 'She that is to be examined', 'type': 'Medinan', 'verses': 13, 'page': 549},
    {'number': 61, 'nameArabic': 'الصف', 'nameEnglish': 'As-Saff', 'meaning': 'The Ranks', 'type': 'Medinan', 'verses': 14, 'page': 551},
    {'number': 62, 'nameArabic': 'الجمعة', 'nameEnglish': 'Al-Jumu\'ah', 'meaning': 'The Congregation', 'type': 'Medinan', 'verses': 11, 'page': 553},
    {'number': 63, 'nameArabic': 'المنافقون', 'nameEnglish': 'Al-Munafiqun', 'meaning': 'The Hypocrites', 'type': 'Medinan', 'verses': 11, 'page': 554},
    {'number': 64, 'nameArabic': 'التغابن', 'nameEnglish': 'At-Taghabun', 'meaning': 'The Mutual Disillusion', 'type': 'Medinan', 'verses': 18, 'page': 556},
    {'number': 65, 'nameArabic': 'الطلاق', 'nameEnglish': 'At-Talaq', 'meaning': 'The Divorce', 'type': 'Medinan', 'verses': 12, 'page': 558},
    {'number': 66, 'nameArabic': 'التحريم', 'nameEnglish': 'At-Tahrim', 'meaning': 'The Prohibition', 'type': 'Medinan', 'verses': 12, 'page': 560},
    {'number': 67, 'nameArabic': 'الملك', 'nameEnglish': 'Al-Mulk', 'meaning': 'The Sovereignty', 'type': 'Meccan', 'verses': 30, 'page': 562},
    {'number': 68, 'nameArabic': 'القلم', 'nameEnglish': 'Al-Qalam', 'meaning': 'The Pen', 'type': 'Meccan', 'verses': 52, 'page': 564},
    {'number': 69, 'nameArabic': 'الحاقة', 'nameEnglish': 'Al-Haqqah', 'meaning': 'The Reality', 'type': 'Meccan', 'verses': 52, 'page': 566},
    {'number': 70, 'nameArabic': 'المعارج', 'nameEnglish': 'Al-Ma\'arij', 'meaning': 'The Ascending Stairways', 'type': 'Meccan', 'verses': 44, 'page': 568},
    {'number': 71, 'nameArabic': 'نوح', 'nameEnglish': 'Nuh', 'meaning': 'Noah', 'type': 'Meccan', 'verses': 28, 'page': 570},
    {'number': 72, 'nameArabic': 'الجن', 'nameEnglish': 'Al-Jinn', 'meaning': 'The Jinn', 'type': 'Meccan', 'verses': 28, 'page': 572},
    {'number': 73, 'nameArabic': 'المزمل', 'nameEnglish': 'Al-Muzzammil', 'meaning': 'The Enshrouded One', 'type': 'Meccan', 'verses': 20, 'page': 574},
    {'number': 74, 'nameArabic': 'المدثر', 'nameEnglish': 'Al-Muddaththir', 'meaning': 'The Cloaked One', 'type': 'Meccan', 'verses': 56, 'page': 575},
    {'number': 75, 'nameArabic': 'القيامة', 'nameEnglish': 'Al-Qiyamah', 'meaning': 'The Resurrection', 'type': 'Meccan', 'verses': 40, 'page': 577},
    {'number': 76, 'nameArabic': 'الإنسان', 'nameEnglish': 'Al-Insan', 'meaning': 'The Man', 'type': 'Medinan', 'verses': 31, 'page': 578},
    {'number': 77, 'nameArabic': 'المرسلات', 'nameEnglish': 'Al-Mursalat', 'meaning': 'Those Sent Forth', 'type': 'Meccan', 'verses': 50, 'page': 580},
    {'number': 78, 'nameArabic': 'النبأ', 'nameEnglish': 'An-Naba\'', 'meaning': 'The Announcement', 'type': 'Meccan', 'verses': 40, 'page': 582},
    {'number': 79, 'nameArabic': 'النازعات', 'nameEnglish': 'An-Nazi\'at', 'meaning': 'Those Who Drag Forth', 'type': 'Meccan', 'verses': 46, 'page': 583},
    {'number': 80, 'nameArabic': 'عبس', 'nameEnglish': '\'Abasa', 'meaning': 'He Frowned', 'type': 'Meccan', 'verses': 42, 'page': 585},
    {'number': 81, 'nameArabic': 'التكوير', 'nameEnglish': 'At-Takwir', 'meaning': 'The Overthrowing', 'type': 'Meccan', 'verses': 29, 'page': 586},
    {'number': 82, 'nameArabic': 'الانفطار', 'nameEnglish': 'Al-Infitar', 'meaning': 'The Cleaving', 'type': 'Meccan', 'verses': 19, 'page': 587},
    {'number': 83, 'nameArabic': 'المطففين', 'nameEnglish': 'Al-Mutaffifin', 'meaning': 'Defrauding', 'type': 'Meccan', 'verses': 36, 'page': 587},
    {'number': 84, 'nameArabic': 'الانشقاق', 'nameEnglish': 'Al-Inshiqaq', 'meaning': 'The Splitting Open', 'type': 'Meccan', 'verses': 25, 'page': 589},
    {'number': 85, 'nameArabic': 'البروج', 'nameEnglish': 'Al-Buruj', 'meaning': 'The Mansions of the Stars', 'type': 'Meccan', 'verses': 22, 'page': 590},
    {'number': 86, 'nameArabic': 'الطارق', 'nameEnglish': 'At-Tariq', 'meaning': 'The Morning Star', 'type': 'Meccan', 'verses': 17, 'page': 591},
    {'number': 87, 'nameArabic': 'الأعلى', 'nameEnglish': 'Al-A\'la', 'meaning': 'The Most High', 'type': 'Meccan', 'verses': 19, 'page': 591},
    {'number': 88, 'nameArabic': 'الغاشية', 'nameEnglish': 'Al-Ghashiyah', 'meaning': 'The Overwhelming Event', 'type': 'Meccan', 'verses': 26, 'page': 592},
    {'number': 89, 'nameArabic': 'الفجر', 'nameEnglish': 'Al-Fajr', 'meaning': 'The Dawn', 'type': 'Meccan', 'verses': 30, 'page': 593},
    {'number': 90, 'nameArabic': 'البلد', 'nameEnglish': 'Al-Balad', 'meaning': 'The City', 'type': 'Meccan', 'verses': 20, 'page': 594},
    {'number': 91, 'nameArabic': 'الشمس', 'nameEnglish': 'Ash-Shams', 'meaning': 'The Sun', 'type': 'Meccan', 'verses': 15, 'page': 595},
    {'number': 92, 'nameArabic': 'الليل', 'nameEnglish': 'Al-Layl', 'meaning': 'The Night', 'type': 'Meccan', 'verses': 21, 'page': 595},
    {'number': 93, 'nameArabic': 'الضحى', 'nameEnglish': 'Ad-Duha', 'meaning': 'The Morning Hours', 'type': 'Meccan', 'verses': 11, 'page': 596},
    {'number': 94, 'nameArabic': 'الشرح', 'nameEnglish': 'Ash-Sharh', 'meaning': 'The Relief', 'type': 'Meccan', 'verses': 8, 'page': 596},
    {'number': 95, 'nameArabic': 'التين', 'nameEnglish': 'At-Tin', 'meaning': 'The Fig', 'type': 'Meccan', 'verses': 8, 'page': 597},
    {'number': 96, 'nameArabic': 'العلق', 'nameEnglish': 'Al-\'Alaq', 'meaning': 'The Clot', 'type': 'Meccan', 'verses': 19, 'page': 597},
    {'number': 97, 'nameArabic': 'القدر', 'nameEnglish': 'Al-Qadr', 'meaning': 'The Power', 'type': 'Meccan', 'verses': 5, 'page': 598},
    {'number': 98, 'nameArabic': 'البينة', 'nameEnglish': 'Al-Bayyinah', 'meaning': 'The Clear Proof', 'type': 'Medinan', 'verses': 8, 'page': 598},
    {'number': 99, 'nameArabic': 'الزلزلة', 'nameEnglish': 'Az-Zalzalah', 'meaning': 'The Earthquake', 'type': 'Medinan', 'verses': 8, 'page': 599},
    {'number': 100, 'nameArabic': 'العاديات', 'nameEnglish': 'Al-\'Adiyat', 'meaning': 'The Courser', 'type': 'Meccan', 'verses': 11, 'page': 599},
    {'number': 101, 'nameArabic': 'القارعة', 'nameEnglish': 'Al-Qari\'ah', 'meaning': 'The Calamity', 'type': 'Meccan', 'verses': 11, 'page': 600},
    {'number': 102, 'nameArabic': 'التكاثر', 'nameEnglish': 'At-Takathur', 'meaning': 'The Rivalry in World Increase', 'type': 'Meccan', 'verses': 8, 'page': 600},
    {'number': 103, 'nameArabic': 'العصر', 'nameEnglish': 'Al-\'Asr', 'meaning': 'The Declining Day', 'type': 'Meccan', 'verses': 3, 'page': 601},
    {'number': 104, 'nameArabic': 'الهمزة', 'nameEnglish': 'Al-Humazah', 'meaning': 'The Traducer', 'type': 'Meccan', 'verses': 9, 'page': 601},
    {'number': 105, 'nameArabic': 'الفيل', 'nameEnglish': 'Al-Fil', 'meaning': 'The Elephant', 'type': 'Meccan', 'verses': 5, 'page': 601},
    {'number': 106, 'nameArabic': 'قريش', 'nameEnglish': 'Quraysh', 'meaning': 'Quraysh', 'type': 'Meccan', 'verses': 4, 'page': 602},
    {'number': 107, 'nameArabic': 'الماعون', 'nameEnglish': 'Al-Ma\'un', 'meaning': 'The Small Kindnesses', 'type': 'Meccan', 'verses': 7, 'page': 602},
    {'number': 108, 'nameArabic': 'الكوثر', 'nameEnglish': 'Al-Kawthar', 'meaning': 'The Abundance', 'type': 'Meccan', 'verses': 3, 'page': 602},
    {'number': 109, 'nameArabic': 'الكافرون', 'nameEnglish': 'Al-Kafirun', 'meaning': 'The Disbelievers', 'type': 'Meccan', 'verses': 6, 'page': 603},
    {'number': 110, 'nameArabic': 'النصر', 'nameEnglish': 'An-Nasr', 'meaning': 'The Divine Support', 'type': 'Medinan', 'verses': 3, 'page': 603},
    {'number': 111, 'nameArabic': 'المسد', 'nameEnglish': 'Al-Masad', 'meaning': 'The Palm Fiber', 'type': 'Meccan', 'verses': 5, 'page': 603},
    {'number': 112, 'nameArabic': 'الإخلاص', 'nameEnglish': 'Al-Ikhlas', 'meaning': 'The Sincerity', 'type': 'Meccan', 'verses': 4, 'page': 604},
    {'number': 113, 'nameArabic': 'الفلق', 'nameEnglish': 'Al-Falaq', 'meaning': 'The Daybreak', 'type': 'Meccan', 'verses': 5, 'page': 604},
    {'number': 114, 'nameArabic': 'الناس', 'nameEnglish': 'An-Nas', 'meaning': 'Mankind', 'type': 'Meccan', 'verses': 6, 'page': 604},
  ];

  // Specific verse content for popular Surahs
  final Map<int, List<Map<String, String>>> _surahVersesData = {
    // 1: Al-Fatihah
    1: [
      {
        'ar': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        'ur': 'اللہ کے نام سے شروع جو نہایت مہربان، رحم والا ہے۔',
        'tr': 'Bismillahir-Rahmanir-Rahim',
      },
      {
        'ar': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        'en': '[All] praise is [due] to Allah, Lord of the worlds -',
        'ur': 'سب تعریفیں اللہ ہی کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے۔',
        'tr': 'Alhamdu lillahi Rabbil-\'alamin',
      },
      {
        'ar': 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'en': 'The Entirely Merciful, the Especially Merciful,',
        'ur': 'نہایت مہربان، بہت رحم فرمانے والا۔',
        'tr': 'Ar-Rahmanir-Rahim',
      },
      {
        'ar': 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
        'en': 'Sovereign of the Day of Recompense.',
        'ur': 'جزا اور سزا کے دن کا مالک۔',
        'tr': 'Maliki Yawmid-Din',
      },
      {
        'ar': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'en': 'It is You we worship and You we ask for help.',
        'ur': 'ہم صرف تیری ہی عبادت کرتے ہیں اور صرف تجھ ہی سے مدد چاہتے ہیں۔',
        'tr': 'Iyyaka na\'budu wa iyyaka nasta\'in',
      },
      {
        'ar': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        'en': 'Guide us to the straight path -',
        'ur': 'ہمیں سیدھے راستے پر چلا۔',
        'tr': 'Ihdinas-Siratal-Mustaqim',
      },
      {
        'ar': 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
        'en': 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
        'ur': 'ان لوگوں کے راستے پر جن پر تو نے انعام فرمایا، ان کے راستے پر نہیں جن پر غضب ڈھایا گیا اور نہ گمراہوں کے۔',
        'tr': 'Siratalladhina an\'amta \'alayhim ghayril-maghdubi \'alayhim wa lad-dallin',
      },
    ],
    // 36: Yaseen
    36: [
      {'ar': 'يس ۝١', 'en': 'Ya, Seen.', 'ur': 'یسٰین۔', 'tr': 'Ya-Sin'},
      {'ar': 'وَٱلْقُرْءَانِ ٱلْحَكِيمِ ۝٢', 'en': 'By the wise Qur\'an.', 'ur': 'حکمت والے قرآن کی قسم۔', 'tr': 'Wal-Qur\'anil-Hakim'},
      {'ar': 'إِنَّكَ لَمِنَ ٱلْمُرْسَلِينَ ۝٣', 'en': 'Indeed you, [O Muhammad], are from among the messengers,', 'ur': 'بے شک آپ رسولوں میں سے ہیں۔', 'tr': 'Innaka laminal-mursalin'},
      {'ar': 'عَلَىٰ صِرَٰطٍ مُّسْتَقِيمٍ ۝٤', 'en': 'On a straight path.', 'ur': 'سیدھے راستے پر۔', 'tr': '\'Ala Siratim Mustaqim'},
      {'ar': 'تَنزِيلَ ٱلْعَزِيزِ ٱلرَّحِيمِ ۝٥', 'en': '[This is] a revelation of the Exalted in Might, the Merciful,', 'ur': 'یہ زبردست، رحم کرنے والے کی طرف سے نازل کردہ ہے۔', 'tr': 'Tanzilal-\'Azizir-Rahim'},
    ],
    // 67: Al-Mulk
    67: [
      {'ar': 'تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَىْءٍ قَدِيرٌ ۝١', 'en': 'Blessed is He in whose hand is dominion, and He is over all things competent -', 'ur': 'بڑی برکت والا ہے وہ جس کے ہاتھ میں بادشاہی ہے اور وہ ہر چیز پر قادر ہے۔', 'tr': 'Tabarakalladhi biyadihil-mulku wa Huwa \'ala kulli shay\'in Qadir'},
      {'ar': 'ٱلَّذِى خَلَقَ ٱلْمَوْتَ وَٱلْحَيَوٰةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ ۝٢', 'en': 'He who created death and life to test you as to which of you is best in deed - and He is the Exalted in Might, the Forgiving -', 'ur': 'جس نے موت اور زندگی کو پیدا کیا تاکہ تمہیں آزمائے کہ تم میں سے عمل کے لحاظ سے کون سب سے اچھا ہے۔', 'tr': 'Alladhi khalaqal-mawta wal-hayata liyabluwakum ayyukum ahsanu \'amala'},
    ],
    // 112: Al-Ikhlas
    112: [
      {'ar': 'قُلْ هُوَ ٱللَّهُ أَحَدٌ ۝١', 'en': 'Say, "He is Allah, [who is] One,', 'ur': 'آپ کہہ دیجیے: وہ اللہ ایک ہے۔', 'tr': 'Qul Huwallahu Ahad'},
      {'ar': 'ٱللَّهُ ٱلصَّمَدُ ۝٢', 'en': 'Allah, the Eternal Refuge.', 'ur': 'اللہ بے نیاز ہے۔', 'tr': 'Allahus-Samad'},
      {'ar': 'لَمْ يَلِدْ وَلَمْ يُولَدْ ۝٣', 'en': 'He neither begets nor is born,', 'ur': 'نہ اس کی کوئی اولاد ہے اور نہ وہ کسی سے پیدا ہوا۔', 'tr': 'Lam yalid wa lam yulad'},
      {'ar': 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌ ۝٤', 'en': 'Nor is there to Him any equivalent."', 'ur': 'اور نہ ہی کوئی اس کا ہمسر ہے۔', 'tr': 'Wa lam yakun lahu kufuwan ahad'},
    ],
    // 113: Al-Falaq
    113: [
      {'ar': 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ ۝١', 'en': 'Say, "I seek refuge in the Lord of daybreak', 'ur': 'آپ کہہ دیجیے: میں صبح کے رب کی پناہ مانگتا ہوں۔', 'tr': 'Qul a\'udhu birabbil-falaq'},
      {'ar': 'مِن شَرِّ مَا خَلَقَ ۝٢', 'en': 'From the evil of that which He created', 'ur': 'ہر اس چیز کے شر سے جو اس نے پیدا کی۔', 'tr': 'Min sharri ma khalaq'},
      {'ar': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝٣', 'en': 'And from the evil of darkness when it settles', 'ur': 'اور اندھیری رات کے شر سے جب وہ چھا جائے۔', 'tr': 'Wa min sharri ghasiqin idha waqab'},
      {'ar': 'وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ ۝٤', 'en': 'And from the evil of the blowers in knots', 'ur': 'اور گرہوں میں پھونکنے والیوں کے شر سے۔', 'tr': 'Wa min sharrin-naffathati fil-\'uqad'},
      {'ar': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ۝٥', 'en': 'And from the evil of an envier when he envies."', 'ur': 'اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔', 'tr': 'Wa min sharri hasidin idha hasad'},
    ],
    // 114: An-Nas
    114: [
      {'ar': 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ ۝١', 'en': 'Say, "I seek refuge in the Lord of mankind,', 'ur': 'آپ کہہ دیجیے: میں انسانوں کے رب کی پناہ مانگتا ہوں۔', 'tr': 'Qul a\'udhu birabbin-nas'},
      {'ar': 'مَلِكِ ٱلنَّاسِ ۝٢', 'en': 'The Sovereign of mankind.', 'ur': 'انسانوں کے بادشاہ کی۔', 'tr': 'Malikin-nas'},
      {'ar': 'إِلَٰهِ ٱلنَّاسِ ۝٣', 'en': 'The God of mankind,', 'ur': 'انسانوں کے معبود کی۔', 'tr': 'Ilahin-nas'},
      {'ar': 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ ۝٤', 'en': 'From the evil of the retreating whisperer -', 'ur': 'وسوسہ ڈالنے والے، پیچھے ہٹ جانے والے کے شر سے۔', 'tr': 'Min sharril-waswasil-khannas'},
      {'ar': 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ ۝٥', 'en': 'Who whispers [evil] into the breasts of mankind -', 'ur': 'جو لوگوں کے سینوں میں وسوسے ڈالتا ہے۔', 'tr': 'Alladhi yuwaswisu fi sudurin-nas'},
      {'ar': 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ ۝٦', 'en': 'From among the jinn and mankind."', 'ur': 'خواہ وہ جنوں میں سے ہو یا انسانوں میں سے۔', 'tr': 'Minal-jinnati wan-nas'},
    ],
    // 2: Al-Baqarah (Opening Authentic Verses)
    2: [
      {
        'ar': 'الم ۝١',
        'en': 'Alif, Lam, Meem.',
        'ur': 'الٓمّٓ۔',
        'tr': 'Alif-Lam-Meem',
      },
      {
        'ar': 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ ۝٢',
        'en': 'This is the Book about which there is no doubt, a guidance for those conscious of Allah -',
        'ur': 'یہ وہ کتاب ہے جس میں کسی طرح کے شک وشبہ کی گنجائش نہیں، پرہیزگاروں کو راستہ دکھانے والی ہے۔',
        'tr': 'Dhalikal-Kitabu la rayba fihi hudal-lil-muttaqin',
      },
      {
        'ar': 'ٱلَّذِينَ يُؤْمِنُونَ بِٱلْغَيْبِ وَيُقِيمُونَ ٱلصَّلَوٰةَ وَمِمَّا رَزَقْنَٰهُمْ يُنفِقُونَ ۝٣',
        'en': 'Who believe in the unseen, establish prayer, and spend out of what We have provided for them,',
        'ur': 'وہ جو بن دیکھے ایمان لاتے ہیں، نماز قائم کرتے ہیں اور جو کچھ ہم نے انہیں دیا ہے اس میں سے خرچ کرتے ہیں۔',
        'tr': 'Alladhina yu\'minuna bil-ghaybi wa yuqimunas-Salata wa mimma razaqnahum yunfiqun',
      },
      {
        'ar': 'وَٱلَّذِينَ يُؤْمِنُونَ بِمَآ أُنزِلَ إِلَيْكَ وَمَآ أُنزِلَ مِن قَبْلِكَ وَبِٱلْءَاخِرَةِ هُمْ يُوقِنُونَ ۝٤',
        'en': 'And who believe in what has been revealed to you, [O Muhammad], and what was revealed before you, and of the Hereafter they are certain [in faith].',
        'ur': 'اور وہ جو ایمان لاتے ہیں اس پر جو آپ کی طرف نازل کیا گیا اور جو آپ سے پہلے نازل کیا گیا، اور آخرت پر وہ یقین رکھتے ہیں۔',
        'tr': 'Walladhina yu\'minuna bima unzila ilayka wa ma unzila min qablika wa bil-Akhirati hum yuqinun',
      },
      {
        'ar': 'أُو۟لَٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُو۟لَٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ ۝٥',
        'en': 'Those are upon [right] guidance from their Lord, and it is those who are the successful.',
        'ur': 'یہی لوگ اپنے رب کی طرف سے ہدایت پر ہیں اور یہی فلاح پانے والے ہیں۔',
        'tr': 'Ula\'ika \'ala hudam-mir-Rabbihim wa ula\'ika humul-muflihun',
      },
    ],
  };

  List<Surah> getAllSurahs() {
    return _surahsMetadata.map((meta) {
      return Surah(
        number: meta['number'],
        nameArabic: meta['nameArabic'],
        nameEnglish: meta['nameEnglish'],
        englishMeaning: meta['meaning'],
        revelationType: meta['type'],
        versesCount: meta['verses'],
        startPage: meta['page'],
        ayahs: _getAyahsForSurah(meta['number'], meta['verses'], meta['page']),
      );
    }).toList();
  }

  Surah getSurahByNumber(int number) {
    final meta = _surahsMetadata.firstWhere(
      (s) => s['number'] == number,
      orElse: () => _surahsMetadata.first,
    );

    return Surah(
      number: meta['number'],
      nameArabic: meta['nameArabic'],
      nameEnglish: meta['nameEnglish'],
      englishMeaning: meta['meaning'],
      revelationType: meta['type'],
      versesCount: meta['verses'],
      startPage: meta['page'],
      ayahs: _getAyahsForSurah(meta['number'], meta['verses'], meta['page']),
    );
  }

  List<Ayah> _getAyahsForSurah(int surahNum, int totalVerses, int startPage) {
    if (_surahVersesData.containsKey(surahNum)) {
      final list = _surahVersesData[surahNum]!;
      return List.generate(list.length, (index) {
        final item = list[index];
        return Ayah(
          numberInSurah: index + 1,
          globalAyahNumber: (surahNum * 100) + index + 1,
          arabicText: item['ar']!,
          englishTranslation: item['en']!,
          urduTranslation: item['ur']!,
          transliteration: item['tr']!,
          pageNumber: startPage + (index ~/ 15),
          juzNumber: ((startPage - 1) ~/ 20) + 1,
          audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${(surahNum * 100) + index + 1}.mp3',
        );
      });
    }

    // Never generate placeholder verses. All other Surahs are loaded authentic from AlQuran Cloud API.
    return [];
  }
}
