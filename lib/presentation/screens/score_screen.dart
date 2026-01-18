import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/score_app_bar.dart';
import 'package:flutter_application_1/presentation/screens/team_score_card.dart';
import 'package:flutter_application_1/presentation/screens/match_history_grid.dart';
import 'package:flutter_application_1/presentation/screens/quick_add_buttons.dart';
import 'package:flutter_application_1/presentation/screens/action_buttons.dart';
import 'package:flutter_application_1/presentation/screens/custom_buttons.dart';
import 'package:flutter_application_1/presentation/screens/points_modal.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int teamAlphaScore = 0;
  int teamBravoScore = 0;
  List<int?> matchHistory = List<int?>.filled(9, null);

  String teamAlphaName = 'Team 1';
  String teamBravoName = 'Team 2';

  bool isAlphaTurn = true;

  void _resetScores() {
    setState(() {
      teamAlphaScore = 0;
      teamBravoScore = 0;
      matchHistory = List<int?>.filled(9, null);
      isAlphaTurn = true;
    });
  }

  void _updateMatchHistory(int index, int? currentValue) {
    setState(() {
      matchHistory[index] = currentValue == null ? 5 : null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }

  // Función para agregar puntos al historial
void _addToHistory(int points, bool isAlpha) {
    int? emptyIndex;
    for (int i = 0; i < matchHistory.length; i++) {
      if (matchHistory[i] == null) {
        emptyIndex = i;
        break;
      }
    }

    if (emptyIndex != null) {
      setState(() {
        // Usar un método helper - FIX: añadido ! para convertir int? a int
        _setHistoryValue(emptyIndex!, points);
        isAlphaTurn = !isAlpha;
      });

      _showSnackBar(
        '${isAlpha ? teamAlphaName : teamBravoName} scored $points points in match ${emptyIndex + 1}!',
      );
    } else {
      _showSnackBar('Match history is full! Reset to continue.');
    }
  }

  void _setHistoryValue(int index, int value) {
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
      appBar: ScoreAppBar(
        onReset: _resetScores,
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTeamsSection(),
              SizedBox(height: 24),
              _buildMatchHistorySection(),
              SizedBox(height: 24),
              QuickAddButtons(
                onAddPoints: (points) {
                  setState(() {
                    teamAlphaScore += points;
                  });
                  _addToHistory(points, true);
                },
              ),
              SizedBox(height: 16),
              ActionButtons(
                onMarkWinner: () =>
                    _showSnackBar('$teamAlphaName marked as winner!'),
                onUndo: () => _undoLastAction(),
              ),
              SizedBox(height: 20),
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
                  label: isAlphaTurn ? 'ADD (Turn)' : 'ADD',
                  color: Colors.orange,
                  isFilled: true,
                  onPressed: _openTeamAlphaModal,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AddButton(
                  label: !isAlphaTurn ? 'ADD (Turn)' : 'ADD',
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
    int? lastIndex;
    int? lastPoints;

    // Buscar la última entrada no nula
    for (int i = matchHistory.length - 1; i >= 0; i--) {
      if (matchHistory[i] != null) {
        lastIndex = i;
        lastPoints = matchHistory[i];
        break;
      }
    }

    if (lastIndex != null && lastPoints != null) {
      final int pointsToRemove = lastPoints;

      setState(() {
        // Restar puntos del equipo correspondiente
        if (isAlphaTurn) {
          teamBravoScore = teamBravoScore - pointsToRemove;
        } else {
          teamAlphaScore = teamAlphaScore - pointsToRemove;
        }

        // Restaurar el turno
        isAlphaTurn = !isAlphaTurn;

        // Eliminar del historial - FIX: usar lastIndex! para acceder al índice
        matchHistory[lastIndex!] = null;
      });

      _showSnackBar('Undo: Removed $pointsToRemove points');
    } else {
      _showSnackBar('Nothing to undo!');
    }
  }
}
