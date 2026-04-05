import 'package:flutter/material.dart';

class MesaWidget extends StatefulWidget {
  final String selectedStarter;
  final ValueChanged<String> onStarterSelected;
  final TextEditingController p1Controller;
  final TextEditingController p2Controller;
  final TextEditingController p3Controller;
  final TextEditingController p4Controller;
  final Color primaryColor;
  final Color primaryDark;

  const MesaWidget({
    Key? key,
    required this.selectedStarter,
    required this.onStarterSelected,
    required this.p1Controller,
    required this.p2Controller,
    required this.p3Controller,
    required this.p4Controller,
    required this.primaryColor,
    required this.primaryDark,
  }) : super(key: key);

  @override
  State<MesaWidget> createState() => _MesaWidgetState();
}

class _MesaWidgetState extends State<MesaWidget> {
  int _rotationIndex = 0; // 0, 1, 2, 3 (represents multiples of 90 degrees)

  // Colors constant in this widget (from the main screen)
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

  void _rotate() {
    setState(() {
      _rotationIndex = (_rotationIndex + 1) % 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Central Table background with decorative icon
          Center(
            child: AnimatedRotation(
              turns: _rotationIndex / 4.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutExpo,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: slate100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: slate200),
                ),
                child: const Center(
                  child: Icon(Icons.casino, size: 32, color: slate300),
                ),
              ),
            ),
          ),

          // The rotating inner stack
          AnimatedRotation(
            turns: _rotationIndex / 4.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutExpo,
            child: Stack(
              children: [
                // Top - P2 (Team A)
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _mesaSeat('p2', widget.p2Controller, widget.primaryColor),
                  ),
                ),
                // Bottom - P1 (Team A)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _mesaSeat('p1', widget.p1Controller, widget.primaryColor),
                  ),
                ),
                // Left - P4 (Team B)
                Positioned(
                  left: 14,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _mesaSeat('p4', widget.p4Controller, widget.primaryDark),
                  ),
                ),
                // Right - P3 (Team B)
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _mesaSeat('p3', widget.p3Controller, widget.primaryDark),
                  ),
                ),
              ],
            ),
          ),

          // Control Button to Rotate (Floating in a corner or center)
          // Botón para Rotar y Etiqueta de Ayuda
          Positioned(
            bottom: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Girar mesa',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _rotate,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.rotate_right_rounded,
                          size: 20,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gira la mesa si es necesario',
                  style: TextStyle(
                    fontSize: 9,
                    color: slate400,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mesaSeat(
    String playerId,
    TextEditingController controller,
    Color teamColor,
  ) {
    final isSelected = widget.selectedStarter == playerId;
    final name = controller.text;
    final inicial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => widget.onStarterSelected(playerId),
      // Inverse rotation to keep the content upright
      child: AnimatedRotation(
        turns: -_rotationIndex / 4.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutExpo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? teamColor.withOpacity(0.12) : slate100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? teamColor : slate200,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: teamColor.withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? teamColor : slate400,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: teamColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name.isEmpty ? '—' : name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? teamColor : slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
