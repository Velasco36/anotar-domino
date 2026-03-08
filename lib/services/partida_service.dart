import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PartidaService {
  static const String _keyPartidas = 'partidas';
  static const String _keyJugadores = 'jugadores';
  static const int _minutosExpiracion = 1;
  // ─────────────────────────────────────────
  // PARTIDAS
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPartidas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyPartidas) ?? [];
    final ahora = DateTime.now();
    final List<Map<String, dynamic>> validas = [];
    final List<String> noExpiradas = [];
    for (final item in raw) {
      try {
        final Map<String, dynamic> partida = jsonDecode(item);
        final fecha = DateTime.parse(partida['fecha'] as String);
        final diff = ahora.difference(fecha);
        if (diff.inMinutes < _minutosExpiracion) {
          validas.add(partida);
          noExpiradas.add(item);
        }
      } catch (_) {}
    }
    if (noExpiradas.length != raw.length) {
      await prefs.setStringList(_keyPartidas, noExpiradas);
    }
    validas.sort((a, b) {
      final fa = DateTime.parse(a['fecha'] as String);
      final fb = DateTime.parse(b['fecha'] as String);
      return fb.compareTo(fa);
    });
    return validas;
  }

  Future<void> guardarPartida({
    required List<String> equipoA,
    required List<String> equipoB,
    required int puntajeA,
    required int puntajeB,
    required String ganador,
    int targetScore = 100,
    int rounds = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyPartidas) ?? [];
    final nuevaPartida = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'equipoA': equipoA,
      'equipoB': equipoB,
      'puntajes': {'equipoA': puntajeA, 'equipoB': puntajeB},
      'ganador': ganador,
      'targetScore': targetScore,
      'rounds': rounds,
      'fecha': DateTime.now().toIso8601String(),
    };
    raw.insert(0, jsonEncode(nuevaPartida));
    await prefs.setStringList(_keyPartidas, raw);
    await guardarJugadores([...equipoA, ...equipoB]);
  }

  Future<void> eliminarPartida(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyPartidas) ?? [];
    final actualizado = raw.where((item) {
      try {
        final partida = jsonDecode(item) as Map<String, dynamic>;
        return partida['id'] != id;
      } catch (_) {
        return false;
      }
    }).toList();
    await prefs.setStringList(_keyPartidas, actualizado);
  }

  Future<void> eliminarTodoElHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPartidas);
  }

  Stream<List<Map<String, dynamic>>> getHistorial() async* {
    yield await getPartidas();
  }

  // ─────────────────────────────────────────
  // JUGADORES
  // ─────────────────────────────────────────
  Future<List<String>> getJugadores() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyJugadores) ?? [];
  }

  Future<void> guardarJugadores(List<String> nombres) async {
    final prefs = await SharedPreferences.getInstance();
    final existentes = prefs.getStringList(_keyJugadores) ?? [];
    final nuevos = nombres
        .map((n) => n.trim().toUpperCase())
        .where((n) => n.isNotEmpty && !existentes.contains(n))
        .toList();
    if (nuevos.isEmpty) return;
    await prefs.setStringList(_keyJugadores, [...existentes, ...nuevos]);
  }

  Future<void> eliminarJugador(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final existentes = prefs.getStringList(_keyJugadores) ?? [];
    existentes.remove(nombre);
    await prefs.setStringList(_keyJugadores, existentes);
  }

  Future<void> actualizarJugadores(List<String> nombres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyJugadores, nombres);
  }

  // ─────────────────────────────────────────
  // ✅ NUEVO: Renombrar jugador
  // Actualiza el nombre en la lista de jugadores
  // Y también en TODAS las partidas existentes
  // ─────────────────────────────────────────
  Future<void> renombrarJugador(String viejo, String nuevo) async {
    final prefs = await SharedPreferences.getInstance();
    final nuevoNorm = nuevo.trim().toUpperCase();
    if (nuevoNorm.isEmpty) return;
    // 1. Actualizar en lista de jugadores
    final jugadores = prefs.getStringList(_keyJugadores) ?? [];
    final index = jugadores.indexOf(viejo);
    // Si el nuevo nombre ya existe y no es el mismo → no duplicar
    if (jugadores.contains(nuevoNorm) && nuevoNorm != viejo) return;
    if (index != -1) {
      jugadores[index] = nuevoNorm;
    }
    await prefs.setStringList(_keyJugadores, jugadores);
    // 2. Actualizar en todas las partidas guardadas
    final raw = prefs.getStringList(_keyPartidas) ?? [];
    final List<String> actualizadas = [];
    for (final item in raw) {
      try {
        final Map<String, dynamic> partida = jsonDecode(item);
        // Reemplazar en equipoA
        final equipoA = List<String>.from(partida['equipoA'] ?? []);
        final idxA = equipoA.indexOf(viejo);
        if (idxA != -1) equipoA[idxA] = nuevoNorm;
        partida['equipoA'] = equipoA;
        // Reemplazar en equipoB
        final equipoB = List<String>.from(partida['equipoB'] ?? []);
        final idxB = equipoB.indexOf(viejo);
        if (idxB != -1) equipoB[idxB] = nuevoNorm;
        partida['equipoB'] = equipoB;
        actualizadas.add(jsonEncode(partida));
      } catch (_) {
        actualizadas.add(item); // Mantener sin cambios si falla
      }
    }
    await prefs.setStringList(_keyPartidas, actualizadas);
  }

  // ─────────────────────────────────────────
  // ✅ NUEVO: Stats de un jugador desde local
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> getStatsJugador(String nombre) async {
    final partidas = await getPartidas(); // Solo devuelve NO expiradas
    int victorias = 0, derrotas = 0, totalPartidas = 0;
    for (final p in partidas) {
      final equipoA = List<String>.from(p['equipoA'] ?? []);
      final equipoB = List<String>.from(p['equipoB'] ?? []);
      final ganador = p['ganador'] as String;
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

  // ─────────────────────────────────────────
  // RANKING
  // ─────────────────────────────────────────
  Future<Map<String, int>> getRanking() async {
    final partidas = await getPartidas();
    final Map<String, int> victorias = {};
    for (final p in partidas) {
      final ganador = p['ganador'] as String;
      final List<String> ganadores = ganador == 'equipoA'
          ? List<String>.from(p['equipoA'] ?? [])
          : List<String>.from(p['equipoB'] ?? []);
      for (final jugador in ganadores) {
        victorias[jugador] = (victorias[jugador] ?? 0) + 1;
      }
    }
    return victorias;
  }

  Future<Map<String, int>> getRankingGrupal() async {
    final partidas = await getPartidas();
    final Map<String, int> victorias = {};
    for (final p in partidas) {
      final ganador = p['ganador'] as String;
      final List<String> equipo = ganador == 'equipoA'
          ? List<String>.from(p['equipoA'] ?? [])
          : List<String>.from(p['equipoB'] ?? []);
      final nombreEquipo = equipo.join(' & ');
      victorias[nombreEquipo] = (victorias[nombreEquipo] ?? 0) + 1;
    }
    return victorias;
  }
}
