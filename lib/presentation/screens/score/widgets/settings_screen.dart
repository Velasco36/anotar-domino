import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isTeamMode = true; // ✅ DEFAULT TEAM MODE
  int? starterIndex;

  // Para modo individual: guarda qué jugadores están seleccionados
  final List<bool> individualSelections = List.filled(4, false);

  final List<Player> players = List.generate(
    4,
    (i) => Player(name: 'Player ${i + 1}'),
  );

  // ===================== LOGIC =====================

  void _toggleMode() {
    setState(() {
      isTeamMode = !isTeamMode;
      starterIndex = null;
      for (var p in players) {
        p.isStarter = false;
      }
      // Reset selecciones individuales
      for (int i = 0; i < individualSelections.length; i++) {
        individualSelections[i] = false;
      }
    });
  }

  void _selectStarter(int index) {
    setState(() {
      if (starterIndex == index) {
        players[index].isStarter = false;
        starterIndex = null;
      } else {
        if (starterIndex != null) {
          players[starterIndex!].isStarter = false;
        }
        players[index].isStarter = true;
        starterIndex = index;
      }
    });
  }

  void _toggleIndividualSelection(int index) {
    if (isTeamMode) return; // Solo en modo individual

    setState(() {
      individualSelections[index] = !individualSelections[index];
    });
  }

  void _editName(int index) {
    final controller = TextEditingController(text: players[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                players[index].name = controller.text.isEmpty
                    ? players[index].name
                    : controller.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isTeamMode ? 'Team Mode' : 'Individual Mode'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modeSwitch(),
                SizedBox(height: 8),
                Text(
                  isTeamMode
                      ? 'Los switches marcan quién inicia (SALIDA)'
                      : 'Los switches marcan quién inicia (SALIDA) y checkboxes para seleccionar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (isTeamMode) _teamInfoLabel(),
          Expanded(child: _playersList()),
          _startButton(),
        ],
      ),
    );
  }

  // ===================== SWITCH MODE =====================

  Widget _modeSwitch() {
    return GestureDetector(
      onTap: _toggleMode,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: isTeamMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.42,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isTeamMode ? Colors.orange : Colors.blue,
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
            Row(
              children: [
                _switchLabel('Individual', !isTeamMode),
                _switchLabel('Teams', isTeamMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchLabel(String text, bool active) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ===================== TEAM INFO =====================

  Widget _teamInfoLabel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              'Equipos de 2 jugadores',
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== PLAYERS LIST =====================

  Widget _playersList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (_, index) => _playerCard(index),
    );
  }

  Widget _playerCard(int index) {
    final player = players[index];
    final isPairedTeam = isTeamMode && index % 2 == 0;
    final teamColor = isTeamMode
        ? (index ~/ 2 == 0 ? Colors.orange : Colors.blue)
        : Colors.blue;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
        border: Border.all(color: teamColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Barra lateral de color
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: teamColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),

              // Checkbox para modo individual (IZQUIERDA)
              if (!isTeamMode)
                Checkbox(
                  value: individualSelections[index],
                  onChanged: (_) => _toggleIndividualSelection(index),
                  activeColor: teamColor,
                ),

              if (!isTeamMode) SizedBox(width: 8),

              // Avatar
              GestureDetector(
                onTap: () => _editName(index),
                child: CircleAvatar(
                  backgroundColor: teamColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: teamColor),
                ),
              ),
              SizedBox(width: 12),

              // Nombre y etiqueta de equipo
              Expanded(
                child: GestureDetector(
                  onTap: () => _editName(index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: teamColor,
                        ),
                      ),
                      if (isTeamMode && isPairedTeam)
                        Text(
                          'Equipo ${(index ~/ 2) + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: teamColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Switch para SALIDA (DERECHA) - SIEMPRE VISIBLE
              Column(
                children: [
                  Switch(
                    value: player.isStarter,
                    onChanged: (_) => _selectStarter(index),
                    activeColor: Colors.green,
                  ),
                  Text(
                    'SALIDA',
                    style: TextStyle(
                      fontSize: 10,
                      color: player.isStarter ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Etiqueta de SALIDA (visible en ambos modos)
          if (player.isStarter)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 14,
                        color: Colors.green[700],
                      ),
                      SizedBox(width: 6),
                      Text(
                        'SALIDA',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===================== START BUTTON =====================

  Widget _startButton() {
    bool canStart = isTeamMode
        ? starterIndex != null
        : individualSelections.where((s) => s).length >= 2 &&
              starterIndex != null;

    return Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canStart ? () {} : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isTeamMode ? Colors.orange : Colors.blue,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Text(
            'INICIAR PARTIDO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: canStart ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== MODEL =====================

class Player {
  String name;
  bool isStarter;

  Player({required this.name, this.isStarter = false});
}
