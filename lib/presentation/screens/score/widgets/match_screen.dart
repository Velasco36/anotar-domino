import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import 'points_modal.dart';
import 'penalty_modal_updated.dart';
import 'edit_target_points_modal.dart';
import 'edit_next_match.dart';
import 'history_match.dart' as history;
import 'edit_current_match_modal.dart';

class MatchScreen extends StatefulWidget {
  final TeamData teamData;
  const MatchScreen({Key? key, required this.teamData}) : super(key: key);

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  late TeamData _teamData;

  int teamAScore = 0;
  int teamBScore = 0;
  int teamAWins = 0;
  int teamBWins = 0;
  int roundNumber = 0;
  int targetScore = 100;
  int currentTurnIndex = 0;
  List<Map<String, dynamic>> roundHistory = [];

  bool _showWinnerAnimation = false;
  bool _hideButtons = false;
  String? _winningTeamName;
  bool _partidaGuardada = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final PartidaService _partidaService = PartidaService();

  @override
  void initState() {
    super.initState();
    _teamData = widget.teamData;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getCurrentTurnPlayer() {
    final players = [
      _teamData.teamAPlayer1,
      _teamData.teamBPlayer1,
      _teamData.teamAPlayer2,
      _teamData.teamBPlayer2,
    ];
    final startingPlayerIndex = players.indexOf(_teamData.startingPlayerName);
    if (startingPlayerIndex != -1) {
      return players[(startingPlayerIndex + currentTurnIndex) % 4];
    }
    return players[currentTurnIndex % 4];
  }

  void advanceTurn() => currentTurnIndex++;

  void _checkForWinner() {
    final teamATotal = _calculateTeamAScore();
    final teamBTotal = _calculateTeamBScore();
    if (teamATotal >= targetScore) {
      _showWinnerAnimationWithTimer(true);
    } else if (teamBTotal >= targetScore) {
      _showWinnerAnimationWithTimer(false);
    }
  }

  void _showWinnerAnimationWithTimer(bool isTeamA) {
    setState(() {
      _winningTeamName = isTeamA
          ? '${_teamData.teamAPlayer1} & ${_teamData.teamAPlayer2}'
          : '${_teamData.teamBPlayer1} & ${_teamData.teamBPlayer2}';
      _showWinnerAnimation = true;
      _hideButtons = true;
    });
    _animationController.reset();
    _animationController.forward();
    if (!_partidaGuardada) {
      _partidaGuardada = true;
      _guardarPartidaFinalizada(isTeamA);
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showWinnerAnimation = false);
    });
  }

  Future<void> _guardarPartidaFinalizada(bool ganadorEsEquipoA) async {
    try {
      await _partidaService.guardarPartida(
        equipoA: [_teamData.teamAPlayer1, _teamData.teamAPlayer2],
        equipoB: [_teamData.teamBPlayer1, _teamData.teamBPlayer2],
        puntajeA: _calculateTeamAScore(),
        puntajeB: _calculateTeamBScore(),
        ganador: ganadorEsEquipoA ? 'equipoA' : 'equipoB',
        targetScore: targetScore,
        rounds: roundNumber,
        roundsData: roundHistory, // ✅ Añadido para que se guarde el detalle
      );
    } catch (e) {
      debugPrint('Error guardando partida: $e');
    }
  }

  void _continueToNextMatch() {
    if (_calculateTeamAScore() >= targetScore)
      teamAWins++;
    else if (_calculateTeamBScore() >= targetScore)
      teamBWins++;

    final matchSummary = {
      'teamData': _teamData,
      'teamAWins': teamAWins,
      'teamBWins': teamBWins,
      'finalTeamAScore': _calculateTeamAScore(),
      'finalTeamBScore': _calculateTeamBScore(),
      'winningTeam': _winningTeamName,
      'roundsPlayed': roundHistory.length,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMatchSettingsScreen(
          matchData: matchSummary,
          onSave: (updatedData) => Navigator.of(context).pop(updatedData),
        ),
      ),
    );
  }

  void _resetMatchData() {
    setState(() {
      teamAScore = 0;
      teamBScore = 0;
      roundNumber = 0;
      currentTurnIndex = 0;
      roundHistory.clear();
      _showWinnerAnimation = false;
      _hideButtons = false;
      _winningTeamName = null;
      _partidaGuardada = false;
    });
  }

  int _calculateTeamAScore() {
    int total = 0;
    for (var round in roundHistory) {
      if (round['deleted'] != true) total += round['teamAScore'] as int;
    }
    return total;
  }

  int _calculateTeamBScore() {
    int total = 0;
    for (var round in roundHistory) {
      if (round['deleted'] != true) total += round['teamBScore'] as int;
    }
    return total;
  }

  Future<void> _showPointsModal(bool isTeamA) async {
    final points = await showPointsModal(
      context,
      teamName: isTeamA
          ? '${_teamData.teamAPlayer1} & ${_teamData.teamAPlayer2}'
          : '${_teamData.teamBPlayer1} & ${_teamData.teamBPlayer2}',
      accentColor: const Color(0xFFf97316),
    );
    if (points != null && points > 0) {
      setState(() {
        if (isTeamA) {
          teamAScore += points;
          roundHistory.insert(0, {
            'teamAScore': points,
            'teamBScore': 0,
            'round': roundNumber + 1,
          });
        } else {
          teamBScore += points;
          roundHistory.insert(0, {
            'teamAScore': 0,
            'teamBScore': points,
            'round': roundNumber + 1,
          });
        }
        roundNumber++;
        advanceTurn();
        _checkForWinner();
      });
    }
  }

  // ✅ Footer de botones extraído como widget — se usa dentro del Column
  Widget _buildBottomButtons() {
    const Color primaryColor = Color(0xFFf97316);
    const Color primaryLightColor = Color(0xFFfff7ed);
    const Color slate100 = Color(0xFFf1f5f9);
    const Color slate500 = Color(0xFF64748b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: slate100, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  roundHistory.insert(0, {
                    'teamAScore': 0,
                    'teamBScore': 0,
                    'round': roundNumber + 1,
                  });
                  roundNumber++;
                  advanceTurn();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: slate100,
                foregroundColor: slate500,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drag_handle, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Iguales',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => history.HistoryScreen(
                      roundHistory: roundHistory,
                      teamData: _teamData,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () async {
                final result = await showPenaltyModal(
                  context,
                  teamAName:
                      '${_teamData.teamAPlayer1} & ${_teamData.teamAPlayer2}',
                  teamBName:
                      '${_teamData.teamBPlayer1} & ${_teamData.teamBPlayer2}',
                  teamAScore: _calculateTeamAScore(),
                  teamBScore: _calculateTeamBScore(),
                  accentColor: primaryColor,
                );
                if (result != null) {
                  setState(() {
                    final penalty = result['penalty'] as int;
                    final team = result['team'] as String;
                    final penaltyPlayer = team == 'A'
                        ? '${_teamData.teamAPlayer1} & ${_teamData.teamAPlayer2}'
                        : '${_teamData.teamBPlayer1} & ${_teamData.teamBPlayer2}';
                    roundHistory.insert(0, {
                      'teamAScore': team == 'A' ? -penalty : 0,
                      'teamBScore': team == 'B' ? -penalty : 0,
                      'round': roundNumber + 1,
                      'penalty': true,
                      'deleted': false,
                      'penaltyPlayer': penaltyPlayer,
                      'penaltyTeam': team,
                    });
                    roundNumber++;
                    advanceTurn();
                    _checkForWinner();
                  });
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: primaryLightColor,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: primaryColor.withOpacity(0.1)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Cabra',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Confirmación antes de salir de la partida
  Future<void> _confirmarSalir(BuildContext context) async {
    const Color primaryColor = Color(0xFFf97316);
    const Color charcoalColor = Color(0xFF0f172a);
    const Color slate100 = Color(0xFFf1f5f9);
    const Color slate500 = Color(0xFF64748b);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Salir de la partida',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: charcoalColor,
          ),
        ),
        content: Text(
          'La partida en curso se perderá. ¿Estás seguro que quieres salir?',
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
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salir',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFf97316);
    const Color primaryLightColor = Color(0xFFfff7ed);
    const Color charcoalColor = Color(0xFF0f172a);
    const Color bgMainColor = Color(0xFFf8fafc);
    const Color slate100 = Color(0xFFf1f5f9);
    const Color slate200 = Color(0xFFe2e8f0);
    const Color slate300 = Color(0xFFcbd5e1);
    const Color slate400 = Color(0xFF94a3b8);
    const Color slate500 = Color(0xFF64748b);

    return WillPopScope(
      onWillPop: () async {
        await _confirmarSalir(context);
        return false; // siempre false — _confirmarSalir maneja la navegación
      },
      child: Scaffold(
        // ✅ Sin bottomSheet — eliminado completamente para evitar conflictos de scroll
        backgroundColor: bgMainColor,
        body: SafeArea(
          child: Stack(
            children: [
              // ✅ Column principal con footer fijo adentro
              Column(
                children: [
                  // ─── Header ───
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 40,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(color: slate100, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _confirmarSalir(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_left,
                                color: primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLightColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => EditTargetPointsModal(
                                  currentScore: targetScore,
                                  onSave: (newScore) {
                                    setState(() => targetScore = newScore);
                                    Navigator.pop(context);
                                  },
                                  onCancel: () => Navigator.pop(context),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Puntos: $targetScore',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => showEditCurrentMatchModal(
                            context,
                            teamData: _teamData,
                            onSave: (updatedTeamData) {
                              setState(() => _teamData = updatedTeamData);
                            },
                          ),
                          icon: const Icon(
                            Icons.more_horiz,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Turno y ronda ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: slate100, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SALIDA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: slate400,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  _teamData.startingPlayerName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: charcoalColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'TURN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: slate400,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  getCurrentTurnPlayer(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ROUND',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: slate400,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              '#$roundNumber',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Marcador equipos ───
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: slate100, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: slate100),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_teamData.teamAPlayer1} & ${_teamData.teamAPlayer2}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: slate400,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _calculateTeamAScore().toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: charcoalColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'wins',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: slate400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      teamAWins.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => _showPointsModal(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      shadowColor: primaryColor.withOpacity(
                                        0.15,
                                      ),
                                    ),
                                    child: const Icon(Icons.add, size: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  '${_teamData.teamBPlayer1} & ${_teamData.teamBPlayer2}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: slate400,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _calculateTeamBScore().toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: charcoalColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'wins',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: slate400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      teamBWins.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => _showPointsModal(false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      shadowColor: primaryColor.withOpacity(
                                        0.15,
                                      ),
                                    ),
                                    child: const Icon(Icons.add, size: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Lista de rondas ───
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: roundHistory.length,
                      itemBuilder: (context, index) {
                        final round = roundHistory[index];
                        final isDeleted = round['deleted'] == true;
                        final isPenalty = round['penalty'] == true;
                        final teamAScoreValue = round['teamAScore'] as int;
                        final teamBScoreValue = round['teamBScore'] as int;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? slate100.withOpacity(0.4)
                                : (isPenalty
                                      ? const Color(0xFFFFF5F5)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            border: isDeleted
                                ? null
                                : Border.all(
                                    color: isPenalty
                                        ? Colors.red.withOpacity(0.2)
                                        : slate100,
                                  ),
                            boxShadow: isDeleted
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  teamAScoreValue.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDeleted
                                        ? slate400
                                        : (isPenalty && teamAScoreValue < 0
                                              ? Colors.red
                                              : (teamAScoreValue > 0
                                                    ? charcoalColor
                                                    : slate300)),
                                    decoration: isDeleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDeleted
                                      ? slate200.withOpacity(0.5)
                                      : (isPenalty
                                            ? Colors.red.withOpacity(0.1)
                                            : slate100),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    isDeleted
                                        ? '0'
                                        : (round['round'] as int).toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isDeleted
                                          ? FontWeight.bold
                                          : FontWeight.w900,
                                      color: isPenalty ? Colors.red : slate400,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  teamBScoreValue.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDeleted
                                        ? slate400
                                        : (isPenalty && teamBScoreValue < 0
                                              ? Colors.red
                                              : (teamBScoreValue > 0
                                                    ? charcoalColor
                                                    : slate300)),
                                    decoration: isDeleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isDeleted) {
                                      roundHistory[index]['deleted'] = false;
                                      roundHistory[index]['round'] =
                                          roundNumber + 1;
                                      roundNumber++;
                                      currentTurnIndex++;
                                      _checkForWinner();
                                    } else {
                                      roundHistory[index]['deleted'] = true;
                                      roundHistory[index]['round'] = 0;
                                      roundNumber--;
                                      currentTurnIndex--;
                                    }
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDeleted
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    isDeleted
                                        ? Icons.restore
                                        : Icons.delete_outline,
                                    size: 16,
                                    color: isDeleted
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ Footer fijo DENTRO del Column — siempre visible, sin conflictos
                  if (!_hideButtons) _buildBottomButtons(),
                ],
              ),

              // ─── Animación ganador ───
              if (_showWinnerAnimation)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '¡GANADOR!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _winningTeamName ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: charcoalColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Ha ganado la partida',
                              style: TextStyle(fontSize: 14, color: slate500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Partida guardada',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(
                                backgroundColor: slate200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ─── Botón continuar (cuando hay ganador) ───
              if (!_showWinnerAnimation && _hideButtons)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: slate100, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _continueToNextMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Continuar a la siguiente partida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
