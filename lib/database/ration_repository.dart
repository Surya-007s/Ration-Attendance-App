import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/ration_card.dart';
import '../models/attendance_history.dart';
import '../utils/ration_cycle.dart';

class RationRepository {
  RationRepository._();

  static final RationRepository instance = RationRepository._();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // ===========================
  // INSERT SINGLE CARD
  // ===========================

  Future<void> insertCard(RationCard card) async {
    final db = await dbHelper.database;

    await db.insert(
      'ration_cards',
      card.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===========================
  // INSERT MULTIPLE CARDS
  // ===========================

  Future<void> insertCards(List<RationCard> cards) async {
    final db = await dbHelper.database;

    Batch batch = db.batch();

    for (final card in cards) {
      batch.insert(
        'ration_cards',
        card.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // ===========================
  // ADD NEW CARD
  // ===========================

  Future<int> addCard(RationCard card) async {
    final db = await dbHelper.database;

    return await db.insert(
      'ration_cards',
      card.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ===========================
  // GET ALL CARDS
  // ===========================

  Future<List<RationCard>> getAllCards() async {
    final db = await dbHelper.database;

    final result = await db.query(
      'ration_cards',
      orderBy: 'head_name ASC',
    );

    return result.map((map) => RationCard.fromMap(map)).toList();
  }

  // ===========================
  // SEARCH
  // ===========================

  Future<List<RationCard>> searchCards(String query) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'ration_cards',
      where: '''
      card_number LIKE ?
      OR head_name LIKE ?
      OR relation LIKE ?
      OR mobile LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
      ],
      orderBy: 'head_name ASC',
    );

    return result.map((map) => RationCard.fromMap(map)).toList();
  }

  // ===========================
  // TOTAL CARDS
  // ===========================

  Future<int> totalCards() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ration_cards',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===========================
  // DELETE ALL
  // ===========================

  Future<void> deleteAllCards() async {
    final db = await dbHelper.database;

    await db.delete('ration_cards');
  }

  // ===========================
  // MARK RECEIVED
  // ===========================

  Future<void> markReceived(String cardNumber) async {
    if (!RationCycle.isDistributionOpen) {
      throw Exception(
        "Distribution is closed from 17th to 24th.",
      );
    }

    final db = await dbHelper.database;

    final exists = await db.query(
      'attendance',
      where: '''
        card_number = ?
        AND month = ?
        AND year = ?
      ''',
      whereArgs: [
        cardNumber,
        RationCycle.cycleMonth,
        RationCycle.cycleYear,
      ],
    );

    if (exists.isNotEmpty) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert(
      'attendance',
      {
        'card_number': cardNumber,
        'month': RationCycle.cycleMonth,
        'year': RationCycle.cycleYear,
        'received': 1,
        'received_date': now,
      },
    );

    final beneficiary = await getCardByNumber(cardNumber);

    await db.insert(
      'attendance_history',
      {
        'card_number': cardNumber,
        'beneficiary_name': beneficiary?.headName ?? '',
        'month': RationCycle.cycleMonth,
        'year': RationCycle.cycleYear,
        'received_at': now,
        'operator_name': '',
        'remarks': '',
      },
    );
  }

  // ===========================
  // CHECK RECEIVED
  // ===========================

  Future<bool> isReceived(String cardNumber) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'attendance',
      where: '''
      card_number = ?
      AND month = ?
      AND year = ?
      ''',
      whereArgs: [
        cardNumber,
        RationCycle.cycleMonth,
        RationCycle.cycleYear,
      ],
    );

    return result.isNotEmpty;
  }

   // ===========================
  // RECEIVED COUNT
  // ===========================

  Future<int> receivedCards() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*)
      FROM attendance
      WHERE month = ?
      AND year = ?
      ''',
      [
        RationCycle.cycleMonth,
        RationCycle.cycleYear,
      ],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===========================
  // PENDING COUNT
  // ===========================

  Future<int> pendingCards() async {
    final total = await totalCards();
    final received = await receivedCards();

    return total - received;
  }

  // ===========================
  // ATTENDANCE HISTORY
  // ===========================

  Future<List<AttendanceHistory>> getAttendanceHistory(
      String cardNumber) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'attendance_history',
      where: 'card_number = ?',
      whereArgs: [cardNumber],
      orderBy: 'year DESC, month DESC, received_at DESC',
    );

    return result.map((map) => AttendanceHistory.fromMap(map)).toList();
  }

  // ===========================
  // PENDING BENEFICIARIES
  // ===========================

  Future<List<RationCard>> getPendingCards() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT *
      FROM ration_cards
      WHERE card_number NOT IN (
        SELECT card_number
        FROM attendance
        WHERE month = ?
        AND year = ?
      )
      ORDER BY head_name ASC
      ''',
      [
        RationCycle.cycleMonth,
        RationCycle.cycleYear,
      ],
    );

    return result.map((map) => RationCard.fromMap(map)).toList();
  }

  // ===========================
  // UPDATE CARD
  // ===========================

  Future<int> updateCard(RationCard card) async {
    final db = await dbHelper.database;

    return await db.update(
      'ration_cards',
      {
        'card_number': card.cardNumber,
        'head_name': card.headName,
        'relation': card.relation,
        'mobile': card.mobile,
        'category': card.category,
        'units': card.units,
        'rice': card.rice,
        'address': card.address,
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // ===========================
  // GET CARD BY CARD NUMBER
  // ===========================

  Future<RationCard?> getCardByNumber(
      String cardNumber) async {
    final db = await dbHelper.database;
    final trimmed = cardNumber.trim();

    // 1. Exact case-insensitive match
    var result = await db.query(
      'ration_cards',
      where: 'LOWER(card_number) = LOWER(?)',
      whereArgs: [trimmed],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return RationCard.fromMap(result.first);
    }

    // 2. If card number has prefix (e.g. AP, WAP), try matching digits only
    final digitsOnly = trimmed.replaceAll(RegExp(r'^[A-Za-z]+'), '');
    if (digitsOnly.isNotEmpty && digitsOnly != trimmed) {
      result = await db.query(
        'ration_cards',
        where: 'card_number = ? OR LOWER(card_number) = LOWER(?)',
        whereArgs: [digitsOnly, digitsOnly],
        limit: 1,
      );
      if (result.isNotEmpty) return RationCard.fromMap(result.first);
    } else {
      // 3. If card number is digits only, try matching with AP or WAP prefix
      result = await db.query(
        'ration_cards',
        where: 'LOWER(card_number) = LOWER(?) OR LOWER(card_number) = LOWER(?)',
        whereArgs: ['AP$trimmed', 'WAP$trimmed'],
        limit: 1,
      );
      if (result.isNotEmpty) return RationCard.fromMap(result.first);
    }

    return null;
  }

  // ===========================
  // GET CARD BY ID
  // ===========================

  Future<RationCard?> getCardById(int id) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'ration_cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RationCard.fromMap(result.first);
  }

  // ===========================
  // DELETE SINGLE CARD
  // ===========================

  Future<int> deleteCard(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      'ration_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================
  // MONTHLY STATISTICS (for History Dashboard)
  // ===========================

  /// Returns a list of {month, year, received_count} for a given year.
  Future<List<Map<String, int>>> getMonthlyStats(int year) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT month, year, COUNT(*) as received_count
      FROM attendance
      WHERE year = ?
      GROUP BY month, year
      ORDER BY month ASC
    ''', [year]);

    return result.map((row) {
      return {
        'month': row['month'] as int,
        'year': row['year'] as int,
        'received_count': row['received_count'] as int,
      };
    }).toList();
  }

  /// Returns a list of distinct years that have attendance data.
  Future<List<int>> getAvailableYears() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT year FROM attendance ORDER BY year DESC
    ''');

    if (result.isEmpty) {
      return [DateTime.now().year];
    }

    return result.map((row) => row['year'] as int).toList();
  }

  /// Returns the total rice distributed in a given month/year.
  Future<int> getRiceDistributed(int month, int year) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(rc.rice), 0) as total_rice
      FROM attendance a
      INNER JOIN ration_cards rc ON a.card_number = rc.card_number
      WHERE a.month = ? AND a.year = ?
    ''', [month, year]);

    return Sqflite.firstIntValue(result) ?? 0;
  }
}