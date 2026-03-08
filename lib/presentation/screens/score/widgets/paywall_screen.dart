import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  final _sub = SubscriptionService();

  static const Color primaryColor  = Color(0xFFf97316);
  static const Color primaryDark   = Color(0xFFea580c);
  static const Color primaryLight  = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate400      = Color(0xFF94a3b8);
  static const Color slate500      = Color(0xFF64748b);
  static const Color slate100      = Color(0xFFf1f5f9);
  static const Color greenColor    = Color(0xFF22c55e);

  bool _loading   = false;
  bool _restoring = false;
  String _precio  = '\$0.99';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _cargarPrecio();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _cargarPrecio() async {
    final precio = await _sub.getPrecio();
    if (mounted) setState(() => _precio = precio);
  }

  Future<void> _comprar() async {
    setState(() => _loading = true);
    final result = await _sub.comprar();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      _mostrarExito();
    } else if (result.isError) {
      _mostrarError(result.message ?? 'Error al procesar el pago');
    }
  }

  Future<void> _restaurar() async {
    setState(() => _restoring = true);
    final result = await _sub.restaurar();
    if (!mounted) return;
    setState(() => _restoring = false);
    if (result.isSuccess) {
      _mostrarExito();
    } else {
      _mostrarError(result.message ?? 'No se encontraron compras anteriores');
    }
  }

  void _mostrarExito() {
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('¡Bienvenido a Premium!',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ]),
      backgroundColor: greenColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFef4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // ─── Header con gradiente naranja ───
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryDark],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cerrar
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70, size: 22),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        const SizedBox(height: 8),
                        // Ícono
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.workspace_premium,
                                    color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Domino Score Premium',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Desbloquea todo el potencial',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Contenido ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      // ── Beneficios ──
                      _beneficio(Icons.history,       'Historial completo',     'Revisa cada partida de las últimas 12 horas'),
                      _beneficio(Icons.leaderboard,   'Ranking individual',     'Descubre quién gana más en la mesa'),
                      _beneficio(Icons.groups,        'Ranking por equipos',    'Las mejores duplas de todos los tiempos'),
                      _beneficio(Icons.bar_chart,     'Estadísticas detalladas','Win rate y rendimiento por jugador'),
                      _beneficio(Icons.people_alt,    'Hasta 20 jugadores',     'La versión gratuita permite hasta 8'),

                      const SizedBox(height: 28),

                      // ── Card de precio estilo Google/Apple ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: slate100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Precio grande
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text('\$',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: charcoalColor)),
                                ),
                                Text(
                                  _precio.replaceAll(RegExp(r'[^\d.]'), ''),
                                  style: const TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: charcoalColor,
                                      height: 1),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 14),
                                  child: Text('/mes',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: slate400,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cancela cuando quieras · Sin compromisos',
                              style: TextStyle(fontSize: 12, color: slate500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // Métodos de pago aceptados
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Pago seguro vía ',
                                    style: TextStyle(
                                        fontSize: 11, color: slate400)),
                                const Icon(Icons.lock,
                                    size: 12, color: greenColor),
                                Text(' Google Play',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: greenColor,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Íconos de confianza ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _trustBadge(Icons.security, 'Pago\nseguro'),
                          _trustBadge(Icons.cancel_outlined, 'Cancela\nfácil'),
                          _trustBadge(Icons.refresh, 'Renovación\nauto'),
                          _trustBadge(Icons.support_agent, 'Soporte\n24/7'),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Botón principal ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _comprar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primaryColor.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white),
                                )
                              : Text(
                                  'Suscribirse por $_precio/mes',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Restaurar ──
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _restoring ? null : _restaurar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: slate500,
                            side: BorderSide(color: slate400.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _restoring
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: slate400),
                                )
                              : const Text('Restaurar compra anterior',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Aviso legal ──
                      Text(
                        'La suscripción se renueva automáticamente cada mes. '
                        'Puedes cancelarla en cualquier momento desde '
                        'Google Play → Suscripciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: slate400,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _beneficio(IconData icon, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: charcoalColor)),
                Text(subtitulo,
                    style: TextStyle(fontSize: 12, color: slate500)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: greenColor, size: 20),
        ],
      ),
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: slate100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: slate500),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 9,
                color: slate400,
                fontWeight: FontWeight.w600,
                height: 1.3)),
      ],
    );
  }
}
