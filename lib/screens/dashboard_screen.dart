import 'package:flutter/material.dart';

import '../database/ration_repository.dart';
import '../services/audio_service.dart';
import '../utils/language_manager.dart';
import '../utils/ration_cycle.dart';

import 'add_card_screen.dart';
import 'backup_screen.dart';
import 'history_dashboard_screen.dart';
import 'import_screen.dart';
import 'pending_screen.dart';
import 'qr_scanner_screen.dart';

import 'reports_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RationRepository repository = RationRepository.instance;
  final LanguageManager _lang = LanguageManager.instance;

  int totalCards = 0;
  int received = 0;
  int pending = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    totalCards = await repository.totalCards();
    received = await repository.receivedCards();
    pending = await repository.pendingCards();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  String get cyclePeriod {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    final start = months[RationCycle.cycleMonth];
    final end = months[RationCycle.cycleMonth == 12 ? 1 : RationCycle.cycleMonth + 1];

    return "25 $start → 16 $end";
  }

  Widget cycleBanner() {
    return Card(
      elevation: 4,
      color: RationCycle.isDistributionOpen
          ? Colors.green.shade50
          : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              RationCycle.isDistributionOpen
                  ? Icons.check_circle
                  : Icons.lock_clock,
              color: RationCycle.isDistributionOpen
                  ? Colors.green
                  : Colors.red,
              size: 45,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RationCycle.isDistributionOpen
                        ? _lang.getText('cycle_open')
                        : _lang.getText('cycle_closed'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: RationCycle.isDistributionOpen
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Cycle : $cyclePeriod",
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_lang.getText('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: !_lang.isTelugu ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                _lang.setLanguage(AppLanguage.english);
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('తెలుగు (Telugu)'),
              trailing: _lang.isTelugu ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                _lang.setLanguage(AppLanguage.telugu);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: _lang,
      builder: (context, language, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/app_logo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Text(_lang.getText('app_title')),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: "Voice Announcements",
                icon: Icon(
                  AudioService.instance.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AudioService.instance.isMuted ? Colors.grey : Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    AudioService.instance.toggleMute();
                  });
                  final isMuted = AudioService.instance.isMuted;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text(
                        isMuted
                            ? "Voice Announcements Muted"
                            : "Voice Announcements Enabled",
                      ),
                    ),
                  );
                  if (!isMuted) {
                    AudioService.instance.speak(
                      "Voice announcements enabled",
                      "శబ్ద ప్రకటనలు ప్రారంభించబడ్డాయి",
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ActionChip(
                  avatar: const Icon(Icons.translate, size: 18, color: Colors.green),
                  label: Text(
                    _lang.isTelugu ? 'తెలుగు' : 'English',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  backgroundColor: Colors.green.shade50,
                  onPressed: _showLanguageSelector,
                ),
              ),
            ],
          ),
          body: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        elevation: 3,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/app_logo.png',
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      cycleBanner(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: dashboardCard(
                              _lang.getText('total_cards'),
                              totalCards.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: dashboardCard(
                              _lang.getText('received'),
                              received.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      dashboardCard(
                        _lang.getText('pending'),
                        pending.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      const SizedBox(height: 30),
                      menuButton(
                        Icons.translate,
                        _lang.isTelugu ? 'Switch to English' : 'తెలుగు భాషకు మార్చండి',
                        _showLanguageSelector,
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.upload_file,
                        _lang.getText('import_excel'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ImportScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.person_add,
                        _lang.getText('add_beneficiary'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddCardScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.search,
                        _lang.getText('search_card'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.list_alt,
                        _lang.getText('pending_list'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PendingScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.trending_up,
                        _lang.getText('history_dashboard'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryDashboardScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.bar_chart,
                        _lang.getText('reports_export'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportsScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 15),
                      menuButton(
                        Icons.settings_backup_restore,
                        _lang.getText('backup_restore'),
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BackupScreen(),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QRScannerScreen(),
                ),
              );
              await loadDashboard();
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(
              _lang.getText('scan_qr'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (index) async {
              if (index == 1) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
                await loadDashboard();
              } else if (index == 2) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
                await loadDashboard();
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home),
                label: _lang.getText('home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.search),
                label: _lang.getText('search'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart),
                label: _lang.getText('reports'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.10),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuButton(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 26,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}