import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../domain/models/surah_model.dart';
import '../services/quran_repository.dart';
import '../services/alquran_api_service.dart';
import 'providers/quran_provider.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final int initialSurahNumber;

  const SurahReaderScreen({
    Key? key,
    this.initialSurahNumber = 1,
  }) : super(key: key);

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final QuranRepository _repository = QuranRepository();
  final AlQuranApiService _apiService = AlQuranApiService();

  late PageController _pageController;
  late Surah _currentSurah;
  late List<Surah> _allSurahs;

  int _currentPageNumber = 1;
  int _selectedViewMode = 1; // 1 = Mushaf Page View (Matching Screenshot), 0 = Verse Cards
  double _arabicFontSize = 24.0;
  bool _showEnglish = true;
  bool _showUrdu = false;
  bool _showTransliteration = true;

  // Selected Ayah for yellow highlight (matching user screenshot)
  int? _selectedAyahNumber;

  // Audio State
  bool _isPlayingAudio = false;
  int _currentlyPlayingAyahIndex = -1;
  String _selectedReciter = 'Mishary Rashid Alafasy';

  final List<String> _reciters = [
    'Mishary Rashid Alafasy',
    'Abdul Rahman Al-Sudais',
    'Maher Al-Muaiqly',
    'Saad Al-Ghamdi',
  ];

  // Bookmarked Ayahs
  final Set<int> _bookmarkedAyahs = {};

  // Authentic API Page Data Cache
  final Map<int, Map<String, dynamic>> _apiPageDataMap = {};
  bool _isLoadingApiPage = false;

  // Authentic API Surah Verses
  List<Map<String, dynamic>> _currentSurahAyahs = [];
  bool _isLoadingSurah = false;

  @override
  void initState() {
    super.initState();
    _allSurahs = _repository.getAllSurahs();
    _currentSurah = _repository.getSurahByNumber(widget.initialSurahNumber);
    _currentPageNumber = _currentSurah.startPage;
    _pageController = PageController(initialPage: _currentPageNumber - 1);

    _loadSurahData(_currentSurah.number);
    _fetchPageFromApi(_currentPageNumber);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadSurah(int surahNum) {
    final s = _repository.getSurahByNumber(surahNum);
    setState(() {
      _currentSurah = s;
      _currentPageNumber = s.startPage;
      _currentlyPlayingAyahIndex = -1;
      _isPlayingAudio = false;
      _selectedAyahNumber = null;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentPageNumber - 1);
    }

    _loadSurahData(surahNum);
    _fetchPageFromApi(_currentPageNumber);
    _syncReadingProgress();
  }

  Future<void> _loadSurahData(int surahNum) async {
    setState(() => _isLoadingSurah = true);

    // If bundled authentic verses exist in repository, seed them
    final bundled = _repository.getSurahByNumber(surahNum).ayahs;
    if (bundled.isNotEmpty) {
      setState(() {
        _currentSurahAyahs = bundled
            .map((a) => {
                  'numberInSurah': a.numberInSurah,
                  'text': a.arabicText,
                  'englishText': a.englishTranslation,
                  'urduText': a.urduTranslation,
                  'transliteration': a.transliteration,
                  'audioUrl': a.audioUrl,
                })
            .toList();
      });
    }

    // Fetch full authentic Surah from AlQuran Cloud API
    final apiAyahs = await _apiService.getSurahData(surahNum);
    if (mounted && apiAyahs.isNotEmpty) {
      setState(() {
        _currentSurahAyahs = apiAyahs;
        _isLoadingSurah = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingSurah = false);
    }
  }

  void _onPageChanged(int pageIndex) {
    final pageNum = pageIndex + 1;
    setState(() {
      _currentPageNumber = pageNum;
      _selectedAyahNumber = null;
    });

    // Update active surah according to page number
    final matchingSurah = _allSurahs.lastWhere(
      (s) => s.startPage <= pageNum,
      orElse: () => _allSurahs.first,
    );

    if (matchingSurah.number != _currentSurah.number) {
      setState(() {
        _currentSurah = matchingSurah;
      });
      _loadSurahData(matchingSurah.number);
    }

    _fetchPageFromApi(pageNum);
    _syncReadingProgress();
  }

  Future<void> _fetchPageFromApi(int pageNum) async {
    if (_apiPageDataMap.containsKey(pageNum)) return;

    setState(() => _isLoadingApiPage = true);
    final data = await _apiService.getPageData(pageNum);
    if (mounted) {
      setState(() {
        if (data.isNotEmpty) {
          _apiPageDataMap[pageNum] = data;
        }
        _isLoadingApiPage = false;
      });
    }
  }

  void _syncReadingProgress() {
    Future.microtask(() {
      ref.read(quranNotifierProvider.notifier).updateCurrentLocation(
            _currentSurah.nameEnglish,
            _currentPageNumber,
          );
    });
  }

  void _togglePlayPauseAudio([int ayahIndex = 0]) {
    setState(() {
      if (_isPlayingAudio && _currentlyPlayingAyahIndex == ayahIndex) {
        _isPlayingAudio = false;
      } else {
        _isPlayingAudio = true;
        _currentlyPlayingAyahIndex = ayahIndex;
      }
    });

    if (_isPlayingAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Playing Recitation (${_currentSurah.nameEnglish} Ayah ${ayahIndex + 1}) by $_selectedReciter',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showJumpToPageDialog(BuildContext context) {
    final controller = TextEditingController(text: _currentPageNumber.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jump to Page (1-604)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Page Number',
              hintText: 'e.g. 2, 255',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page >= 1 && page <= 604) {
                  Navigator.pop(context);
                  _pageController.jumpToPage(page - 1);
                }
              },
              child: const Text('Jump'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizationSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reader Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Arabic Font Size: ${_arabicFontSize.toInt()}pt',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Slider(
                    value: _arabicFontSize,
                    min: 18,
                    max: 38,
                    divisions: 10,
                    activeColor: AppColors.gold,
                    onChanged: (val) {
                      setSheetState(() => _arabicFontSize = val);
                      setState(() => _arabicFontSize = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    title: const Text('English Translation'),
                    value: _showEnglish,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) {
                      setSheetState(() => _showEnglish = val);
                      setState(() => _showEnglish = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Urdu Translation (اردو ترجمہ)'),
                    value: _showUrdu,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) {
                      setSheetState(() => _showUrdu = val);
                      setState(() => _showUrdu = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Transliteration'),
                    value: _showTransliteration,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) {
                      setSheetState(() => _showTransliteration = val);
                      setState(() => _showTransliteration = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141916) : const Color(0xFFFAF8F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              '${_currentSurah.number}. ${_currentSurah.nameEnglish} (${_currentSurah.nameArabic})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Page $_currentPageNumber of 604 • ${_currentSurah.revelationType}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pin_drop_outlined, color: AppColors.gold),
            onPressed: () => _showJumpToPageDialog(context),
            tooltip: 'Jump to Page',
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showCustomizationSheet(context),
            tooltip: 'Reader Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Surah & View Mode Switcher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.95),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _currentSurah.number > 1
                      ? () => _loadSurah(_currentSurah.number - 1)
                      : null,
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _currentSurah.number,
                        isExpanded: true,
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gold : AppColors.lightPrimary,
                        ),
                        items: _allSurahs.map((s) {
                          return DropdownMenuItem<int>(
                            value: s.number,
                            child: Text(
                              '${s.number}. ${s.nameEnglish} (${s.nameArabic})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _loadSurah(val);
                        },
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _currentSurah.number < 114
                      ? () => _loadSurah(_currentSurah.number + 1)
                      : null,
                ),

                const SizedBox(width: 6),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: _selectedViewMode == 1
                              ? AppColors.gold
                              : Colors.grey,
                        ),
                        onPressed: () => setState(() => _selectedViewMode = 1),
                        tooltip: 'Mushaf Page View',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 18,
                          color: _selectedViewMode == 0
                              ? AppColors.gold
                              : Colors.grey,
                        ),
                        onPressed: () => setState(() => _selectedViewMode = 0),
                        tooltip: 'Verse Cards View',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Quran Display
          Expanded(
            child: _selectedViewMode == 1
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: 604,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final pageNum = index + 1;
                      return _buildAuthenticMushafPage(pageNum, isDark);
                    },
                  )
                : _buildAyahListView(isDark),
          ),

          // Audio Player Bar
          _buildAudioPlayerBar(isDark),
        ],
      ),
    );
  }

  // Authentic 15-Line Madani Mushaf Page Layout (Matching User Screenshot Exactly)
  Widget _buildAuthenticMushafPage(int pageNum, bool isDark) {
    final apiData = _apiPageDataMap[pageNum];
    final juzNumber = apiData != null && apiData.containsKey('juz')
        ? apiData['juz']
        : (((pageNum - 1) ~/ 20) + 1);

    final List ayahsList = (apiData != null && apiData.containsKey('ayahs'))
        ? apiData['ayahs']
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2420) : const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.6),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Header Row (Surah Name Left, Part/Juz Right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentSurah.nameEnglish,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E7B3B),
                      ),
                    ),
                    Text(
                      'Part $juzNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E7B3B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Loading State or Content
                if (_isLoadingApiPage && ayahsList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppColors.gold),
                        const SizedBox(height: 16),
                        Text(
                          'Loading Page $pageNum from the Holy Quran...',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (ayahsList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load page from the Quran API.\nPlease check your connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry Loading Page'),
                          onPressed: () => _fetchPageFromApi(pageNum),
                        ),
                      ],
                    ),
                  )
                else
                  _buildMushafScriptureContent(ayahsList, isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Page Flip Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                onPressed: _currentPageNumber > 1
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
              GestureDetector(
                onTap: () => _showJumpToPageDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Page $_currentPageNumber of 604',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              IconButton.outlined(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onPressed: _currentPageNumber < 604
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Renders the 15-Line Madani Scripture Content with Ornate Surah Banners
  Widget _buildMushafScriptureContent(List ayahsList, bool isDark) {
    List<Widget> pageElements = [];
    int currentSurahNum = -1;

    for (int i = 0; i < ayahsList.length; i++) {
      final item = ayahsList[i];
      final Map<String, dynamic> surahInfo = (item is Map && item.containsKey('surah'))
          ? Map<String, dynamic>.from(item['surah'])
          : {
              'number': _currentSurah.number,
              'name': _currentSurah.nameArabic,
              'englishName': _currentSurah.nameEnglish,
            };

      final int surahNumber = surahInfo['number'] ?? 1;
      final int ayahInSurah = item['numberInSurah'] ?? 1;
      final String arabicText = item['text'] ?? '';
      final String englishText = item['englishText'] ?? '';
      final String urduText = item['urduText'] ?? '';

      // Detect start of new Surah on page
      if (surahNumber != currentSurahNum) {
        currentSurahNum = surahNumber;

        // 1. Ornate Surah Header Banner Frame
        pageElements.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C241B)
                    : const Color(0xFFF7F2E7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFBCA16B),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'سُورَةُ ${surahInfo['name'] ?? _currentSurah.nameArabic}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // 2. Bismillah Header Ornament (except Surah At-Tawbah #9)
        if (surahNumber != 9) {
          pageElements.add(
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3728),
                ),
              ),
            ),
          );
        }
      }

      final isSelected = (_selectedAyahNumber == ayahInSurah) ||
          (_isPlayingAudio && _currentlyPlayingAyahIndex == i);

      // 3. Ayah Paragraph with Soft Yellow Highlight (Matching Screenshot)
      pageElements.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedAyahNumber = isSelected ? null : ayahInSurah;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? const Color(0xFF4A411E)
                      : const Color(0xFFFFF4BD))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$arabicText ',
                        style: TextStyle(
                          fontSize: _arabicFontSize,
                          fontFamily: 'Amiri',
                          height: 2.2,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF212121),
                        ),
                      ),
                      TextSpan(
                        text: ' ﴿${_toArabicDigits(ayahInSurah)}﴾ ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBCA16B),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_showEnglish && englishText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    englishText,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.grey.shade800,
                    ),
                  ),
                ],

                if (_showUrdu && urduText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    urduText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF8D6E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: pageElements,
    );
  }

  // 1. Ayah Cards View (Authentic Verses Only)
  Widget _buildAyahListView(bool isDark) {
    if (_isLoadingSurah && _currentSurahAyahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              'Loading authentic Surah ${_currentSurah.nameEnglish}...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (_currentSurahAyahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Unable to fetch verses for ${_currentSurah.nameEnglish}.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => _loadSurahData(_currentSurah.number),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentSurahAyahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GlassCard(
            child: Column(
              children: [
                Text(
                  _currentSurah.nameArabic,
                  style: const TextStyle(
                    fontSize: 32,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentSurah.nameEnglish} • "${_currentSurah.englishMeaning}"',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Revelation: ${_currentSurah.revelationType} • ${_currentSurah.versesCount} Verses',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final ayah = _currentSurahAyahs[index - 1];
        final ayahNum = ayah['numberInSurah'] ?? index;
        final arabic = ayah['text'] ?? '';
        final english = ayah['englishText'] ?? '';
        final urdu = ayah['urduText'] ?? '';
        final translit = ayah['transliteration'] ?? '';

        final isPlaying = _isPlayingAudio && _currentlyPlayingAyahIndex == (index - 1);
        final isBookmarked = _bookmarkedAyahs.contains(ayahNum);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isPlaying
              ? (isDark
                  ? const Color(0xFF4A411E)
                  : const Color(0xFFFFF4BD))
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Text(
                        '${_currentSurah.number}:$ayahNum',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_outline_rounded,
                            color: AppColors.gold,
                          ),
                          onPressed: () => _togglePlayPauseAudio(index - 1),
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.gold : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isBookmarked) {
                                _bookmarkedAyahs.remove(ayahNum);
                              } else {
                                _bookmarkedAyahs.add(ayahNum);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              size: 18, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: arabic));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied Arabic text to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  arabic,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: _arabicFontSize,
                    fontFamily: 'Amiri',
                    height: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_showTransliteration && translit.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    translit,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
                if (_showEnglish && english.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    english,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
                if (_showUrdu && urdu.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    urdu,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Audio Player Bar
  Widget _buildAudioPlayerBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _togglePlayPauseAudio(
                  _currentlyPlayingAyahIndex == -1 ? 0 : _currentlyPlayingAyahIndex),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gold,
                child: Icon(Icons.play_arrow_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPlayingAudio
                        ? 'Playing: ${_currentSurah.nameEnglish} (Ayah ${_currentlyPlayingAyahIndex + 1})'
                        : 'Audio Reciter',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReciter,
                      isDense: true,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      dropdownColor:
                          isDark ? AppColors.darkSurface : Colors.white,
                      items: _reciters.map((r) {
                        return DropdownMenuItem(
                            value: r,
                            child: Text(r, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReciter = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: AppColors.gold),
              onPressed: () {
                final maxCount = _currentSurahAyahs.isNotEmpty ? _currentSurahAyahs.length : 1;
                final nextIdx = (_currentlyPlayingAyahIndex + 1) % maxCount;
                _togglePlayPauseAudio(nextIdx);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _toArabicDigits(int num) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String str = num.toString();
    for (int i = 0; i < englishDigits.length; i++) {
      str = str.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return str;
  }
}
