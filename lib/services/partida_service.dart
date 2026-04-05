import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_service.dart'; // ✅ importa para usar keyIsPremium

class PartidaService {
  static const String _keyPartidas = 'partidas';
  static const String _keyJugadores = 'jugadores';

  // limites jugadores
  static const int _limiteNormal = 8;
  static const int _limitePremium = 20;

  // ─────────────────────────────────────────
  // SUSCRIPCIÓN — lee la misma key que SubscriptionService
  // ─────────────────────────────────────────

  /// Lee directamente la cache de SubscriptionService.
  /// Funciona sin internet porque SubscriptionService ya guardó el valor.
  Future<bool> esPremium() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Usa SubscriptionService.keyIsPremium en vez de su propia key privada
    return prefs.getBool(SubscriptionService.keyIsPremium) ?? false;
  }

  Future<int> _limiteJugadores() async {
    final premium = await esPremium();
    return premium ? _limitePremium : _limiteNormal;
  }

  // ─────────────────────────────────────────
  // PARTIDAS — sin expiración automática
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPartidas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyPartidas) ?? [];

    final List<Map<String, dynamic>> partidas = [];

    for (final item in raw) {
      try {
        final Map<String, dynamic> partida = jsonDecode(item);
        partidas.add(partida);
      } catch (_) {
        // ignorar items corruptos
      }
    }

    // ✅ Ordenar por fecha descendente (más reciente primero)
    partidas.sort((a, b) {
      final fa = DateTime.tryParse(a['fecha'] ?? '') ?? DateTime(0);
      final fb = DateTime.tryParse(b['fecha'] ?? '') ?? DateTime(0);
      return fb.compareTo(fa);
    });

    return partidas;
  }

  Future<void> guardarPartida({
    required List<String> equipoA,
    required List<String> equipoB,
    required int puntajeA,
    required int puntajeB,
    required String ganador,
    int targetScore = 100,
    int rounds = 0,
    List<Map<String, dynamic>>? roundsData,
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
      'roundsData': roundsData ?? [],
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
        final partida = jsonDecode(item);
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
    final limite = await _limiteJugadores();

    List<String> jugadores = List.from(existentes);

    for (var nombre in nombres) {
      final n = nombre.trim().toUpperCase();

      if (n.isEmpty || jugadores.contains(n)) continue;

      if (jugadores.length >= limite) {
        jugadores.removeLast();
      }

      jugadores.add(n);
    }

    await prefs.setStringList(_keyJugadores, jugadores);
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
  // RENOMBRAR JUGADOR
  // ─────────────────────────────────────────

  Future<void> renombrarJugador(String viejo, String nuevo) async {
    final prefs = await SharedPreferences.getInstance();

    final nuevoNorm = nuevo.trim().toUpperCase();
    if (nuevoNorm.isEmpty) return;

    final jugadores = prefs.getStringList(_keyJugadores) ?? [];

    if (jugadores.contains(nuevoNorm) && nuevoNorm != viejo) return;

    final index = jugadores.indexOf(viejo);
    if (index != -1) {
      jugadores[index] = nuevoNorm;
    }

    await prefs.setStringList(_keyJugadores, jugadores);

    final raw = prefs.getStringList(_keyPartidas) ?? [];
    final List<String> actualizadas = [];

    for (final item in raw) {
      try {
        final Map<String, dynamic> partida = jsonDecode(item);

        final equipoA = List<String>.from(partida['equipoA'] ?? []);
        final idxA = equipoA.indexOf(viejo);
        if (idxA != -1) equipoA[idxA] = nuevoNorm;

        final equipoB = List<String>.from(partida['equipoB'] ?? []);
        final idxB = equipoB.indexOf(viejo);
        if (idxB != -1) equipoB[idxB] = nuevoNorm;

        partida['equipoA'] = equipoA;
        partida['equipoB'] = equipoB;

        actualizadas.add(jsonEncode(partida));
      } catch (_) {
        actualizadas.add(item);
      }
    }

    await prefs.setStringList(_keyPartidas, actualizadas);
  }

  // ─────────────────────────────────────────
  // STATS JUGADOR
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>> getStatsJugador(String nombre) async {
    final partidas = await getPartidas();

    int victorias = 0;
    int derrotas = 0;
    int totalPartidas = 0;

    for (final p in partidas) {
      final equipoA = List<String>.from(p['equipoA'] ?? []);
      final equipoB = List<String>.from(p['equipoB'] ?? []);
      final ganador = p['ganador'];

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
      final ganador = p['ganador'];

      final List<String> ganadores = ganador == 'equipoA'
          ? List<String>.from(p['equipoA'])
          : List<String>.from(p['equipoB']);

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
      final ganador = p['ganador'];

      final List<String> equipo = ganador == 'equipoA'
          ? List<String>.from(p['equipoA'])
          : List<String>.from(p['equipoB']);

      final nombreEquipo = equipo.join(' & ');

      victorias[nombreEquipo] = (victorias[nombreEquipo] ?? 0) + 1;
    }

    return victorias;
  }
}
