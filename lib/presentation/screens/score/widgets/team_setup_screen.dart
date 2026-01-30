import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import './match_screen.dart';

class TeamSetupScreen extends StatefulWidget {
  @override
  _TeamSetupScreenState createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  String selectedMode = 'teams';
  String selectedStarter = 'p1';

  // Definir los colores naranja que usarás
  static const Color primaryOrange = Color(0xFFF97316); // Naranja principal
  static const Color lightOrange = Color(0xFFFED7AA); // Naranja claro
  static const Color darkOrange = Color(0xFFEA580C); // Naranja oscuro

  // Definir colores azules que serán reemplazados
  static const Color oldBlue = Color(0xFF2563EB);
  static const Color oldLightBlue = Color(0xFF60A5FA);

  final TextEditingController teamAPlayer1Controller = TextEditingController(
    text: 'Alex',
  );
  final TextEditingController teamAPlayer2Controller = TextEditingController(
    text: 'Jordan',
  );
  final TextEditingController teamBPlayer1Controller = TextEditingController(
    text: 'Taylor',
  );
  final TextEditingController teamBPlayer2Controller = TextEditingController(
    text: 'Casey',
  );

  @override
  void initState() {
    super.initState();
    // Agregar listeners para actualizar la UI cuando cambian los textos
    teamAPlayer1Controller.addListener(_updateUI);
    teamAPlayer2Controller.addListener(_updateUI);
    teamBPlayer1Controller.addListener(_updateUI);
    teamBPlayer2Controller.addListener(_updateUI);
  }

  void _updateUI() {
    // Actualiza la UI cuando cambian los nombres
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Remover los listeners
    teamAPlayer1Controller.removeListener(_updateUI);
    teamAPlayer2Controller.removeListener(_updateUI);
    teamBPlayer1Controller.removeListener(_updateUI);
    teamBPlayer2Controller.removeListener(_updateUI);

    teamAPlayer1Controller.dispose();
    teamAPlayer2Controller.dispose();
    teamBPlayer1Controller.dispose();
    teamBPlayer2Controller.dispose();
    super.dispose();
  }

  // Método para obtener el nombre según el playerId
  String _getNameForPlayerId(String playerId) {
    switch (playerId) {
      case 'p1':
        return teamAPlayer1Controller.text;
      case 'p2':
        return teamAPlayer2Controller.text;
      case 'p3':
        return teamBPlayer1Controller.text;
      case 'p4':
        return teamBPlayer2Controller.text;
      default:
        return '';
    }
  }

