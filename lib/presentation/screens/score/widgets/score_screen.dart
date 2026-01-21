import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/score_app_bar.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/team_score_card.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/match_history_grid.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/custom_buttons.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/points_modal.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/match_history_modal.dart';
import 'package:flutter_application_1/models/player_model.dart';

class ScoreScreen extends StatefulWidget {
  final List<Player> players;
  final int starterIndex;
  final bool isTeamMode;
  final List<String> selectedNames;

  const ScoreScreen({
    Key? key,
    required this.players,
    required this.starterIndex,
    required this.isTeamMode,
    required this.selectedNames,
  }) : super(key: key);

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

  String teamAlphaName = '';
  String teamBravoName = '';
  List<Player> _teamAlphaPlayers = [];
  List<Player> _teamBravoPlayers = [];

  @override
  void initState() {
    super.initState();
    _initializeTeams();

    _ensureListsSize(2);

     _teamAlphaPlayers = _getAlphaPlayers();
    _teamBravoPlayers = _getBravoPlayers();
  }

  void _initializeTeams() {
    if (widget.isTeamMode) {
      // Modo Equipos: jugadores 0,1 vs 2,3
      if (widget.players.length >= 4) {
        teamAlphaName = '${widget.players[0].name} & ${widget.players[1].name}';
        teamBravoName = '${widget.players[2].name} & ${widget.players[3].name}';
      } else {
        // Fallback si no hay suficientes jugadores
        teamAlphaName = 'Team Alpha';
        teamBravoName = 'Team Bravo';
      }
    } else {
      // Modo Individual: 2 jugadores seleccionados
      if (widget.selectedNames.length >= 2) {
        teamAlphaName = widget.selectedNames[0];
        teamBravoName = widget.selectedNames[1];
      } else {
        // Fallback si no hay suficientes nombres
        teamAlphaName = 'Player 1';
        teamBravoName = 'Player 2';
      }
    }

    // Mostrar quién tiene la salida
    _showInitialStarterInfo();
  }

