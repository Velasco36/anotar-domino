class Team {
  final String id;
  final String name;
  final int score;
  final String? avatarUrl;

  Team({required this.id, required this.name, this.score = 0, this.avatarUrl});

  Team copyWith({String? id, String? name, int? score, String? avatarUrl}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'score': score, 'avatarUrl': avatarUrl};
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      score: json['score'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
