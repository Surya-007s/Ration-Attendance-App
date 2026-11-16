import 'package:flutter/material.dart';
import '../database/ration_repository.dart';
import '../models/ration_card.dart';
import '../services/excel_import_service.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool importing = false;

  Future<void> importData() async {
    setState(() {
      importing = true;
    });

    try {
      debugPrint("========== IMPORT STARTED ==========");

      final service = ExcelImportService();
      final repository = RationRepository.instance;

      debugPrint("Step 1: Opening Excel...");
      List<RationCard> cards = await service.importExcel();

      debugPrint("Step 2: Excel Loaded");
      debugPrint("Total Cards: ${cards.length}");

      if (cards.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text("No cards found in the Excel file."),
          ),
        );
        return;
      }

      if (!mounted) return;

      // Confirm before importing
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.upload_file, color: Colors.green, size: 48),
          title: const Text("Confirm Import"),
          content: Text(
            "Found ${cards.length} beneficiaries in the Excel file.\n\n"
            "This will replace all existing card data. Continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Import"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      debugPrint("Step 3: Deleting old database records...");
      await repository.deleteAllCards();

      debugPrint("Step 4: Saving into SQLite...");
      await repository.insertCards(cards);

      debugPrint("Step 5: Import Completed");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "${cards.length} Cards Imported Successfully",
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("=========== IMPORT ERROR ===========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint("====================================");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Import Failed\n$e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          importing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import Ration Data"),
      ),
      body: Center(
        child: importing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Importing Excel...\nPlease wait.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
            : ElevatedButton.icon(
                onPressed: importData,
                icon: const Icon(Icons.upload_file),
                label: const Text(
                  "IMPORT EXCEL",
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}