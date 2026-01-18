import 'package:flutter/material.dart';
import 'presentation/screens/score_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anotar',
      home: ScoreScreen(),
    );
  }
}
