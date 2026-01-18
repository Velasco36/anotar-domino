import 'package:flutter/material.dart';

class MatchHistoryGrid extends StatefulWidget {
  final List<int?> history;
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
          // Primera fila: elementos 0, 1, 2
          Row(
            children: [
              Expanded(child: _buildCell(0)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(1)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(2)),
            ],
          ),
          SizedBox(height: 8),

          // Segunda fila: elementos 3, 4, 5
          Row(
            children: [
              Expanded(child: _buildCell(3)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(4)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(5)),
            ],
          ),
          SizedBox(height: 8),

          // Tercera fila: elementos 6, 7, 8
          Row(
            children: [
              Expanded(child: _buildCell(6)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(7)),
              SizedBox(width: 8),
              Expanded(child: _buildCell(8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int index) {
    final value = index < widget.history.length ? widget.history[index] : null;
    final isHighlighted = value != null && [30, 50, 64, 72].contains(value);

    return GestureDetector(
      onTap: () => widget.onCellTap(index, value),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isHighlighted ? Colors.orange : Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (value != null) ...[
              Text(
                value.toString(),
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if ([30, 50].contains(value))
                Text(
                  'POINTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ] else ...[
              Icon(
                Icons.sports_volleyball,
                color: Colors.orange.withOpacity(0.3),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
