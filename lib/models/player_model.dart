// player_model.dart
import 'package:uuid/uuid.dart';

class Player {
  final String id; // UUID único
  String name;

  Player({String? id, required this.name}) : id = id ?? const Uuid().v4();

  // Para fácil comparación
  @override
  bool operator ==(Object other) {
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
