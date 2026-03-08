import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartidaService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<void> guardarJugadores(List<String> nombres) async {
    final ref = _db.collection('jugadores').doc(_uid);
    final doc = await ref.get();
    List<String> existentes = [];
    if (doc.exists) {
      existentes = List<String>.from(doc.data()?['nombres'] ?? []);
    }
    final nuevos = nombres
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty && !existentes.contains(n))
        .toList();
    if (nuevos.isEmpty) return;
    await ref.set({
      'nombres': [...existentes, ...nuevos],
    });
  }

  Future<List<String>> getJugadores() async {
    try {
      final doc = await _db.collection('jugadores').doc(_uid).get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['nombres'] ?? []);
    } catch (e) {
      return [];
    }
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
    await _db.collection('users').doc(_uid).collection('partidas').add({
      'equipoA': equipoA,
      'equipoB': equipoB,
      'puntajes': {'equipoA': puntajeA, 'equipoB': puntajeB},
      'ganador': ganador,
      'targetScore': targetScore,
      'rounds': rounds,
      'fecha': FieldValue.serverTimestamp(),
    });
    await guardarJugadores([...equipoA, ...equipoB]);
  }

  // ✅ Eliminar una partida por ID
  Future<void> eliminarPartida(String partidaId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('partidas')
        .doc(partidaId)
        .delete();
  }

  // ✅ Eliminar todo el historial de una vez (batch)
  Future<void> eliminarTodoElHistorial() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('partidas')
        .get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> getHistorial() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('partidas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Future<Map<String, int>> getRanking() async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('partidas')
          .get();
      final Map<String, int> victorias = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ganador = data['ganador'] as String;
        final List<String> ganadores = ganador == 'equipoA'
            ? List<String>.from(data['equipoA'] ?? [])
            : List<String>.from(data['equipoB'] ?? []);
        for (final jugador in ganadores) {
          victorias[jugador] = (victorias[jugador] ?? 0) + 1;
        }
      }
      return victorias;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, int>> getRankingGrupal() async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('partidas')
          .get();
      final Map<String, int> victorias = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ganador = data['ganador'] as String;
        final List<String> equipo = ganador == 'equipoA'
            ? List<String>.from(data['equipoA'] ?? [])
            : List<String>.from(data['equipoB'] ?? []);
        final nombreEquipo = equipo.join(' & ');
        victorias[nombreEquipo] = (victorias[nombreEquipo] ?? 0) + 1;
      }
      return victorias;
    } catch (e) {
      return {};
    }
  }
}
