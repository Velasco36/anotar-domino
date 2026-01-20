import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Importa la pantalla de settings

// En ScoreAppBar (o directamente en ScoreScreen si no usas widget separado):
class ScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onReset;
  final String? starterInfo; // Nueva propiedad

  const ScoreAppBar({Key? key, required this.onReset, this.starterInfo})
    : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'PUNTAJE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (starterInfo != null)
            Text(
              starterInfo!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.orange),
          onPressed: onReset,
        ),
      ],
    );
  }
}
