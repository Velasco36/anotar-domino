import 'package:flutter/material.dart';
import '../../../../services/partida_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final PartidaService _partidaService = PartidaService();
  String _vista = 'individual'; // 'individual' o 'grupal'

  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLightColor = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color bgMainColor = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMainColor,
      body: Column(
        children: [
          // ─── Header ───
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
                              const Icon(
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
                          'RANKING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: slate400,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 60),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Toggle individual / grupal
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _toggleBtn('INDIVIDUAL', 'individual'),
                          _toggleBtn('GRUPAL', 'grupal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Contenido ───
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: _vista == 'individual'
                  ? _partidaService.getRanking()
                  : _partidaService.getRankingGrupal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmpty();
                }

                final ranking = snapshot.data!.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ranking.length,
                  itemBuilder: (context, index) {
                    return _buildRankingItem(
                      ranking[index].key,
                      ranking[index].value,
                      index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, String value) {
    final isActive = _vista == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vista = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isActive ? primaryColor : slate500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingItem(String nombre, int victorias, int pos) {
    final isFirst = pos == 0;
    final isSecond = pos == 1;
    final isThird = pos == 2;
    final isPodio = pos < 3;

    Color medalColor = slate400;
    if (isFirst)
      medalColor = const Color(0xFFFFD700);
    else if (isSecond)
      medalColor = const Color(0xFFC0C0C0);
    else if (isThird)
      medalColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? primaryLightColor.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? primaryColor.withOpacity(0.1) : slate100,
        ),
        boxShadow: isPodio
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Posición
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPodio ? medalColor.withOpacity(0.15) : slate100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isPodio
                  ? Icon(Icons.emoji_events, size: 18, color: medalColor)
                  : Text(
                      '${pos + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: slate400,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFirst ? primaryColor.withOpacity(0.1) : slate100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 24,
              color: isFirst ? primaryColor : slate400,
            ),
          ),
          const SizedBox(width: 12),
          // Nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isFirst ? charcoalColor : charcoalColor,
                  ),
                ),
                Text(
                  '${victorias} ${victorias == 1 ? "victoria" : "victorias"}',
                  style: TextStyle(fontSize: 11, color: slate400),
                ),
              ],
            ),
          ),
          // Badge victorias
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFirst
                  ? primaryColor
                  : (isPodio ? medalColor.withOpacity(0.1) : slate100),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$victorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isFirst
                    ? Colors.white
                    : (isPodio ? medalColor : slate500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: slate400.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Sin datos de ranking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: slate400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Juega algunas partidas para ver el ranking',
            style: TextStyle(fontSize: 13, color: slate400),
          ),
        ],
      ),
    );
  }
}
