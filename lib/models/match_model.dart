// match_model.dart
import 'package:uuid/uuid.dart';

class DominoMatch {
  final String id;
  final DateTime date;
  final List<Team> teams;
  final String? winningTeamId;
  final Map<String, int> scores;

  DominoMatch({
    String? id,
    required this.teams,
    this.winningTeamId,
    this.scores = const {},
  }) : id = id ?? Uuid().v4(),  // NOTA: Uuid() no es const
       date = DateTime.now();

  // Método 1: Usando try-catch
  Team? getTeamByPlayer(String playerId) {
    try {
      return teams.firstWhere(
        (team) => team.playerIds.contains(playerId),
      );
    } catch (e) {
      return null;
    }
  }

  // Método 2: Versión más explícita
  Team? getTeamByPlayer2(String playerId) {
    for (final team in teams) {
      if (team.playerIds.contains(playerId)) {
        return team;
      }
    }
    return null;
  }

  bool didPlayerWin(String playerId) {
    final team = getTeamByPlayer(playerId);
    return team != null && team.id == winningTeamId;
  }
}

// team_model.dart
class Team {
  final String id;
  final List<String> playerIds;

  Team({String? id, required this.playerIds})
    : id = id ?? Uuid().v4();  // NOTA: Uuid() no es const

  factory Team.fromPlayerIds(List<String> playerIds) {
    return Team(playerIds: playerIds);
  }

  // Métodos útiles
  bool containsPlayer(String playerId) => playerIds.contains(playerId);

  @override
  String toString() => 'Team(id: $id, players: $playerIds)';
}
