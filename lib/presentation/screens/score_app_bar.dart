import 'package:flutter/material.dart';

class ScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onReset;
  final VoidCallback onBack;

  ScoreAppBar({required this.onReset, required this.onBack});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBack,
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
