class ProgressSummaryResponse {
  final int achievementPoints;
  final double totalPercentage;
  final int totalPhasesCount;
  final int passedPhaseCount;

  final double spatialActivities;
  final double spatialRelation;
  final double visualRelation;

  ProgressSummaryResponse({
    required this.achievementPoints,
    required this.totalPercentage,
    required this.totalPhasesCount,
    required this.passedPhaseCount,
    required this.spatialActivities,
    required this.spatialRelation,
    required this.visualRelation,
  });

  factory ProgressSummaryResponse.fromJson(Map<String, dynamic> json) {
    final cat = json['categoriesPercentages'] ?? {};

    return ProgressSummaryResponse(
      totalPercentage: (json['totalPercentage'] ?? 0).toDouble(),
      passedPhaseCount: json['passedPhaseCount'] ?? 0,
      totalPhasesCount: json['totalPhasesCount'] ?? 0,
      achievementPoints: json['achievementPoints'] ?? 0,

      spatialActivities: (cat['spatialActivities'] ?? 0).toDouble(),
      spatialRelation: (cat['spatialRelation'] ?? 0).toDouble(),
      visualRelation: (cat['visualRelation'] ?? 0).toDouble(),
    );
  }
}