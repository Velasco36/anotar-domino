import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Importa la pantalla de settings

class ScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onReset;

  ScoreAppBar({required this.onReset});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.black),
        onPressed: () {
          // Navega a la pantalla de configuración
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
      ),
      title: Text(
        'Puntuación',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: onReset,
          child: Text(
            'RESET',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
