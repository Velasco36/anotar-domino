import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import './match_screen.dart';

class TeamSetupScreen extends StatefulWidget {
  @override
  _TeamSetupScreenState createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  String selectedMode = 'teams';
  String selectedStarter = 'p1';

  static const Color primaryOrange = Color(0xFFF97316);
  static const Color lightOrange = Color(0xFFFED7AA);
  static const Color darkOrange = Color(0xFFEA580C);

  final PartidaService _partidaService = PartidaService();
  List<String> _jugadoresGuardados = [];

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
    teamAPlayer1Controller.addListener(_updateUI);
    teamAPlayer2Controller.addListener(_updateUI);
    teamBPlayer1Controller.addListener(_updateUI);
    teamBPlayer2Controller.addListener(_updateUI);
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    final jugadores = await _partidaService.getJugadores();
    if (mounted) {
      setState(() => _jugadoresGuardados = jugadores);
    }
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
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

  void _startMatch(BuildContext context) async {
    // Guardar jugadores en Firestore
    await _partidaService.guardarJugadores([
      teamAPlayer1Controller.text.trim(),
      teamAPlayer2Controller.text.trim(),
      teamBPlayer1Controller.text.trim(),
      teamBPlayer2Controller.text.trim(),
    ]);

    final teamData = TeamData(
      teamAPlayer1: teamAPlayer1Controller.text,
      teamAPlayer2: teamAPlayer2Controller.text,
      teamBPlayer1: teamBPlayer1Controller.text,
      teamBPlayer2: teamBPlayer2Controller.text,
      startingPlayerId: selectedStarter,
      startingPlayerName: _getStartingPlayerName(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchScreen(teamData: teamData)),
    );
  }

  String _getStartingPlayerName() => _getNameForPlayerId(selectedStarter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildTitleSection(),
                    SizedBox(height: 10),
                    _buildTeamInputs(),
                    SizedBox(height: 24),
                    _buildTable(),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: primaryOrange,
                  size: 24,
                ),
                onPressed: () => SystemNavigator.pop(),
              ),
              Text(
                'Configuración de Equipos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: primaryOrange, size: 24),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        SizedBox(height: 4),
        Text(
          'Toca un jugador en la mesa para establecer quién empieza',
          style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
        ),
      ],
    );
  }

  Widget _buildTeamInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildTeamInputCard(
            title: 'JUGADORES EQUIPO A',
            titleColor: primaryOrange,
            backgroundColor: Colors.white,
            borderColor: lightOrange.withOpacity(0.5),
            controller1: teamAPlayer1Controller,
            controller2: teamAPlayer2Controller,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildTeamInputCard(
            title: 'JUGADORES EQUIPO B',
            titleColor: darkOrange,
            backgroundColor: Color(0xFFFFEDD5).withOpacity(0.5),
            borderColor: Color(0xFFFDBA74).withOpacity(0.5),
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
          _buildAutocompleteField(controller1, isTeamB: isTeamB),
          SizedBox(height: 8),
          _buildAutocompleteField(controller2, isTeamB: isTeamB),
        ],
      ),
    );
  }

  // ─── Campo con Autocomplete ───
  Widget _buildAutocompleteField(
    TextEditingController controller, {
    bool isTeamB = false,
  }) {
    return Autocomplete<String>(
      // Valor inicial
      initialValue: TextEditingValue(text: controller.text),

      // Filtra las opciones según lo que escribe el usuario
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return _jugadoresGuardados;
        return _jugadoresGuardados.where(
          (nombre) => nombre.toLowerCase().contains(query),
        );
      },

      // Cuántas opciones mostrar
      optionsMaxHeight: 180,

      // Cómo se ve cada opción en el dropdown
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final nombre = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(nombre),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: primaryOrange),
                          SizedBox(width: 8),
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },

      // Cómo se ve el campo de texto
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            // Sincroniza el controller externo con el interno del Autocomplete
            fieldController.text = controller.text;
            fieldController.addListener(() {
              controller.text = fieldController.text;
            });

            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: isTeamB
                    ? Colors.white.withOpacity(0.8)
                    : Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                isDense: true,
                suffixIcon: _jugadoresGuardados.isNotEmpty
                    ? Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: Color(0xFFCBD5E1),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            );
          },

      // Cuando selecciona una opción
      onSelected: (String nombre) {
        controller.text = nombre;
        setState(() {});
      },
    );
  }

  Widget _buildTable() {
    return SizedBox(
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
          _buildPlayerSeatPositioned(
            playerId: 'p1',
            name: _getNameForPlayerId('p1'),
            team: 'Equipo A',
            position: PlayerPosition.bottom,
            teamColor: primaryOrange,
            bgColor: Color(0xFFF8FAFC),
            iconColor: lightOrange,
          ),
          _buildPlayerSeatPositioned(
            playerId: 'p2',
            name: _getNameForPlayerId('p2'),
            team: 'Equipo A',
            position: PlayerPosition.top,
            teamColor: primaryOrange,
            bgColor: Color(0xFFF8FAFC),
            iconColor: lightOrange,
          ),
          _buildPlayerSeatPositioned(
            playerId: 'p3',
            name: _getNameForPlayerId('p3'),
            team: 'Equipo B',
            position: PlayerPosition.right,
            teamColor: darkOrange,
            bgColor: Color(0xFFFFEDD5),
            iconColor: Color(0xFFFDBA74),
          ),
          _buildPlayerSeatPositioned(
            playerId: 'p4',
            name: _getNameForPlayerId('p4'),
            team: 'Equipo B',
            position: PlayerPosition.left,
            teamColor: darkOrange,
            bgColor: Color(0xFFFFEDD5),
            iconColor: Color(0xFFFDBA74),
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
    double? top, bottom, left, right;
    Alignment alignment;

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
      child: SizedBox(
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
                          color: primaryOrange,
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
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'COMENZAR PARTIDA',
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

enum PlayerPosition { top, bottom, left, right }
