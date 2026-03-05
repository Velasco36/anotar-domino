import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLightColor = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color bgMainColor = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  String _searchQuery = '';
  List<String> _todosLosJugadores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('jugadores')
          .doc(uid)
          .get();

      if (doc.exists) {
        final nombres = List<String>.from(doc.data()?['nombres'] ?? []);
        setState(() {
          _todosLosJugadores = nombres;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>> _getEstadisticasJugador(String nombre) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('partidas')
        .get();

    int victorias = 0;
    int derrotas = 0;
    int totalPartidas = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final equipoA = List<String>.from(data['equipoA'] ?? []);
      final equipoB = List<String>.from(data['equipoB'] ?? []);
      final ganador = data['ganador'] as String;

      final estaEnA = equipoA.contains(nombre);
      final estaEnB = equipoB.contains(nombre);

      if (estaEnA || estaEnB) {
        totalPartidas++;
        if ((estaEnA && ganador == 'equipoA') ||
            (estaEnB && ganador == 'equipoB')) {
          victorias++;
        } else {
          derrotas++;
        }
      }
    }

    return {
      'victorias': victorias,
      'derrotas': derrotas,
      'totalPartidas': totalPartidas,
      'winRate': totalPartidas > 0
          ? (victorias / totalPartidas * 100).toStringAsFixed(0)
          : '0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final jugadoresFiltrados = _todosLosJugadores
        .where((j) => j.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JUGADORES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: slate400,
                            letterSpacing: 2,
                          ),
                        ),
                        // Total jugadores
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLightColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_todosLosJugadores.length} jugadores',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Buscador
                    Container(
                      decoration: BoxDecoration(
                        color: slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Buscar jugador...',
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

          // ─── Lista de jugadores ───
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : jugadoresFiltrados.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _cargarJugadores,
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jugadoresFiltrados.length,
                      itemBuilder: (context, index) {
                        final nombre = jugadoresFiltrados[index];
                        return _buildJugadorCard(nombre, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJugadorCard(String nombre, int index) {
    // Color del avatar basado en inicial
    final colores = [
      primaryColor,
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
    ];
    final colorAvatar = colores[index % colores.length];
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _mostrarDetalle(nombre),
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
          child: Row(
            children: [
              // Avatar con inicial
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorAvatar.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colorAvatar,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Nombre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: charcoalColor,
                      ),
                    ),
                    Text(
                      'Toca para ver estadísticas',
                      style: TextStyle(fontSize: 11, color: slate400),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: slate400),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(String nombre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JugadorDetalleSheet(nombre: nombre),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 64,
            color: slate400.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay jugadores aún',
            style: TextStyle(
              color: slate400,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los jugadores aparecen cuando juegas partidas',
            style: TextStyle(color: slate400, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet con estadísticas del jugador ───
class _JugadorDetalleSheet extends StatefulWidget {
  final String nombre;
  const _JugadorDetalleSheet({required this.nombre});

  @override
  State<_JugadorDetalleSheet> createState() => _JugadorDetalleSheetState();
}

class _JugadorDetalleSheetState extends State<_JugadorDetalleSheet> {
  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLightColor = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);

  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('partidas')
        .get();

    int victorias = 0;
    int derrotas = 0;
    int totalPartidas = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final equipoA = List<String>.from(data['equipoA'] ?? []);
      final equipoB = List<String>.from(data['equipoB'] ?? []);
      final ganador = data['ganador'] as String;
      final estaEnA = equipoA.contains(widget.nombre);
      final estaEnB = equipoB.contains(widget.nombre);

      if (estaEnA || estaEnB) {
        totalPartidas++;
        if ((estaEnA && ganador == 'equipoA') ||
            (estaEnB && ganador == 'equipoB')) {
          victorias++;
        } else {
          derrotas++;
        }
      }
    }

    setState(() {
      _stats = {
        'victorias': victorias,
        'derrotas': derrotas,
        'totalPartidas': totalPartidas,
        'winRate': totalPartidas > 0
            ? (victorias / totalPartidas * 100).toStringAsFixed(0)
            : '0',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final inicial = widget.nombre.isNotEmpty
        ? widget.nombre[0].toUpperCase()
        : '?';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: slate100,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Avatar grande
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            widget.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: charcoalColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jugador registrado',
            style: TextStyle(fontSize: 13, color: slate400),
          ),
          const SizedBox(height: 24),

          // Stats
          if (_stats == null)
            const CircularProgressIndicator(color: primaryColor)
          else
            Row(
              children: [
                _statBox(
                  'PARTIDAS',
                  '${_stats!['totalPartidas']}',
                  Icons.sports_score,
                ),
                const SizedBox(width: 10),
                _statBox(
                  'VICTORIAS',
                  '${_stats!['victorias']}',
                  Icons.emoji_events,
                  color: primaryColor,
                ),
                const SizedBox(width: 10),
                _statBox('WIN RATE', '${_stats!['winRate']}%', Icons.bar_chart),
              ],
            ),
          const SizedBox(height: 24),

          // Botón cerrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'CERRAR',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color != null ? color.withOpacity(0.08) : slate100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? slate400),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color ?? charcoalColor,
              ),
            ),
            const SizedBox(height: 2),
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