  void _startMatch(BuildContext context) {
    // Crear objeto con los datos del equipo
    final teamData = TeamData(
      teamAPlayer1: teamAPlayer1Controller.text,
      teamAPlayer2: teamAPlayer2Controller.text,
      teamBPlayer1: teamBPlayer1Controller.text,
      teamBPlayer2: teamBPlayer2Controller.text,
      startingPlayerId: selectedStarter,
      startingPlayerName: _getStartingPlayerName(),
    );

    // Navegar a la pantalla del partido
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchScreen(teamData: teamData)),
    );
  }

  String _getStartingPlayerName() {
    return _getNameForPlayerId(selectedStarter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mode selector
                    _buildModeSelector(),

                    SizedBox(height: 40),

                    // Title section
                    _buildTitleSection(),

                    SizedBox(height: 24),

                    // Table with players - AHORA USA LOS NOMBRES ACTUALIZADOS
                    _buildTable(),

                    SizedBox(height: 32),

                    // Team inputs
                    _buildTeamInputs(),

                    SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom button
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: primaryOrange, // Cambiado a naranja
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                'Team Setup',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: primaryOrange, size: 24), // Cambiado a naranja
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFE2E8F0).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeButton('Individual', 'individual'),
          _buildModeButton('Teams', 'teams'),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMode = mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selectedMode == mode ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selectedMode == mode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selectedMode == mode
                  ? primaryOrange // Cambiado a naranja cuando está seleccionado
                  : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Select Starting Player',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Tap a player at the table to set who starts',
          style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return SizedBox(
      width: double.infinity,
      height: 380,
      child: Stack(
        children: [
          // Center table
          Center(
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.casino, size: 36, color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Players - AHORA USA LOS NOMBRES DE LOS CONTROLLERS
          _buildPlayerSeatPositioned(
            playerId: 'p1',
            name: _getNameForPlayerId('p1'), // Nombre dinámico
            team: 'Team A',
            position: PlayerPosition.bottom,
            teamColor: primaryOrange, // Cambiado a naranja
            bgColor: Color(0xFFF8FAFC),
            iconColor: lightOrange, // Cambiado a naranja claro
          ),

          _buildPlayerSeatPositioned(
            playerId: 'p2',
            name: _getNameForPlayerId('p2'), // Nombre dinámico
            team: 'Team A',
            position: PlayerPosition.top,
            teamColor: primaryOrange, // Cambiado a naranja
            bgColor: Color(0xFFF8FAFC),
            iconColor: lightOrange, // Cambiado a naranja claro
          ),

          _buildPlayerSeatPositioned(
            playerId: 'p3',
            name: _getNameForPlayerId('p3'), // Nombre dinámico
            team: 'Team B',
            position: PlayerPosition.right,
            teamColor: darkOrange, // Cambiado a naranja oscuro
            bgColor: Color(0xFFFFEDD5), // Fondo naranja muy claro
            iconColor: Color(0xFFFDBA74), // Naranja medio
          ),

          _buildPlayerSeatPositioned(
            playerId: 'p4',
            name: _getNameForPlayerId('p4'), // Nombre dinámico
            team: 'Team B',
            position: PlayerPosition.left,
            teamColor: darkOrange, // Cambiado a naranja oscuro
            bgColor: Color(0xFFFFEDD5), // Fondo naranja muy claro
            iconColor: Color(0xFFFDBA74), // Naranja medio
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSeatPositioned({
    required String playerId,
    required String name,
    required String team,
    required PlayerPosition position,
    required Color teamColor,
    required Color bgColor,
    required Color iconColor,
  }) {
    Alignment alignment;
    double? top, bottom, left, right;

    switch (position) {
      case PlayerPosition.top:
        alignment = Alignment.topCenter;
        top = 0;
        left = 0;
        right = 0;
        break;
      case PlayerPosition.bottom:
        alignment = Alignment.bottomCenter;
        bottom = 0;
        left = 0;
        right = 0;
        break;
      case PlayerPosition.left:
        alignment = Alignment.centerLeft;
        left = 0;
        top = 0;
        bottom = 0;
        break;
      case PlayerPosition.right:
        alignment = Alignment.centerRight;
        right = 0;
        top = 0;
        bottom = 0;
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Align(
        alignment: alignment,
        child: _buildPlayerSeat(
          playerId: playerId,
          name: name,
          team: team,
          teamColor: teamColor,
          bgColor: bgColor,
          iconColor: iconColor,
          isTop: position == PlayerPosition.top,
        ),
      ),
    );
  }

  Widget _buildPlayerSeat({
    required String playerId,
    required String name,
    required String team,
    required Color teamColor,
    required Color bgColor,
    required Color iconColor,
    bool isTop = false,
  }) {
    final isSelected = selectedStarter == playerId;

    return GestureDetector(
      onTap: () => setState(() => selectedStarter = playerId),
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
              SizedBox(height: 4),
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
                    duration: Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryOrange, // Cambiado a naranja
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(Icons.star, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? primaryOrange : Color(0xFF475569),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.edit, size: 14, color: Color(0xFFCBD5E1)),
              ],
            ),
            if (!isTop) ...[
              SizedBox(height: 2),
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

  Widget _buildTeamInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildTeamInputCard(
            title: 'TEAM A PLAYERS',
            titleColor: primaryOrange, // Cambiado a naranja
            backgroundColor: Colors.white,
            borderColor: lightOrange.withOpacity(0.5), // Borde naranja claro
            controller1: teamAPlayer1Controller,
            controller2: teamAPlayer2Controller,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildTeamInputCard(
            title: 'TEAM B PLAYERS',
            titleColor: darkOrange, // Cambiado a naranja oscuro
            backgroundColor: Color(0xFFFFEDD5).withOpacity(0.5), // Fondo naranja claro
            borderColor: Color(0xFFFDBA74).withOpacity(0.5), // Borde naranja medio
            controller1: teamBPlayer1Controller,
            controller2: teamBPlayer2Controller,
            isTeamB: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamInputCard({
    required String title,
    required Color titleColor,
    required Color backgroundColor,
    required Color borderColor,
    required TextEditingController controller1,
    required TextEditingController controller2,
    bool isTeamB = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          _buildTextField(controller1, isTeamB: isTeamB),
          SizedBox(height: 8),
          _buildTextField(controller2, isTeamB: isTeamB),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isTeamB = false,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      onChanged: (value) {
        // Esto ya no es necesario porque tenemos los listeners
        // pero lo dejamos por si acaso
        setState(() {});
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: isTeamB ? Colors.white.withOpacity(0.8) : Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: () => _startMatch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange, // Cambiado a naranja
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: primaryOrange.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'START MATCH',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 12),
                Icon(Icons.play_arrow, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ Enums y Modelos ============

enum PlayerPosition { top, bottom, left, right }
