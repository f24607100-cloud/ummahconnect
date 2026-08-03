enum CharityCause {
  mosque,
  orphan,
  foodDrive,
  emergencyRelief,
}

class CharityCampaign {
  final String id;
  final CharityCause cause;
  final String title;
  final String description;
  final String organization;
  final double targetAmount;
  final double raisedAmount;
  final int donorsCount;

  CharityCampaign({
    required this.id,
    required this.cause,
    required this.title,
    required this.description,
    required this.organization,
    required this.targetAmount,
    required this.raisedAmount,
    this.donorsCount = 0,
  });

  double get percentRaised {
    if (targetAmount == 0) return 0.0;
    final pct = raisedAmount / targetAmount;
    return pct > 1.0 ? 1.0 : pct;
  }

  String get causeLabel {
    switch (cause) {
      case CharityCause.mosque:
        return 'Mosque Support';
      case CharityCause.orphan:
        return 'Orphan Care';
      case CharityCause.foodDrive:
        return 'Food Drive';
      case CharityCause.emergencyRelief:
        return 'Emergency Relief';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cause': cause.name,
      'title': title,
      'description': description,
      'organization': organization,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'donorsCount': donorsCount,
    };
  }

  factory CharityCampaign.fromMap(Map<dynamic, dynamic> map) {
    final causeString = map['cause'] ?? 'mosque';
    final cause = CharityCause.values.firstWhere(
      (e) => e.name == causeString,
      orElse: () => CharityCause.mosque,
    );

    return CharityCampaign(
      id: map['id'] ?? '',
      cause: cause,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      organization: map['organization'] ?? 'Verified Islamic Relief',
      targetAmount: (map['targetAmount'] ?? 1000.0).toDouble(),
      raisedAmount: (map['raisedAmount'] ?? 0.0).toDouble(),
      donorsCount: map['donorsCount'] ?? 0,
    );
  }

  CharityCampaign copyWith({
    double? raisedAmount,
    int? donorsCount,
  }) {
    return CharityCampaign(
      id: id,
      cause: cause,
      title: title,
      description: description,
      organization: organization,
      targetAmount: targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      donorsCount: donorsCount ?? this.donorsCount,
    );
  }
}
