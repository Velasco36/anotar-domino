import 'package:flutter/material.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int teamAlphaScore = 154;
  int teamBravoScore = 112;

  // Grid de historial de puntos (3x3)
  List<int?> matchHistory = [
    25, null, null,
    15, null, 10,
    null, null, null
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              // Reset scores
              setState(() {
                teamAlphaScore = 0;
                teamBravoScore = 0;
                matchHistory = List.filled(9, null);
              });
            },
            child: Text(
              'RESET',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Teams Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),

                ),

                child: Column(
                  children: [
                    // League Badge
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: Colors.orange, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Salida',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Teams and Scores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Team Alpha
                        Expanded(
                          child: _buildTeam(
                            'ALPHA',
                            teamAlphaScore,
                            Colors.orange,
                            'https://i.pravatar.cc/150?img=12',
                          ),
                        ),
                        SizedBox(width: 20),
                        // Team Bravo
                        Expanded(
                          child: _buildTeam(
                            'BRAVO',
                            teamBravoScore,
                            Colors.blueGrey[700]!,
                            'https://i.pravatar.cc/150?img=33',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Add Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                teamAlphaScore += 1;
                              });
                            },
                            icon: Icon(Icons.add, size: 18),
                            label: Text(
                              'ADD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                teamBravoScore += 1;
                              });
                            },
                            icon: Icon(Icons.add, size: 18),
                            label: Text(
                              'ADD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueGrey[700],
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Match History Section
           Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Column(
                  // Cambia esto a center o stretch para alinear al centro
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // O CrossAxisAlignment.stretch

                  children: [
                    // Contenedor con márgenes para el texto
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                      ), // Márgenes aquí
                      width: double.infinity, // Para que ocupe todo el ancho
                      child: Text(
                        'Puntuación',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Grid 3x3
                    _buildMatchHistoryGrid(),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Quick Add Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAddButton('50'),
                  _buildQuickAddButton('75'),
                  _buildQuickAddButton('100'),
                  _buildQuickAddButton('200'),

                ],
              ),

              SizedBox(height: 16),

              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Mark as winner - Team Alpha
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Team Alpha marked as winner!')),
                        );
                      },
                      icon: Icon(Icons.emoji_events, size: 18),
                      label: Text(
                        'MARK WINNER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Undo last action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Last action undone!')),
                        );
                      },
                      icon: Icon(Icons.undo, size: 18),
                      label: Text(
                        'UNDO LAST',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String name, int score, Color color, String avatarUrl) {
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
          name,
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

  Widget _buildMatchHistoryGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final value = matchHistory[index];
          final isHighlighted = value != null && [30, 50, 64, 72].contains(value);

          return GestureDetector(
            onTap: () {
              // Toggle value or add custom value
              setState(() {
                if (value == null) {
                  matchHistory[index] = 5; // Default value
                } else {
                  matchHistory[index] = null;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.orange : Colors.white,


              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (value != null) ...[
                    Text(
                      value.toString(),
                      style: TextStyle(
                        color: isHighlighted ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ([30, 50].contains(value))
                      Text(
                        'POINTS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ] else ...[
                    Icon(
                      Icons.sports_volleyball,
                      color: Colors.orange.withOpacity(0.3),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAddButton(String label) {
    return OutlinedButton(
      onPressed: () {
        final points = int.parse(label.substring(1));
        setState(() {
          // Add to the team that was last selected (default: Team Alpha)
          teamAlphaScore += points;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $points points!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
