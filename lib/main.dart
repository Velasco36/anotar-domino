import 'package:flutter/material.dart';
import 'presentation/screens/score/widgets/settings_screen.dart'; // Importa SettingsScreen

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anotar',
      home: SettingsScreen(), // Ahora SettingsScreen es la pantalla inicial
    );
  }
}
