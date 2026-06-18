import '../models/week_entry.dart';
import 'database_helper.dart';

class WeekEntryRepository {
  String _weekFilter(int? weekId) {
    return weekId == null ? 'weekId IS NULL' : 'weekId = ?';
  }

  List<Object?> _weekArgs(int? weekId) {
    return weekId == null ? [] : [weekId];
  }

  Future<List<WeekEntry>> getEntries({
    int? weekId,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    final results = await db.query(
      'week_entries',
      where: _weekFilter(weekId),
      whereArgs: _weekArgs(weekId),
      orderBy: 'id ASC',
    );

    return results
        .map(WeekEntry.fromMap)
        .toList();
  }

  Future<int> insertEntry({
    int? weekId,
    required String description,
    required double credit,
    required double debit,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.insert(
      'week_entries',
      {
        'weekId': weekId,
        'description': description,
        'credit': credit,
        'debit': debit,
      },
    );
  }

  Future<int> updateEntry({
    required int id,
    required String description,
    required double credit,
    required double debit,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.update(
      'week_entries',
      {
        'description': description,
        'credit': credit,
        'debit': debit,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.delete(
      'week_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getTotals({
    int? weekId,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    final results = await db.rawQuery('''
      SELECT COALESCE(SUM(credit), 0) AS totalCredit,
             COALESCE(SUM(debit), 0) AS totalDebit
      FROM week_entries
      WHERE ${_weekFilter(weekId)}
    ''', _weekArgs(weekId));

    final row = results.first;
    final totalCredit =
        (row['totalCredit'] as num).toDouble();
    final totalDebit =
        (row['totalDebit'] as num).toDouble();

    return {
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'netProfit': totalCredit - totalDebit,
    };
  }
}
