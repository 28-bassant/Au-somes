class LogAttemptResponse {
  final int totalCount;
  final bool isPassed;
  final int points;

  LogAttemptResponse({
    required this.totalCount,
    required this.isPassed,
    required this.points,
  });

  factory LogAttemptResponse.fromJson(
      Map<String, dynamic> json) {
    return LogAttemptResponse(
      totalCount: json["totalCount"] ?? 0,
      isPassed: json["isPassed"] ?? false,
      points: json["points"] ?? 0,
    );
  }
}