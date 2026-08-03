enum BusinessCategory {
  restaurant,
  tutor,
  doctor,
  freelancer,
  islamicSchool,
}

class HalalBusiness {
  final String id;
  final BusinessCategory category;
  final String name;
  final String description;
  final String address;
  final String phone;
  final double rating;
  final String hours;
  final bool isHalalCertified;

  HalalBusiness({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.rating,
    required this.hours,
    this.isHalalCertified = true,
  });

  String get categoryLabel {
    switch (category) {
      case BusinessCategory.restaurant:
        return 'Halal Restaurant';
      case BusinessCategory.tutor:
        return 'Quran & Academic Tutor';
      case BusinessCategory.doctor:
        return 'Muslim Doctor / Clinic';
      case BusinessCategory.freelancer:
        return 'Professional Freelancer';
      case BusinessCategory.islamicSchool:
        return 'Islamic Academy / School';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'rating': rating,
      'hours': hours,
      'isHalalCertified': isHalalCertified,
    };
  }

  factory HalalBusiness.fromMap(Map<dynamic, dynamic> map) {
    final catString = map['category'] ?? 'restaurant';
    final category = BusinessCategory.values.firstWhere(
      (e) => e.name == catString,
      orElse: () => BusinessCategory.restaurant,
    );

    return HalalBusiness(
      id: map['id'] ?? '',
      category: category,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      hours: map['hours'] ?? '09:00 AM - 09:00 PM',
      isHalalCertified: map['isHalalCertified'] ?? true,
    );
  }
}
