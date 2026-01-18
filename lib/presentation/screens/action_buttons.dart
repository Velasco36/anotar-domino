import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onMarkWinner;
  final VoidCallback onUndo;

  ActionButtons({required this.onMarkWinner, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onMarkWinner,
            icon: Icon(Icons.emoji_events, size: 18),
            label: Text(
              'MARK WINNER',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.orange.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUndo,
            icon: Icon(Icons.undo, size: 18),
            label: Text(
              'UNDO LAST',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
