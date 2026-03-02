// lib/services/partida_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartidaService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Guardar partida al finalizar
  Future<void> guardarPartida({
    required List<String> jugadores,
    required Map<String, int> puntajes,
    required String ganador,
  }) async {
    await _db.collection('users').doc(_uid).collection('partidas').add({
      'jugadores': jugadores,
      'puntajes': puntajes,
      'ganador': ganador,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Obtener historial del usuario
  Stream<QuerySnapshot> getHistorial() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('partidas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}
