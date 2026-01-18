import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/score_app_bar.dart';
import 'package:flutter_application_1/presentation/screens/team_score_card.dart';
import 'package:flutter_application_1/presentation/screens/match_history_grid.dart';
import 'package:flutter_application_1/presentation/screens/quick_add_buttons.dart';
import 'package:flutter_application_1/presentation/screens/action_buttons.dart';
import 'package:flutter_application_1/presentation/screens/custom_buttons.dart';
import 'package:flutter_application_1/presentation/screens/points_modal.dart';

// CLASE PRINCIPAL QUE FALTABA
class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  // CORREGIDO: Puntajes iniciales en 0
  int teamAlphaScore = 0;
  int teamBravoScore = 0;
  List<int?> matchHistory = [];

  // CORREGIDO: Cambiar nombres a Team 1 y Team 2
  String teamAlphaName = 'Team 1';
  String teamBravoName = 'Team 2';

  bool isAlphaTurn = true;
  int lastAddedScore = 0;

  void _resetScores() {
    setState(() {
      teamAlphaScore = 0;
      teamBravoScore = 0;
      matchHistory = []; // Especificar tipo
      isAlphaTurn = true;
      lastAddedScore = 0;
    });
  }

  void _updateMatchHistory(int index, int? currentValue) {
    setState(() {
      matchHistory[index] = currentValue == 0 ? 5 : 0;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }

  // Función para agregar puntos al historial
  void _addToHistory(int points, bool isAlpha) {
    // Buscar el primer espacio vacío en el historial
    int? emptyIndex;
    for (int i = 0; i < matchHistory.length; i++) {
      if (matchHistory[i] == null) {
        emptyIndex = i;
        break;
      }
    }

    if (emptyIndex != null) {
      setState(() {
        matchHistory[emptyIndex!] =
            points; // Agregar ! para indicar que no es null
        lastAddedScore = points;

        // Alternar turno para la próxima partida
        isAlphaTurn = !isAlpha;
      });

      // Mostrar mensaje informativo
      _showSnackBar(
        '${isAlpha ? teamAlphaName : teamBravoName} scored $points points in match ${emptyIndex + 1}!',
      );
    } else {
      _showSnackBar('Match history is full! Reset to continue.');
    }
  }

  // Función para abrir el modal de Team 1
  Future<void> _openTeamAlphaModal() async {
    final points = await showPointsModal(
      context,
      teamName: teamAlphaName, // Usar variable
      accentColor: Colors.orange,
    );

    if (points != null && points > 0) {
      setState(() {
        teamAlphaScore += points;
      });

      // Agregar al historial
      _addToHistory(points, true);

      _showSnackBar('Added $points points to $teamAlphaName!');
    }
  }

  // Función para abrir el modal de Team 2
  Future<void> _openTeamBravoModal() async {
    final points = await showPointsModal(
      context,
      teamName: teamBravoName, // Usar variable
      accentColor: Colors.blueGrey[700]!,
    );

    if (points != null && points > 0) {
      setState(() {
        teamBravoScore += points;
      });

      // Agregar al historial
      _addToHistory(points, false);

      _showSnackBar('Added $points points to $teamBravoName!');
    }
  }

  // Modificar los botones de +1 para que también agreguen al historial
  void _addQuickPoint(bool isAlpha) {
    setState(() {
      if (isAlpha) {
        teamAlphaScore += 1;
        _addToHistory(1, true);
      } else {
        teamBravoScore += 1;
        _addToHistory(1, false);
      }
    });
    _showSnackBar(
      'Added 1 point to ${isAlpha ? teamAlphaName : teamBravoName}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ScoreAppBar(
        onReset: _resetScores,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Teams Section
              _buildTeamsSection(),
              SizedBox(height: 24),

              // Match History
              _buildMatchHistorySection(),
              SizedBox(height: 24),

              // Quick Add Buttons
              QuickAddButtons(
                onAddPoints: (points) {
                  setState(() {
                    teamAlphaScore += points;
                    _addToHistory(points, true);
                  });
                  _showSnackBar('Added $points points to $teamAlphaName!');
                },
              ),
              SizedBox(height: 16),

              // Action Buttons
              ActionButtons(
                onMarkWinner: () =>
                    _showSnackBar('$teamAlphaName marked as winner!'),
                onUndo: () => _undoLastAction(),
              ),
              SizedBox(height: 20),

              // Indicador de turno (opcional)
              _buildTurnIndicator(),
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
          // League Badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Salida',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Teams and Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Team 1
              Expanded(
                child: TeamScoreCard(
                  teamName: teamAlphaName.toUpperCase(), // Usar variable
                  score: teamAlphaScore,
                  primaryColor: Colors.orange,
                  avatarUrl: 'https://i.pravatar.cc/150?img=12',
                  onAddPoints: () => _addQuickPoint(true),
                ),
              ),
              SizedBox(width: 20),
              // Team 2
              Expanded(
                child: TeamScoreCard(
                  teamName: teamBravoName.toUpperCase(), // Usar variable
                  score: teamBravoScore,
                  primaryColor: Colors.blueGrey[700]!,
                  avatarUrl: 'https://i.pravatar.cc/150?img=33',
                  onAddPoints: () => _addQuickPoint(false),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Add Buttons
          Row(
            children: [
              Expanded(
                child: AddButton(
                  label: isAlphaTurn ? 'ADD (Turn)' : 'ADD',
                  color: Colors.orange,
                  isFilled: isAlphaTurn,
                  onPressed: _openTeamAlphaModal,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AddButton(
                  label: !isAlphaTurn ? 'ADD (Turn)' : 'ADD',
                  color: Colors.blueGrey[700]!,
                  isFilled: !isAlphaTurn,
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
            child: Text(
              'Puntuación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 16),
          MatchHistoryGrid(
            history: matchHistory,
            onCellTap: _updateMatchHistory,
          ),
        ],
      ),
    );
  }

  // Widget para mostrar el indicador de turno
  Widget _buildTurnIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAlphaTurn
            ? Colors.orange.withOpacity(0.1)
            : Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            color: isAlphaTurn ? Colors.orange : Colors.blueGrey[700],
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            isAlphaTurn ? "$teamAlphaName's turn" : "$teamBravoName's turn",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAlphaTurn ? Colors.orange : Colors.blueGrey[700],
            ),
          ),
        ],
      ),
    );
  }

void _undoLastAction() {
    // Buscar la última entrada no nula
    int? lastIndex;
    int? lastPoints;

    for (int i = matchHistory.length - 1; i >= 0; i--) {
      if (matchHistory[i] != null) {
        lastIndex = i;
        lastPoints = matchHistory[i];
        break;
      }
    }

    if (lastIndex != null && lastPoints != null) {
      final int removedPoints = lastPoints;

      setState(() {
        // Restar puntos del equipo correspondiente
        if (isAlphaTurn) {
          teamBravoScore -= removedPoints;
        } else {
          teamAlphaScore -= removedPoints;
        }

        // Restaurar el turno
        isAlphaTurn = !isAlphaTurn;

        // Eliminar del historial
        matchHistory[lastIndex!] = null; // ✅ Agregar ! después de lastIndex
      });

      _showSnackBar('Undo: Removed $removedPoints points');
    } else {
      _showSnackBar('Nothing to undo!');
    }
  }
}
