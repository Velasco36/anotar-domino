import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history;
  final Function(int index, int? value) onCellTap; // Solo para la "X"
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
    return (widget.history.length / 3).ceil();
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
        child: const Center(
          child: Text(
            'No hay datos de partidos',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final double rowHeight = 55;
    final double spacing = 0;
    final double padding = 0;
    final int maxVisibleRows = 5;

    final double maxHeight =
        (maxVisibleRows * rowHeight) +
        ((maxVisibleRows - 1) * spacing) +
        (padding * 2);

    final double totalHeight =
        (numberOfRows * rowHeight) +
        ((numberOfRows - 1) * spacing) +
        (padding * 2);

    return Container(
      height: totalHeight > maxHeight ? maxHeight : totalHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(numberOfRows, (row) {
              final inverseRow = numberOfRows - row - 1;
              final base = inverseRow * 3;

              final Color rowColor = row % 2 == 0
                  ? Colors.white
                  : Colors.grey.shade200;

              return Container(
                color: rowColor,
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.only(bottom: spacing),
                height: rowHeight,
                child: Row(
                  children: [
                    // Columna de "X" - con GestureDetector
                    _deleteColumn(base),
                    // Celdas del partido - SIN GestureDetector
                    _teamCell(base, true),
                    _centerCell(base + 1, numberOfRows - row),
                    _teamCell(base + 2, false),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _teamCell(int index, bool isLeft) {
    final bool exists = index < widget.history.length;
    final int? value = exists ? widget.history[index] : null;
    final bool hasValue = value != null && value > 0;
    final bool isDeleted = exists && index < widget.deletedMatches.length
        ? widget.deletedMatches[index]
        : false;

    Color bg;
    Color text;

    if (!hasValue) {
      bg = Colors.transparent;
      text = Colors.grey.shade600;
    } else if (isDeleted) {
      bg = Colors.grey.shade200;
      text = Colors.grey[400]!;
    } else {
      bg = Colors.transparent;
      text = Colors.grey[600]!;
    }

    return Flexible(
      flex: 4,
      child: Container(
        // Cambiado de GestureDetector a Container
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: hasValue
              ? Text(
                  value.toString(),
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(Icons.remove, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _centerCell(int index, int matchNumber) {
    final bool exists = index < widget.history.length;
    final int? value = exists ? widget.history[index] : null;
    final bool hasValue = value != null && value > 0;
    final bool isDeleted = exists && index < widget.deletedMatches.length
        ? widget.deletedMatches[index]
        : false;

    Color textColor;
    Color bgColor;

    if (!hasValue) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade600;
    } else if (isDeleted) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.black;
    } else {
      bgColor = Colors.transparent;
      textColor = Colors.grey[600]!;
    }

    return Container(
      width: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        // Cambiado de GestureDetector a Container
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: hasValue
              ? Text(
                  value.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : _matchNumber(matchNumber),
        ),
      ),
    );
  }

  Widget _deleteColumn(int base) {
    bool hasDeleted = false;

    // Verificar si hay partidos eliminados en esta fila
    for (int i = 0; i < 3; i++) {
      final index = base + i;
      if (index < widget.deletedMatches.length &&
          widget.deletedMatches[index]) {
        hasDeleted = true;
        break;
      }
    }

    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () {
          // Llama a onCellTap con el índice de la primera celda de la fila
          widget.onCellTap(base, widget.history[base]);
        },
        child: Center(
          child: Icon(
            Icons.close,
            color: hasDeleted ? Colors.red.shade400 : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _matchNumber(int number) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
