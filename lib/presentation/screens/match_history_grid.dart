import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history;
  final Function(int index, int? value) onCellTap;
  final List<bool?> matchTeams;
  final List<bool> deletedMatches;

  const MatchHistoryGrid({
    Key? key,
    required this.history,
    required this.onCellTap,
    required this.matchTeams,
    required this.deletedMatches,
  }) : super(key: key);

  @override
  State<MatchHistoryGrid> createState() => _MatchHistoryGridState();
}

class _MatchHistoryGridState extends State<MatchHistoryGrid> {
  int get numberOfRows {
    if (widget.history.isEmpty) return 0;
    final int actualCells = widget.history.length;
    return (actualCells / 3).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (numberOfRows == 0) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No hay datos de partidos',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      );
    }

    // Calcular alto dinámicamente
    final double rowHeight = 70.0;
    final double rowSpacing = 12.0;
    final double padding = 16.0;

    // Máximo de 5 filas visibles (ajustable según tu necesidad)
    final int maxVisibleRows = 5;
    final double maxVisibleHeight =
        (maxVisibleRows * rowHeight) +
        ((maxVisibleRows - 1) * rowSpacing) +
        (padding * 2);

    final double totalContentHeight =
        (numberOfRows * rowHeight) +
        ((numberOfRows - 1) * rowSpacing) +
        (padding * 2);

    // Usar el menor entre el contenido total y el máximo permitido
    final double containerHeight = totalContentHeight > maxVisibleHeight
        ? maxVisibleHeight
        : totalContentHeight;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          physics: const BouncingScrollPhysics(),
          child: _buildGridContent(),
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(numberOfRows, (rowIndex) {
        // CAMBIO IMPORTANTE: Usar índice inverso
        final inverseRowIndex = numberOfRows - rowIndex - 1;
        final baseIndex = inverseRowIndex * 3;

        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < numberOfRows - 1 ? 12 : 0,
          ),
          child: _buildMatchRow(
            leftIndex: baseIndex,
            centerIndex: baseIndex + 1,
            rightIndex: baseIndex + 2,
            // CAMBIO: Mostrar número de partido en orden descendente
            matchNumber: numberOfRows - rowIndex,
          ),
        );
      }),
    );
  }

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
    final bool indexExists = index < widget.history.length;
    final int? value = indexExists ? widget.history[index] : null;

    bool? teamValue;
    if (indexExists && index < widget.matchTeams.length) {
      teamValue = widget.matchTeams[index];
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
