enum MatchResult { teamAlpha, teamBravo, tie }

class Match {
  final int matchNumber;
  final int points;
  final MatchResult result;
  final bool isDeleted;
  final DateTime timestamp;

  Match({
    required this.matchNumber,
    required this.points,
    required this.result,
    this.isDeleted = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Match copyWith({
    int? matchNumber,
    int? points,
    MatchResult? result,
    bool? isDeleted,
    DateTime? timestamp,
  }) {
    return Match(
      matchNumber: matchNumber ?? this.matchNumber,
      points: points ?? this.points,
      result: result ?? this.result,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchNumber': matchNumber,
      'points': points,
      'result': result.toString(),
      'isDeleted': isDeleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchNumber: json['matchNumber'] as int,
      points: json['points'] as int,
      result: MatchResult.values.firstWhere(
        (e) => e.toString() == json['result'],
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
