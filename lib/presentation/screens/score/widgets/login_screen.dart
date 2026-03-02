import 'package:flutter/material.dart';
import './../../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  bool _loading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    try {
      await _auth.loginGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo degradado sutil
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF5E6),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Línea degradada inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFF49D25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Ícono ficha dominó
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5E6),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: const Color(0xFFF49D25).withOpacity(0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle: 0.21,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF49D25),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF49D25).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Puntos superiores
                                    Positioned(top: 10, left: 10,
                                      child: _dot()),
                                    Positioned(top: 10, right: 10,
                                      child: _dot()),
                                    // Línea divisoria
                                    Center(
                                      child: Container(
                                        height: 1.5,
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    // Punto central
                                    Center(child: _dot()),
                                    // Puntos inferiores
                                    Positioned(bottom: 10, left: 10,
                                      child: _dot()),
                                    Positioned(bottom: 10, right: 10,
                                      child: _dot()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Título
                        const Text(
                          'Bienvenido a',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),
                          const Text(
                          ' Domino Score',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtítulo
                        const Text(
                          'La forma más fácil y moderna de llevar el control de tus partidas de dominó.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 56),

                        // Botón Google
                        _loading
                            ? const CircularProgressIndicator(
                                color: Color(0xFFF49D25),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton(
                                  onPressed: _loginGoogle,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 1,
                                    shadowColor: Colors.black.withOpacity(0.06),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Logo Google SVG como imagen
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CustomPaint(painter: _GoogleLogoPainter()),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continuar con Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                        const SizedBox(height: 20),

                        // Términos
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.6),
                            children: [
                              TextSpan(text: 'Al continuar, aceptas nuestros '),
                              TextSpan(
                                text: 'Términos de Servicio',
                                style: TextStyle(color: Color(0xFFF49D25)),
                              ),
                              TextSpan(text: ' y '),
                              TextSpan(
                                text: 'Política de Privacidad',
                                style: TextStyle(color: Color(0xFFF49D25)),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 11,
    height: 11,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}

// Painter para el logo de Google
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    // Azul
    paint.color = const Color(0xFF4285F4);
    path.moveTo(size.width, size.height * 0.51);
    path.lineTo(size.width, size.height * 0.51);
    canvas.drawPath(path, paint);

    // Usamos un círculo de colores simplificado
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      colors: const [
        Color(0xFF4285F4),
        Color(0xFF34A853),
        Color(0xFFFBBC05),
        Color(0xFFEA4335),
        Color(0xFF4285F4),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Hueco blanco del centro
    paint.shader = null;
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 3.5,
      paint,
    );

    // G letra simplificada
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, size.height * 0.38, size.width * 0.38, size.height * 0.13),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
