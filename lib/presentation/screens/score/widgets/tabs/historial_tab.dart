import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/partida_service.dart';
import '../partida_detail_screen.dart';

class HistorialTab extends StatefulWidget {
  const HistorialTab({Key? key}) : super(key: key);

  @override
  State<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<HistorialTab>
    with AutomaticKeepAliveClientMixin {
  // ✅ keepAlive evita que el tab se reconstruya cada vez que cambias de tab
  @override
  bool get wantKeepAlive => true;

  final PartidaService _partidaService = PartidaService();
  String _searchQuery = '';

  static const Color primaryColor = Color(0xFFf97316);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color bgMainColor = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // ─── Buscador ───
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: slate200),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar por jugador o equipo...',
                hintStyle: TextStyle(fontSize: 14, color: slate400),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: slate400, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              style: TextStyle(fontSize: 14, color: charcoalColor),
            ),
          ),
        ),

        // ─── Lista ───
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

              final docs = snapshot.data!.docs.where((doc) {
                if (_searchQuery.isEmpty) return true;
                final data = doc.data() as Map<String, dynamic>;
                final a = (data['equipoA'] as List).join(' ').toLowerCase();
                final b = (data['equipoB'] as List).join(' ').toLowerCase();
                return a.contains(_searchQuery) || b.contains(_searchQuery);
              }).toList();

              if (docs.isEmpty) {
                return _buildEmpty(
                  mensaje: 'Sin resultados para "$_searchQuery"',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildPartidaCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartidaCard(Map<String, dynamic> data) {
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
        fechaTexto = 'Hoy, ${DateFormat('HH:mm').format(fecha)}';
      else if (diff.inDays == 1)
        fechaTexto = 'Ayer, ${DateFormat('HH:mm').format(fecha)}';
      else
        fechaTexto = DateFormat('dd MMM, HH:mm').format(fecha);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PartidaDetailScreen(partida: data)),
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
              // Fecha y flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icon(Icons.emoji_events, color: primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 11, color: slate400),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Equipos y marcador
              Row(
                children: [
                  // Equipo A
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          equipoA,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: ganadorEsA
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: ganadorEsA ? charcoalColor : slate500,
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

                  // Marcador
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
                            color: ganadorEsA ? primaryColor : slate400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
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
                            color: ganadorEsA ? slate400 : primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Equipo B
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipoB,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: ganadorEsA
                                ? FontWeight.w500
                                : FontWeight.w800,
                            color: ganadorEsA ? slate500 : charcoalColor,
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
  }

  Widget _buildEmpty({String? mensaje}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_score, size: 64, color: slate400.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            mensaje ?? 'No hay partidas aún',
            style: TextStyle(
              color: slate400,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Juega tu primera partida!',
            style: TextStyle(color: slate400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
