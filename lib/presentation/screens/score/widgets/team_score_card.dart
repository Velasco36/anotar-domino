import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/player_model.dart';

class TeamScoreCard extends StatelessWidget {
  final String teamName;
  final List<Player> players; // Lista de jugadores del equipo
  final int score;
  final Color primaryColor;
  final VoidCallback onAddPoints;
  final bool hasStarter;

  const TeamScoreCard({
    Key? key,
    required this.teamName,
    required this.players,
    required this.score,
    required this.primaryColor,
    required this.onAddPoints,
    this.hasStarter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasStarter ? primaryColor.withOpacity(0.3) : Colors.grey[200]!,
          width: hasStarter ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatares de los jugadores en fila
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mostrar avatares superpuestos
                      Stack(
                        children: List.generate(
                          players.length > 3 ? 3 : players.length,
                          (index) {
                            final player = players[index];
                            return Padding(
                              padding: EdgeInsets.only(left: index * 35.0),
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasStarter && index == 0
                                        ? primaryColor
                                        : Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      size: 28,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Badge de cámara si tiene starter
                    ],
                  ),
                ),

                // Nombres de los jugadores
              Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (int i = 0; i < players.length; i++)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Estrella amarilla solo para el primer jugador cuando hay starter
                            if (hasStarter && i == 0)
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.yellow[700],
                              ),
                            if (hasStarter && i == 0) SizedBox(width: 4),

                            // Ícono de persona
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            SizedBox(width: 4),

                            // Nombre del jugador
                            Text(
                              players[i].name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 4),

                            // Pincel para cada jugador (lado derecho)
                            Icon(Icons.edit, size: 14, color: Colors.grey[500]),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
