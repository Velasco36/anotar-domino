import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/player_model.dart';

class TeamScoreCard extends StatefulWidget {
  final String teamName;
  final List<Player> players;
  final int score;
  final Color primaryColor;
  final bool hasStarter;
  final ValueChanged<List<Player>>? onPlayersUpdated;

  const TeamScoreCard({
    Key? key,
    required this.teamName,
    required this.players,
    required this.score,
    required this.primaryColor,
    this.hasStarter = false,
    this.onPlayersUpdated,
  }) : super(key: key);

  @override
  _TeamScoreCardState createState() => _TeamScoreCardState();
}

class _TeamScoreCardState extends State<TeamScoreCard> {
  late List<Player> _currentPlayers;

  @override
  void initState() {
    super.initState();
    _currentPlayers = widget.players
        .map((player) => Player(name: player.name, isStarter: player.isStarter))
        .toList();
  }

  @override
  void didUpdateWidget(TeamScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.players != oldWidget.players) {
      setState(() {
        _currentPlayers = widget.players
            .map(
              (player) =>
                  Player(name: player.name, isStarter: player.isStarter),
            )
            .toList();
      });
    }
  }

  void _showEditPlayersModal(BuildContext context) {
    List<Player> tempPlayers = _currentPlayers
        .map((player) => Player(name: player.name, isStarter: player.isStarter))
        .toList();

    List<TextEditingController> controllers = tempPlayers
        .map((player) => TextEditingController(text: player.name))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditPlayersModal(
          teamName: widget.teamName,
          players: tempPlayers,
          controllers: controllers,
          primaryColor: widget.primaryColor,
          hasStarter: widget.hasStarter,
          onSave: (updatedPlayers) {
            setState(() {
              _currentPlayers = updatedPlayers
                  .map(
                    (player) =>
                        Player(name: player.name, isStarter: player.isStarter),
                  )
                  .toList();
            });

            if (widget.onPlayersUpdated != null) {
              widget.onPlayersUpdated!(updatedPlayers);
            }

            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditPlayersModal(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatares de los jugadores en fila
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: List.generate(
                            _currentPlayers.length > 3
                                ? 3
                                : _currentPlayers.length,
                            (index) {
                              final player = _currentPlayers[index];
                              return Padding(
                                padding: EdgeInsets.only(left: index * 35.0),
                                child: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: widget.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 28,
                                        color: widget.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nombres de los jugadores
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (int i = 0; i < _currentPlayers.length; i++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.hasStarter && i == 0)
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.yellow[700],
                                ),
                              if (widget.hasStarter && i == 0)
                                SizedBox(width: 4),

                              // Ícono de persona

                              // Nombre del jugador
                              Text(
                                _currentPlayers[i].name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4),

                              // Pincel para cada jugador (lado derecho)
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Puntos del equipo (sin GestureDetector para incrementar)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        SizedBox(height: 4),
                        Text(
                          widget.score.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para el modal de edición
class _EditPlayersModal extends StatefulWidget {
  final String teamName;
  final List<Player> players;
  final List<TextEditingController> controllers;
  final Color primaryColor;
  final bool hasStarter;
  final ValueChanged<List<Player>> onSave;

  const _EditPlayersModal({
    required this.teamName,
    required this.players,
    required this.controllers,
    required this.primaryColor,
    required this.hasStarter,
    required this.onSave,
  });

  @override
  __EditPlayersModalState createState() => __EditPlayersModalState();
}

class __EditPlayersModalState extends State<_EditPlayersModal> {
  @override
  void dispose() {
    for (var controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Indicador para arrastrar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Título
                Row(
                  children: [
                    Icon(Icons.edit, color: widget.primaryColor, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editar Nombres',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            widget.teamName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Lista de jugadores para editar
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.players.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Número del jugador
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: widget.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),



                            // Campo de texto
                            Expanded(
                              child: TextField(
                                controller: widget.controllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Nombre del jugador',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  widget.players[index].name = value;
                                },
                              ),
                            ),

                            // Indicador de starter (si aplica)
                            if (widget.hasStarter && index == 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.yellow.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.yellow[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'SALIDA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.yellow[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Botones de acción
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Botón Guardar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Verificar que los nombres no estén vacíos
                            for (int i = 0; i < widget.controllers.length; i++) {
                              if (widget.controllers[i].text.trim().isEmpty) {
                                widget.controllers[i].text =
                                    widget.players[i].name;
                              }
                            }
                            widget.onSave(widget.players);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
