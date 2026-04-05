import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import './match_screen.dart';
import './mesa_widget.dart';

class TeamSetupScreen extends StatefulWidget {
  @override
  _TeamSetupScreenState createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  String selectedStarter = 'p1';

  // ── Colores coherentes con el resto de la app ──
  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLight = Color(0xFFfff7ed);
  static const Color primaryDark = Color(0xFFea580c);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  final PartidaService _partidaService = PartidaService();
  List<String> _jugadoresGuardados = [];

  // ✅ Inputs vacíos al iniciar
  final TextEditingController teamAPlayer1Controller = TextEditingController();
  final TextEditingController teamAPlayer2Controller = TextEditingController();
  final TextEditingController teamBPlayer1Controller = TextEditingController();
  final TextEditingController teamBPlayer2Controller = TextEditingController();

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
    if (mounted) setState(() => _jugadoresGuardados = jugadores);
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

  String _getStartingPlayerName() => _getNameForPlayerId(selectedStarter);

  // ✅ Estado de errores por campo
  final Map<String, bool> _fieldErrors = {
    'p1': false,
    'p2': false,
    'p3': false,
    'p4': false,
  };

  void _startMatch(BuildContext context) async {
    // ✅ Validar que ningún jugador esté vacío
    final p1 = teamAPlayer1Controller.text.trim();
    final p2 = teamAPlayer2Controller.text.trim();
    final p3 = teamBPlayer1Controller.text.trim();
    final p4 = teamBPlayer2Controller.text.trim();

    setState(() {
      _fieldErrors['p1'] = p1.isEmpty;
      _fieldErrors['p2'] = p2.isEmpty;
      _fieldErrors['p3'] = p3.isEmpty;
      _fieldErrors['p4'] = p4.isEmpty;
    });

    final hayErrores = _fieldErrors.values.any((e) => e);
    if (hayErrores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Escribe el nombre de todos los jugadores',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFef4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await _partidaService.guardarJugadores([p1, p2, p3, p4]);

    final teamData = TeamData(
      teamAPlayer1: p1,
      teamAPlayer2: p2,
      teamBPlayer1: p3,
      teamBPlayer2: p4,
      startingPlayerId: selectedStarter,
      startingPlayerName: _getStartingPlayerName(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchScreen(teamData: teamData)),
    );
  }

  void _swapPlayers(
    TextEditingController c1,
    TextEditingController c2,
    String id1,
    String id2,
  ) {
    final temp = c1.text;
    c1.text = c2.text;
    c2.text = temp;

    // Si uno de los dos era el que salía, movemos la estrella con el jugador
    if (selectedStarter == id1) {
      selectedStarter = id2;
    } else if (selectedStarter == id2) {
      selectedStarter = id1;
    }

    HapticFeedback.mediumImpact();
    setState(() {});
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Equipo A ──
                  _sectionLabel(
                    'EQUIPO A',
                    primaryColor,
                    onSwap:
                        () => _swapPlayers(
                          teamAPlayer1Controller,
                          teamAPlayer2Controller,
                          'p1',
                          'p2',
                        ),
                  ),
                  const SizedBox(height: 10),
                  _teamCard(
                    controller1: teamAPlayer1Controller,
                    controller2: teamAPlayer2Controller,
                    teamColor: primaryColor,
                    bgColor: primaryLight,
                    cardBg: Colors.white,
                    label1: 'Jugador 1',
                    label2: 'Jugador 2',
                    playerId1: 'p1',
                    playerId2: 'p2',
                  ),

                  const SizedBox(height: 20),

                  // ── Equipo B ──
                  _sectionLabel(
                    'EQUIPO B',
                    primaryDark,
                    onSwap:
                        () => _swapPlayers(
                          teamBPlayer1Controller,
                          teamBPlayer2Controller,
                          'p3',
                          'p4',
                        ),
                  ),
                  const SizedBox(height: 10),
                  _teamCard(
                    controller1: teamBPlayer1Controller,
                    controller2: teamBPlayer2Controller,
                    teamColor: primaryDark,
                    bgColor: const Color(0xFFFFEDD5),
                    cardBg: Colors.white,
                    label1: 'Jugador 1',
                    label2: 'Jugador 2',
                    playerId1: 'p3',
                    playerId2: 'p4',
                  ),

                  const SizedBox(height: 20),

                  // ── Quién sale ──
                  _sectionLabel('QUIÉN SALE', slate500),
                  const SizedBox(height: 6),
                  Text(
                    'Toca un jugador para marcarlo como salida',
                    style: TextStyle(fontSize: 12, color: slate400),
                  ),
                  const SizedBox(height: 14),

                  MesaWidget(
                    selectedStarter: selectedStarter,
                    onStarterSelected: (id) => setState(() => selectedStarter = id),
                    p1Controller: teamAPlayer1Controller,
                    p2Controller: teamAPlayer2Controller,
                    p3Controller: teamBPlayer1Controller,
                    p4Controller: teamBPlayer2Controller,
                    primaryColor: primaryColor,
                    primaryDark: primaryDark,
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: slate100, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  foregroundColor: slate400,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, size: 20),
                    SizedBox(width: 2),
                    Text(
                      'Atrás',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Nueva Partida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: charcoalColor,
                ),
              ),
              // Espacio simétrico
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, Color color, {VoidCallback? onSwap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        if (onSwap != null)
          GestureDetector(
            onTap: onSwap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'CAMBIAR POSICIÓN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── TEAM CARD ──────────────────────────────────────────────────────────────

  Widget _teamCard({
    required TextEditingController controller1,
    required TextEditingController controller2,
    required Color teamColor,
    required Color bgColor,
    required Color cardBg,
    required String label1,
    required String label2,
    required String playerId1,
    required String playerId2,
  }) {
    final hasError1 = _fieldErrors[playerId1] ?? false;
    final hasError2 = _fieldErrors[playerId2] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: teamColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _playerRow(
            controller: controller1,
            label: label1,
            teamColor: teamColor,
            bgColor: bgColor,
            playerId: playerId1,
            hasError: hasError1,
          ),
          const SizedBox(height: 12),
          _playerRow(
            controller: controller2,
            label: label2,
            teamColor: teamColor,
            bgColor: bgColor,
            playerId: playerId2,
            hasError: hasError2,
          ),
        ],
      ),
    );
  }

