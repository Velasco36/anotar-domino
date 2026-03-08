import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/team_data.dart';
import '../../../../services/partida_service.dart';
import 'match_screen.dart';

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
  String? _selectedStarter;
  bool _starterError = false;

  late TeamData _originalTeamData;
  late int _teamAWins;
  late int _teamBWins;
  late String _winningTeam;

  final PartidaService _partidaService = PartidaService();
  List<String> _jugadoresGuardados = [];

  @override
  void initState() {
    super.initState();
    _originalTeamData = widget.matchData['teamData'] as TeamData;
    _teamAWins = widget.matchData['teamAWins'] as int;
    _teamBWins = widget.matchData['teamBWins'] as int;
    _winningTeam = widget.matchData['winningTeam'] as String;

    _controllers = {
      'teamA1': TextEditingController(text: _originalTeamData.teamAPlayer1),
      'teamA2': TextEditingController(text: _originalTeamData.teamAPlayer2),
      'teamB1': TextEditingController(text: _originalTeamData.teamBPlayer1),
      'teamB2': TextEditingController(text: _originalTeamData.teamBPlayer2),
    };

    // Igual que el modal: null al abrir, usuario debe tocar estrella
    _selectedStarter = null;
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

  bool _isStarter(String key) =>
      _selectedStarter != null && _selectedStarter == _controllers[key]!.text;

  void _setStarter(String key) {
    setState(() {
      _selectedStarter = _controllers[key]!.text;
      _starterError = false;
    });
  }

  String _getStarterId(String name) {
    for (final entry in _controllers.entries) {
      if (entry.value.text == name) return entry.key;
    }
    return 'teamA1';
  }

  void _save() {
    final jugadoresActuales = _controllers.values
        .map((c) => c.text.trim())
        .toList();
    final starterValido =
        _selectedStarter != null &&
        _selectedStarter!.trim().isNotEmpty &&
        jugadoresActuales.contains(_selectedStarter!.trim());

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
      teamAPlayer1: _controllers['teamA1']!.text.trim(),
      teamAPlayer2: _controllers['teamA2']!.text.trim(),
      teamBPlayer1: _controllers['teamB1']!.text.trim(),
      teamBPlayer2: _controllers['teamB2']!.text.trim(),
      startingPlayerId: _getStarterId(_selectedStarter!),
      startingPlayerName: _selectedStarter!,
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
        builder: (context) => MatchScreen(teamData: updatedTeamData),
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
                    _sectionLabel('EQUIPO A', primaryColor),
                    const SizedBox(height: 10),
                    _teamCard(
                      keys: ['teamA1', 'teamA2'],
                      teamColor: primaryColor,
                      bgColor: primaryLight,
                      cardBg: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // ── Equipo B ──
                    _sectionLabel('EQUIPO B', primaryDark),
                    const SizedBox(height: 10),
                    _teamCard(
                      keys: ['teamB1', 'teamB2'],
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
                      child: _buildMesa(),
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
            key: keys[0],
            label: 'Jugador 1',
            teamColor: teamColor,
            bgColor: bgColor,
          ),
          const SizedBox(height: 12),
          _playerRow(
            key: keys[1],
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
    required String key,
    required String label,
    required Color teamColor,
    required Color bgColor,
  }) {
    final isSelected = _isStarter(key);
    final controller = _controllers[key]!;

    return Row(
      children: [
        // Avatar inicial
        Container(
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

        // Autocomplete
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
                      setState(() {});
                    }
                  });
                  return TextField(
                    controller: fieldController,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
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
              if (_isStarter(key)) {
                setState(() => _selectedStarter = nombre.toUpperCase());
              } else {
                setState(() {});
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        // Estrella de salida
        GestureDetector(
          onTap: () => _setStarter(key),
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

  Widget _sectionLabel(String text, Color color) {
    return Row(
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
    );
  }

  // ── MESA ───────────────────────────────────────────────────────────────────

  Widget _buildMesa() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: slate100),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: slate100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: slate200),
              ),
              child: const Center(
                child: Icon(Icons.casino, size: 28, color: slate300),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Center(child: _mesaSeat('teamA2', primaryColor)),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(child: _mesaSeat('teamA1', primaryColor)),
          ),
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(child: _mesaSeat('teamB2', primaryDark)),
          ),
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(child: _mesaSeat('teamB1', primaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _mesaSeat(String key, Color teamColor) {
    final isSelected = _isStarter(key);
    final name = _controllers[key]!.text;
    final inicial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _setStarter(key),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? teamColor.withOpacity(0.12) : slate100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? teamColor : slate200,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: teamColor.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? teamColor : slate400,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: teamColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name.isEmpty ? '—' : name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? teamColor : slate500,
            ),
          ),
        ],
      ),
    );
  }
}
