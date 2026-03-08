import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/team_data.dart';
import 'tabs/historial_tab.dart';
import 'tabs/ranking_tab.dart';
import 'tabs/jugadores_tab.dart';
import './premium_guard.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> roundHistory;
  final TeamData teamData;

  const HistoryScreen({
    Key? key,
    required this.roundHistory,
    required this.teamData,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFf97316);
  static const Color bgMainColor = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);
  static const Color charcoalColor = Color(0xFF0f172a);

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // ✅ Confirmar cierre de sesión
  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: charcoalColor,
          ),
        ),
        content: Text(
          '¿Estás seguro que quieres cerrar sesión?',
          style: TextStyle(fontSize: 13, color: slate500),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    backgroundColor: slate100,
                    foregroundColor: slate500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFef4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Elimina toda la pila de navegación y va al login
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMainColor,
      body: Column(
        children: [
          // ─── Header ───
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_left,
                            color: primaryColor,
                            size: 24,
                          ),
                          Text(
                            'Partida',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Título
                    const Text(
                      'ESTADÍSTICAS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: slate400,
                        letterSpacing: 2,
                      ),
                    ),

                    // ✅ Logout
                    TextButton(
                      onPressed: () => _confirmarLogout(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        foregroundColor: const Color(0xFFef4444),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 16,
                            color: Color(0xFFef4444),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Salir',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFef4444),
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

          // ─── Contenido del tab activo ───
          Expanded(
            child: _tabController != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                       PremiumGuard(
                        lockedMessage: 'Historial Premium',
                        lockedSubtitle:
                            'Suscríbete para ver las estadisticas por equipo',
                        lockedIcon: Icons.leaderboard,
                        child: HistorialTab(),
                      ),

                      // ✅ Historial disponible para todos


                      // 🔒 Ranking — solo Premium
                      PremiumGuard(
                        lockedMessage: 'Ranking Premium',
                        lockedSubtitle:
                            'Suscríbete para ver quién domina la mesa — individual y por equipo',
                        lockedIcon: Icons.leaderboard,
                        child: RankingTab(),
                      ),

                      // 🔒 Jugadores — solo Premium
                     const JugadoresTab(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),

      // ─── TabBar abajo ───
      bottomNavigationBar: _tabController != null
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: slate100, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3,
                  labelColor: primaryColor,
                  unselectedLabelColor: slate400,
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    // 🔒 Historial con badge PRO
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.history, size: 22),
                              Positioned(
                                top: -4,
                                right: -10,
                                child: PremiumBadge(),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('HISTORIAL', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    // 🔒 Ranking con badge PRO
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.leaderboard, size: 22),
                              Positioned(
                                top: -4,
                                right: -10,
                                child: PremiumBadge(),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('RANKING', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    // ✅ Jugadores — libre
                    const Tab(
                      icon: Icon(Icons.people_alt_outlined, size: 22),
                      text: 'JUGADORES',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
