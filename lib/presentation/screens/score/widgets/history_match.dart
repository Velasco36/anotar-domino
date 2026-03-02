import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import 'partida_detail_screen.dart';
import 'ranking_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> roundHistory;
  final TeamData teamData;

  const HistoryScreen({
    Key? key,
    required this.roundHistory,
    required this.teamData,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PartidaService _partidaService = PartidaService();
  String _searchQuery = '';

  final Color primaryColor = const Color(0xFFf97316);
  final Color primaryLightColor = const Color(0xFFfff7ed);
  final Color charcoalColor = const Color(0xFF0f172a);
  final Color bgMainColor = const Color(0xFFf8fafc);
  final Color slate100 = const Color(0xFFf1f5f9);
  final Color slate400 = const Color(0xFF94a3b8);
  final Color slate500 = const Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMainColor,
      body: Column(
        children: [
          Container(
            color: Colors.white.withOpacity(0.8),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_left,
                                color: primaryColor,
                                size: 24,
                              ),
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
                          'HISTORIAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: slate400,
                            letterSpacing: 2,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RankingScreen(),
                            ),
                          ),
                          icon: Icon(
                            Icons.leaderboard,
                            color: primaryColor,
                            size: 18,
                          ),
                          label: Text(
                            'Ranking',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Buscar por jugador o equipo...',
                          hintStyle: TextStyle(fontSize: 14, color: slate400),
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
                        style: TextStyle(fontSize: 14, color: charcoalColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _partidaService.getHistorial(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_score,
                          size: 64,
                          color: slate400.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay partidas aun',
                          style: TextStyle(
                            color: slate400,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Juega tu primera partida!',
                          style: TextStyle(color: slate400, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final a = (data['equipoA'] as List).join(' ').toLowerCase();
                  final b = (data['equipoB'] as List).join(' ').toLowerCase();
                  return a.contains(_searchQuery) || b.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final equipoA = (data['equipoA'] as List).join(' & ');
                    final equipoB = (data['equipoB'] as List).join(' & ');
                    final puntajes = data['puntajes'] as Map<String, dynamic>;
                    final puntajeA = puntajes['equipoA'] as int;
                    final puntajeB = puntajes['equipoB'] as int;
                    final ganadorEsA = data['ganador'] == 'equipoA';
                    String fechaTexto = '';
                    if (data['fecha'] != null) {
                      final fecha = (data['fecha'] as Timestamp).toDate();
                      final diff = DateTime.now().difference(fecha);
                      if (diff.inDays == 0)
                        fechaTexto =
                            'Hoy, ${DateFormat('HH:mm').format(fecha)}';
                      else if (diff.inDays == 1)
                        fechaTexto =
                            'Ayer, ${DateFormat('HH:mm').format(fecha)}';
                      else
                        fechaTexto = DateFormat('dd MMM, HH:mm').format(fecha);
                    }

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PartidaDetailScreen(partida: data),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: slate100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fechaTexto,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: slate400,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: primaryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 11,
                                        color: slate400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          equipoA,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: ganadorEsA
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            color: ganadorEsA
                                                ? charcoalColor
                                                : slate500,
                                          ),
                                        ),
                                        if (ganadorEsA)
                                          Text(
                                            'GANADOR',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: primaryColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: slate100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$puntajeA',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: ganadorEsA
                                                ? primaryColor
                                                : slate400,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: slate400.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$puntajeB',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: ganadorEsA
                                                ? slate400
                                                : primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          equipoB,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: ganadorEsA
                                                ? FontWeight.w500
                                                : FontWeight.w800,
                                            color: ganadorEsA
                                                ? slate500
                                                : charcoalColor,
                                          ),
                                        ),
                                        if (!ganadorEsA)
                                          Text(
                                            'GANADOR',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: primaryColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: slate100, width: 1)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_score, color: slate400, size: 24),
                const SizedBox(height: 4),
                Text(
                  'Partida',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: slate400,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: primaryColor, size: 24),
                const SizedBox(height: 4),
                Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RankingScreen()),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, color: slate400, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Ranking',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: slate400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, color: slate400, size: 24),
                const SizedBox(height: 4),
                Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: slate400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
