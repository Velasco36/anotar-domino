import 'package:flutter/material.dart';

class PenaltyModal extends StatefulWidget {
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final Color accentColor;

  const PenaltyModal({
    Key? key,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    this.accentColor = const Color(0xFFf97316),
  }) : super(key: key);

  @override
  _PenaltyModalState createState() => _PenaltyModalState();
}

class _PenaltyModalState extends State<PenaltyModal> {
  String selectedTeam = 'A'; // 'A' o 'B'
  int penaltyPoints = 25;
  final List<int> presetValues = [25, 30, 40, 50];

  void _incrementPenalty() {
    setState(() {
      if (penaltyPoints < 99) {
        penaltyPoints++;
      }
    });
  }

  void _decrementPenalty() {
    setState(() {
      if (penaltyPoints > 1) {
        penaltyPoints--;
      }
    });
  }

  void _setPenalty(int value) {
    setState(() {
      penaltyPoints = value;
    });
  }

  void _applyPenalty() {
    Navigator.pop(context, {'team': selectedTeam, 'penalty': penaltyPoints});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 24),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xFFe2e8f0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Column(
                      children: [
                        Text(
                          'Penalizar Cabra',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0f172a),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecciona el equipo y el puntaje',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748b),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Team Selection
                    Column(
                      children: [
                        _buildTeamButton(
                          teamId: 'A',
                          teamName: widget.teamAName,
                          isSelected: selectedTeam == 'A',
                        ),
                        SizedBox(height: 12),
                        _buildTeamButton(
                          teamId: 'B',
                          teamName: widget.teamBName,
                          isSelected: selectedTeam == 'B',
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Penalty Points Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Color(0xFFf1f5f9), width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'PUNTOS DE PENALIZACIÓN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94a3b8),
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 24),

                          // Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCounterButton(
                                icon: Icons.remove,
                                onTap: _decrementPenalty,
                              ),
                              SizedBox(width: 24),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      '$penaltyPoints',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0f172a),
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width: 80,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: widget.accentColor.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 24),
                              _buildCounterButton(
                                icon: Icons.add,
                                onTap: _incrementPenalty,
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Preset Values
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: presetValues.map((value) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: _buildPresetButton(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyPenalty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: widget.accentColor.withOpacity(0.15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'APLICAR PENALIZACIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamButton({
    required String teamId,
    required String teamName,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTeam = teamId;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFFFFF7ED) // primary-light
                : Color(0xFFF8FAFC),
            border: Border.all(
              color: isSelected ? widget.accentColor : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EQUIPO $teamId',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? widget.accentColor
                          : Color(0xFF94a3b8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Color(0xFF0f172a) : Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? widget.accentColor : Color(0xFFe2e8f0),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFFe2e8f0), width: 2),
          ),
          child: Icon(icon, color: Color(0xFF94a3b8), size: 24),
        ),
      ),
    );
  }

  Widget _buildPresetButton(int value) {
    final isSelected = penaltyPoints == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _setPenalty(value),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? widget.accentColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? widget.accentColor : Color(0xFFf1f5f9),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Color(0xFF0f172a),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Función helper para mostrar el modal de penalización
Future<Map<String, dynamic>?> showPenaltyModal(
  BuildContext context, {
  required String teamAName,
  required String teamBName,
  required int teamAScore,
  required int teamBScore,
  Color accentColor = const Color(0xFFf97316),
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      return PenaltyModal(
        teamAName: teamAName,
        teamBName: teamBName,
        teamAScore: teamAScore,
        teamBScore: teamBScore,
        accentColor: accentColor,
      );
    },
  );
}
