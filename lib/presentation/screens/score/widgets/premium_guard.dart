import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/subscription_service.dart';
import 'package:flutter_application_1/presentation/screens/score/widgets/paywall_screen.dart';

class PremiumGuard extends StatefulWidget {
  final Widget child;
  final String? lockedMessage;
  final String? lockedSubtitle;
  final IconData? lockedIcon;

  const PremiumGuard({
    Key? key,
    required this.child,
    this.lockedMessage,
    this.lockedSubtitle,
    this.lockedIcon,
  }) : super(key: key);

  @override
  State<PremiumGuard> createState() => _PremiumGuardState();
}

class _PremiumGuardState extends State<PremiumGuard> {
  static const Color primaryColor = Color(0xFFf97316);
  static const Color primaryLight = Color(0xFFfff7ed);
  static const Color charcoalColor = Color(0xFF0f172a);
  static const Color slate500 = Color(0xFF64748b);
  static const Color slate400 = Color(0xFF94a3b8);

  bool? _isPremium;

  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    final premium = await SubscriptionService().isPremium();
    if (mounted) setState(() => _isPremium = premium);
  }

  Future<void> _abrirPaywall() async {
    final compro = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (compro == true && mounted) _verificar();
  }

  @override
  Widget build(BuildContext context) {
    // Cargando
    if (_isPremium == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    // ✅ Tiene premium — contenido normal
    if (_isPremium!) return widget.child;

    // 🔒 No tiene premium — blur estilo Tinder/LinkedIn
    return Stack(
      children: [
        // ── Contenido real detrás del blur (genera curiosidad) ──
        widget.child,

        // ── Capa de blur ──
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withOpacity(0.15)),
            ),
          ),
        ),

        // ── Overlay degradado inferior ──
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.95),
                ],
                stops: const [0.0, 0.45, 0.75],
              ),
            ),
          ),
        ),

        // ── Card de desbloqueo centrado ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono con glow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.lockedIcon ?? Icons.lock_outline,
                    size: 34,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  widget.lockedMessage ?? 'Función Premium',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: charcoalColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtítulo
                Text(
                  widget.lockedSubtitle ??
                      'Suscríbete para desbloquear esta función',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: slate500, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _abrirPaywall,
                    icon: const Icon(Icons.workspace_premium, size: 18),
                    label: const Text(
                      'Desbloquear Premium',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Restaurar
                TextButton(
                  onPressed: () async {
                    final result = await SubscriptionService().restaurar();
                    if (result.isSuccess && mounted) _verificar();
                  },
                  child: Text(
                    'Restaurar compra anterior',
                    style: TextStyle(
                      fontSize: 12,
                      color: slate400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PremiumBadge — badge PRO en tabs
// ══════════════════════════════════════════════════════════════

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFf97316),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
