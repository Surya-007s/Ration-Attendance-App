import 'package:flutter/material.dart';

import '../database/ration_repository.dart';
import '../services/report_export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final RationRepository repository = RationRepository.instance;
  final ReportExportService exportService = ReportExportService();

  int total = 0;
  int received = 0;
  int pending = 0;

  bool loading = true;
  bool exporting = false;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    total = await repository.totalCards();
    received = await repository.receivedCards();
    pending = await repository.pendingCards();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0;

    if (total > 0) {
      progress = received / total;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadReport,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  reportCard(
                    "Total Cards",
                    total.toString(),
                    Icons.people,
                    Colors.blue,
                  ),

                  reportCard(
                    "Received",
                    received.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),

                  reportCard(
                    "Pending",
                    pending.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Distribution Progress",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "${(progress * 100).toStringAsFixed(1)} %",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: exporting
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => exporting = true);
                            try {
                              await exportService.exportPdf();
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text("PDF Export Failed: $e")),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => exporting = false);
                            }
                          },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(exporting ? "Generating PDF..." : "Export PDF"),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: exporting
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => exporting = true);
                            try {
                              await exportService.exportExcel();
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text("Excel Export Failed: $e")),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => exporting = false);
                            }
                          },
                    icon: const Icon(Icons.table_chart),
                    label: Text(exporting ? "Generating Excel..." : "Export Excel"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget reportCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}