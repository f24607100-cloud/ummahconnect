import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/islamic_event.dart';
import 'providers/events_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _selectedCatFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = ref.watch(eventsNotifierProvider);
    final notifier = ref.read(eventsNotifierProvider.notifier);

    final filtered = events.where((e) {
      if (_selectedCatFilter == 'All') return true;
      if (_selectedCatFilter == 'Lectures' && e.category == EventCategory.lecture) return true;
      if (_selectedCatFilter == 'Quran Classes' && e.category == EventCategory.quranClass) return true;
      if (_selectedCatFilter == 'Workshops' && e.category == EventCategory.workshop) return true;
      if (_selectedCatFilter == 'Eid Events' && e.category == EventCategory.eidEvent) return true;
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Islamic Events'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Category Filter Bar
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'Lectures', 'Quran Classes', 'Workshops', 'Eid Events'].map((cat) {
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
              const SizedBox(height: 8),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No events found in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final formattedDate = DateFormat('EEE, d MMM y • h:mm a').format(item.dateTime);

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
                                      Text(
                                        '${item.rsvpCount} Attending',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: AppColors.gold),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.speaker,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),

                                  ElevatedButton.icon(
                                    onPressed: () => notifier.toggleRsvp(item.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: item.isRsvped 
                                          ? AppColors.success 
                                          : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
                                    ),
                                    icon: Icon(item.isRsvped ? Icons.check_circle : Icons.event_available, size: 16),
                                    label: Text(item.isRsvped ? 'Attending (RSVP Confirmed)' : 'RSVP to Event'),
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