  // ── PLAYER ROW ─────────────────────────────────────────────────────────────

  Widget _playerRow({
    required TextEditingController controller,
    required String label,
    required Color teamColor,
    required Color bgColor,
    required String playerId,
    bool hasError = false,
  }) {
    final isSelected = selectedStarter == playerId;

    return Row(
      children: [
        // Avatar inicial
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: hasError
                ? const Color(0xFFef4444).withOpacity(0.08)
                : bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasError
                  ? const Color(0xFFef4444)
                  : isSelected
                  ? teamColor
                  : slate200,
              width: hasError || isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              controller.text.isNotEmpty
                  ? controller.text[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: teamColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Autocomplete con mayúsculas
        Expanded(
          child: Autocomplete<String>(
            initialValue: TextEditingValue(text: controller.text),
            optionsBuilder: (TextEditingValue val) {
              final query = val.text.toLowerCase();
              if (query.isEmpty) return _jugadoresGuardados;
              return _jugadoresGuardados.where(
                (n) => n.toLowerCase().contains(query),
              );
            },
            optionsMaxHeight: 160,
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final nombre = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(nombre),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 16, color: teamColor),
                                const SizedBox(width: 8),
                                Text(
                                  nombre,
                                  style: const TextStyle(
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
            fieldViewBuilder:
                (context, fieldController, focusNode, onSubmitted) {
                  fieldController.text = controller.text;
                  fieldController.addListener(() {
                    // ✅ Forzar mayúsculas
                    final upper = fieldController.text.toUpperCase();
                    if (fieldController.text != upper) {
                      fieldController.value = fieldController.value.copyWith(
                        text: upper,
                        selection: TextSelection.collapsed(
                          offset: upper.length,
                        ),
                      );
                    }
                    if (controller.text != fieldController.text) {
                      controller.text = fieldController.text;
                      // ✅ Limpiar error al escribir
                      if (_fieldErrors[playerId] == true &&
                          fieldController.text.isNotEmpty) {
                        _fieldErrors[playerId] = false;
                      }
                      setState(() {});
                    }
                  });
                  return TextField(
                    controller: fieldController,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        12,
                      ), // ✅ max 12 caracteres
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      }),
                    ],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: hasError ? const Color(0xFFef4444) : slate400,
                      ),
                      filled: true,
                      fillColor: hasError
                          ? const Color(0xFFef4444).withOpacity(0.05)
                          : const Color(0xFFf8fafc),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: hasError
                            ? const BorderSide(
                                color: Color(0xFFef4444),
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: hasError
                            ? const BorderSide(
                                color: Color(0xFFef4444),
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: hasError ? const Color(0xFFef4444) : teamColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                      suffixIcon: _jugadoresGuardados.isNotEmpty
                          ? Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: slate300,
                            )
                          : null,
                    ),
                  );
                },
            onSelected: (nombre) {
              controller.text = nombre.toUpperCase();
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 10),
        // ✅ Estrella de salida — igual que el modal
        GestureDetector(
          onTap: () => setState(() => selectedStarter = playerId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? teamColor : slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 18,
              color: isSelected ? Colors.white : slate400,
            ),
          ),
        ),
      ],
    );
  }


  // ── BOTTOM BUTTON ──────────────────────────────────────────────────────────

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: slate100, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ElevatedButton(
            onPressed: () => _startMatch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              shadowColor: primaryColor.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 22),
                SizedBox(width: 8),
                Text(
                  'COMENZAR PARTIDA',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PlayerPosition { top, bottom, left, right }
