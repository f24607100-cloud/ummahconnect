import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/charity_campaign.dart';

class CharityNotifier extends StateNotifier<List<CharityCampaign>> {
  final HiveService _hiveService = HiveService();
  static const String _charityKey = 'charity_campaigns_v2';

  CharityNotifier() : super([]) {
    _loadCampaigns();
  }

  void _loadCampaigns() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _charityKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => CharityCampaign.fromMap(e as Map)).toList();
    } else {
      state = [
        CharityCampaign(
          id: 'c_1',
          cause: CharityCause.mosque,
          title: 'Solar Power Installation for Local Mosque',
          description: 'Help equip Masjid Al-Noor with clean solar energy to reduce operational utility costs and fund free Quran classes.',
          organization: 'Masjid Al-Noor Trust',
          targetAmount: 15000,
          raisedAmount: 11250,
          donorsCount: 148,
        ),
        CharityCampaign(
          id: 'c_2',
          cause: CharityCause.orphan,
          title: 'Sponsor Education & Care for 50 Orphans',
          description: 'Providing monthly food packages, school uniforms, books, and medical care for vulnerable orphan children.',
          organization: 'Ummah Care Foundation',
          targetAmount: 20000,
          raisedAmount: 14800,
          donorsCount: 230,
        ),
        CharityCampaign(
          id: 'c_3',
          cause: CharityCause.foodDrive,
          title: 'Daily Food Basket Distribution for Needy Families',
          description: 'Distributing essential nutrition packages containing rice, flour, oil, dates, and lentils.',
          organization: 'Barakah Food Bank',
          targetAmount: 10000,
          raisedAmount: 7600,
          donorsCount: 95,
        ),
        CharityCampaign(
          id: 'c_4',
          cause: CharityCause.emergencyRelief,
          title: 'Emergency Medical & Clean Water Relief',
          description: 'Providing urgent clean water filtration units and emergency first-aid kits to crisis-affected regions.',
          organization: 'Global Islamic Relief',
          targetAmount: 30000,
          raisedAmount: 24500,
          donorsCount: 410,
        ),
      ];
      _saveCampaigns();
    }
  }

  Future<void> _saveCampaigns() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _charityKey, list);
  }

  void processDonation(String campaignId, double amount) {
    state = state.map((camp) {
      if (camp.id == campaignId) {
        return camp.copyWith(
          raisedAmount: camp.raisedAmount + amount,
          donorsCount: camp.donorsCount + 1,
        );
      }
      return camp;
    }).toList();
    _saveCampaigns();
  }
}

final charityNotifierProvider = StateNotifierProvider<CharityNotifier, List<CharityCampaign>>((ref) {
  return CharityNotifier();
});
