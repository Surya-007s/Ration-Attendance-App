import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/ration_repository.dart';
import '../utils/language_manager.dart';

/// A data class for monthly distribution statistics.
class _MonthStat {
  final int month;
  final int year;
  final int received;
  final int total;
  final int riceKg;

  _MonthStat({
    required this.month,
    required this.year,
    required this.received,
    required this.total,
    required this.riceKg,
  });

  int get pending => total - received;
  double get percentage => total > 0 ? (received / total) * 100 : 0;

  String get monthName => DateFormat('MMM').format(DateTime(year, month));
  String get monthFullName => DateFormat('MMMM').format(DateTime(year, month));
}

class HistoryDashboardScreen extends StatefulWidget {
  const HistoryDashboardScreen({super.key});

  @override
  State<HistoryDashboardScreen> createState() => _HistoryDashboardScreenState();
}

class _HistoryDashboardScreenState extends State<HistoryDashboardScreen>
    with SingleTickerProviderStateMixin {
  final RationRepository _repo = RationRepository.instance;
  final LanguageManager _lang = LanguageManager.instance;

  List<int> _years = [];
  int _selectedYear = DateTime.now().year;
  List<_MonthStat> _monthStats = [];
  bool _loading = true;

  late AnimationController _animController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _barAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final years = await _repo.getAvailableYears();
    final totalCards = await _repo.totalCards();
    final stats = await _repo.getMonthlyStats(_selectedYear);

    // Build full 12-month list
    final List<_MonthStat> fullStats = [];
    for (int m = 1; m <= 12; m++) {
      final match = stats.where((s) => s['month'] == m);
      final received = match.isNotEmpty ? match.first['received_count']! : 0;
      final riceKg = await _repo.getRiceDistributed(m, _selectedYear);
      fullStats.add(_MonthStat(
        month: m,
        year: _selectedYear,
        received: received,
        total: totalCards,
        riceKg: riceKg,
      ));
    }

    if (!mounted) return;

    setState(() {
      _years = years;
      _monthStats = fullStats;
      _loading = false;
    });

    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_lang.getText('history_dashboard')),
        actions: [
          // Year selector chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<int>(
              initialValue: _selectedYear,
              onSelected: (year) {
                _selectedYear = year;
                _loadData();
              },
              itemBuilder: (ctx) => _years.map((y) {
                return PopupMenuItem<int>(
                  value: y,
                  child: Text(
                    '$y',
                    style: TextStyle(
                      fontWeight: y == _selectedYear
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              child: Chip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text('$_selectedYear'),
                backgroundColor: colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Summary Cards ──
                  _buildYearlySummary(colorScheme),
                  const SizedBox(height: 24),

                  // ── Bar Chart ──
                  Text(
                    _lang.getText('monthly_distribution'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBarChart(colorScheme),
                  const SizedBox(height: 24),

                  // ── Month Detail Cards ──
                  Text(
                    _lang.getText('month_details'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildMonthCards(colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Yearly Summary Row ──
  Widget _buildYearlySummary(ColorScheme cs) {
    final totalReceived = _monthStats.fold<int>(0, (s, m) => s + m.received);
    final totalRice = _monthStats.fold<int>(0, (s, m) => s + m.riceKg);
    final activeMonths = _monthStats.where((m) => m.received > 0).length;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.people,
            label: _lang.getText('total_distributed'),
            value: '$totalReceived',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            icon: Icons.rice_bowl,
            label: _lang.getText('total_rice_kg'),
            value: '$totalRice kg',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            icon: Icons.date_range,
            label: _lang.getText('active_months'),
            value: '$activeMonths',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated Bar Chart ──
  Widget _buildBarChart(ColorScheme cs) {
    final maxReceived = _monthStats.fold<int>(
      1,
      (prev, s) => s.received > prev ? s.received : prev,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _barAnimation,
          builder: (context, child) {
            return SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _monthStats.map((stat) {
                  final barHeight = maxReceived > 0
                      ? (stat.received / maxReceived) * 160 * _barAnimation.value
                      : 0.0;

                  final isCurrentMonth = stat.month == DateTime.now().month &&
                      stat.year == DateTime.now().year;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _showMonthDetail(stat),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Value on top
                          if (stat.received > 0)
                            Text(
                              '${stat.received}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isCurrentMonth
                                    ? cs.primary
                                    : Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isCurrentMonth
                                    ? [cs.primary, cs.primary.withAlpha(180)]
                                    : stat.received > 0
                                        ? [
                                            Colors.green.shade400,
                                            Colors.green.shade200,
                                          ]
                                        : [
                                            Colors.grey.shade300,
                                            Colors.grey.shade200,
                                          ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Month label
                          Text(
                            stat.monthName,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentMonth
                                  ? cs.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Month Detail Cards (scrollable list) ──
  List<Widget> _buildMonthCards(ColorScheme cs) {
    // Show only months with data, sorted by most recent first
    final activeMonths =
        _monthStats.where((m) => m.received > 0).toList().reversed.toList();

    if (activeMonths.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _lang.getText('no_history_data'),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return activeMonths.map((stat) {
      final percentage = stat.percentage;
      final color = percentage >= 90
          ? Colors.green
          : percentage >= 60
              ? Colors.orange
              : Colors.red;

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showMonthDetail(stat),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Month circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(30),
                  ),
                  child: Center(
                    child: Text(
                      stat.monthName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stat.monthFullName} $_selectedYear',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _statChip(Icons.check_circle, '${stat.received}',
                              Colors.green),
                          const SizedBox(width: 12),
                          _statChip(Icons.pending, '${stat.pending}',
                              Colors.orange),
                          const SizedBox(width: 12),
                          _statChip(Icons.rice_bowl, '${stat.riceKg} kg',
                              Colors.brown),
                        ],
                      ),
                    ],
                  ),
                ),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  // ── Month Detail Bottom Sheet ──
  void _showMonthDetail(_MonthStat stat) {
    final percentage = stat.percentage;
    final color = percentage >= 90
        ? Colors.green
        : percentage >= 60
            ? Colors.orange
            : Colors.red;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '${stat.monthFullName} ${stat.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Circular progress
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Detail rows
            _detailRow(Icons.people, _lang.getText('total_cards'),
                '${stat.total}'),
            _detailRow(Icons.check_circle, _lang.getText('received'),
                '${stat.received}', Colors.green),
            _detailRow(Icons.pending_actions, _lang.getText('pending'),
                '${stat.pending}', Colors.orange),
            _detailRow(Icons.rice_bowl,
                _lang.getText('rice_distributed'), '${stat.riceKg} kg',
                Colors.brown),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
