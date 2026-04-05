import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import 'match_screen.dart';
import 'mesa_widget.dart';

class EditMatchSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final Function(Map<String, dynamic>) onSave;

  const EditMatchSettingsScreen({
    Key? key,
    required this.matchData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditMatchSettingsScreen> createState() =>
      _EditMatchSettingsScreenState();
}

class _EditMatchSettingsScreenState extends State<EditMatchSettingsScreen> {
  // ── Colores idénticos al modal ──
  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLight = Color(0xFFfff7ed);
  static const Color primaryDark = Color(0xFFea580c);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  late Map<String, TextEditingController> _controllers;
  String _selectedStarter = ''; // ✅ Ya no nullable, inicializado vacío
  bool _starterError = false;

  late TeamData _originalTeamData;
  late int _teamAWins;
  late int _teamBWins;
  late String _winningTeam;
  late int _targetScore;

  final PartidaService _partidaService = PartidaService();
  List<String> _jugadoresGuardados = [];

  @override
  void initState() {
    super.initState();
    _originalTeamData = widget.matchData['teamData'] as TeamData;
    _teamAWins = widget.matchData['teamAWins'] as int;
    _teamBWins = widget.matchData['teamBWins'] as int;
    _winningTeam = widget.matchData['winningTeam'] as String;
    _targetScore = widget.matchData['targetScore'] ?? 100;

    _controllers = {
      'p1': TextEditingController(text: _originalTeamData.teamAPlayer1),
      'p2': TextEditingController(text: _originalTeamData.teamAPlayer2),
      'p3': TextEditingController(text: _originalTeamData.teamBPlayer1),
      'p4': TextEditingController(text: _originalTeamData.teamBPlayer2),
    };

    // Igual que el modal: inicializamos sin selección
    _selectedStarter = '';
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    final jugadores = await _partidaService.getJugadores();
    if (mounted) setState(() => _jugadoresGuardados = jugadores);
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  bool _isStarter(String key) => _selectedStarter == key;

  void _setStarter(String key) {
    setState(() {
      _selectedStarter = key;
      _starterError = false;
    });
  }

  void _swapPlayers(String p1Key, String p2Key) {
    setState(() {
      final tempText = _controllers[p1Key]!.text;
      _controllers[p1Key]!.text = _controllers[p2Key]!.text;
      _controllers[p2Key]!.text = tempText;

      // Mantener la salida en la misma silla lógicamente si se intercambian
      if (_selectedStarter == p1Key) {
        _selectedStarter = p2Key;
      } else if (_selectedStarter == p2Key) {
        _selectedStarter = p1Key;
      }
    });

    HapticFeedback.mediumImpact();
  }

  void _save() {
    // Verificar que esté seleccionado un puesto válido y tenga nombre
    final starterValido = _selectedStarter.isNotEmpty &&
        _controllers[_selectedStarter] != null &&
        _controllers[_selectedStarter]!.text.trim().isNotEmpty;

    if (!starterValido) {
      setState(() => _starterError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Debes seleccionar quién sale',
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

    final updatedTeamData = TeamData(
      teamAPlayer1: _controllers['p1']!.text.trim(),
      teamAPlayer2: _controllers['p2']!.text.trim(),
      teamBPlayer1: _controllers['p3']!.text.trim(),
      teamBPlayer2: _controllers['p4']!.text.trim(),
      startingPlayerId: _selectedStarter,
      startingPlayerName: _controllers[_selectedStarter]!.text.trim(),
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

    widget.onSave(updatedMatchSummary);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScreen(
          teamData: updatedTeamData,
          initialTeamAWins: _teamAWins,
          initialTeamBWins: _teamBWins,
          initialTargetScore: _targetScore,
        ),
      ),
      (route) => false,
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Equipo A ──
                    _sectionLabel(
                      'EQUIPO A',
                      primaryColor,
                      onSwap: () => _swapPlayers('p1', 'p2'),
                    ),
                    const SizedBox(height: 10),
                    _teamCard(
                      keys: ['p1', 'p2'],
                      teamColor: primaryColor,
                      bgColor: primaryLight,
                      cardBg: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // ── Equipo B ──
                    _sectionLabel(
                      'EQUIPO B',
                      primaryDark,
                      onSwap: () => _swapPlayers('p3', 'p4'),
                    ),
                    const SizedBox(height: 10),
                    _teamCard(
                      keys: ['p3', 'p4'],
                      teamColor: primaryDark,
                      bgColor: const Color(0xFFFFEDD5),
                      cardBg: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // ── Quién sale ──
                    Row(
                      children: [
                        _sectionLabel('QUIÉN SALE', slate500),
                        if (_starterError) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFef4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Requerido',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFef4444),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca un jugador para marcarlo como salida',
                      style: TextStyle(fontSize: 12, color: slate400),
                    ),
                    const SizedBox(height: 14),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: _starterError
                            ? Border.all(
                                color: const Color(0xFFef4444),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: MesaWidget(
                        selectedStarter: _selectedStarter,
                        onStarterSelected: _setStarter,
                        p1Controller: _controllers['p1']!,
                        p2Controller: _controllers['p2']!,
                        p3Controller: _controllers['p3']!,
                        p4Controller: _controllers['p4']!,
                        primaryColor: primaryColor,
                        primaryDark: primaryDark,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botón guardar ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
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
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Guardar y Continuar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER (como el del modal pero con Back en lugar de Cancelar) ──────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: slate100, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
                  'Cancelar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Text(
            'Siguiente Partida',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: charcoalColor,
            ),
          ),
          TextButton(
            onPressed: _save,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              foregroundColor: primaryColor,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ── TEAM CARD ──────────────────────────────────────────────────────────────

  Widget _teamCard({
    required List<String> keys,
    required Color teamColor,
    required Color bgColor,
    required Color cardBg,
  }) {
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
            playerKey: keys[0],
            label: 'Jugador 1',
            teamColor: teamColor,
            bgColor: bgColor,
          ),
          const SizedBox(height: 12),
          _playerRow(
            playerKey: keys[1],
            label: 'Jugador 2',
            teamColor: teamColor,
            bgColor: bgColor,
          ),
        ],
      ),
    );
  }

  // ── PLAYER ROW ─────────────────────────────────────────────────────────────

  Widget _playerRow({
    required String playerKey,
    required String label,
    required Color teamColor,
    required Color bgColor,
  }) {
    final isSelected = _isStarter(playerKey);
    final controller = _controllers[playerKey]!;

    return Row(
      children: [
        // Avatar con ValueListenableBuilder para actualizarse al escribir
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? teamColor : slate200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  value.text.isNotEmpty ? value.text[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: teamColor,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10),

        // Campo Autocomplete
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
            fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && fieldController.text != controller.text) {
                   fieldController.text = controller.text;
                }
              });

              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text.toUpperCase(),
                    );
                  }),
                ],
                onChanged: (value) {
                  final upper = value.toUpperCase();
                  if (controller.text != upper) {
                    controller.text = upper;
                    setState(() {});
                  }
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(fontSize: 12, color: slate400),
                  filled: true,
                  fillColor: const Color(0xFFf8fafc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: teamColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                  suffixIcon: _jugadoresGuardados.isNotEmpty
                      ? Icon(Icons.arrow_drop_down, size: 18, color: slate300)
                      : null,
                  counterStyle: TextStyle(fontSize: 10, color: slate400),
                ),
              );
            },
            onSelected: (nombre) {
              final nombreCortado = nombre.length > 10
                  ? nombre.substring(0, 10).toUpperCase()
                  : nombre.toUpperCase();
              controller.text = nombreCortado;
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 10),

        // Botón estrella
        GestureDetector(
          onTap: () => _setStarter(playerKey),
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
          InkWell(
            onTap: onSwap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, size: 16, color: slate400),
                  const SizedBox(width: 4),
                  Text(
                    'CAMBIAR POSICIÓN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: slate400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
