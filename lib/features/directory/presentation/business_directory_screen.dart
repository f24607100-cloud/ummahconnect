import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/halal_business.dart';
import 'providers/directory_provider.dart';

class BusinessDirectoryScreen extends ConsumerStatefulWidget {
  const BusinessDirectoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessDirectoryScreen> createState() => _BusinessDirectoryScreenState();
}

class _BusinessDirectoryScreenState extends ConsumerState<BusinessDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCatFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final businesses = ref.watch(directoryNotifierProvider);

    final filtered = businesses.where((b) {
      bool matchesCat = true;
      if (_selectedCatFilter == 'Restaurants') matchesCat = b.category == BusinessCategory.restaurant;
      if (_selectedCatFilter == 'Tutors') matchesCat = b.category == BusinessCategory.tutor;
      if (_selectedCatFilter == 'Doctors') matchesCat = b.category == BusinessCategory.doctor;
      if (_selectedCatFilter == 'Freelancers') matchesCat = b.category == BusinessCategory.freelancer;
      if (_selectedCatFilter == 'Schools') matchesCat = b.category == BusinessCategory.islamicSchool;

      bool matchesSearch = b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.address.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Halal Business Directory'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search Halal restaurants, tutors, doctors...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Category Filter Bar
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'Restaurants', 'Tutors', 'Doctors', 'Freelancers', 'Schools'].map((cat) {
                    final isSel = _selectedCatFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(cat),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isSel ? (isDark ? Colors.black : Colors.white) : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() => _selectedCatFilter = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Directory list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No listings found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];

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
                                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.categoryLabel.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                          ),
                                        ),
                                      ),
                                      if (item.isHalalCertified)
                                        Row(
                                          children: const [
                                            Icon(Icons.verified, color: AppColors.gold, size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'Certified Halal',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.gold),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.rating}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.hours,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gold),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.address,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Calling ${item.name} (${item.phone})...')),
                                      );
                                    },
                                    icon: const Icon(Icons.phone, size: 16),
                                    label: Text('Contact (${item.phone})'),
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
