import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import 'match_screen.dart'; // Añade esta importación

class EditMatchSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final Function(Map<String, dynamic>) onSave;

  const EditMatchSettingsScreen({
    Key? key,
    required this.matchData,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditMatchSettingsScreenState createState() =>
      _EditMatchSettingsScreenState();
}

class _EditMatchSettingsScreenState extends State<EditMatchSettingsScreen> {
  late Map<String, TextEditingController> _playerControllers;
  String _selectedCaptain = 'Juan';

  late TeamData _originalTeamData;
  late int _teamAWins;
  late int _teamBWins;
  late String _winningTeam;

  static const Color primaryOrange = Color(0xFFF97316);
  static const Color lightOrange = Color(0xFFFED7AA);
  static const Color darkOrange = Color(0xFFEA580C);

  @override
  void initState() {
    super.initState();

    _originalTeamData = widget.matchData['teamData'] as TeamData;
    _teamAWins = widget.matchData['teamAWins'] as int;
    _teamBWins = widget.matchData['teamBWins'] as int;
    _winningTeam = widget.matchData['winningTeam'] as String;

    _playerControllers = {
      'teamA1': TextEditingController(text: _originalTeamData.teamAPlayer1),
      'teamA2': TextEditingController(text: _originalTeamData.teamAPlayer2),
      'teamB1': TextEditingController(text: _originalTeamData.teamBPlayer1),
      'teamB2': TextEditingController(text: _originalTeamData.teamBPlayer2),
    };

    _selectedCaptain = _originalTeamData.startingPlayerName;
  }

  @override
  void dispose() {
    _playerControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleCaptain(String playerKey) {
    setState(() {
      _selectedCaptain = _playerControllers[playerKey]!.text;
    });
  }

  bool _isCaptain(String playerName) {
    return _selectedCaptain == playerName;
  }

  void _saveAndNavigate(BuildContext context) {
    final updatedTeamData = TeamData(
      teamAPlayer1: _playerControllers['teamA1']!.text,
      teamAPlayer2: _playerControllers['teamA2']!.text,
      teamBPlayer1: _playerControllers['teamB1']!.text,
      teamBPlayer2: _playerControllers['teamB2']!.text,
      startingPlayerId: _getPlayerId(_selectedCaptain),
      startingPlayerName: _selectedCaptain,
    );

    final updatedMatchSummary = {
      'teamData': updatedTeamData,
      'teamAWins': _teamAWins,
      'teamBWins': _teamBWins,
      'winningTeam': _winningTeam,
      'finalTeamAScore': widget.matchData['finalTeamAScore'] ?? 0,
      'finalTeamBScore': widget.matchData['finalTeamBScore'] ?? 0,
      'roundsPlayed': widget.matchData['roundsPlayed'] ?? 0,
    };

    // Ejecuta el callback onSave primero
    widget.onSave(updatedMatchSummary);

    // Luego navega a MatchScreen con los datos actualizados
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScreen(teamData: updatedTeamData),
      ),
      (route) => false, // Esto elimina todas las rutas anteriores
    );
  }

  String _getPlayerId(String playerName) {
    if (playerName == _playerControllers['teamA1']!.text) return 'teamA1';
    if (playerName == _playerControllers['teamA2']!.text) return 'teamA2';
    if (playerName == _playerControllers['teamB1']!.text) return 'teamB1';
    if (playerName == _playerControllers['teamB2']!.text) return 'teamB2';
    return 'teamA1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 40,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryOrange,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_left, size: 20),
                        SizedBox(width: 2),
                        Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Ajustes de Partida',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildEditPlayersSection(),
                    _buildGameTableSection(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: const Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveAndNavigate(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: primaryOrange.withOpacity(0.15),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPlayersSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: Color(0xFFF97316), size: 20),
              const SizedBox(width: 8),
              Text(
                'EDITAR JUGADORES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8).withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightOrange.withOpacity(0.5), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JUGADORES EQUIPO A',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primaryOrange,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPlayerInput(
                  controller: _playerControllers['teamA1']!,
                  playerKey: 'teamA1',
                  isTeamA: true,
                ),
                const SizedBox(height: 12),
                _buildPlayerInput(
                  controller: _playerControllers['teamA2']!,
                  playerKey: 'teamA2',
                  isTeamA: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDBA74).withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JUGADORES EQUIPO B',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: darkOrange,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPlayerInput(
                  controller: _playerControllers['teamB1']!,
                  playerKey: 'teamB1',
                  isTeamA: false,
                ),
                const SizedBox(height: 12),
                _buildPlayerInput(
                  controller: _playerControllers['teamB2']!,
                  playerKey: 'teamB2',
                  isTeamA: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInput({
    required TextEditingController controller,
    required String playerKey,
    required bool isTeamA,
  }) {
    bool isCaptain = _isCaptain(controller.text);

    return Row(
      children: [
        GestureDetector(
          onTap: () => _toggleCaptain(playerKey),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCaptain ? primaryOrange : Colors.transparent,
              border: Border.all(
                color: isCaptain ? primaryOrange : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: isCaptain
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: isTeamA
                  ? const Color(0xFFF8FAFC)
                  : Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
              suffixIcon: Icon(
                Icons.edit,
                size: 16,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            onChanged: (value) {
              if (isCaptain) {
                setState(() {
                  _selectedCaptain = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTableSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart, color: Color(0xFFF97316), size: 20),
              const SizedBox(width: 8),
              Text(
                'MESA DE JUEGO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8).withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Toca un jugador en la mesa para establecer quién empieza',
              style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 380,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.casino,
                          size: 36,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildPlayerSeat(
                      name: _playerControllers['teamA1']!.text,
                      initial: _playerControllers['teamA1']!.text.isNotEmpty
                          ? _playerControllers['teamA1']!.text[0]
                          : 'J',
                      playerKey: 'teamA1',
                      team: 'Equipo A',
                      teamColor: primaryOrange,
                      bgColor: const Color(0xFFF8FAFC),
                      iconColor: lightOrange,
                      isTop: false,
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildPlayerSeat(
                      name: _playerControllers['teamA2']!.text,
                      initial: _playerControllers['teamA2']!.text.isNotEmpty
                          ? _playerControllers['teamA2']!.text[0]
                          : 'P',
                      playerKey: 'teamA2',
                      team: 'Equipo A',
                      teamColor: primaryOrange,
                      bgColor: const Color(0xFFF8FAFC),
                      iconColor: lightOrange,
                      isTop: true,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildPlayerSeat(
                      name: _playerControllers['teamB2']!.text,
                      initial: _playerControllers['teamB2']!.text.isNotEmpty
                          ? _playerControllers['teamB2']!.text[0]
                          : 'T',
                      playerKey: 'teamB2',
                      team: 'Equipo B',
                      teamColor: darkOrange,
                      bgColor: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFFDBA74),
                      isTop: false,
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildPlayerSeat(
                      name: _playerControllers['teamB1']!.text,
                      initial: _playerControllers['teamB1']!.text.isNotEmpty
                          ? _playerControllers['teamB1']!.text[0]
                          : 'A',
                      playerKey: 'teamB1',
                      team: 'Equipo B',
                      teamColor: darkOrange,
                      bgColor: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFFDBA74),
                      isTop: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSeat({
    required String name,
    required String initial,
    required String playerKey,
    required String team,
    required Color teamColor,
    required Color bgColor,
    required Color iconColor,
    bool isTop = false,
  }) {
    final isSelected = _isCaptain(name);

    return GestureDetector(
      onTap: () => _toggleCaptain(playerKey),
      child: Container(
        width: 128,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTop) ...[
              Text(
                team.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryOrange : iconColor,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryOrange.withOpacity(0.4),
                              blurRadius: 20,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(Icons.account_circle, size: 40, color: iconColor),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? primaryOrange : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit, size: 14, color: Color(0xFFCBD5E1)),
              ],
            ),
            if (!isTop) ...[
              const SizedBox(height: 2),
              Text(
                team.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
