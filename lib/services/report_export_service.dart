import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/ration_repository.dart';
import '../utils/ration_cycle.dart';

class ReportExportService {
  final RationRepository _repository = RationRepository.instance;

  /// Export PDF Report
  Future<void> exportPdf() async {
    final pdf = pw.Document();

    final allCards = await _repository.getAllCards();
    final pendingCards = await _repository.getPendingCards();
    final receivedCount = await _repository.receivedCards();
    final totalCount = allCards.length;
    final pendingCount = pendingCards.length;

    final progressPct = totalCount > 0 ? (receivedCount / totalCount * 100).toStringAsFixed(1) : "0.0";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Ration Attendance Report",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.Text(
                    DateFormat("dd MMM yyyy").format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Cycle Details Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Cycle: ${RationCycle.currentCycle.replaceAll('→', 'to')}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    "Status: ${RationCycle.status}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: RationCycle.isDistributionOpen ? PdfColors.green700 : PdfColors.red700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Statistics Summary
            pw.Row(
              children: [
                _buildPdfStatBox("Total Cards", "$totalCount", PdfColors.blue100, PdfColors.blue800),
                pw.SizedBox(width: 10),
                _buildPdfStatBox("Received", "$receivedCount", PdfColors.green100, PdfColors.green800),
                pw.SizedBox(width: 10),
                _buildPdfStatBox("Pending", "$pendingCount", PdfColors.orange100, PdfColors.orange800),
                pw.SizedBox(width: 10),
                _buildPdfStatBox("Completion", "$progressPct%", PdfColors.teal100, PdfColors.teal800),
              ],
            ),
            pw.SizedBox(height: 20),

            // Pending Beneficiaries Table
            pw.Text(
              "Pending Beneficiaries ($pendingCount)",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (pendingCards.isEmpty)
              pw.Text("All beneficiaries have received their ration!", style: const pw.TextStyle(color: PdfColors.green700))
            else
              pw.TableHelper.fromTextArray(
                headers: ["Card #", "Head Name", "Mobile", "Units", "Rice (KG)"],
                data: pendingCards
                    .map((card) => [
                          card.cardNumber,
                          card.headName,
                          card.mobile,
                          "${card.units}",
                          "${card.rice}",
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
              ),
          ];
        },
      ),
    );

    // Save PDF file locally and open
    final pdfBytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "Ration_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
    final filePath = "${directory.path}/$fileName";

    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    final openResult = await OpenFilex.open(filePath);
    if (openResult.type != ResultType.done) {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    }
  }

  static pw.Widget _buildPdfStatBox(String title, String value, PdfColor bgColor, PdfColor textColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 10, color: textColor)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  /// Export Excel Report
  Future<void> exportExcel() async {
    final excel = Excel.createExcel();

    final allCards = await _repository.getAllCards();
    final pendingCards = await _repository.getPendingCards();
    final receivedCount = await _repository.receivedCards();
    final totalCount = allCards.length;
    final pendingCount = pendingCards.length;

    // Create Sheets
    final Sheet summarySheet = excel['Summary'];
    excel.setDefaultSheet('Summary');

    summarySheet.appendRow(['Ration Attendance Report']);
    summarySheet.appendRow(['Generated On: ${DateFormat("dd MMM yyyy HH:mm").format(DateTime.now())}']);
    summarySheet.appendRow(['Cycle: ${RationCycle.currentCycle}']);
    summarySheet.appendRow(['Status: ${RationCycle.status}']);
    summarySheet.appendRow([]);
    summarySheet.appendRow(['Metric', 'Value']);
    summarySheet.appendRow(['Total Cards', '$totalCount']);
    summarySheet.appendRow(['Received Cards', '$receivedCount']);
    summarySheet.appendRow(['Pending Cards', '$pendingCount']);

    // Pending Sheet
    final Sheet pendingSheet = excel['Pending List'];
    pendingSheet.appendRow([
      'Card Number',
      'Head Name',
      'Relation',
      'Mobile',
      'Category',
      'Units',
      'Rice (KG)',
      'Address',
    ]);

    for (final card in pendingCards) {
      pendingSheet.appendRow([
        card.cardNumber,
        card.headName,
        card.relation,
        card.mobile,
        card.category,
        '${card.units}',
        '${card.rice}',
        card.address,
      ]);
    }

    // All Cards Sheet (app-friendly format)
    final Sheet allSheet = excel['All Cards'];
    allSheet.appendRow([
      'Card Number',
      'Head Name',
      'Relation',
      'Mobile',
      'Category',
      'Units',
      'Rice (KG)',
      'Address',
      'Source',
    ]);

    for (final card in allCards) {
      allSheet.appendRow([
        card.cardNumber,
        card.headName,
        card.relation,
        card.mobile,
        card.category,
        '${card.units}',
        '${card.rice}',
        card.address,
        card.id != null ? 'Database' : 'New',
      ]);
    }

    // Master List Sheet (matches original import format for re-import)
    final Sheet masterSheet = excel['Master List'];
    masterSheet.appendRow([
      'S.No',
      '',
      'Card Number',
      'Head Name',
      'Relation',
      'Mobile',
      'Category',
      'Units',
      'Rice (KG)',
      'Address',
    ]);

    int sNo = 1;
    for (final card in allCards) {
      masterSheet.appendRow([
        '$sNo',
        '',
        card.cardNumber,
        card.headName,
        card.relation,
        card.mobile,
        card.category,
        '${card.units}',
        '${card.rice}',
        card.address,
      ]);
      sNo++;
    }

    final fileBytes = excel.save();
    if (fileBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Ration_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    await OpenFilex.open(filePath);
  }
}
