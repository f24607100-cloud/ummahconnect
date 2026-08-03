import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/charity_campaign.dart';
import 'providers/charity_provider.dart';

class CharityScreen extends ConsumerStatefulWidget {
  const CharityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharityScreen> createState() => _CharityScreenState();
}

class _CharityScreenState extends ConsumerState<CharityScreen> {
  String _selectedCauseFilter = 'All';

  void _showDonateModal(BuildContext context, CharityCampaign campaign) {
    double selectedAmount = 25.0;
    final customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                  Text(
                    'Donate to ${campaign.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Managed by ${campaign.organization}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Quick donation amount buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [10.0, 25.0, 50.0, 100.0].map((amt) {
                      final isSel = selectedAmount == amt;
                      return ChoiceChip(
                        selected: isSel,
                        label: Text('\$${amt.toInt()}'),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isSel ? (isDark ? Colors.black : Colors.white) : null,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedAmount = amt;
                              customController.clear();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Custom amount field
                  TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Custom Donation Amount (\$)',
                      prefixText: '\$ ',
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setModalState(() {
                          selectedAmount = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(charityNotifierProvider.notifier).processDonation(campaign.id, selectedAmount);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('JazaakAllah Khair! Direct donation of \$${selectedAmount.toStringAsFixed(2)} completed.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.volunteer_activism),
                    label: Text('Donate \$${selectedAmount.toStringAsFixed(2)}'),
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
    final campaigns = ref.watch(charityNotifierProvider);

    final filtered = campaigns.where((c) {
      if (_selectedCauseFilter == 'All') return true;
      if (_selectedCauseFilter == 'Mosques' && c.cause == CharityCause.mosque) return true;
      if (_selectedCauseFilter == 'Orphans' && c.cause == CharityCause.orphan) return true;
      if (_selectedCauseFilter == 'Food Drives' && c.cause == CharityCause.foodDrive) return true;
      if (_selectedCauseFilter == 'Emergency' && c.cause == CharityCause.emergencyRelief) return true;
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Charity & Causes'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: Column(
            children: [
              // Cause Filter Bar
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'Mosques', 'Orphans', 'Food Drives', 'Emergency'].map((cause) {
                    final isSel = _selectedCauseFilter == cause;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(cause),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        labelStyle: TextStyle(
                          color: isSel ? (isDark ? Colors.black : Colors.white) : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCauseFilter = cause;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No campaigns in this category.'))
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
                                          item.causeLabel.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.donorsCount} Donors',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),

                                  // Progress metrics
                                  LinearProgressIndicator(
                                    value: item.percentRaised,
                                    minHeight: 8,
                                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? AppColors.gold : AppColors.lightPrimary,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item.raisedAmount.toInt()} raised of \$${item.targetAmount.toInt()}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${(item.percentRaised * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.gold : AppColors.lightPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  ElevatedButton.icon(
                                    onPressed: () => _showDonateModal(context, item),
                                    icon: const Icon(Icons.favorite, size: 18),
                                    label: const Text('Donate Directly'),
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
