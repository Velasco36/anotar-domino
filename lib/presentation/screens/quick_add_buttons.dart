import 'package:flutter/material.dart';

class QuickAddButtons extends StatelessWidget {
  final Function(int points) onAddPoints;

  QuickAddButtons({required this.onAddPoints});

  @override
  Widget build(BuildContext context) {
    final buttons = ['50', '75', '100', '200'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((label) {
        return OutlinedButton(
          onPressed: () => onAddPoints(int.parse(label)),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
}
