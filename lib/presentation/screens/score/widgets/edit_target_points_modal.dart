import 'package:flutter/material.dart';

class EditTargetPointsModal extends StatefulWidget {
  final int currentScore;
  final Function(int) onSave;
  final Function() onCancel;

  const EditTargetPointsModal({
    Key? key,
    required this.currentScore,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  _EditTargetPointsModalState createState() => _EditTargetPointsModalState();
}

class _EditTargetPointsModalState extends State<EditTargetPointsModal> {
  late int _selectedScore;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.currentScore;
    _textController.text = _selectedScore.toString();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _incrementScore() {
    setState(() {
      _selectedScore += 25;
      _textController.text = _selectedScore.toString();
    });
  }

  void _decrementScore() {
    if (_selectedScore > 25) {
      setState(() {
        _selectedScore -= 25;
        _textController.text = _selectedScore.toString();
      });
    }
  }

  void _setPresetScore(int score) {
    setState(() {
      _selectedScore = score;
      _textController.text = _selectedScore.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Espacio para deslizar hacia abajo para cerrar
            GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                height: 15,
                color: Colors.transparent,
              ),
            ),

            // Contenido del modal
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de deslizamiento
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Límite de Puntos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0f172a),
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    const Text(
                      'Define el puntaje para ganar la partida',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748b),
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Contenedor de puntos
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8fafc),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFe2e8f0),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Etiqueta "Puntos Objetivo"
                          const Text(
                            'PUNTOS OBJETIVO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94a3b8),
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Controles de incremento/decremento
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botón decremento
                              GestureDetector(
                                onTap: _decrementScore,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFcbd5e1),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 28,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 32),

                              // Input de puntos
                              SizedBox(
                                width: 96,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _textController,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0f172a),
                                        fontFamily: 'PlusJakartaSans',
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        final parsed = int.tryParse(value);
                                        if (parsed != null && parsed > 0) {
                                          setState(() {
                                            _selectedScore = parsed;
                                          });
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    // Indicador visual
                                    Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFf97316).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 32),

                              // Botón incremento
                              GestureDetector(
                                onTap: _incrementScore,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFcbd5e1),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 28,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Botones predefinidos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPresetButton(50),
                              const SizedBox(width: 12),
                              _buildPresetButton(100),
                              const SizedBox(width: 12),
                              _buildPresetButton(150),
                              const SizedBox(width: 12),
                              _buildPresetButton(200),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botones de acción
                    Column(
                      children: [
                        // Botón principal
                        GestureDetector(
                          onTap: () {
                            widget.onSave(_selectedScore);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf97316),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFf97316).withOpacity(0.15),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ESTABLECER LÍMITE',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón cancelar
                        GestureDetector(
                          onTap: widget.onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94a3b8),
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(int score) {
    final isSelected = _selectedScore == score;

    return GestureDetector(
      onTap: () => _setPresetScore(score),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFf97316) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFf97316) : const Color(0xFFe2e8f0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFf97316).withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF64748b),
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
      ),
    );
  }
}
