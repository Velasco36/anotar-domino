import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import 'points_modal.dart'; // Asegúrate de importar el modal

class MatchScreen extends StatefulWidget {
  final TeamData teamData;

  const MatchScreen({Key? key, required this.teamData}) : super(key: key);

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int teamAScore = 0;
  int teamBScore = 0;
  int teamAWins = 0; // ← NUEVO: Victorias del equipo A
  int teamBWins = 0; // ← NUEVO: Victorias del equipo B
  int roundNumber = 0;
  int targetScore = 100;
  int currentTurnIndex = 0;
  List<Map<String, dynamic>> roundHistory = [];

  String getCurrentTurnPlayer() {
    final players = [
      widget.teamData.teamAPlayer1, // 0
      widget.teamData.teamBPlayer1, // 1
      widget.teamData.teamAPlayer2, // 2
      widget.teamData.teamBPlayer2, // 3
    ];

    // Encontrar el índice del jugador que sale (startingPlayerName)
    final startingPlayerIndex = players.indexOf(
      widget.teamData.startingPlayerName,
    );

    // Si encontramos al startingPlayer en la lista
    if (startingPlayerIndex != -1) {
      // Calcular el turno relativo al startingPlayer
      return players[(startingPlayerIndex + currentTurnIndex) % 4];
    }

    // Fallback (no debería pasar si startingPlayerName es válido)
    return players[currentTurnIndex % 4];
  }

  // ← NUEVO: Función para avanzar al siguiente turno
  void advanceTurn() {
    currentTurnIndex++;
  }

  // ← NUEVO: Función para verificar si alguien ganó la partida
  void _checkForWinner() {
    if (teamAScore >= targetScore) {
      _showWinnerDialog(true);
    } else if (teamBScore >= targetScore) {
      _showWinnerDialog(false);
    }
  }

  // ← NUEVO: Función para mostrar diálogo de ganador y reiniciar
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

  // ← NUEVO: Función para reiniciar la partida
  void _resetMatch() {
    setState(() {
      // Sumar victoria al equipo ganador
      if (teamAScore >= targetScore) {
        teamAWins++;
      } else if (teamBScore >= targetScore) {
        teamBWins++;
      }

      // Reiniciar todo para nueva partida
      teamAScore = 0;
      teamBScore = 0;
      roundNumber = 0;
      currentTurnIndex = 0;
      roundHistory.clear();
    });
  }

  // Función para mostrar el modal de puntos
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

        // ← NUEVO: Verificar si hay ganador después de sumar puntos
        _checkForWinner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definir colores según el diseño
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
            // Header
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

            // Starting Player Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lado izquierdo: SALIDA
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

                  // Centro: TURN (con el nombre centrado entre SALIDA y ROUND)
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

                  // Lado derecho: ROUND
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

            // Scoreboard Section - MODIFICADO PARA INCLUIR WINS
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                children: [
                  // Team A
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
                            teamAScore.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: charcoalColor,
                            ),
                          ),
                          // ← NUEVO: Wins del equipo A
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

                  // Team B
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
                            teamBScore.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: charcoalColor,
                            ),
                          ),
                          // ← NUEVO: Wins del equipo B
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

            // Round History Section
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDeleted
                          ? slate100.withOpacity(0.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isDeleted ? null : Border.all(color: slate100),
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
                        // Team A Score
                        Expanded(
                          flex: 3,
                          child: Text(
                            (round['teamAScore'] as int).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? slate400
                                  : ((round['teamAScore'] as int) > 0
                                        ? charcoalColor
                                        : slate300),
                              decoration: isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),

                        // Round Number - CENTRADO
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? slate200.withOpacity(0.5)
                                : slate100,
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
                                color: slate400,
                              ),
                            ),
                          ),
                        ),

                        // Team B Score
                        Expanded(
                          flex: 3,
                          child: Text(
                            (round['teamBScore'] as int).toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDeleted
                                  ? slate400
                                  : ((round['teamBScore'] as int) > 0
                                        ? charcoalColor
                                        : slate300),
                              decoration: isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),

                        // Delete Button
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isDeleted) {
                                // Si ya está eliminado, restaurar
                                roundHistory[index]['deleted'] = false;
                                roundNumber++;
                                advanceTurn();
                                teamAScore += round['teamAScore'] as int;
                                teamBScore += round['teamBScore'] as int;

                                // Verificar si hay ganador después de restaurar
                                _checkForWinner();
                              } else {
                                // Marcar como eliminado
                                roundHistory[index]['deleted'] = true;
                                roundHistory[index]['round'] = 0;
                                roundNumber = roundNumber - 1;
                                teamAScore -= round['teamAScore'] as int;
                                teamBScore -= round['teamBScore'] as int;
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

      // Bottom Bar
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
                // Equal Button
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

                // Goat Button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Lógica para Cabra
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
