import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/match_model.dart';
import '../models/team_data.dart';

class PartidaService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ─── Guardar jugadores nuevos (acumula sin repetir) ───
  Future<void> guardarJugadores(List<String> nombres) async {
    final ref = _db.collection('jugadores').doc(_uid);
    final doc = await ref.get();

    List<String> existentes = [];
    if (doc.exists) {
      existentes = List<String>.from(doc.data()?['nombres'] ?? []);
    }

    // Agrega solo los que no existen
    final nuevos = nombres.where((n) => !existentes.contains(n)).toList();
    if (nuevos.isEmpty) return;

    await ref.set({
      'nombres': [...existentes, ...nuevos],
    });
  }

  // ─── Obtener jugadores guardados (para autocompletar) ───
  Future<List<String>> getJugadores() async {
    final doc = await _db.collection('jugadores').doc(_uid).get();
    if (!doc.exists) return [];
    return List<String>.from(doc.data()?['nombres'] ?? []);
  }

  // ─── Guardar partida al finalizar ───
  Future<void> guardarPartida({
    required List<String> equipoA,
    required List<String> equipoB,
    required int puntajeA,
    required int puntajeB,
    required String ganador, // "equipoA" o "equipoB"
  }) async {
    // Guarda la partida
    await _db.collection('users').doc(_uid).collection('partidas').add({
      'equipoA': equipoA,
      'equipoB': equipoB,
      'puntajes': {'equipoA': puntajeA, 'equipoB': puntajeB},
      'ganador': ganador,
      'fecha': FieldValue.serverTimestamp(),
    });

    // Guarda los jugadores para futuras partidas
    await guardarJugadores([...equipoA, ...equipoB]);
  }

  // ─── Obtener historial de partidas ───
  Stream<QuerySnapshot> getHistorial() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('partidas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}
