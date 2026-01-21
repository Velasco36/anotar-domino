import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isFilled;
  final BorderRadiusGeometry borderRadius; // Nuevo parámetro
  final VoidCallback onPressed;

  AddButton({
    required this.label,
    required this.color,
    this.isFilled = true,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(8),
    ), // Valor por defecto
    required this.onPressed,
  });
@override
  Widget build(BuildContext context) {
    if (isFilled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add_circle_outline, size: 24),
        label: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ), // Usa el parámetro aquí
          elevation: 0,
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add_circle_outline, size: 18),
        label: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ), // Usa el parámetro aquí también
        ),
      );
    }
  }

}
