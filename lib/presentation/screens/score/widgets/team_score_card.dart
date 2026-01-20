import 'package:flutter/material.dart';

class TeamScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color primaryColor;
  final String avatarUrl;
  final VoidCallback onAddPoints;
  final bool hasStarter; // Nueva propiedad

  const TeamScoreCard({
    Key? key,
    required this.teamName,
    required this.score,
    required this.primaryColor,
    required this.avatarUrl,
    required this.onAddPoints,
    this.hasStarter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasStarter ? Colors.green : Colors.grey[200]!,
          width: hasStarter ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge de SALIDA si tiene
          if (hasStarter)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 12, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'SALIDA',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Resto del contenido de TeamScoreCard...
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // ... resto del código existente ...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
