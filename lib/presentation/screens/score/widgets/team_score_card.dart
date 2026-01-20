import 'package:flutter/material.dart';

class TeamScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color primaryColor;
  final String avatarUrl;
  final VoidCallback onAddPoints;

  TeamScoreCard({
    required this.teamName,
    required this.score,
    required this.primaryColor,
    required this.avatarUrl,
    required this.onAddPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!, width: 2),
            image: DecorationImage(
              image: NetworkImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),

        // Team Name
        Text(
          teamName,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),

        // Score
        Text(
          score.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
