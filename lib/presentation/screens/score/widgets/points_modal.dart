import 'package:flutter/material.dart';

class PointsModal extends StatefulWidget {
  final String teamName;
  final Color accentColor;

  const PointsModal({
    Key? key,
    required this.teamName,
    this.accentColor = Colors.orange,
  }) : super(key: key);

  @override
  _PointsModalState createState() => _PointsModalState();
}

class _PointsModalState extends State<PointsModal> {
  String currentPoints = '0';

  void _addDigit(String digit) {
    setState(() {
      // Validar que no se puedan ingresar más de 2 dígitos
      if (currentPoints.length >= 2 && currentPoints != '0') {
        // Si ya tiene 2 dígitos, no agregar más
        return;
      }

      if (currentPoints == '0') {
        currentPoints = digit;
      } else {
        currentPoints += digit;
      }
    });
  }

  void _clear() {
    setState(() {
      currentPoints = '0';
    });
  }

  void _backspace() {
    setState(() {
      if (currentPoints.length > 1) {
        currentPoints = currentPoints.substring(0, currentPoints.length - 1);
      } else {
        currentPoints = '0';
      }
    });
  }

  void _confirmPoints() {
    Navigator.pop(context, int.parse(currentPoints));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar para indicar que se puede deslizar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ADD POINTS FOR',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.teamName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Display de puntos
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentPoints,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: currentPoints.length > 2
                                  ? Colors
                                        .red // Cambia a rojo si excede 2 dígitos
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'POINTS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.accentColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Indicador de límite de dígitos
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  '${currentPoints.length}/2',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: currentPoints.length > 2
                                        ? Colors.red
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Mensaje de error si se excede el límite
                          if (currentPoints.length > 2)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Máximo 2 dígitos permitidos',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Teclado numérico
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildNumberButton('1'),
                        _buildNumberButton('2'),
                        _buildNumberButton('3'),
                        _buildNumberButton('4'),
                        _buildNumberButton('5'),
                        _buildNumberButton('6'),
                        _buildNumberButton('7'),
                        _buildNumberButton('8'),
                        _buildNumberButton('9'),
                        _buildActionButton('CLEAR', _clear),
                        _buildNumberButton('0'),
                        _buildActionButton('⌫', _backspace, isIcon: true),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Botón confirmar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: currentPoints.length <= 2
                            ? _confirmPoints
                            : null,
                        icon: Icon(Icons.check_circle, size: 18),
                        label: Text(
                          'CONFIRM POINTS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    bool isDisabled = currentPoints.length >= 2 && currentPoints != '0';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : () => _addDigit(number),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[100] : Colors.white,
            border: Border.all(
              color: isDisabled ? Colors.grey[200]! : Colors.grey[300]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDisabled ? Colors.grey[400] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onTap, {
    bool isIcon = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: isIcon
              ? Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: Colors.grey[700],
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// Función helper para mostrar el modal desde abajo
Future<int?> showPointsModal(
  BuildContext context, {
  required String teamName,
  required Color accentColor,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      return PointsModal(teamName: teamName, accentColor: accentColor);
    },
  );
}
