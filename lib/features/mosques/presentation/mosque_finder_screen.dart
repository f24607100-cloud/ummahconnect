import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import 'providers/mosque_provider.dart';

class MosqueFinderScreen extends ConsumerStatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  ConsumerState<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends ConsumerState<MosqueFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCityFilter = 'Near Me';

  final List<String> _quickCities = [
    'Near Me',
    'I-13 Islamabad',
    'Islamabad',
    'Rawalpindi',
    'Lahore',
    'Karachi',
    'Dubai',
    'Makkah',
    'Medina',
    'London',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCityChipSelected(String city) {
    setState(() {
      _selectedCityFilter = city;
      _searchController.clear();
    });

    if (city == 'Near Me') {
      ref.read(mosqueNotifierProvider.notifier).loadNearbyMosques();
    } else {
      ref.read(mosqueNotifierProvider.notifier).searchMosques(city);
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      setState(() => _selectedCityFilter = '');
      ref.read(mosqueNotifierProvider.notifier).searchMosques(query.trim());
    }
  }

  Future<void> _openGoogleMaps(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map navigation.')),
        );
      }
    }
  }

  void _showGoogleApiKeyDialog(BuildContext context, MosqueState state) {
    final keyController = TextEditingController(text: state.googleApiKey ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.key_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Google Places API Key',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect your Google Cloud API key to load 100% of all local mosques directly from Google Maps.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: state.hasGoogleApiKey
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.hasGoogleApiKey ? Colors.green : Colors.blue,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.hasGoogleApiKey ? Icons.check_circle : Icons.info_outline,
                        color: state.hasGoogleApiKey ? Colors.green : Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.hasGoogleApiKey
                              ? 'Google Places API Active'
                              : 'Currently using free OpenStreetMap (Overpass API)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: state.hasGoogleApiKey ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keyController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Google Cloud API Key',
                    hintText: 'AIzaSy...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => keyController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Requires "Places API" enabled in your Google Cloud Console project.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            if (state.hasGoogleApiKey)
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogCtx);
                  await ref.read(mosqueNotifierProvider.notifier).setGoogleApiKey('');
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Switched back to free OpenStreetMap.')),
                  );
                },
                child: const Text('Clear Key', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final key = keyController.text.trim();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogCtx);
                await ref.read(mosqueNotifierProvider.notifier).setGoogleApiKey(key);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      key.isNotEmpty
                          ? 'Google Places API Key saved! Refreshing mosques...'
                          : 'Using free OpenStreetMap engine.',
                    ),
                  ),
                );
              },
              child: const Text('Save & Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mosqueState = ref.watch(mosqueNotifierProvider);
    final notifier = ref.read(mosqueNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Mosque Finder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '📍 ${mosqueState.currentCity}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.gold : AppColors.lightPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Google Places API Key configuration button
          IconButton(
            icon: Icon(
              mosqueState.hasGoogleApiKey ? Icons.key_rounded : Icons.key_outlined,
              color: mosqueState.hasGoogleApiKey ? AppColors.gold : null,
            ),
            tooltip: 'Google Maps API Key',
            onPressed: () => _showGoogleApiKeyDialog(context, mosqueState),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Mosques',
            onPressed: () {
              if (_selectedCityFilter == 'Near Me' || _selectedCityFilter.isEmpty) {
                notifier.loadNearbyMosques();
              } else {
                notifier.searchMosques(_selectedCityFilter);
              }
            },
          ),
        ],
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search sector or city (e.g. I-13 Islamabad)...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.loadNearbyMosques();
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.gold),
                            onPressed: () => _onSearchSubmitted(_searchController.text),
                          ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),

              // Quick Sector & City Selector Horizontal Scroll
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickCities.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = _quickCities[index];
                    final isSelected = _selectedCityFilter == city;

                    return ChoiceChip(
                      label: Text(
                        city,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.gold,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.gold
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      onSelected: (_) => _onCityChipSelected(city),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Live Status Header with Source Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Mosques (${mosqueState.mosques.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showGoogleApiKeyDialog(context, mosqueState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (mosqueState.activeSource == 'Google Places' ? Colors.blue : Colors.green)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (mosqueState.activeSource == 'Google Places' ? Colors.blue : Colors.green)
                                .withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: mosqueState.activeSource == 'Google Places' ? Colors.blue : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              mosqueState.activeSource == 'Google Places'
                                  ? 'Google Places API'
                                  : 'OpenStreetMap & Overpass',
                              style: TextStyle(
                                fontSize: 10,
                                color: mosqueState.activeSource == 'Google Places' ? Colors.blue : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_outlined,
                              size: 11,
                              color: mosqueState.activeSource == 'Google Places' ? Colors.blue : Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Mosques List
              Expanded(
                child: mosqueState.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.gold),
                            const SizedBox(height: 16),
                            Text(
                              mosqueState.hasGoogleApiKey
                                  ? 'Fetching live mosques from Google Places API...'
                                  : 'Searching live neighborhood mosques via Overpass API...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                    : mosqueState.mosques.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.mosque_outlined, size: 54, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No mosques found in "${mosqueState.currentCity}".',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Try searching for "I-13 Islamabad" or tap "Near Me".',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                                    icon: const Icon(Icons.near_me, size: 16),
                                    label: const Text('Find Near Me'),
                                    onPressed: () => _onCityChipSelected('Near Me'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: mosqueState.mosques.length,
                            itemBuilder: (context, index) {
                              final item = mosqueState.mosques[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GlassCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Title & Badges
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (item.rating != null) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${item.rating}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (item.userRatingsTotal != null) ...[
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '(${item.userRatingsTotal} reviews)',
                                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.darkPrimary
                                                  : AppColors.lightPrimary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.gold, width: 0.5),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.near_me, color: AppColors.gold, size: 12),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${item.distanceKm} km away',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Full Address
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item.address,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Jummah Schedule
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.05)
                                              : Colors.black.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.mosque, color: AppColors.gold, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Jummah: ${item.jummahTime}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Real Prayer Times Grid from AlAdhan API
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: item.prayerTimes.entries.map((entry) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.darkSurface : Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                            ),
                                            child: Text(
                                              '${entry.key}: ${entry.value}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 14),

                                      // Get Directions Button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.gold,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _openGoogleMaps(item.googleMapsUrl),
                                        icon: const Icon(Icons.directions, size: 16),
                                        label: const Text('Get Directions on Google Maps'),
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
