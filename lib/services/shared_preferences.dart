import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../presentation/screens/score/widgets/paywall_screen.dart';



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
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);

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
    if (compro == true) {
      _verificar(); // refresca el estado tras comprar
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cargando
    if (_isPremium == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    // Tiene premium → muestra el contenido normal
    if (_isPremium!) return widget.child;

    // No tiene premium → muestra pantalla bloqueada
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.lockedIcon ?? Icons.lock_outline,
                size: 38,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.lockedMessage ?? 'Función Premium',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: charcoalColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.lockedSubtitle ??
                  'Suscríbete a Premium para desbloquear esta función',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: slate500, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _abrirPaywall,
                icon: const Icon(Icons.workspace_premium, size: 18),
                label: const Text(
                  'Ver planes Premium',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
            const SizedBox(height: 12),
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
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PremiumBadge — badge pequeño para mostrar en tabs bloqueados
// ══════════════════════════════════════════════════════════════

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFf97316),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
