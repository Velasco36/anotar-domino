class TeamData {
  final String teamAPlayer1;
  final String teamAPlayer2;
  final String teamBPlayer1;
  final String teamBPlayer2;
  final String startingPlayerId;
  final String startingPlayerName;

  TeamData({
    String? teamAPlayer1,
    String? teamAPlayer2,
    String? teamBPlayer1,
    String? teamBPlayer2,
    String? startingPlayerId,
    String? startingPlayerName,
  })  : teamAPlayer1 = teamAPlayer1 ?? '',
        teamAPlayer2 = teamAPlayer2 ?? '',
        teamBPlayer1 = teamBPlayer1 ?? '',
        teamBPlayer2 = teamBPlayer2 ?? '',
        startingPlayerId = startingPlayerId ?? '',
        startingPlayerName = startingPlayerName ?? '';
}
