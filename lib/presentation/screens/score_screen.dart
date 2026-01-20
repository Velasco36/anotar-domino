import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/score_app_bar.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/team_score_card.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/match_history_grid.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/action_buttons.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/custom_buttons.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/points_modal.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int teamAlphaScore = 0;
  int teamBravoScore = 0;

  // ✅ Listas dinámicas - empiezan vacías y crecen según sea necesario
  List<int?> matchHistory = [];
  List<bool?> matchTeams = []; // true = Alpha, false = Bravo, null = Tabla
  List<bool> matchDeleted = []; // true = tachado/cancelado

  String teamAlphaName = 'Team 1';
  String teamBravoName = 'Team 2';

  // ✅ Función auxiliar para asegurar que las listas tengan el tamaño necesario
  void _ensureListsSize(int requiredIndex) {
    while (matchHistory.length <= requiredIndex) {
      matchHistory.add(null);
      matchTeams.add(null);
      matchDeleted.add(false);
    }
  }

  void _resetScores() {
    setState(() {
      teamAlphaScore = 0;
      teamBravoScore = 0;
      matchHistory.clear();
      matchTeams.clear();
      matchDeleted.clear();
    });
  }

  Future<void> _updateMatchHistory(int index, int? currentValue) async {
    // Si la celda está vacía, no hacer nada
    if (currentValue == null) return;

    // Calcular el número de partida basado en el índice
    int matchNumber = (index ~/ 3) + 1;

    // Mostrar diálogo simple solo para tachar/restaurar
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Match $matchNumber'),
          content: Text(
            matchDeleted[index]
                ? 'This match is crossed out.'
                : 'Current points: $currentValue',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'strike'),
              child: Text(
                matchDeleted[index] ? 'Restore' : 'Strike Through',
                style: TextStyle(
                  color: matchDeleted[index] ? Colors.green : Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (result == 'strike') {
      _toggleStrikeThrough(index);
    }
    // Eliminada la opción 'edit' - ya no hay edición directa
  }

  void _toggleStrikeThrough(int index) {
    int matchNumber = (index ~/ 3) + 1;

    setState(() {
      matchDeleted[index] = !matchDeleted[index];
    });

    String message = matchDeleted[index]
        ? 'Match $matchNumber crossed out (score unchanged)'
        : 'Match $matchNumber restored';
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }

  // Función para agregar puntos al historial
  void _addToHistory(int points, bool isAlpha) {
    // Buscar la primera partida (fila) vacía
    int? emptyMatchRow;
    for (int row = 0; ; row++) {
      int baseIndex = row * 3;
      int leftIndex = baseIndex; // Team 1 position
      int centerIndex = baseIndex + 1; // Tabla position
      int rightIndex = baseIndex + 2; // Team 2 position

      // ✅ Asegurar que las listas tengan el tamaño necesario
      _ensureListsSize(rightIndex);

      // Verificar si esta fila está completamente vacía
      if (matchHistory[leftIndex] == null &&
          matchHistory[centerIndex] == null &&
          matchHistory[rightIndex] == null) {
        emptyMatchRow = row;
        break;
      }
    }

    int baseIndex = emptyMatchRow! * 3;
    int targetIndex = isAlpha
        ? baseIndex
        : baseIndex + 2; // 0 o 2 para left/right

    setState(() {
      matchHistory[targetIndex] = points;
      matchTeams[targetIndex] = isAlpha;
      matchDeleted[targetIndex] = false;
    });

    _showSnackBar(
      '${isAlpha ? teamAlphaName : teamBravoName} scored $points points in match ${emptyMatchRow + 1}!',
    );
  }

  // Función para agregar tabla al historial
  void _addTableToHistory(int points) {
    // Buscar la primera partida (fila) vacía
    int? emptyMatchRow;
    for (int row = 0; ; row++) {
      int baseIndex = row * 3;
      int leftIndex = baseIndex;
      int centerIndex = baseIndex + 1; // Tabla position
      int rightIndex = baseIndex + 2;

      // ✅ Asegurar que las listas tengan el tamaño necesario
      _ensureListsSize(rightIndex);

      // Verificar si esta fila está completamente vacía
      if (matchHistory[leftIndex] == null &&
          matchHistory[centerIndex] == null &&
          matchHistory[rightIndex] == null) {
        emptyMatchRow = row;
        break;
      }
    }

    int centerIndex = emptyMatchRow! * 3 + 1; // Posición central

    setState(() {
      matchHistory[centerIndex] = points;
      matchTeams[centerIndex] = null; // null indica tabla
      matchDeleted[centerIndex] = false;
    });

    _showSnackBar(
      'Table registered: Both teams scored $points points in match ${emptyMatchRow + 1}!',
    );
  }

  void _setHistoryValue(int index, int value) {
    _ensureListsSize(index);
    matchHistory[index] = value;
  }

  // Función para abrir el modal de Team 1
  Future<void> _openTeamAlphaModal() async {
    final points = await showPointsModal(
      context,
      teamName: teamAlphaName,
      accentColor: Colors.orange,
    );

    if (points != null && points > 0) {
      setState(() {
        teamAlphaScore += points;
      });
      _addToHistory(points, true);
    }
  }

  // Función para abrir el modal de Team 2
  Future<void> _openTeamBravoModal() async {
    final points = await showPointsModal(
      context,
      teamName: teamBravoName,
      accentColor: Colors.blueGrey[700]!,
    );

    if (points != null && points > 0) {
      setState(() {
        teamBravoScore += points;
      });
      _addToHistory(points, false);
    }
  }

  // Función para manejar EMPATE (coloca 0 puntos automáticamente)
  void _handleDraw() async {
    // Mostrar confirmación antes de registrar empate con 0 puntos
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Register Draw'),
          content: Text(
            'Do you want to register a draw with 0 points for both teams?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'si, Register Draw',
                style: TextStyle(
                  color: Colors.white,
                ), // ✅ TextStyle dentro de Text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ), // ✅ Un solo style
            )
          ],
        );
      },
    );

    if (confirm == true) {
      // Buscar la primera partida (fila) vacía
      int? emptyMatchRow;
      for (int row = 0; ; row++) {
        int baseIndex = row * 3;
        int leftIndex = baseIndex;
        int centerIndex = baseIndex + 1; // Tabla position
        int rightIndex = baseIndex + 2;

        // ✅ Asegurar que las listas tengan el tamaño necesario
        _ensureListsSize(rightIndex);

        // Verificar si esta fila está completamente vacía
        if (matchHistory[leftIndex] == null &&
            matchHistory[centerIndex] == null &&
            matchHistory[rightIndex] == null) {
          emptyMatchRow = row;
          break;
        }
      }

      int centerIndex = emptyMatchRow! * 3 + 1; // Posición central

      setState(() {
        // No se suman puntos a los equipos (0 puntos)
        matchHistory[centerIndex] = 0;
        matchTeams[centerIndex] = null; // null indica tabla
        matchDeleted[centerIndex] = false;
      });

      _showSnackBar(
        'Draw registered with 0 points in match ${emptyMatchRow + 1}!',
      );
    }
  }

  // Función para abrir el modal de Tabla (solo si se quieren puntos > 0)
  Future<void> _openTableModal() async {
    final points = await showPointsModal(
      context,
      teamName: 'Table',
      accentColor: Colors.orange,
    );

    if (points != null && points > 0) {
      setState(() {
        teamAlphaScore += points;
        teamBravoScore += points;
      });
      _addTableToHistory(points);
    }
  }

  void _addQuickPoint(bool isAlpha) {
    setState(() {
      if (isAlpha) {
        teamAlphaScore += 1;
      } else {
        teamBravoScore += 1;
      }
    });
    _addToHistory(1, isAlpha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ScoreAppBar(onReset: _resetScores),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTeamsSection(),
              SizedBox(height: 24),
              _buildMatchHistorySection(),
              SizedBox(height: 24),
              ActionButtons(
                onMarkWinner: () =>
                    _showSnackBar('$teamAlphaName marked as winner!'),
                onUndo: () => _undoLastAction(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TeamScoreCard(
                  teamName: teamAlphaName.toUpperCase(),
                  score: teamAlphaScore,
                  primaryColor: Colors.orange,
                  avatarUrl: 'https://i.pravatar.cc/150?img=12',
                  onAddPoints: () => _addQuickPoint(true),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TeamScoreCard(
                  teamName: teamBravoName.toUpperCase(),
                  score: teamBravoScore,
                  primaryColor: Colors.blueGrey[700]!,
                  avatarUrl: 'https://i.pravatar.cc/150?img=33',
                  onAddPoints: () => _addQuickPoint(false),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AddButton(
                  label: 'ADD',
                  color: Colors.orange,
                  isFilled: true,
                  onPressed: _openTeamAlphaModal,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blueGrey[400]!,
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleDraw, // Cambiado a _handleDraw
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_handle,
                              color: Colors.blueGrey[700],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'EMPATE',
                              style: TextStyle(
                                color: Colors.blueGrey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AddButton(
                  label: 'ADD',
                  color: Colors.blueGrey[700]!,
                  isFilled: false,
                  onPressed: _openTeamBravoModal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistorySection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                left: BorderSide.none,
                right: BorderSide.none,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_chart, color: Colors.grey[400], size: 18),
                SizedBox(width: 8),
                Text(
                  'Puntuación',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          MatchHistoryGrid(
            history: matchHistory,
            onCellTap: _updateMatchHistory,
            matchTeams: matchTeams,
            deletedMatches: matchDeleted,
          ),
        ],
      ),
    );
  }

void _undoLastAction() {
    int? lastIndex;
    int? lastPoints;
    bool? lastTeam;

    // Buscar la última entrada no nula
    for (int i = matchHistory.length - 1; i >= 0; i--) {
      if (matchHistory[i] != null) {
        lastIndex = i;
        lastPoints = matchHistory[i];
        lastTeam = matchTeams[i];
        break;
      }
    }

    if (lastIndex != null && lastPoints != null) {
      final int pointsToRemove = lastPoints;

      setState(() {
        // Restar puntos del equipo correspondiente (solo si no es 0)
        if (lastPoints! > 0) {
          if (lastTeam == null) {
            // Era una tabla
            teamAlphaScore = (teamAlphaScore - pointsToRemove)
                .clamp(0, double.infinity)
                .toInt();
            teamBravoScore = (teamBravoScore - pointsToRemove)
                .clamp(0, double.infinity)
                .toInt();
          } else if (lastTeam!) {
            teamAlphaScore = (teamAlphaScore - pointsToRemove)
                .clamp(0, double.infinity)
                .toInt();
          } else {
            teamBravoScore = (teamBravoScore - pointsToRemove)
                .clamp(0, double.infinity)
                .toInt();
          }
        }

        // Eliminar del historial
        matchHistory[lastIndex!] = null;
        matchTeams[lastIndex] = null;
        matchDeleted[lastIndex] = false;
      });

      String teamName = lastTeam == null
          ? 'Tabla' // Traducido de 'Table'
          : (lastTeam ? teamAlphaName : teamBravoName);

      // Texto del snackbar traducido
      _showSnackBar(
        'Deshacer: Se eliminaron ${lastPoints == 0 ? 'empate (0 puntos)' : '$pointsToRemove puntos'} de $teamName',
      );
    } else {
      // Mensaje cuando no hay nada que deshacer
      _showSnackBar('¡No hay nada para deshacer!');
    }
  }
}