  void _showInitialStarterInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.starterIndex < widget.players.length) {
        Player starter = widget.players[widget.starterIndex];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡${starter.name} tiene la SALIDA!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // ✅ Función auxiliar para asegurar que las listas tengan el tamaño necesario
  void _ensureListsSize(int requiredIndex) {
    while (matchHistory.length <= requiredIndex) {
      matchHistory.add(null);
      matchTeams.add(null);
      matchDeleted.add(false);
    }
  }

  void _updateAlphaPlayers(List<Player> updatedPlayers) {
    setState(() {
      _teamAlphaPlayers = updatedPlayers
          .map((p) => Player(name: p.name, isStarter: p.isStarter))
          .toList();

      // También actualizar la lista principal de players
      if (widget.isTeamMode) {
        widget.players[0].name = updatedPlayers[0].name;
        widget.players[1].name = updatedPlayers[1].name;
      } else {
        widget.players[0].name = updatedPlayers[0].name;
      }
    });
  }

  void _updateBravoPlayers(List<Player> updatedPlayers) {
    setState(() {
      _teamBravoPlayers = updatedPlayers
          .map((p) => Player(name: p.name, isStarter: p.isStarter))
          .toList();

      // También actualizar la lista principal de players
      if (widget.isTeamMode) {
        widget.players[2].name = updatedPlayers[0].name;
        widget.players[3].name = updatedPlayers[1].name;
      } else {
        widget.players[1].name = updatedPlayers[0].name;
      }
    });
  }


  // ✅ Método para obtener los jugadores del equipo Alpha
  List<Player> _getAlphaPlayers() {
    List<Player> alphaPlayers = [];

    if (widget.isTeamMode) {
      // En modo equipo, los jugadores 0 y 1 van a Alpha
      if (widget.players.length >= 2) {
        alphaPlayers = [widget.players[0], widget.players[1]];
      } else if (widget.players.isNotEmpty) {
        alphaPlayers = [widget.players[0]];
      }
    } else {
      // En modo individual, solo el primer jugador
      if (widget.players.isNotEmpty) {
        alphaPlayers = [widget.players[0]];
      }
    }

    return alphaPlayers;
  }

  // ✅ Método para obtener los jugadores del equipo Bravo
  List<Player> _getBravoPlayers() {
    List<Player> bravoPlayers = [];

    if (widget.isTeamMode) {
      // En modo equipo, los jugadores 2 y 3 van a Bravo
      if (widget.players.length >= 4) {
        bravoPlayers = [widget.players[2], widget.players[3]];
      } else if (widget.players.length >= 3) {
        bravoPlayers = [widget.players[2]];
      }
    } else {
      // En modo individual, solo el segundo jugador
      if (widget.players.length > 1) {
        bravoPlayers = [widget.players[1]];
      }
    }

    return bravoPlayers;
  }

  void _resetScores() {
    setState(() {
      teamAlphaScore = 0;
      teamBravoScore = 0;
      matchHistory.clear();
      matchTeams.clear();
      matchDeleted.clear();
      // Inicializar con espacio para al menos una fila
      _ensureListsSize(2);
    });
  }

Future<void> _updateMatchHistory(int index, int? currentValue) async {
    if (currentValue == null) return;

    int matchNumber = (index ~/ 3) + 1;

    final result = await MatchHistoryModal.show(
      context: context,
      matchNumber: matchNumber,
      isDeleted: matchDeleted[index],
      currentPoints: currentValue,
      // Removimos onStrikeToggle ya que no es necesario
    );

    if (result == 'strike') {
      _toggleStrikeThrough(index);
    }
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
    for (int row = 0; row < 20; row++) {
      // Límite de 20 filas máximo
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

    if (emptyMatchRow == null) {
      _showSnackBar('No hay espacio para más partidos');
      return;
    }

    int baseIndex = emptyMatchRow * 3;
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
// Función para manejar EMPATE - versión simplificada
// Función para manejar EMPATE - versión simplificada
  void _handleDraw() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Línea decorativa superior
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Puntos iguales',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const Text(
                'Confirma que los jugadores tienen la misma cantidad de puntos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Continuar'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    // ¡FALTABA ESTA PARTE CRÍTICA!
    if (confirm == true) {
      // Buscar la primera partida (fila) vacía
      int? emptyMatchRow;
      for (int row = 0; row < 20; row++) {
        // Límite de 20 filas máximo
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

      if (emptyMatchRow == null) {
        _showSnackBar('No hay espacio para más partidos');
        return;
      }

      int centerIndex = emptyMatchRow * 3 + 1; // Posición central

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

  // Determinar qué equipo tiene al jugador que sale
  bool _alphaHasStarter() {
    if (widget.isTeamMode) {
      // Modo equipo: jugadores 0 y 1 son Team Alpha
      return widget.starterIndex == 0 || widget.starterIndex == 1;
    } else {
      // Modo individual: verificar si el que sale está en Team Alpha
      if (widget.selectedNames.isNotEmpty &&
          widget.starterIndex < widget.players.length) {
        String starterName = widget.players[widget.starterIndex].name;
        return widget.selectedNames[0] == starterName;
      }
      return false;
    }
  }

  bool _bravoHasStarter() {
    if (widget.isTeamMode) {
      // Modo equipo: jugadores 2 y 3 son Team Bravo
      return widget.starterIndex == 2 || widget.starterIndex == 3;
    } else {
      // Modo individual: verificar si el que sale está en Team Bravo
      if (widget.selectedNames.length > 1 &&
          widget.starterIndex < widget.players.length) {
        String starterName = widget.players[widget.starterIndex].name;
        return widget.selectedNames[1] == starterName;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener información del jugador que sale para el ScoreAppBar
    String starterInfo = '';
    if (widget.starterIndex < widget.players.length) {
      Player starter = widget.players[widget.starterIndex];
      starterInfo = 'SALIDA: ${starter.name}';
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ScoreAppBar(onReset: _resetScores, starterInfo: starterInfo),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTeamsSection(),
              SizedBox(height: 24),
              _buildMatchHistorySection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTeamsSection() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TeamScoreCard(
                  teamName: teamAlphaName.toUpperCase(),
                  players: _getAlphaPlayers(),
                  score: teamAlphaScore,
                  primaryColor: Colors.orange,
                  hasStarter: _alphaHasStarter(),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: TeamScoreCard(
                  teamName: teamBravoName.toUpperCase(),
                  players: _getBravoPlayers(),
                  score: teamBravoScore,
                  primaryColor: Colors.blueGrey[700]!,
                  hasStarter: _bravoHasStarter(),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AddButton(
                  label: '',
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30),
                  isFilled: true,
                  onPressed: _openTeamAlphaModal,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30), // Más redondeado
                    border: Border.all(
                      color: Colors.grey[400]!, // Gris más claro
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleDraw,
                      borderRadius: BorderRadius.circular(30), // Más redondeado
                      splashColor: Colors.grey[200], // Efecto de splash
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14, // Un poco más de padding vertical
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_handle,
                              color: Colors.blueGrey[700],
                              size: 22, // Icono un poco más grande
                            ),
                            SizedBox(width: 8),
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
                  label: '',
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // Ahora esto funcionará
                  isFilled: true,
                  onPressed: _openTeamAlphaModal,
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
            margin: EdgeInsets.symmetric(vertical: 0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(

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
                  'PUNTUACIÓN',
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
}
