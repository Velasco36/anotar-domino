
import 'package:flutter/material.dart';
import 'presentation/screens/score/widgets/team_setup_screen.dart';
import 'presentation/screens/score/widgets/match_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anotar',
      theme: ThemeData(
        primaryColor: Color(0xFF2563EB),
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TeamSetupScreen(),

      },
    );
  }
}
