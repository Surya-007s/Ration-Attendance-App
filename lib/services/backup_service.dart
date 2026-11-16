import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class BackupResult {
  final bool success;
  final String message;
  final int cardsCount;
  final int attendanceCount;
  final int historyCount;

  BackupResult({
    required this.success,
    required this.message,
    this.cardsCount = 0,
    this.attendanceCount = 0,
    this.historyCount = 0,
  });
}

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Export all database tables into a formatted JSON backup file
  Future<BackupResult> exportBackup() async {
    try {
      final db = await _dbHelper.database;

      final cards = await db.query('ration_cards');
      final attendance = await db.query('attendance');
      final history = await db.query('attendance_history');

      final Map<String, dynamic> backupData = {
        'version': 1,
        'app': 'ration_attendance',
        'exported_at': DateTime.now().toIso8601String(),
        'ration_cards': cards,
        'attendance': attendance,
        'attendance_history': history,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'ration_backup_$timestamp.json';

      String? savePath;
      try {
        savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Ration Attendance Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
      } catch (_) {}

      if (savePath == null || savePath.isEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/$fileName';
      }

      final file = File(savePath);
      await file.writeAsString(jsonString);

      return BackupResult(
        success: true,
        message: 'Backup exported successfully to:\n$savePath',
        cardsCount: cards.length,
        attendanceCount: attendance.length,
        historyCount: history.length,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Export Backup Failed: $e',
      );
    }
  }

  /// Import and restore database from a JSON backup file
  Future<BackupResult> restoreBackup() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (pickerResult == null || pickerResult.files.isEmpty) {
        return BackupResult(
          success: false,
          message: 'No backup file selected.',
        );
      }

      final filePath = pickerResult.files.single.path;
      if (filePath == null) {
        return BackupResult(
          success: false,
          message: 'Unable to read selected file.',
        );
      }

      final file = File(filePath);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic> ||
          decoded['app'] != 'ration_attendance' ||
          !decoded.containsKey('ration_cards')) {
        return BackupResult(
          success: false,
          message: 'Invalid backup file format.',
        );
      }

      final List cards = decoded['ration_cards'] ?? [];
      final List attendance = decoded['attendance'] ?? [];
      final List history = decoded['attendance_history'] ?? [];

      final db = await _dbHelper.database;
      final batch = db.batch();

      for (final raw in cards) {
        if (raw is Map) {
          final cardMap = Map<String, dynamic>.from(raw)..remove('id');
          batch.insert(
            'ration_cards',
            cardMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (final raw in attendance) {
        if (raw is Map) {
          final attMap = Map<String, dynamic>.from(raw)..remove('id');
          batch.insert(
            'attendance',
            attMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (final raw in history) {
        if (raw is Map) {
          final histMap = Map<String, dynamic>.from(raw)..remove('id');
          batch.insert(
            'attendance_history',
            histMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await batch.commit(noResult: true);

      return BackupResult(
        success: true,
        message: 'Database restored successfully!',
        cardsCount: cards.length,
        attendanceCount: attendance.length,
        historyCount: history.length,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Restore Backup Failed: $e',
      );
    }
  }
}
