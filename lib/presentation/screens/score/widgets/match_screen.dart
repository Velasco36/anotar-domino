import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import 'points_modal.dart';
import 'penalty_modal_updated.dart';

class MatchScreen extends StatefulWidget {
  final TeamData teamData;

  const MatchScreen({Key? key, required this.teamData}) : super(key: key);

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int teamAScore = 0;
  int teamBScore = 0;
  int teamAWins = 0;
  int teamBWins = 0;
  int roundNumber = 0;
  int targetScore = 100;
  int currentTurnIndex = 0;
  List<Map<String, dynamic>> roundHistory = [];

  String getCurrentTurnPlayer() {
    final players = [
      widget.teamData.teamAPlayer1,
      widget.teamData.teamBPlayer1,
      widget.teamData.teamAPlayer2,
      widget.teamData.teamBPlayer2,
    ];

    final startingPlayerIndex = players.indexOf(
      widget.teamData.startingPlayerName,
    );

    if (startingPlayerIndex != -1) {
      return players[(startingPlayerIndex + currentTurnIndex) % 4];
    }

    return players[currentTurnIndex % 4];
  }

  void advanceTurn() {
    currentTurnIndex++;
  }

  void _checkForWinner() {
    final teamATotal = _calculateTeamAScore();
    final teamBTotal = _calculateTeamBScore();

    if (teamATotal >= targetScore) {
      _showWinnerDialog(true);
    } else if (teamBTotal >= targetScore) {
      _showWinnerDialog(false);
    }
  }

  int _calculateTeamAScore() {
    int total = 0;
    for (var round in roundHistory) {
      if (round['deleted'] != true) {
        final points = round['teamAScore'] as int;
        total += points;
      }
    }
    return total;
  }

  int _calculateTeamBScore() {
    int total = 0;
    for (var round in roundHistory) {
      if (round['deleted'] != true) {
        final points = round['teamBScore'] as int;
        total += points;
      }
    }
    return total;
  }

