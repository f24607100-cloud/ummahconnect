import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../../core/services/hive_service.dart';

class DuaItem {
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  DuaItem({
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });
}

class DuaScreen extends ConsumerStatefulWidget {
  const DuaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends ConsumerState<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Morning',
    'Evening',
    'Food',
    'Travel',
    'Sleeping',
    'Illness',
    'Rain',
  ];

  final List<DuaItem> _duas = [
    DuaItem(
      category: 'Morning',
      title: 'Dua for waking up',
      arabic: 'الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      transliteration: 'Alhamdu lillahil-lathee ahyana ba\'da ma amatana wa-ilayhin-nushoor.',
      translation: 'All praise is due to Allah who gave us life after having taken it from us and unto Him is the resurrection.',
      reference: 'Sahih al-Bukhari 6312',
    ),
    DuaItem(
      category: 'Morning',
      title: 'Dua for protection (3x)',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      transliteration: 'Bismillahil-lathee la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-samee\'ul-\'aleem.',
      translation: 'In the name of Allah with Whose name nothing can harm on earth or in heaven, and He is the All-Hearing, All-Knowing.',
      reference: 'Abu Dawud 4/323',
    ),
    DuaItem(
      category: 'Evening',
      title: 'Seeking forgiveness (Sayyid al-Istighfar)',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      transliteration: 'Allahumma anta Rabbee la ilaha illa anta, khalaqtanee wa-ana \'abduka, wa-ana \'ala \'ahdika wa-wa\'dika mas-tata\'tu...',
      translation: 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant, and I remain faithful to Your covenant...',
      reference: 'Sahih al-Bukhari 6306',
    ),
    DuaItem(
      category: 'Food',
      title: 'Before Eating',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah.',
      translation: 'In the name of Allah.',
      reference: 'Abu Dawud 3/347',
    ),
    DuaItem(
      category: 'Food',
      title: 'After Eating',
      arabic: 'الْحَمْدُ للهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      transliteration: 'Alhamdu lillahil-lathee at\'amanee hatha wa razaqaneehi min ghayri hawlin minnee wa la quwwah.',
      translation: 'Praise be to Allah who fed me this and provided it for me without any might or power from myself.',
      reference: 'At-Tirmidhi 3457',
    ),
    DuaItem(
      category: 'Travel',
      title: 'Dua for mounting a vehicle',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      transliteration: 'Subhanal-lathee sakhkhara lana hatha wa ma kunna lahu muqrineen. Wa inna ila Rabbina lamunqaliboon.',
      translation: 'Glory to Him Who has subjected this to us, and we could never have it by our efforts. And verily, to our Lord we remain to return.',
      reference: 'Surah Az-Zukhruf 13-14',
    ),
    DuaItem(
      category: 'Sleeping',
      title: 'Dua before sleeping',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amootu wa-ahya.',
      translation: 'In Your name, O Allah, I die and I live.',
      reference: 'Sahih al-Bukhari 6324',
    ),
    DuaItem(
      category: 'Illness',
      title: 'Dua for recovery',
      arabic: 'أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ اشْفِ وَأَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا',
      transliteration: 'Athhibil-ba\'sa Rabban-nas, ishfi wa antash-Shafee, la shifa\'a illa shifa\'uka, shifa\'an la yughadiru saqama.',
      translation: 'Take away the disease, O Lord of the people! Heal, for You are the Healer. There is no cure but Your cure, a cure that leaves no illness.',
      reference: 'Sahih al-Bukhari 5743',
    ),
    DuaItem(
      category: 'Rain',
      title: 'Dua when it rains',
      arabic: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
      transliteration: 'Allahumma sayyiban nafi\'a.',
      translation: 'O Allah, make it a beneficial rain.',
      reference: 'Sahih al-Bukhari 1032',
    ),
  ];

  List<String> _bookmarkedDuaTitles = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final hive = HiveService();
    final list = hive.getValue<List>(HiveService.bookmarksBox, 'bookmarked_duas', defaultValue: []);
    setState(() {
      _bookmarkedDuaTitles = List<String>.from(list!);
    });
  }

  Future<void> _toggleBookmark(String title) async {
    final updated = List<String>.from(_bookmarkedDuaTitles);
    if (updated.contains(title)) {
      updated.remove(title);
    } else {
      updated.add(title);
    }
    setState(() {
      _bookmarkedDuaTitles = updated;
    });
    await HiveService().setValue<List<String>>(HiveService.bookmarksBox, 'bookmarked_duas', updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter Duas
    final filteredDuas = _duas.where((dua) {
      final matchesCategory = _selectedCategory == 'All' || dua.category == _selectedCategory;
      final matchesSearch = dua.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dua.translation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dua.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Dua Collection'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Duas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear), 
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ) 
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              // Category chips list
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        checkmarkColor: isDark ? Colors.black : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? (isDark ? Colors.black : Colors.white) 
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Duas display list
              Expanded(
                child: filteredDuas.isEmpty
                    ? const Center(child: Text('No Duas found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDuas.length,
                        itemBuilder: (context, index) {
                          final item = filteredDuas[index];
                          final isBookmarked = _bookmarkedDuaTitles.contains(item.title);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : AppColors.lightPrimary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: AppColors.gold,
                                        ),
                                        onPressed: () => _toggleBookmark(item.title),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.arabic,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.transliteration,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${item.translation}"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.reference,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
