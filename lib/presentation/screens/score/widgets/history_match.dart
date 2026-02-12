import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/team_data.dart'; // Importa TeamData del modelo

// ¡ELIMINA la definición de TeamData que está al final del archivo!

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> roundHistory;
  final TeamData teamData; // Usa TeamData del modelo

  // Colores del diseño
  final Color primaryColor = const Color(0xFFf97316);
  final Color primaryDarkColor = const Color(0xFFea580c);
  final Color primaryLightColor = const Color(0xFFfff7ed);
  final Color charcoalColor = const Color(0xFF0f172a);
  final Color bgMainColor = const Color(0xFFf8fafc);
  final Color slate100 = const Color(0xFFf1f5f9);
  final Color slate400 = const Color(0xFF94a3b8);
  final Color slate500 = const Color(0xFF64748b);

  const HistoryScreen({
    Key? key,
    required this.roundHistory,
    required this.teamData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMainColor,
      body: Column(
        children: [
          // Header con search
          Container(
            color: Colors.white.withOpacity(0.8),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chevron_left,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Atrás',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'HISTORIAL DE PARTIDAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: slate400,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ), // Placeholder para centrar
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: slate100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar por jugador o equipo...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: slate400,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: slate400,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: charcoalColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ranking Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RANKING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: slate400,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: slate100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              'INDIVIDUAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'GRUPAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: slate500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Primer jugador del ranking
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryLightColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: slate100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Juan Pérez',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: charcoalColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '42',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VICTORIAS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: slate400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Segundo jugador del ranking
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: slate100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: slate100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: slate400,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pedro Gómez',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: charcoalColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '38',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: charcoalColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VICTORIAS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: slate400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Historial de partidas
          Expanded(
            child: Container(
              color: slate100,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: BoxDecoration(
                      color: slate100.withOpacity(0.95),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PARTIDAS RECIENTES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: slate500,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: _getGameHistory().length,
                      itemBuilder: (context, index) {
                        final game = _getGameHistory()[index];
                        return _buildGameCard(game, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: slate100, width: 1)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.sports_score,
              label: 'Partida',
              isActive: false,
            ),
            _buildBottomNavItem(
              icon: Icons.history,
              label: 'Historial',
              isActive: true,
            ),
            _buildBottomNavItem(
              icon: Icons.leaderboard,
              label: 'Ranking',
              isActive: false,
            ),
            _buildBottomNavItem(
              icon: Icons.settings,
              label: 'Ajustes',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game, int index) {
    final bool isWinner = game['winner'] == 'teamA';
    final String dateText = game['dateText'];
    final String teamAName = game['teamA']['name'];
    final String teamBName = game['teamB']['name'];
    final int teamAScore = game['teamA']['score'];
    final int teamBScore = game['teamB']['score'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slate100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: slate400,
                  ),
                ),
                if (isWinner)
                  Icon(Icons.emoji_events, color: primaryColor, size: 18)
                else
                  const SizedBox(width: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    teamAName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
                      color: isWinner ? charcoalColor : slate500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$teamAScore',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isWinner ? primaryColor : slate400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: slate400.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Text(
                        '$teamBScore',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isWinner ? slate400 : primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    teamBName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isWinner ? FontWeight.w500 : FontWeight.w800,
                      color: isWinner ? slate500 : charcoalColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? primaryColor : slate400, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isActive ? primaryColor : slate400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Función para generar datos de ejemplo (reemplaza con tus datos reales)
  List<Map<String, dynamic>> _getGameHistory() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastWeek = now.subtract(const Duration(days: 3));

    return [
      {
        'dateText': 'Hoy, ${DateFormat('HH:mm').format(now)}',
        'teamA': {
          'name': '${teamData.teamAPlayer1} & ${teamData.teamAPlayer2}',
          'score': 100,
        },
        'teamB': {
          'name': '${teamData.teamBPlayer1} & ${teamData.teamBPlayer2}',
          'score': 84,
        },
        'winner': 'teamA',
      },
      {
        'dateText': 'Ayer, ${DateFormat('HH:mm').format(yesterday)}',
        'teamA': {
          'name': '${teamData.teamAPlayer1} & ${teamData.teamAPlayer2}',
          'score': 76,
        },
        'teamB': {'name': 'Carlos & Ana', 'score': 100},
        'winner': 'teamB',
      },
      {
        'dateText': DateFormat('dd MMM, HH:mm').format(lastWeek),
        'teamA': {
          'name': '${teamData.teamAPlayer1} & ${teamData.teamAPlayer2}',
          'score': 102,
        },
        'teamB': {'name': 'Roberto & Lucía', 'score': 24},
        'winner': 'teamA',
      },
    ];
  }
}


