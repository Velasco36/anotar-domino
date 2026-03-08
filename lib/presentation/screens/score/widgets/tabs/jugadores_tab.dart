import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JugadoresTab extends StatefulWidget {
  const JugadoresTab({Key? key}) : super(key: key);

  @override
  State<JugadoresTab> createState() => _JugadoresTabState();
}

class _JugadoresTabState extends State<JugadoresTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLight = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
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
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ✅ Eliminar jugador de Firestore
  Future<void> _eliminarJugador(String nombre) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar jugador',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: charcoalColor,
          ),
        ),
        content: Text(
          '¿Eliminar a "$nombre" de la lista? Sus partidas no se verán afectadas.',
          style: TextStyle(fontSize: 13, color: slate500),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    backgroundColor: slate100,
                    foregroundColor: slate500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFef4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _todosLosJugadores.remove(nombre));
      await FirebaseFirestore.instance.collection('jugadores').doc(uid).update({
        'nombres': _todosLosJugadores,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Jugador eliminado',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF22c55e),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final filtrados = _todosLosJugadores
        .where((j) => j.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // ─── Buscador + contador ───
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: slate200),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar jugador...',
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
              const SizedBox(width: 10),
              // Contador de jugadores
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_todosLosJugadores.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── Lista ───
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : filtrados.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _cargarJugadores,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) =>
                        _buildJugadorCard(filtrados[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildJugadorCard(String nombre) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    // ✅ Swipe para eliminar
    return Dismissible(
      key: Key(nombre),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _eliminarJugador(nombre);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFef4444),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
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
                // ✅ Avatar solo en primaryColor
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
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

                // ✅ Botón eliminar visible en la card
                GestureDetector(
                  onTap: () => _eliminarJugador(nombre),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFef4444).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFef4444),
                    ),
                  ),
                ),

                Icon(Icons.arrow_forward_ios, size: 14, color: slate400),
              ],
            ),
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
      builder: (_) => JugadorDetalleSheet(nombre: nombre),
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
            color: slate400.withOpacity(0.4),
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
            'Los jugadores aparecen al jugar partidas',
            style: TextStyle(color: slate400, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTTOM SHEET — detalle del jugador
// ══════════════════════════════════════════════════════════════
class JugadorDetalleSheet extends StatefulWidget {
  final String nombre;
  const JugadorDetalleSheet({Key? key, required this.nombre}) : super(key: key);

  @override
  State<JugadorDetalleSheet> createState() => _JugadorDetalleSheetState();
}

class _JugadorDetalleSheetState extends State<JugadorDetalleSheet> {
  static const Color primaryColor = Color(0xFFf97316);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
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

    int victorias = 0, derrotas = 0, totalPartidas = 0;

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
              color: slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Avatar
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