  Future<void> _showWinnerDialog(bool isTeamA) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¡Partida Ganada!',
            style: TextStyle(
              color: const Color(0xFFf97316),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${isTeamA ? '${widget.teamData.teamAPlayer1} & ${widget.teamData.teamAPlayer2}' : '${widget.teamData.teamBPlayer1} & ${widget.teamData.teamBPlayer2}'} han ganado esta partida.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetMatch();
              },
              child: const Text(
                'Nueva Partida',
                style: TextStyle(
                  color: Color(0xFFf97316),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetMatch() {
    setState(() {
      if (teamAScore >= targetScore) {
        teamAWins++;
      } else if (teamBScore >= targetScore) {
        teamBWins++;
      }

      teamAScore = 0;
      teamBScore = 0;
      roundNumber = 0;
      currentTurnIndex = 0;
      roundHistory.clear();
    });
  }

  Future<void> _showPointsModal(bool isTeamA) async {
    final points = await showPointsModal(
      context,
      teamName: isTeamA
          ? '${widget.teamData.teamAPlayer1} & ${widget.teamData.teamAPlayer2}'
          : '${widget.teamData.teamBPlayer1} & ${widget.teamData.teamBPlayer2}',
      accentColor: const Color(0xFFf97316),
    );

    if (points != null && points > 0) {
      setState(() {
        if (isTeamA) {
          teamAScore += points;
          roundHistory.insert(0, {
            'teamAScore': points,
            'teamBScore': 0,
            'round': roundNumber + 1,
          });
        } else {
          teamBScore += points;
          roundHistory.insert(0, {
            'teamAScore': 0,
            'teamBScore': points,
            'round': roundNumber + 1,
          });
        }
        roundNumber++;
        advanceTurn();
        _checkForWinner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFf97316);
    const Color primaryDarkColor = Color(0xFFea580c);
    const Color primaryLightColor = Color(0xFFfff7ed);
    const Color charcoalColor = Color(0xFF0f172a);
    const Color bgMainColor = Color(0xFFf8fafc);
    const Color slate100 = Color(0xFFf1f5f9);
    const Color slate200 = Color(0xFFe2e8f0);
    const Color slate300 = Color(0xFFcbd5e1);
    const Color slate400 = Color(0xFF94a3b8);
    const Color slate500 = Color(0xFF64748b);

    return Scaffold(
      backgroundColor: bgMainColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 40,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryLightColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Target: $targetScore',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 14, color: primaryColor),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALIDA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: slate400,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            widget.teamData.startingPlayerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: charcoalColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'TURN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: slate400,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            getCurrentTurnPlayer(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ROUND',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: slate400,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '#$roundNumber',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: slate100)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.teamData.teamAPlayer1} & ${widget.teamData.teamAPlayer2}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: slate400,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateTeamAScore().toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'wins',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: slate400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  teamAWins.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => _showPointsModal(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: primaryColor.withOpacity(0.15),
                              ),
                              child: const Icon(Icons.add, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '${widget.teamData.teamBPlayer1} & ${widget.teamData.teamBPlayer2}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: slate400,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateTeamBScore().toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'wins',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: slate400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  teamBWins.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => _showPointsModal(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: primaryColor.withOpacity(0.15),
                              ),
                              child: const Icon(Icons.add, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: roundHistory.length,
                itemBuilder: (context, index) {
                  final round = roundHistory[index];
                  final isDeleted = round['deleted'] == true;
                  final isPenalty = round['penalty'] == true;
                  final teamAScoreValue = round['teamAScore'] as int;
                  final teamBScoreValue = round['teamBScore'] as int;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDeleted
                          ? slate100.withOpacity(0.4)
                          : (isPenalty ? Color(0xFFFFF5F5) : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: isDeleted
                          ? null
                          : Border.all(
                              color: isPenalty
                                  ? Colors.red.withOpacity(0.2)
                                  : slate100,
                            ),
                      boxShadow: isDeleted
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            teamAScoreValue.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? slate400
                                  : (isPenalty && teamAScoreValue < 0
                                        ? Colors.red
                                        : (teamAScoreValue > 0
                                              ? charcoalColor
                                              : slate300)),
                              decoration: isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),

                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? slate200.withOpacity(0.5)
                                : (isPenalty
                                      ? Colors.red.withOpacity(0.1)
                                      : slate100),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              isDeleted
                                  ? '0'
                                  : (round['round'] as int).toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isDeleted
                                    ? FontWeight.bold
                                    : FontWeight.w900,
                                color: isPenalty ? Colors.red : slate400,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            teamBScoreValue.toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? slate400
                                  : (isPenalty && teamBScoreValue < 0
                                        ? Colors.red
                                        : (teamBScoreValue > 0
                                              ? charcoalColor
                                              : slate300)),
                              decoration: isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isDeleted) {
                                roundHistory[index]['deleted'] = false;
                                roundNumber++;
                                advanceTurn();

                                if (isPenalty) {
                                  teamAScore += teamAScoreValue;
                                  teamBScore += teamBScoreValue;
                                } else {
                                  teamAScore -= teamAScoreValue;
                                  teamBScore -= teamBScoreValue;
                                }

                                _checkForWinner();
                              } else {
                                roundHistory[index]['deleted'] = true;
                                roundHistory[index]['round'] = 0;
                                roundNumber = roundNumber - 1;

                                if (isPenalty) {
                                  teamAScore += teamAScoreValue;
                                  teamBScore += teamBScoreValue;
                                } else {
                                  teamAScore -= teamAScoreValue;
                                  teamBScore -= teamBScoreValue;
                                }
                              }
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDeleted
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isDeleted ? Icons.restore : Icons.delete_outline,
                              size: 16,
                              color: isDeleted ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: slate100, width: 1)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (teamAScore == teamBScore) {
                          roundHistory.insert(0, {
                            'teamAScore': 0,
                            'teamBScore': 0,
                            'round': roundNumber + 1,
                          });
                          roundNumber++;
                          advanceTurn();
                        } else {
                          roundHistory.insert(0, {
                            'teamAScore': 0,
                            'teamBScore': 0,
                            'round': roundNumber + 1,
                          });
                          roundNumber++;
                          advanceTurn();
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: slate100,
                      foregroundColor: slate500,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.drag_handle, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Iguales',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final result = await showPenaltyModal(
                        context,
                        teamAName:
                            '${widget.teamData.teamAPlayer1} & ${widget.teamData.teamAPlayer2}',
                        teamBName:
                            '${widget.teamData.teamBPlayer1} & ${widget.teamData.teamBPlayer2}',
                        teamAScore: _calculateTeamAScore(),
                        teamBScore: _calculateTeamBScore(),
                        accentColor: primaryColor,
                      );

                      if (result != null) {
                        setState(() {
                          final penalty = result['penalty'] as int;
                          final team = result['team'] as String;

                          final String penaltyPlayer = team == 'A'
                              ? '${widget.teamData.teamAPlayer1} & ${widget.teamData.teamAPlayer2}'
                              : '${widget.teamData.teamBPlayer1} & ${widget.teamData.teamBPlayer2}';

                          roundHistory.insert(0, {
                            'teamAScore': team == 'A' ? -penalty : 0,
                            'teamBScore': team == 'B' ? -penalty : 0,
                            'round': roundNumber + 1,
                            'penalty': true,
                            'deleted': false,
                            'penaltyPlayer': penaltyPlayer,
                            'penaltyTeam': team,
                          });

                          roundNumber++;
                          advanceTurn();
                          _checkForWinner();
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: primaryLightColor,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: primaryColor.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pets, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Cabra',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
