import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history;
  final Function(int index, int? value) onCellTap;
  final List<bool?> matchTeams;
  final List<bool> deletedMatches;
  final int minRows;

  const MatchHistoryGrid({
    Key? key,
    required this.history,
    required this.onCellTap,
    required this.matchTeams,
    required this.deletedMatches,
    this.minRows = 6,
  }) : super(key: key);

  @override
  State<MatchHistoryGrid> createState() => _MatchHistoryGridState();
}

class _MatchHistoryGridState extends State<MatchHistoryGrid> {
  int get numberOfRows {
    final int totalCellsNeeded = widget.minRows * 3;
    final int actualCells = widget.history.length;

    if (actualCells < totalCellsNeeded) {
      return widget.minRows;
    } else {
      return (actualCells / 3).ceil();
    }
  }

  void _ensureListSize(int index) {
    if (index >= widget.history.length) {
      debugPrint(
        'Necesitas expandir tus listas al menos hasta el índice $index',
      );
      debugPrint('Lista actual tiene ${widget.history.length} elementos');
      debugPrint('Se necesitan al menos ${index + 1} elementos');
    }
  }

  void _printHistoryDebug() {
    debugPrint('===== MATCH HISTORY DEBUG =====');
    debugPrint('Historia length: ${widget.history.length}');
    debugPrint('Filas calculadas: $numberOfRows');
    debugPrint('Celdas totales necesarias: ${numberOfRows * 3}');

    for (int row = 0; row < numberOfRows; row++) {
      debugPrint('--- Fila ${row + 1} ---');
      for (int col = 0; col < 3; col++) {
        final index = row * 3 + col;
        final bool indexExists = index < widget.history.length;
        final score = indexExists ? widget.history[index] : null;

        String team = "null";
        if (indexExists && index < widget.matchTeams.length) {
          final teamValue = widget.matchTeams[index];
          team = teamValue == null ? "Empate" : (teamValue ? "Team1" : "Team2");
        }

        debugPrint(
          '  Celda $col (idx $index): ${indexExists ? "✓" : "✗"} - Puntos: $score, Equipo: $team',
        );
      }
    }

    debugPrint('===============================');
  }

  @override
  Widget build(BuildContext context) {
    _printHistoryDebug();

    return Container(
      constraints: BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(numberOfRows, (rowIndex) {
            final baseIndex = rowIndex * 3;

            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < numberOfRows - 1 ? 12 : 0,
              ),
              child: _buildMatchRow(
                // ✅ AQUÍ SE LLAMA AL MÉTODO
                leftIndex: baseIndex,
                centerIndex: baseIndex + 1,
                rightIndex: baseIndex + 2,
                matchNumber: rowIndex + 1,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ✅ AÑADE ESTE MÉTODO QUE FALTABA
  Widget _buildMatchRow({
    required int leftIndex,
    required int centerIndex,
    required int rightIndex,
    required int matchNumber,
  }) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          _teamCell(leftIndex, true),
          _centerCell(centerIndex, matchNumber),
          _teamCell(rightIndex, false),
        ],
      ),
    );
  }

  Widget _teamCell(int index, bool isLeft) {
    _ensureListSize(index);

    final bool indexExists = index < widget.history.length;
    final int? value = indexExists ? widget.history[index] : null;

    bool? teamValue;
    if (indexExists) {
      if (index < widget.matchTeams.length) {
        teamValue = widget.matchTeams[index];
      }
    }

    final bool hasValue = value != null && value > 0;
    final bool isDeleted = indexExists && index < widget.deletedMatches.length
        ? widget.deletedMatches[index]
        : false;

    return Flexible(
      flex: 4,
      child: GestureDetector(
        onTap: () => widget.onCellTap(index, value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: hasValue
                ? (isLeft ? Colors.orange : Colors.blueGrey)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasValue
                  ? (isLeft
                        ? Colors.orange.shade300
                        : Colors.blueGrey.shade500!)
                  : Colors.grey.shade300,
              width: hasValue ? 2 : 1.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: hasValue
                    ? Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        isLeft ? 'TEAM 1' : 'TEAM 2',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (isDeleted && hasValue)
                Positioned.fill(
                  child: CustomPaint(painter: StrikeThroughPainter()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerCell(int index, int matchNumber) {
    _ensureListSize(index);

    final bool indexExists = index < widget.history.length;
    final int? value = indexExists ? widget.history[index] : null;

    bool isTie = false;
    if (indexExists && index < widget.matchTeams.length) {
      isTie = widget.matchTeams[index] == null;
    }

    final bool isDeleted = indexExists && index < widget.deletedMatches.length
        ? widget.deletedMatches[index]
        : false;

    return Container(
      width: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: (isTie && value != null)
          ? _buildTieCell(
              value: value!,
              isDeleted: isDeleted,
              onTap: () => widget.onCellTap(index, value),
            )
          : _buildMatchNumber(matchNumber),
    );
  }

  Widget _buildMatchNumber(int matchNumber) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          matchNumber.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildTieCell({
    required int value,
    required bool isDeleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isDeleted)
            Positioned.fill(
              child: CustomPaint(painter: StrikeThroughPainter()),
            ),
        ],
      ),
    );
  }
}

class StrikeThroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
