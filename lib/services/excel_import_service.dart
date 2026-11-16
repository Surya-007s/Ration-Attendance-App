import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../models/ration_card.dart';

class ExcelImportService {
  Future<List<RationCard>> importExcel() async {
    List<RationCard> cards = [];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return cards;

    File file = File(result.files.single.path!);

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    for (final sheet in excel.tables.values) {
      bool firstRow = true;

      for (final row in sheet.rows) {
        if (firstRow) {
          firstRow = false;
          continue;
        }

        if (row.length < 10) continue;

        String cardNumber =
            row[2]?.value?.toString().replaceAll(".0", "").trim() ?? "";

        String headName =
            row[3]?.value?.toString().trim() ?? "";

        String relation =
            row[4]?.value?.toString().trim() ?? "";

        String mobile =
            row[5]?.value?.toString().replaceAll(".0", "").trim() ?? "";

        String category =
            row[6]?.value?.toString().trim() ?? "";

        int units = int.tryParse(
                row[7]?.value?.toString().replaceAll(".0", "") ?? "0") ??
            0;

        int rice = int.tryParse(
                row[8]?.value?.toString().replaceAll(".0", "") ?? "0") ??
            0;

        String address =
            row[9]?.value?.toString().trim() ?? "";

        // Skip completely empty rows
        if (cardNumber.isEmpty &&
            headName.isEmpty &&
            relation.isEmpty &&
            mobile.isEmpty &&
            address.isEmpty) {
          continue;
        }

        // Skip group/category header rows
        // (They have no useful data except a title)
        if (cardNumber.isEmpty &&
            relation.isEmpty &&
            mobile.isEmpty &&
            category.isEmpty &&
            units == 0 &&
            rice == 0) {
          continue;
        }

        cards.add(RationCard(
          cardNumber: cardNumber,
          headName: headName,
          relation: relation,
          mobile: mobile,
          category: category,
          units: units,
          rice: rice,
          address: address,
        ));
      }
    }

    return cards;
  }
}