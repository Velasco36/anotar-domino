import 'package:flutter/material.dart';
import '../../../../models/team_data.dart';
import 'tabs/historial_tab.dart';
import 'tabs/ranking_tab.dart';
import 'tabs/jugadores_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMainColor,

      // ─── Header ───
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left,
                              color: primaryColor, size: 24),
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
                    Text(
                      'ESTADÍSTICAS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: slate400,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 80),
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
                    children: const [
                      HistorialTab(),
                      RankingTab(),
                      JugadoresTab(),
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
                border: Border(
                  top: BorderSide(color: slate100, width: 1),
                ),
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
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.history, size: 22),
                      text: 'HISTORIAL',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.leaderboard, size: 22),
                      text: 'RANKING',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
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
