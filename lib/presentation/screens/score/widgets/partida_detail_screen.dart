import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartidaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> partida;

  const PartidaDetailScreen({Key? key, required this.partida})
    : super(key: key);

  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLightColor = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color bgMainColor = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    final equipoA = (partida['equipoA'] as List).cast<String>();
    final equipoB = (partida['equipoB'] as List).cast<String>();
    final puntajes = partida['puntajes'] as Map<String, dynamic>;
    final puntajeA = puntajes['equipoA'] as int;
    final puntajeB = puntajes['equipoB'] as int;
    final ganador = partida['ganador'] as String;
    final ganadorEsA = ganador == 'equipoA';
    final rounds = partida['rounds'] ?? 0;
    final targetScore = partida['targetScore'] ?? 100;

    // Fecha
    String fechaTexto = '';
    if (partida['fecha'] != null) {
      final fecha = (partida['fecha'] as Timestamp).toDate();
      fechaTexto = DateFormat('dd MMM yyyy, HH:mm').format(fecha);
    }

    final nombreEquipoA = equipoA.join(' & ');
    final nombreEquipoB = equipoB.join(' & ');
    final nombreGanador = ganadorEsA ? nombreEquipoA : nombreEquipoB;

    return Scaffold(
      backgroundColor: bgMainColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
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
                  Column(
                    children: [
                      Text(
                        'PARTIDA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: slate400,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        fechaTexto,
                        style: TextStyle(fontSize: 10, color: slate400),
                      ),
                    ],
                  ),
                  // Badge solo lectura
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: slate100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 10, color: slate400),
                        const SizedBox(width: 4),
                        Text(
                          'Solo lectura',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info turno (decorativo, no interactivo) ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ganador
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GANADOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: slate400,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            nombreGanador,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: charcoalColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Puntos objetivo
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
                    child: Text(
                      'Puntos: $targetScore',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Rondas
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'RONDAS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: slate400,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '#$rounds',
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

            // ─── Marcador final ───
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: slate100, width: 1)),
              ),
              child: Row(
                children: [
                  // Equipo A
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: slate100)),
                        color: ganadorEsA
                            ? primaryLightColor.withOpacity(0.3)
                            : Colors.white,
                      ),
                      child: Column(
                        children: [
                          if (ganadorEsA)
                            const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                          Text(
                            nombreEquipoA,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ganadorEsA ? primaryColor : slate400,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$puntajeA',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: ganadorEsA ? primaryColor : charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Jugadores
                          ...equipoA.map(
                            (jugador) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 12, color: slate400),
                                  const SizedBox(width: 2),
                                  Text(
                                    jugador,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Equipo B
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !ganadorEsA
                            ? primaryLightColor.withOpacity(0.3)
                            : Colors.white,
                      ),
                      child: Column(
                        children: [
                          if (!ganadorEsA)
                            const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                          Text(
                            nombreEquipoB,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: !ganadorEsA ? primaryColor : slate400,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$puntajeB',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: !ganadorEsA ? primaryColor : charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...equipoB.map(
                            (jugador) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 12, color: slate400),
                                  const SizedBox(width: 2),
                                  Text(
                                    jugador,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Lista de rondas (solo lectura) ───
            Expanded(child: _buildRoundsList()),
          ],
        ),
      ),

      // ─── Botón Aceptar ───
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border(top: BorderSide(color: slate100, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ACEPTAR',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundsList() {
    // Si hay rondas guardadas las muestra, si no muestra un resumen
    final roundsData = partida['roundsData'] as List<dynamic>?;

    if (roundsData == null || roundsData.isEmpty) {
      // Sin detalle de rondas, muestra resumen visual
      return _buildResumenVisual();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: roundsData.length,
      itemBuilder: (context, index) {
        final round = roundsData[index] as Map<String, dynamic>;
        final isDeleted = round['deleted'] == true;
        final isPenalty = round['penalty'] == true;
        final teamAScore = round['teamAScore'] as int;
        final teamBScore = round['teamBScore'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDeleted
                ? slate100.withOpacity(0.4)
                : (isPenalty ? const Color(0xFFFFF5F5) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: isDeleted
                ? null
                : Border.all(
                    color: isPenalty ? Colors.red.withOpacity(0.2) : slate100,
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '$teamAScore',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDeleted
                        ? slate400
                        : (isPenalty && teamAScore < 0
                              ? Colors.red
                              : (teamAScore > 0 ? charcoalColor : slate300)),
                    decoration: isDeleted ? TextDecoration.lineThrough : null,
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
                      : (isPenalty ? Colors.red.withOpacity(0.1) : slate100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    isDeleted ? '✕' : '${round['round'] ?? index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isPenalty ? Colors.red : slate400,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '$teamBScore',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDeleted
                        ? slate400
                        : (isPenalty && teamBScore < 0
                              ? Colors.red
                              : (teamBScore > 0 ? charcoalColor : slate300)),
                    decoration: isDeleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Sin botón de eliminar - solo lectura
              const SizedBox(width: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumenVisual() {
    final puntajes = partida['puntajes'] as Map<String, dynamic>;
    final puntajeA = puntajes['equipoA'] as int;
    final puntajeB = puntajes['equipoB'] as int;
    final rounds = partida['rounds'] ?? 0;
    final ganador = partida['ganador'] as String;
    final ganadorEsA = ganador == 'equipoA';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 40, color: slate300),
            const SizedBox(height: 12),
            Text(
              'Resumen de la partida',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: slate500,
              ),
            ),
            const SizedBox(height: 24),
            // Stats cards
            Row(
              children: [
                _statCard('RONDAS\nJUGADAS', '$rounds', Icons.repeat),
                const SizedBox(width: 12),
                _statCard(
                  'DIFERENCIA',
                  '${(puntajeA - puntajeB).abs()} pts',
                  Icons.bar_chart,
                ),
                const SizedBox(width: 12),
                _statCard(
                  'RESULTADO',
                  ganadorEsA ? 'A ganó' : 'B ganó',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: slate100),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: charcoalColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: slate400,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
