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
  int roundNumber = 1;
  int targetScore = 100;
  List<Map<String, dynamic>> roundHistory = [
    {'teamAScore': 15, 'teamBScore': 0, 'round': 4, 'deleted': true},
  ];

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
                            'Salida',
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Round',
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

            // Scoreboard Section - MODIFICADO PARA USAR EL MODAL
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
              child: Container(
                color: const Color(0xFFf8fafc),
                child: Column(
                  children: [
                    // History Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8fafc).withOpacity(0.95),
                        border: Border(
                          bottom: BorderSide(color: slate200.withOpacity(0.5)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tabla de Rondas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: slate500,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // History List
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
                              border: isDeleted
                                  ? null
                                  : Border.all(color: slate100),
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
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
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

                                // Round Number
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDeleted
                                        ? slate200.withOpacity(0.5)
                                        : slate100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (round['round'] as int).toString(),
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
                               SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        (round['teamBScore'] as int).toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDeleted
                                              ? slate400
                                              : ((round['teamBScore'] as int) >
                                                        0
                                                    ? charcoalColor
                                                    : slate300),
                                          decoration: isDeleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (isDeleted) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ],
                                    ],
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
                  // Equal Button - MODIFICADO
                  Expanded(
                    child: TextButton(
                onPressed: () {
          setState(() {
            if (teamAScore == teamBScore) {
              // Si ya son iguales, registrar 0-0 en el historial
              roundHistory.insert(0, {
                'teamAScore': 0,
                'teamBScore': 0,
                'round': roundNumber + 1,
              });
              // Incrementar el número de ronda
              roundNumber++;
            } else {

              // Registrar la diferencia en el historial ANTES de igualar
              roundHistory.insert(0, {
                'teamAScore': 0,
                'teamBScore': 0,
                'round': roundNumber + 1,
              });

              // Ahora igualar los marcadores
              if (teamAScore > teamBScore) {
                teamBScore += 0;
              } else {
                teamAScore += 0;
              }

              // Incrementar el número de ronda
              roundNumber++;
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

          const SizedBox(width: 8),

          // Delete Button
    // Delete Button
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (roundHistory.isNotEmpty) {
                        setState(() {
                          final lastRound = roundHistory.first;
                          final teamAPoints = lastRound['teamAScore'] as int;
                          final teamBPoints = lastRound['teamBScore'] as int;

                          // Verificar si fue una ronda de "igualar"
                          // Si ambos tienen la misma cantidad de puntos en el historial
                          if (teamAPoints == teamBPoints && teamAPoints > 0) {
                            // Fue una ronda donde se igualaron los marcadores
                            // Necesitamos revertir la igualación
                            if (teamAScore > teamBScore) {
                              // Team A tenía más puntos antes
                              teamBScore -= teamAPoints;
                            } else if (teamBScore > teamAScore) {
                              // Team B tenía más puntos antes
                              teamAScore -= teamBPoints;
                            }
                            // Si son iguales, no hacer nada con los marcadores
                          } else {
                            // Fue una ronda normal, solo restar los puntos
                            teamAScore -= teamAPoints;
                            teamBScore -= teamBPoints;
                          }

                          roundHistory.removeAt(0);
                          roundNumber--;
                        });
                      }
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
                        const Icon(Icons.delete, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Eliminar',
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
