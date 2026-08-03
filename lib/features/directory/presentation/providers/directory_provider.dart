import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/halal_business.dart';

class DirectoryNotifier extends StateNotifier<List<HalalBusiness>> {
  final HiveService _hiveService = HiveService();
  static const String _directoryKey = 'halal_directory_v2';

  DirectoryNotifier() : super([]) {
    _loadDirectory();
  }

  void _loadDirectory() {
    final cached = _hiveService.getValue<List>(HiveService.bookmarksBox, _directoryKey);
    if (cached != null && cached.isNotEmpty) {
      state = cached.map((e) => HalalBusiness.fromMap(e as Map)).toList();
    } else {
      state = [
        HalalBusiness(
          id: 'b_1',
          category: BusinessCategory.restaurant,
          name: 'Al-Bait Authentic Mediterranean Grill',
          description: '100% Hand-Zabiha Halal grilled meats, shawarma, and fresh Middle Eastern mezze platter.',
          address: '142 King Abdulaziz Rd, Makkah',
          phone: '+966 12 555 0192',
          rating: 4.9,
          hours: '11:00 AM - 11:30 PM',
          isHalalCertified: true,
        ),
        HalalBusiness(
          id: 'b_2',
          category: BusinessCategory.islamicSchool,
          name: 'Dar Al-Iman International Islamic School',
          description: 'Combined National Curriculum & Tajweed Quranic Hifz program for KG through High School.',
          address: '88 Medina Highway, Medina',
          phone: '+966 14 888 0143',
          rating: 4.8,
          hours: '07:30 AM - 02:30 PM',
          isHalalCertified: true,
        ),
        HalalBusiness(
          id: 'b_3',
          category: BusinessCategory.tutor,
          name: 'Ustadh Hamza Online Tajweed & Arabic',
          description: 'Certified Al-Azhar Ijazah holder offering 1-on-1 online Quran recitation and Tajweed classes for kids and adults.',
          address: 'Online / Remote',
          phone: '+966 50 123 4567',
          rating: 5.0,
          hours: 'Flexible Hours',
          isHalalCertified: true,
        ),
        HalalBusiness(
          id: 'b_4',
          category: BusinessCategory.doctor,
          name: 'Al-Shifa Family & Pediatric Clinic',
          description: 'Compassionate, Muslim family practice clinic providing general health care, pediatrics, and preventive wellness.',
          address: '25 Olaya St, Riyadh',
          phone: '+966 11 444 0988',
          rating: 4.7,
          hours: '09:00 AM - 08:00 PM',
          isHalalCertified: true,
        ),
        HalalBusiness(
          id: 'b_5',
          category: BusinessCategory.freelancer,
          name: 'Minaret Creative Studio (Web & Branding)',
          description: 'Halal-focused web design, mobile app development, and ethical branding agency for Muslim entrepreneurs.',
          address: 'Remote / Global',
          phone: '+966 55 987 6543',
          rating: 4.9,
          hours: '09:00 AM - 06:00 PM',
          isHalalCertified: true,
        ),
      ];
      _saveDirectory();
    }
  }

  Future<void> _saveDirectory() async {
    final list = state.map((e) => e.toMap()).toList();
    await _hiveService.setValue<List>(HiveService.bookmarksBox, _directoryKey, list);
  }
}

final directoryNotifierProvider = StateNotifierProvider<DirectoryNotifier, List<HalalBusiness>>((ref) {
  return DirectoryNotifier();
});
