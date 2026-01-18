import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isFilled;
  final VoidCallback onPressed;

  AddButton({
    required this.label,
    required this.color,
    this.isFilled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add, size: 18),
        label: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add, size: 18),
        label: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
