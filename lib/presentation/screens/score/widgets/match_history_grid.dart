import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history;
  final Function(int index, int? value) onCellTap;
  final List<bool?> matchTeams; // true = Team 1, false = Team 2, null = Empate
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
    final double spacing = 8;
    final double padding = 12;
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
          child: Column(
            children: List.generate(numberOfRows, (row) {
              final inverseRow = numberOfRows - row - 1;
              final base = inverseRow * 3;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: row < numberOfRows - 1 ? spacing : 0,
                ),
                child: SizedBox(
                  height: rowHeight,
                  child: Row(
                    children: [
                      // Columna de "X" - siempre visible
                      _deleteColumn(base),
                      // Celdas del partido
                      _teamCell(base, true),
                      _centerCell(base + 1, numberOfRows - row),
                      _teamCell(base + 2, false),
                    ],
                  ),
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
    Color border;
    Color text;

    if (!hasValue) {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      text = Colors.grey.shade600;
    } else if (isDeleted) {
      bg = isLeft
          ? Colors.orange.withOpacity(0.7)
          : Colors.blueGrey.withOpacity(0.7);
      border = isLeft ? Colors.orange.shade800 : Colors.blueGrey.shade800;
      text = Colors.white.withOpacity(0.8);
    } else {
      bg = isLeft ? Colors.orange : Colors.blueGrey;
      border = isLeft ? Colors.orange.shade300 : Colors.blueGrey.shade500!;
      text = Colors.white;
    }

    return Flexible(
      flex: 4,
      child: GestureDetector(
        onTap: () => widget.onCellTap(index, value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: isDeleted ? 2 : 1.5),
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
                : Icon(Icons.remove, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _centerCell(int index, int matchNumber) {
    final bool exists = index < widget.history.length;
    final int? value = exists ? widget.history[index] : null;

    final bool isTie = exists && index < widget.matchTeams.length
        ? widget.matchTeams[index] == null
        : false;

    final bool isDeleted = exists && index < widget.deletedMatches.length
        ? widget.deletedMatches[index]
        : false;

    if (!isTie || value == null) {
      return Container(
        width: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: _matchNumber(matchNumber),
      );
    }

    return Container(
      width: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          widget.onCellTap(index, value);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDeleted ? Colors.grey.shade300 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDeleted ? Colors.grey.shade500 : Colors.grey.shade400,
              width: isDeleted ? 2 : 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.sync,
              size: 18,
              color: isDeleted ? Colors.grey.shade600 : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

Widget _deleteColumn(int base) {
    // Verificamos si ALGUNA de las 3 celdas de esta fila está eliminada
    bool hasDeleted = false;
    int? deletedIndex;

    for (int i = 0; i < 3; i++) {
      final index = base + i;
      if (index < widget.deletedMatches.length &&
          widget.deletedMatches[index] &&
          index < widget.history.length &&
          widget.history[index] != null) {
        hasDeleted = true;
        deletedIndex = index;
        break;
      }
    }

    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () {
          // Solo funciona si hay un partido eliminado
          if (deletedIndex != null) {
            widget.onCellTap(deletedIndex, widget.history[deletedIndex]);
          }
        },
        child: Center(
          child: Icon(
            Icons.close,
            color: hasDeleted ? Colors.red.shade400 : Colors.grey.shade600,
            size: 20,
          ),
        ),
      ),
    );
  }
  Widget _matchNumber(int number) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
