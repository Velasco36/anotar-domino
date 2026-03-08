import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/partida_service.dart';

class RankingTab extends StatefulWidget {
  const RankingTab({Key? key}) : super(key: key);

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PartidaService _partidaService = PartidaService();
  String _vista = 'individual'; // 'individual' | 'grupal'

  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLightColor = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  // ✅ Calcula el ranking individual desde los docs del stream
  Map<String, int> _calcularRankingIndividual(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, int> victorias = {};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ganador = data['ganador'] as String;
      final List<String> ganadores = ganador == 'equipoA'
          ? List<String>.from(data['equipoA'] ?? [])
          : List<String>.from(data['equipoB'] ?? []);
      for (final jugador in ganadores) {
        victorias[jugador] = (victorias[jugador] ?? 0) + 1;
      }
    }
    return victorias;
  }

  // ✅ Calcula el ranking grupal desde los docs del stream
  Map<String, int> _calcularRankingGrupal(List<QueryDocumentSnapshot> docs) {
    final Map<String, int> victorias = {};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ganador = data['ganador'] as String;
      final List<String> equipo = ganador == 'equipoA'
          ? List<String>.from(data['equipoA'] ?? [])
          : List<String>.from(data['equipoB'] ?? []);
      final nombreEquipo = equipo.join(' & ');
      victorias[nombreEquipo] = (victorias[nombreEquipo] ?? 0) + 1;
    }
    return victorias;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // ─── Toggle individual / grupal ───
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
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
        ),

        // ✅ StreamBuilder — reacciona automáticamente a cambios en el historial
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _partidaService.getHistorial(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmpty();
              }

              final docs = snapshot.data!.docs;

              final rankingMap = _vista == 'individual'
                  ? _calcularRankingIndividual(docs)
                  : _calcularRankingGrupal(docs);

              if (rankingMap.isEmpty) return _buildEmpty();

              final ranking = rankingMap.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
    );
  }

  Widget _toggleBtn(String label, String value) {
    final isActive = _vista == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vista = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
    final isPodio = pos < 3;

    Color medalColor = slate400;
    if (pos == 0) medalColor = const Color(0xFFFFD700);
    if (pos == 1) medalColor = const Color(0xFFC0C0C0);
    if (pos == 2) medalColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pos == 0 ? primaryLightColor.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pos == 0 ? primaryColor.withOpacity(0.1) : slate100,
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
          // Medalla / posición
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
              color: pos == 0 ? primaryColor.withOpacity(0.1) : slate100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 24,
              color: pos == 0 ? primaryColor : slate400,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre y victorias
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: charcoalColor,
                  ),
                ),
                Text(
                  '$victorias ${victorias == 1 ? "victoria" : "victorias"}',
                  style: TextStyle(fontSize: 11, color: slate400),
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pos == 0
                  ? primaryColor
                  : (isPodio ? medalColor.withOpacity(0.1) : slate100),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$victorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: pos == 0
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
          Icon(Icons.leaderboard, size: 64, color: slate400.withOpacity(0.4)),
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
