import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history; // Cambiar de List<int> a List<int?>
  final Function(int index, int? value) onCellTap;

  const MatchHistoryGrid({
    Key? key,
    required this.history,
    required this.onCellTap,
  }) : super(key: key);

  @override
  _MatchHistoryGridState createState() => _MatchHistoryGridState();
}

class _MatchHistoryGridState extends State<MatchHistoryGrid> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // Primera fila: Partida 1 (índices 0, 1, 2)
          _buildMatchRow(0, 1, 2),
          SizedBox(height: 8),

          // Segunda fila: Partida 4 (índices 3, 4, 5)
          _buildMatchRow(3, 4, 5),
          SizedBox(height: 8),

          // Tercera fila: Partida 7 (índices 6, 7, 8)
          _buildMatchRow(6, 7, 8),
        ],
      ),
    );
  }

  Widget _buildMatchRow(int leftIndex, int centerIndex, int rightIndex) {
    return Row(
      children: [
        // Columna izquierda: Team 1
        Expanded(
          child: _buildTeamCell(
            value: widget.history[leftIndex],
            isLeft: true,
            onTap: () => widget.onCellTap(leftIndex, widget.history[leftIndex]),
          ),
        ),

        // Columna central: número de partida
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            (leftIndex ~/ 3 + 1).toString(), // Calcular número de partida
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),

        // Columna derecha: Team 2
        Expanded(
          child: _buildTeamCell(
            value: widget.history[rightIndex],
            isLeft: false,
            onTap: () =>
                widget.onCellTap(rightIndex, widget.history[rightIndex]),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCell({
    required int? value,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null && value > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: hasValue
              ? (isLeft ? Colors.orange : Colors.blueGrey[700])
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValue
                ? (isLeft ? Colors.orange.shade300 : Colors.blueGrey[500]!)
                : Colors.grey.shade300,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasValue) ...[
              // Mostrar valor si existe
              Text(
                value.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'POINTS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ] else ...[
              // Mostrar equipo si está vacío
              Text(
                isLeft ? 'TEAM 1' : 'TEAM 2',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Icon(
                Icons.add_circle_outline,
                color: isLeft
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.blueGrey.withOpacity(0.3),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
